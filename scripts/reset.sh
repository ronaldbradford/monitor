#!/bin/sh

BASE_DIR=${HOME}

echo "Stopping services"
sudo service mysql stop
sudo service apache2 stop
sudo service memcached stop

echo "Starting services"
sudo service mysql start
sudo service apache2 start
sudo service memcached start


[ -f "${BASE_DIR}/git/reqstat/support/reqstat_reset.php" ] && php ${BASE_DIR}/git/reqstat/support/reqstat_reset.php
[ -f "${BASE_DIR}/git/reqstat/support/reqstat_debug.php" ] && php ${BASE_DIR}/git/reqstat/support/reqstat_debug.php

exit 0
