#!/bin/bash
#Create the public network
source admin-openrc.sh

neutron net-create --shared --provider:physical_network provider \
  --provider:network_type flat provider
#Config security group
#nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
#nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
#Get some usefull data
echo -n "Enter Provider CIDR > "
read PROVIDER_NETWORK_CIDR
echo -n "Enter start IP address > "
read START_IP_ADDRESS
echo -n "Enter end IP address > "
read END_IP_ADDRESS
echo -n "Enter DNS > "
read DNS_RESOLVER
echo -n "Enter gateway > "
read PROVIDER_NETWORK_GATEWAY
#Create a subnet on the network:

neutron subnet-create --name provider \
  --allocation-pool start=$START_IP_ADDRESS,end=$END_IP_ADDRESS \
  --dns-nameserver $DNS_RESOLVER --gateway $PROVIDER_NETWORK_GATEWAY \
  provider $PROVIDER_NETWORK_CIDR


