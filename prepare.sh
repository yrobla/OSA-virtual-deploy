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
 
grep -Rn virbr /etc/network/interfaces
if [ $? -ne 0 ]; then
  cp $TEMPLATEI_PATH/bifrost/interfaces.temp /etc/network/interfaces
  ifdown  -a && ifup -a 
fi

ssh_args="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa"
IP_LIST="2 3 4 5 6"
for i in $IP_LIST
do
  MGMT_IP="192.168.122.$i"
  echo $MGMT_IP
  ssh  $ssh_args root@$MGMT_IP apt-get install -y python
done
