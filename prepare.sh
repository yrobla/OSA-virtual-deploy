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
#
#if [ ! -d "$IMAGE_PATH" ]; then 
#  mkdir "$IMAGE_PATH" 
#fi
#
#if [ ! -f "$RSA_PATH" ]; then
#/usr/bin/expect gensshkey
#fi
#if [ ! -f "$IMAGE_URL" ]; then 
#  wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
#  mv ./xenial-server-cloudimg-amd64-disk1.img $IMAGE_URL
#  qemu-img resize $IMAGE_URL +100GB
#fi
#
#virsh net-list | awk '{print $1}' | grep prod
##if [ "$netname"x -eq ""x ]; then
#if [ $? -eq 0 ]; then
#  virsh net-destroy prod
#fi
#
#virsh net-create $WORK_PATH/prod.xml

#i/sbin/ifconfig | grep prodnetbr.10
if [ $? -ne 0 ]; then
  cp $TEMPLATEI_PATH/interfaces.temp /etc/network/interfaces
#  cat $TEMPLATEI_PATH/interfaces.temp >> /etc/network/interfaces
  ifdown  -a && ifup -a 
fi

#grep "host_key_checking = False" /etc/ansible/ansible.cfg
#if [ $? -ne 0 ]; then
#  echo "[defaults]" >> /etc/ansible/ansible.cfg
#  echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
#fi
#
#varhost_key=$(grep "host_key_checking = False" /etc/ansible/ansible.cfg)
#vardefault=$(grep "defaults" /etc/ansible/ansible.cfg)
#echo $vardefault
#if [ "$vardefault"x != "[defaults]"x ]; then
#  echo -e "[defaults]\nhost_key_checking = False" > /etc/ansible/ansible.cfg
#else
#  if [ "$varhost_key"x != "host_key_checking = False"x ]; then
#    sed -i '/\[defaults\]/a\host_key_checking = False' /etc/ansible/ansible.cfg
#  fi
#fi
#
#cd $LAUNCH_VM_PATH
#source ./launch.sh
ssh_args="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa"
IP_LIST="2 3 4 5 6"
for i in $IP_LIST
do
  MGMT_IP="192.168.122.$i"
  echo $MGMT_IP
  ssh  $ssh_args root@$MGMT_IP apt-get install -y python
done
