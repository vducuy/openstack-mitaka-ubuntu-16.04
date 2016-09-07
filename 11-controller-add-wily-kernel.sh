#!/bin/bash
source admin-openrc.sh

wget http://192.168.0.254/soft/wily-server-cloudimg-arm64-vmlinuz-generic
KERNEL_IMAGE_FILE=wily-server-cloudimg-arm64-vmlinuz-generic
KERNEL_IMAGE_NAME="Wily Kernel"

#if [ "$1" = "" ] || [ "$2" = "" ]
#then
#	echo "Usage: $0 <Image File> <Kernel Name>"
#	exit 0
#fi


#KERNEL_IMAGE_NAME=$2
#KERNEL_IMAGE_FILE=$1

glance image-create \
--disk-format aki \
--container-format bare \
--name "${KERNEL_IMAGE_NAME}" \
--property hw_machine_type=virt \
--property os_command_line='root=/dev/vda1  console=ttyAMA0' \
--property hw_cdrom_bus=virtio \
--property visibility=public < \
${KERNEL_IMAGE_FILE}
