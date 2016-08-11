#!/bin/bash
if [ "$1" = "" ] || [ "$2" = "" ]
then
	echo "Usage: $0 <Image File> <Kernel Name>"
	exit 0
fi

KERNEL_IMAGE_NAME=$2
KERNEL_IMAGE_FILE=$1

glance image-create \
--disk-format aki \
--container-format bare \
--name "${KERNEL_IMAGE_NAME}" \
--property hw_machine_type=virt \
--property os_command_line='root=/dev/vda1  console=ttyAMA0' \
--property hw_cdrom_bus=virtio < \
${KERNEL_IMAGE_FILE}
