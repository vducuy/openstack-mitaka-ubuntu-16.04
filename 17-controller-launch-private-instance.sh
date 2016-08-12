#!/bin/bash
source demo-openrc.sh
openstack flavor list
openstack image list
openstack network list
openstack security group list

echo -n "Copy Private network ID > "
read PRIVATE_NET_ID
nova --debug boot --flavor m1.small --image Wily --nic net-id=$PRIVATE_NET_ID --security-group default --key-name mykey wily


openstack server list

