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

rm -r /opt/bifrost /opt/releng /opt/puppet-infracloud
git clone https://git.openstack.org/openstack/bifrost /opt/bifrost
git clone https://gerrit.opnfv.org/gerrit/releng /opt/releng
git clone https://git.openstack.org/openstack-infra/puppet-infracloud /opt/puppet-infracloud

cp -R /opt/releng/prototypes/bifrost/* /opt/bifrost/


####
sed -i -e 's/TEST_VM_NODE_NAMES="jumphost.opnfvlocal controller00.opnfvlocal compute00.opnfvlocal"/TEST_VM_NODE_NAMES="controller00.opnfvlocal controller01.opnfvlocal controller02.opnfvlocal compute00.opnfvlocal compute01.opnfvlocal"/g' \
    -e 's/TEST_VM_NUM_NODES=3/TEST_VM_NUM_NODES=5/g' \
    -e 's/VM_CPU=${VM_CPU:-4}/VM_CPU=${VM_CPU:-8}/g' \
    -e 's/VM_DISK=${VM_DISK:-100}/VM_DISK=${VM_DISK:-60}/g' \
    -e 's/VM_MEMORY_SIZE=${VM_MEMORY_SIZE:-8192}/VM_MEMORY_SIZE=${VM_MEMORY_SIZE:-16384}/g' \
    -e 's/DIB_OS_RELEASE=${DIB_OS_RELEASE:-trusty}/DIB_OS_RELEASE=${DIB_OS_RELEASE:-xenial}/g' \
     /opt/bifrost/scripts/test-bifrost-deployment.sh

sed -i -e 's/jumphost.opnfvlocal/controller01.opnfvlocal/g' \
    -e '/virsh destroy controller00.opnfvlocal || true/a\virsh destroy controller02.opnfvlocal || true' \
    -e '/virsh destroy compute00.opnfvlocal || true/a\virsh destroy compute01.opnfvlocal || true' \
    -e '/virsh undefine controller00.opnfvlocal || true/a\virsh undefine controller02.opnfvlocal || true' \
    -e '/virsh undefine compute00.opnfvlocal || true/a\virsh undefine compute01.opnfvlocal || true'  \
     /opt/bifrost/scripts/destroy-env.sh
#####


cd $BIFROST_PATH
#something to do
./scripts/destroy-env.sh 
rm -r /opt/stack/
#echo "nameserver 8.8.8.8" >> /etc/resolv.conf
./scripts/test-bifrost-deployment.sh

grep -Rn virbr /etc/network/interfaces
if [ $? -ne 0 ]; then
  cat $TEMPLATEI_PATH/bifrost/interfaces.temp >> /etc/network/interfaces
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
