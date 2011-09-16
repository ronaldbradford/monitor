#!/bin/sh


echo "Stopping services"
sudo service mysql stop
sudo service apache2 stop
sudo service memcached stop

echo "Starting services"
sudo service mysql start
sudo service apache2 start
sudo service memcached start

php /tmp/reqstat/support/reqstat_reset.php
php /tmp/reqstat/support/reqstat_debug.php
