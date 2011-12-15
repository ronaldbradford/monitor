#!/bin/sh

# Bootstrap script to prepare a server for benchmark monitoring

[ -z "${BASE_DIR}" ] && BASE_DIR=${HOME}
sudo apt-get install -y git-core dstat gnuplot
mkdir -p ${BASE_DIR}/git
cd ${BASE_DIR}/git

[ ! -d "monitor" ] && git clone http://github.com/ronaldbradford/monitor
[ ! -d "reqstat" ] && git clone http://github.com/ronaldbradford/reqstat

export PATH=${BASE_DIR}/git/reqstat:$PATH
cd ${BASE_DIR}/git/monitor/scripts
./reset.sh
./start.sh
ID=`ls -tr ../log | tail -1`
sleep 10 
./graph.sh -i ${ID}
if [ ! -d "/var/www/admin" ] 
then
  sudo mkdir -p /var/www/admin/
  sudo ln -s /home/ubuntu/git/monitor/www /var/www/admin/monitor
fi

PUBLIC_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/public-hostname`":81"

echo "Goto:  http://${PUBLIC_HOSTNAME}/admin/monitor"
exit 0

