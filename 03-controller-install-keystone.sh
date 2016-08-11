#!/bin/bash
source default-config.inc
#Install the identity
#Prerequisites
mysql -u root --password=${ADMIN_PASSWORD} <<MYSQL_SCRIPT
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
MYSQL_SCRIPT
#Generate a random value to use as the administration token during initial configuration
export ADMIN_TOKEN=$(openssl rand -hex 10)
#Disable the keystone service from starting automatically after installation
echo "manual" > /etc/init/keystone.override
#Run the following command to install the packages
apt-get install keystone apache2 libapache2-mod-wsgi -y
#Edit the /etc/keystone/keystone.conf file and complete the following actions
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
crudini --set /etc/keystone/keystone.conf DEFAULT verbose True
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet
#crudini --set /etc/keystone/keystone.conf token driver memcache
#crudini --set /etc/keystone/keystone.conf revoke driver sql
#Populate the Identity service database:
su -s /bin/sh -c "keystone-manage db_sync" keystone

#Intialize Fernet keys
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

#==============
#Configure the Apache HTTP server
sed -i '14 a ServerName controller' /etc/apache2/apache2.conf
cp wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
#Enable the Identity service virtual hosts
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
# initial Fernet key
#Finalize the installation
service apache2 restart

service keystone restart
rm -f /var/lib/keystone/keystone.db

#Create Service Enty and API endpoints
export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
echo "export OS_TOKEN=$OS_TOKEN" > endpoint_token.sh
echo "export OS_URL=http://controller:35357/v3" >> endpoint_token.sh
echo "export OS_IDENTITY_API_VERSION=3" >> endpoint_token.sh



