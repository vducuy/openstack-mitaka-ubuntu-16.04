#!/bin/bash
source default-config.inc
#OpenStack Image service
#Prerequisites
mysql -u root --password=${ADMIN_PASSWORD} <<MYSQL_SCRIPT
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'CINDER_DBPASS';
MYSQL_SCRIPT
source ./admin-openrc.sh

openstack user create --domain default --project service --password ${ADMIN_PASSWORD} cinder

openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume 
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2 
openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s  
openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s 
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s 
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s 
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s 

apt-get -y install cinder-api cinder-scheduler python-cinderclient
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip controller
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rootwrap_config /etc/cinder/rootwrap.conf
crudini --set /etc/cinder/cinder.conf DEFAULT api_paste_confg /etc/cinder/api-paste.ini
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v1_api True
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v2_api True
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT scheduler_driver cinder.scheduler.filter_scheduler.FilterScheduler
# MariaDB connection info
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:CINDER_DBPASS@controller/cinder
# Keystone auth info

crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${ADMIN_PASSWORD}

crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path $state_path/tmp

# RabbitMQ connection info
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_port 5672
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password ${ADMIN_PASSWORD}

su -s /bin/bash cinder -c "cinder-manage db sync" 
systemctl restart cinder-api cinder-scheduler
cinder service-list 


#-------------INSTALL FOR CINDER NODE---------
apt-get -y install cinder-volume python-mysqldb

crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen 0.0.0.0
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen_port 8776
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292

systemctl restart cinder-volume



