#!/bin/sh

#Install NTP service
apt-get -y install chrony
sed -i '20,23d' /etc/chrony/chrony.conf
sed -i '20 a server ntp1.jst.mfeed.ad.jp offline iburst' /etc/chrony/chrony.conf
service chrony restart

chronyc	sources

#Enable OpenStack Repository
apt-get update && apt-get dist-upgrade -y
apt-get install software-properties-common python-openstackclient -y 
reboot


