#!/bin/bash
set -ex

apt-get update

apt-get install bridge-utils debootstrap \
	ifenslave  lsof lvm2 ntp ntpdate \
	tcpdump vlan aptitude build-essential \
	git ntp ntpdate python-dev git figlet -y
export CHANGE_SOURCE=${CHANGE_SOURCE:-"fault"}
export WORK_PATH=$(pwd)
export IMAGE_PATH=$WORK_PATH/image
export TEMPLATEI_PATH=$WORK_PATH/template
export LAUNCH_VM_PATH=$WORK_PATH/launch-vm
export IMAGE_URL=$IMAGE_PATH/prod-xen.img

wget https://cloud-images.ubuntu.com/xenial/current/current/xenial-server-cloudimg-amd64-disk1.img $IMAGE_PATH
mv $IMAGE_PATH/xenial-server-cloudimg-amd64-disk1.img $IMAGE_URL

qemu-img resize $IMAGE_URL +100GB

if ["$CHANGE_SOURCE"x = "true"]
then
  cp $TEMPLATEI_PATH/source-list.temp /etc/apt/source-list
fi 


virsh net-create $WORK_PATH/prod.xml
cp $TEMPLATEI_PATH/interfaces.temp /etc/network/interfaces
#ifdown  -a && ifup -a 

