#!/bin/bash
source default-config.inc
#OpenStack Image service
#Prerequisites
mysql -u root --password=${ADMIN_PASSWORD} <<MYSQL_SCRIPT
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
MYSQL_SCRIPT
source ./admin-openrc.sh

#Create the service credentials, complete these steps
openstack user create --domain default --password ${ADMIN_PASSWORD} glance
openstack role add --project service --user glance admin
openstack service create --name glance \
	  --description "OpenStack Image service" image
openstack endpoint create --region RegionOne \
	  image public http://controller:9292
openstack endpoint create --region RegionOne \
	  image internal http://controller:9292
openstack endpoint create --region RegionOne \
	  image admin http://controller:9292
#Install and configure components
apt-get install glance -y
#Edit the /etc/glance/glance-api.conf file and complete the following actions
crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
crudini --del /etc/glance/glance-api.conf keystone_authtoken
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password ${ADMIN_PASSWORD}
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
crudini --set /etc/glance/glance-api.conf DEFAULT verbose True
#Edit the /etc/glance/glance-registry.conf file and complete the following actions
crudini --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
crudini --del /etc/glance/glance-registry.conf keystone_authtoken
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken password ${ADMIN_PASSWORD}
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-registry.conf DEFAULT verbose True
#Populate the Image service database
su -s /bin/sh -c "glance-manage db_sync" glance
#Finalize installation
service glance-registry restart
service glance-api restart
rm -f /var/lib/glance/glance.sqlite
#Verify Glance, download an image
#echo "export OS_IMAGE_API_VERSION=2" \
#	  | tee -a admin-openrc.sh demo-openrc.sh

source admin-openrc.sh
#wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
#openstack image create "cirros" \
#	--file cirros-0.3.4-x86_64-disk.img \
#	--disk-format qcow2 --container-format bare \
#	--public

openstack image list


