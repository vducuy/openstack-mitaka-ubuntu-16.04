#!/bin/bash
#Create private net and subnet
source demo-openrc.sh
neutron net-create private
neutron subnet-create private 172.16.1.0/24 --name private --dns-nameserver 8.8.8.8 --gateway 172.16.1.1
#Create router
source admin-openrc.sh
neutron net-update provider --router:external
source demo-openrc.sh
neutron router-create router
neutron router-interface-add router private
neutron router-gateway-set router provider
neutron net-list


