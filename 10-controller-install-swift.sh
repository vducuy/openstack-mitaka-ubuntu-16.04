#!/bin/bash
source default-config.inc


#OpenStack Image service
#Prerequisites
#mysql -u root --password=${ADMIN_PASSWORD} <<MYSQL_SCRIPT
#CREATE DATABASE swift;
#GRANT ALL PRIVILEGES ON swift.* TO 'proxy-server'@'localhost' IDENTIFIED BY 'CINDER_DBPASS';
#GRANT ALL PRIVILEGES ON swift.* TO 'proxy-server'@'%' IDENTIFIED BY 'CINDER_DBPASS';
#MYSQL_SCRIPT
source ./admin-openrc.sh

openstack user create --domain default --password ${ADMIN_PASSWORD} swift

openstack role add --project service --user swift admin
openstack service create --name swift \
  --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne \
  object-store public http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store internal http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store admin http://controller:8080/v1

apt-get install swift swift-proxy python-swiftclient \
  python-keystoneclient python-keystonemiddleware \
  memcached

mkdir -p /etc/swift
curl -o /etc/swift/proxy-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/mitaka

crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port 8080 
crudini --set /etc/swift/proxy-server.conf DEFAULT user swift 
crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift

crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline  "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server"
# Keystone auth info

crudini --set /etc/swift/proxy-server.conf filter:authtoken paste.filter_factory keystonemiddleware.auth_token:filter_factory

crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_uri http://controller:5000
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_url http://controller:35357
crudini --set /etc/swift/proxy-server.conf filter:authtoken memcached_servers controller:11211
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_type password
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_domain_name default
crudini --set /etc/swift/proxy-server.conf filter:authtoken user_domain_name default
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_name service
crudini --set /etc/swift/proxy-server.conf filter:authtoken username swift
crudini --set /etc/swift/proxy-server.conf filter:authtoken password ${ADMIN_PASSWORD}
crudini --set /etc/swift/proxy-server.conf filter:authtoken delay_auth_decision True




