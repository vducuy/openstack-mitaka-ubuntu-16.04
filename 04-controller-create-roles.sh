#!/bin/bash

source default-config.inc

#Install the identity
source ./endpoint_token.sh


#Create the service entity and API endpoints
openstack service create \
  --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne \
  identity public http://controller:5000/v3
openstack endpoint create --region RegionOne \
  identity internal http://controller:5000/v3
openstack endpoint create --region RegionOne \
  identity admin http://controller:35357/v3
#Create projects, users and roles
openstack domain create --description "Default Domain" default

openstack project create --domain default \
  --description "Admin Project" admin

openstack user create --domain default \
  --password ${ADMIN_PASSWORD} admin
openstack role create admin
openstack role add --project admin --user admin admin

openstack project create --domain default \
  --description "Service Project" service
openstack project create --domain default \
  --description "Demo Project" demo
openstack user create --domain default \
  --password ${ADMIN_PASSWORD} demo
openstack role create user
openstack role add --project demo --user demo user
#Verify Operation
#For security reasons, disable the temporary authentication token mechanism.Unset the temporary OS_TOKEN and OS_URL environment variables
unset OS_TOKEN OS_URL
sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension user_crud_extension public_service/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension user_crud_extension public_service/g' /etc/keystone/keystone-paste.ini
sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension s3_extension crud_extension admin_service/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension crud_extension admin_service/g' /etc/keystone/keystone-paste.ini

sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3/g' /etc/keystone/keystone-paste.ini
#Actually test
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name admin --os-username admin --os-password ${ADMIN_PASSWORD}\
  token issue
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name demo --os-username demo --os-password ${ADMIN_PASSWORD} \
  token issue

source admin-openrc.sh
openstack token issue

