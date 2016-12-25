##############################################################################
# Copyright (c) 2015 Huawei Technologies Co.,Ltd and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# this is a modified copy of bottlenecks/utils/rubbos_dev_env_setup/env_config.sh
#assist,deploy | ifra1,infra2,infra3,compute1,compute2
export OS_FAMILY=${OS_FAMILY:-"Ubuntu16.04"}
export HOSTNAMES=${HOSTNAMES:- "infra1" "infra2" "infra3" "compute1" "compute2"}
export VIRT_NUMBER=${VIRT_NUMBER:-"3"}
export VIRT_MEM=${VIRT_MEM:-"16384"}
export VIRT_CPUS=${VIRT_CPUS:-"4"}
#export IMAGE_URL=${IMAGE_URL:-"https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img"}
export IMAGE_URL=${IMAGE_URL:-"file:///home/wtw/libvirt/prod-xen.img"}
export IMAGE_NAME=${IMAGE_NAME:-"prod-xen.img"}
export IPADDR_PREFIX=${IPADDR_PREFIX:-"10.200.200."}

