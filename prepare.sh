#!/bin/bash
set -ex

export CHANGE_SOURCE=${CHANGE_SOURCE:-"fault"}
export WORK_PATH=$(pwd)
export IMAGE_PATH=$WORK_PATH/image
export TEMPLATEI_PATH=$WORK_PATH/template
export LAUNCH_VM_PATH=$WORK_PATH/launch-vm
export IMAGE_URL=$IMAGE_PATH/prod-xen.img

if [ "$CHANGE_SOURCE"x == "true"x ]
then
  cp $TEMPLATEI_PATH/source-list.temp /etc/apt/sources.list
  apt-get -s clean
fi

apt-get update

apt-get install bridge-utils debootstrap \
        ifenslave  lsof lvm2  ntpdate libvirt-bin \
        tcpdump vlan aptitude build-essential \
        ntp ntpdate python-dev git figlet -y

if [ ! -d "$IMAGE_PATH" ]; then 
  mkdir "$IMAGE_PATH" 
fi

if [ ! -f "$IMAGE_URL" ]; then 
  wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img 
  mv ./xenial-server-cloudimg-amd64-disk1.img $IMAGE_URL
  qemu-img resize $IMAGE_URL +100GB
fi

virsh net-create $WORK_PATH/prod.xml
cp $TEMPLATEI_PATH/interfaces.temp /etc/network/interfaces
#ifdown  -a && ifup -a 

