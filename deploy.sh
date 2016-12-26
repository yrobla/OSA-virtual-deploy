#!/bin/bash
#TODO
export WORK_PATH=$(pwd)

source ./var/env_var.sh

source ./prepare.sh

set -x
git clone https://git.openstack.org/openstack/openstack-ansible $OSA_PATH

cd $OSA_PATH
./scripts/bootstrap-ansible.sh
cd opt/openstack-ansible/scripts/
python ./scripts/pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

cp -r $OSA_PATH/etc/openstack_deploy $OSA_ETC_PATH 
cd $WORK_PATH
pwd
cp ./template/openstack_user_config.yml.temp $OSA_ETC_PATH/openstack_user_config.yml

cp ./template/user_variables.yml.temp $OSA_ETC_PATH/user_variables.yml

cp ./template/cinder.yml.temp $OSA_ETC_PATH/env.d/cinder.yml

ansible-playbook -i inventory playbook.yml #: e "change_source=true" -e pipeline=true 

source ./OpenStackAnsible.sh

#source ./test.sh
