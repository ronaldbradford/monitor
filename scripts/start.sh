#!/bin/sh
#
#-------------------------------------------------------------------------------
# Name:     start.sh
# Purpose:  Start Benchmarking
# Author:   Ronald Bradford  http://ronaldbradford.com
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Script Definition
#
SCRIPT_NAME=`basename $0 | sed -e "s/.sh$//"`
SCRIPT_VERSION="0.10 16-SEP-2011"
SCRIPT_REVISION=""

#-------------------------------------------------------------------------------
# Constants - These values never change
#

#-------------------------------------------------------------------------------
# Script specific variables
#


pre_processing() {
  local FUNCTION="pre_processing()"
  debug "${FUNCTION} ($*)"

  local SOURCES="$1"
  [ -z "${SOURCES}" ] && fatal "${FUNCTION} \$SOURCES is not defined"

  local RUN_DSTAT
  local RUN_VMSTAT
  local RUN_REQSTAT
  RUN_DSTAT=`echo ${SOURCES} | grep dstat | wc -l`
  RUN_VMSTAT=`echo ${SOURCES} | grep vmstat | wc -l`
  RUN_REQSTAT=`echo ${SOURCES} | grep reqstat | wc -l`
  [ ${RUN_DSTAT} -eq 1 -a -z `which dstat 2>/dev/null` ] && error "dstat not found in PATH"
  [ ${RUN_VMSTAT} -eq 1 -a -z `which vmstat 2>/dev/null` ] && error "vmstat not found in PATH"
  [ ${RUN_REQSTAT} -eq 1 -a -z `which reqstat 2>/dev/null` ] && error "reqstat not found in PATH"
  [ ! -f "${DEFAULT_CNF_FILE}" ] && error "Default config file not found '${DEFAULT_CNF_FILE}'"

  return 0
}

