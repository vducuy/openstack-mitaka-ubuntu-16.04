#!/bin/sh
source admin-openrc.sh
#if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
#then
#	echo "Usage: $0 <Image File> <Image Name> <KERNEL_ID>"
#	exit 0;
#fi
#IMAGE_FILE=$1
#IMAGE_NAME=$2
#KERNEL_ID=$3

wget http://192.168.0.254/soft/wily-server-cloudimg-arm64-disk1.img
IMAGE_FILE=wily-server-cloudimg-arm64-disk1.img
IMAGE_NAME=Wily

nova image-list


echo -n "Enter kernel ID > "
read KERNEL_ID

glance \
image-create \
--disk-format qcow2 \
--container-format bare \
--name "${IMAGE_NAME}" \
--property hw_machine_type=virt \
--property os_command_line='root=/dev/vda1  console=ttyAMA0' \
--property hw_cdrom_bus=virtio \
--property kernel_id=${KERNEL_ID} \
--property visibility=public \
< \
${IMAGE_FILE}

