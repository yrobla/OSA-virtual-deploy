#!/bin/bash
##############################################################################
# Copyright (c) 2015 Huawei Technologies Co.,Ltd and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# copy from bottlenecks/utils/rubbos_dev_env_setup/deploy.sh

set -x

function download_iso()
{
    mkdir -p ${WORK_DIR}/cache
#    curl --connect-timeout 10 -o ${WORK_DIR}/cache/$IMAGE_NAME $IMAGE_URL
    cp $IMAGE_URL ${WORK_DIR}/cache/$IMAGE_NAME
}


function tear_down_machines() {
    echo "tear down machine:" $1
    sudo virsh destroy $1
    sudo virsh undefine $1
    rm -rf $host_vm_dir/$1
}


function get_host_macs() {
    local mac_generator=${SCRIPT_DIR}/mac_generator.sh
    local machines=

    chmod +x $mac_generator
#    mac_array=$($mac_generator $VIRT_NUMBER)
    mac_array=$($mac_generator 4)
    machines=$(echo $mac_array)

    echo $machines
}
function install_python(){
   MGMT_IP=$1
   ssh  $ssh_args root@$MGMT_IP apt-get install -y python
}
function wait_ok() {
    MGMT_IP=$1
    set +x
    echo "wait_ok enter"
    ssh-keygen -f "/root/.ssh/known_hosts" -R $MGMT_IP >/dev/null 2>&1
    retry=0
    until timeout 1s ssh $ssh_args ubuntu@$MGMT_IP "exit" >/dev/null 2>&1
    do
        echo "os install time used: $((retry*100/$2))%"
        sleep 1
        let retry+=1
        if [[ $retry -ge $2 ]];then
            timeout 1s ssh $ssh_args ubuntu@$MGMT_IP "exit"
            echo "os install time out"
            exit 1
        fi
    done
    echo "wait_ok exit"
    set -x
}


function launch_host_vms() {
    mac_array=($(get_host_macs))

    echo ${mac_array[2]}
    echo ${mac_array[*]}

    old_ifs=$IFS
    IFS=,
    tear_down_machines $1
    echo "bringing up vms ${mac_array[*]}"
#    i=0
#    i=10
#    echo $HOSTNAMES
#    for host in $HOSTNAMES; do
#    for((numb=0;i<$VIRT_NUMBER;numb++)) 
#        host=${$HOSTNAMES[$numb]}
    host=$1
    i=$2
    echo $host
    echo "creating vm disk for instance $host" \
         "ip ${IPADDR_PREFIX}$((i+11))" \
         "mac ${mac_array[$i]}"
    vm_dir=$host_vm_dir/$host
    mkdir -p $vm_dir

    cp ${WORK_DIR}/cache/$IMAGE_NAME $vm_dir

    # create seed.iso
    sed -e "s/REPLACE_IPADDR/${IPADDR_PREFIX}$((i+11))/g" \
        -e "s/REPLACE_GATEWAY/${IPADDR_PREFIX}1/g" \
        -e "s/REPLACE_HOSTNAME/${host}/g" \
        meta-data_template \
        > meta-data

    if [ -f ~/.ssh/id_rsa.pub ]; then
        sed -e "/ssh_authorized_keys/a\  - $(cat ~/.ssh/id_rsa.pub)" user-data_template \
            > user-data
    else
        cp user-data_template user-data
    fi

    genisoimage  -output seed.iso -volid cidata -joliet -rock user-data meta-data
    cp seed.iso $vm_dir

    # create vm xml
    sed -e "s/REPLACE_MEM/$VIRT_MEM/g" \
        -e "s/REPLACE_CPU/$VIRT_CPUS/g" \
        -e "s/REPLACE_NAME/$host/g" \
        -e "s#REPLACE_IMAGE#$vm_dir/prod-xen.img#g" \
        -e "s#REPLACE_SEED_IMAGE#$vm_dir/seed.iso#g" \
        -e "s/REPLACE_MAC_ADDR1/${mac_array[0]}/g" \
        -e "s/REPLACE_MAC_ADDR2/${mac_array[1]}/g" \
        -e "s/REPLACE_MAC_ADDR3/${mac_array[2]}/g" \
        -e "s/REPLACE_MAC_ADDR4/${mac_array[3]}/g" \
        libvirt_template.xml \
        > $vm_dir/libvirt.xml

    sudo virsh define $vm_dir/libvirt.xml
    sudo virsh start $host
    IFS=$old_ifs
    rm -rf meta-data user-data seed.iso
    wait_ok "${IPADDR_PREFIX}$((i+11))" 25
    root_auth_setup "${IPADDR_PREFIX}$((i+11))"
    if [ "$OS_FAMILY"x == "Ubuntu16.04"x ]
    then
       install_python "${IPADDR_PREFIX}$((i+11))"
    fi






#done
#    IFS=$old_ifs
#    rm -rf meta-data user-data seed.iso
}

#function wait_ok() {
#    MGMT_IP=$1
#    set +x
 #   echo "wait_ok enter"
#    ssh-keygen -f "/root/.ssh/known_hosts" -R $MGMT_IP >/dev/null 2>&1
#    retry=0
#    until timeout 1s ssh $ssh_args ubuntu@$MGMT_IP "exit" >/dev/null 2>&1
#    do
#        echo "os install time used: $((retry*100/$2))%"
#        sleep 1
#        let retry+=1
#        if [[ $retry -ge $2 ]];then
#            timeout 1s ssh $ssh_args ubuntu@$MGMT_IP "exit"
#            echo "os install time out"
#            exit 1
#        fi
#    done
#    echo "wait_ok exit"
#}

function root_auth_setup()
{
    MGMT_IP=$1
    ssh $ssh_args ubuntu@$MGMT_IP "
        sudo sed -ie 's/ssh-rsa/\n&/g' /root/.ssh/authorized_keys
        sudo sed -ie '/echo/d' /root/.ssh/authorized_keys
    "
}

#source ./env_config.sh
source ./env_config_host.sh

SCRIPT_DIR=`cd ${BASH_SOURCE[0]%/*};pwd`
WORK_DIR=${SCRIPT_DIR}/work
ssh_args="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa"

mkdir -p $WORK_DIR
host_vm_dir=$WORK_DIR/vm

download_iso
i=0
#launch_host_vms "openstaktest" 0
for host in $HOSTNAMES; do
    echo $host
    launch_host_vms $host $i
    let i=i+1
done

set +x