#-------------------------------------------------------------------  process --
process() {
  local FUNCTION="process()"
  debug "${FUNCTION} ($*)"
  [ $# -ne 1 ] && fatal "${FUNCTION} This function requires one argument."
  local SOURCES="$1"
  [ -z "${SOURCES}" ] && fatal "${FUNCTION} \$SOURCES is not defined"

  local COUNT="3600"
  local DELAY="1"
  local ID

  ID=`date +%Y%m%d.%H%M%S`
  mkdir -p ${LOG_DIR}/${ID}
  gather_stats ${ID} ${DELAY} ${COUNT} ${SOURCES}
  gather_config ${ID}
  identify ${ID}

  return 0

}

identify() {
  info "Monitoring output can be found in ${LOG_DIR}/${ID}"
  warn "Be sure to add benchmark details to ${LOG_DIR}/${ID}/README"
  echo "***Add details here ***" > ${LOG_DIR}/${ID}/README

  return 0
}

gather_stats() {
  local FUNCTION="gather_stats()"
  debug "${FUNCTION} ($*)"
  [ $# -ne 4 ] && fatal "${FUNCTION} This function requires three arguments."
  local ID="$1"
  [ -z "${ID}" ] && fatal "${FUNCTION} \$ID is not defined"
  local DELAY="$2"
  [ -z "${DELAY}" ] && fatal "${FUNCTION} \$DELAY is not defined"
  local COUNT="$3"
  [ -z "${COUNT}" ] && fatal "${FUNCTION} \$COUNT is not defined"
  local SOURCES="$4"
  [ -z "${SOURCES}" ] && fatal "${FUNCTION} \$SOURCES is not defined"

  info "Starting Benchmark Monitoring ID:${ID} (${DELAY} ${COUNT})"

  local RUN_DSTAT
  local RUN_VMSTAT
  local RUN_REQSTAT
  RUN_DSTAT=`echo ${SOURCES} | grep dstat | wc -l`
  RUN_VMSTAT=`echo ${SOURCES} | grep vmstat | wc -l`
  RUN_REQSTAT=`echo ${SOURCES} | grep reqstat | wc -l`

  if [ ${RUN_DSTAT} -eq 1 ] 
  then
    local FILENAME=${LOG_DIR}/${ID}/${ID}.${SHORT_HOSTNAME}.dstat${DATA_EXT}
    dstat --epoch --time --load --cpu --mem --swap --disk --net --proc --nocolor --noheaders --output ${FILENAME} ${DELAY} ${COUNT} > /dev/null &
    local DSTAT_PID=$!
    info "Logging 'dstat' to ${FILENAME}, PID=${DSTAT_PID}"
  fi
 
  if [ ${RUN_REQSTAT} -eq 1 ] 
  then
    local FILENAME=${LOG_DIR}/${ID}/${ID}.${SHORT_HOSTNAME}.reqstat${DATA_EXT}
    reqstat ${DELAY} ${COUNT} > ${FILENAME} &
    local REQSTAT_PID=$!
    info "Logging 'reqstat' to ${FILENAME}, PID=${REQSTAT_PID}"
  fi

  if [ ${RUN_VMSTAT} -eq 1 ] 
  then
    local FILENAME=${LOG_DIR}/${ID}/${ID}.${SHORT_HOSTNAME}.vmstat${DATA_EXT}
    vmstat -n ${DELAY} ${COUNT} > ${FILENAME} &
    local VMSTAT_PID=$!
    info "Logging 'vmstat' to ${FILENAME}, PID=${VMSTAT_PID}"
  fi

  (
    echo "dstat:${DSTAT_PID}"
    echo "reqstat:${REQSTAT_PID}"
    echo "vmstat:${VMSTAT_PID}"
  ) > ${LOG_DIR}/${ID}/${SCRIPT_NAME}.pid
  return 0
}

gather_config() {
  local FUNCTION="gather_stats()"
  debug "${FUNCTION} ($*)"
  [ $# -ne 1 ] && fatal "${FUNCTION} This function requires one argument."
  local ID="$1"
  [ -z "${ID}" ] && fatal "${FUNCTION} \$ID is not defined"

  BACKUP_CNF_DIR=${TMP_DIR}/${SCRIPT_NAME}/${ID}/config
  info "Creating config copy at ${BACKUP_CNF_DIR}"
  mkdir -p ${BACKUP_CNF_DIR}

  info "Backing up configuration files"
  while read LINE
  do
    info "..${LINE}"
    cp -r ${LINE} ${BACKUP_CNF_DIR}
  done < ${DEFAULT_CNF_FILE}

  FILENAME=${FULL_BASE_DIR}/log/${ID}/${ID}.${SHORT_HOSTNAME}.config.tar.gz
  info "Generating configuration backup ${FILENAME}"
  CWD=`pwd`
  cd ${BACKUP_CNF_DIR}/..
  tar cfz ${FILENAME} .
  cd ${CWD}

  return 0
}

#-----------------------------------------------------------------  bootstrap --
# Essential script bootstrap
#
bootstrap() {
  local DIRNAME=`dirname $0`
  local COMMON_SCRIPT_FILE="${DIRNAME}/common.sh"
  [ ! -f "${COMMON_SCRIPT_FILE}" ] && echo "ERROR: You must have a matching '${COMMON_SCRIPT_FILE}' with this script ${0}" && exit 1
  . ${COMMON_SCRIPT_FILE}
  set_base_paths

  return 0
}

#----------------------------------------------------------------------- help --
# Display Script help syntax
#
help() {
  echo ""
  echo "Usage: ${SCRIPT_NAME}.sh -s <sources> [ -q | -v | --help | --version ]"
  echo ""
  echo "  Required:"
  echo "    -s         Monitoring Sources (currently dstat:vmstat:reqstat)"
  echo ""
  echo "  Optional:"
  echo "    -q         Quiet Mode"
  echo "    -v         Verbose logging"
  echo "    --help     Script help"
  echo "    --version  Script version (${SCRIPT_VERSION}) ${SCRIPT_REVISION}"
  echo ""
  echo "  Dependencies:"
  echo "    common.sh"

  return 0
}

#-------------------------------------------------------------- process_args --
# Process Command Line Arguments
#
process_args() {
  check_for_long_args $*
  debug "Processing supplied arguments '$*'"
  while getopts s:qv OPTION
  do
    case "$OPTION" in
      s)  PARAM_OPTIONS=${OPTARG};;
      q)  QUIET="Y";; 
      v)  USE_DEBUG="Y";; 
    esac
  done
  shift `expr ${OPTIND} - 1`

  [ -z "${PARAM_OPTIONS}" ] && error "You must specify a the monitoring sources with -s. See --help for full instructions."

  return 0
}

#----------------------------------------------------------------------- main --
# Main Script Processing
#
main () {
  [ ! -z "${TEST_FRAMEWORK}" ] && return 1
  bootstrap
  process_args $*
  pre_processing ${PARAM_OPTIONS}
  commence
  process ${PARAM_OPTIONS}
  complete

  return 0
}

main $*

# END
