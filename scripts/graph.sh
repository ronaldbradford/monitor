#!/bin/sh
#
#-------------------------------------------------------------------------------
# Name:     graph.sh
# Purpose:  Graph monitoring results
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


process() {
  local FUNCTION="process()"
  debug "${FUNCTION} ($*)"
  [ $# -ne 1 ] && fatal "${FUNCTION} This function requires one argument."
  local ID="$1"
  [ -z "${ID}" ] && fatal "${FUNCTION} \$ID is not defined"


  RUN_DIR=${LOG_DIR}/${ID}

  [ ! -d "${RUN_DIR}" ] && error "Unable to find matching logs in '${RUN_DIR}'"

  sed -e "s/#ID#/${ID}/;s/#HOSTNAME#/${SHORT_HOSTNAME}/" ${SCRIPT_DIR}/reqstat.gp > ${RUN_DIR}/reqstat.gp
  sed -e "s/#ID#/${ID}/;s/#HOSTNAME#/${SHORT_HOSTNAME}/" ${SCRIPT_DIR}/dstat.gp > ${RUN_DIR}/dstat.gp

  sed -e "s/#ID#/${ID}/;" ${CNF_DIR}/${SCRIPT_NAME}.index.php.t > ${RUN_DIR}/index.php

  [ ! -d "${BASE_DIR}/www" ] && mkdir ${BASE_DIR}/www  && warn "Created $BASE_DIR/www. Be sure to link to webserver, i.e. sudo mkdir -p /var/www/admin/; sudo ln -s ${FULL_BASE_DIR}/www /var/www/admin/monitor"
  [ ! -d "${BASE_DIR}/www/${ID}" ] && ln -s ${RUN_DIR} ${BASE_DIR}/www/${ID}

  chmod +x *.gp

  info "Configuring files for graphing"
  cd ${RUN_DIR}
  if [ `ls ${ID}.*.reqstat.csv 2>/dev/null| wc -l` -eq 1 ]
  then
    cp ${ID}.*.reqstat.csv reqstat.csv
    sed -e "s/,/\\t/g;s/^epoch/#epoch/" reqstat.csv > reqstat.tsv
    info "Graphing reqstat output"
    ./reqstat.gp
  fi

  if [ `ls ${ID}.*.dstat.csv 2>/dev/null| wc -l` -eq 1 ]
  then
    cp ${ID}.*.dstat.csv dstat.csv
    sed -e "s/,/\\t/g;s/^\"/#\"/;/^$/d" dstat.csv > dstat.tsv
    info "Graphing dstat output"
    ./dstat.gp
  fi

  return 0
}


#-------------------------------------------------------------------------------
# Script specific variables
#

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
  echo "Usage: ${SCRIPT_NAME}.sh -X <example-string> [ -q | -v | --help | --version ]"
  echo ""
  echo "  Required:"
  echo "    -X         Example mandatory parameter"
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
  while getopts i:qv OPTION
  do
    case "$OPTION" in
      i)  PARAM_ID=${OPTARG};;
      q)  QUIET="Y";; 
      v)  USE_DEBUG="Y";; 
    esac
  done
  shift `expr ${OPTIND} - 1`

  [ -z "${PARAM_ID}" ] && error "You must specify a Test Id with -i. See --help for full instructions."

  return 0
}

pre_processing() {
  [ -z `which gnuplot 2>/dev/null` ] && error "gunplot is required for this program"
  return 0
}

#----------------------------------------------------------------------- main --
# Main Script Processing
#
main () {
  [ ! -z "${TEST_FRAMEWORK}" ] && return 1
  bootstrap
  pre_processing
  process_args $*
  commence
  process ${PARAM_ID}
  complete

  return 0
}

main $*

# END
