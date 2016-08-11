#!/bin/bash

source default-config.inc

#Install mySQL
apt-get install -y mariadb-server python-mysqldb

#Install crudini./
apt-get install crudini -y
#Create and edit the /etc/mysql/conf.d/mysqld_openstack.cnf file
touch /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf
crudini --set /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf mysqld bind-address ${CONTROLLER_NODE_ADDR}
crudini --set /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf mysqld default-storage-engine innodb
crudini --set /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf mysqld init-connect "'SET NAMES utf8'"
crudini --set /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf mysqld character-set-server utf8
sed -i '6 a innodb_file_per_table' /etc/mysql/mariadb.conf.d/mysqld_openstack.cnf

#Restart the database service
service mysql restart
# Automate Secure the database service by running the mysql_secure_installation script.
apt-get -y install expect
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"amcc1234\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"n\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
apt-get -y purge expect
#Install NoSQL database Install and configure components
apt-get install mongodb-server mongodb-clients python-pymongo -y
sed -i 's/bind_ip = 127.0.0.1/bind_ip = controller/g' /etc/mongodb.conf
sed -i '$ a smallfiles = true' /etc/mongodb.conf
#Finalize installation
service mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
service mongodb start

#Install Message Queue Install and configure components
apt-get install rabbitmq-server -y
rabbitmqctl add_user openstack ${ADMIN_PASSWORD}
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

apt-get install memcached python-memcache
sed -i 's/\-l 127.0.0.1/\-l controller/g' /etc/memcached.conf

