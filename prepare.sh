#!/bin/bash
set -x

if [ "$CHANGE_SOURCE"x == "true"x ]
then
  cp $TEMPLATEI_PATH/source-list.temp /etc/apt/sources.list
  apt-get -s clean
fi

apt-get update

apt-get install bridge-utils debootstrap expect \
        ifenslave  lsof lvm2  ntpdate libvirt-bin \
        tcpdump vlan aptitude build-essential \
        ntp ntpdate python-dev git figlet genisoimage -y

if [ ! -d "$IMAGE_PATH" ]; then 
  mkdir "$IMAGE_PATH" 
fi

if [ ! -f "$RSA_PATH" ]; then
/usr/bin/expect gensshkey
fi
if [ ! -f "$IMAGE_URL" ]; then 
  wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
  mv ./xenial-server-cloudimg-amd64-disk1.img $IMAGE_URL
  qemu-img resize $IMAGE_URL +60GB
fi

virsh net-list | awk '{print $1}' | grep prod
#if [ "$netname"x -eq ""x ]; then
if [ $? -eq 0 ]; then
  virsh net-destroy prod
fi

virsh net-create $WORK_PATH/prod.xml

grep -Rn prodnetbr.10 /etc/network/interfaces
if [ $? -ne 0 ]; then
#  cp $TEMPLATEI_PATH/interfaces.temp /etc/network/interfaces
  cat $TEMPLATEI_PATH/interfaces.temp >> /etc/network/interfaces
  ifdown  -a && ifup -a
fi


varhost_key=$(grep "host_key_checking = False" /etc/ansible/ansible.cfg)
vardefault=$(grep "defaults" /etc/ansible/ansible.cfg)
echo $vardefault
if [ "$vardefault"x != "[defaults]"x ]; then
  echo -e "[defaults]\nhost_key_checking = False" > /etc/ansible/ansible.cfg
else
  if [ "$varhost_key"x != "host_key_checking = False"x ]; then
    sed -i '/\[defaults\]/a\host_key_checking = False' /etc/ansible/ansible.cfg
  fi
fi

cd $LAUNCH_VM_PATH
source ./launch.sh
