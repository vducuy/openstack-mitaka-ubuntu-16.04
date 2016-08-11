#!/bin/sh
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
then
	echo "Usage: $0 <Image File> <Image Name> <KERNEL_ID>"
	exit 0;
fi
IMAGE_FILE=$1
IMAGE_NAME=$2
KERNEL_ID=$3
glance \
image-create \
--disk-format qcow2 \
--container-format bare \
--name "${IMAGE_NAME}" \
--property hw_machine_type=virt \
--property os_command_line='root=/dev/vda  console=ttyAMA0' \
--property hw_cdrom_bus=virtio \
--property kernel_id=${KERNEL_ID} \
< \
${IMAGE_FILE}

