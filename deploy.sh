#!/bin/bash
#TODO
export WORK_PATH=$(pwd)

source ./var/env_var.sh

source ./prepare.sh

set -x

rm -rf $OSA_PATH
git clone https://git.openstack.org/openstack/openstack-ansible $OSA_PATH

cd $OSA_PATH
./scripts/bootstrap-ansible.sh
rm -rf $OSA_ETC_PATH
cp -r $OSA_PATH/etc/openstack_deploy $OSA_ETC_PATH

cd /opt/openstack-ansible/scripts/
python pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

cd $WORK_PATH

pwd
cp ./template/openstack_user_config.yml.temp $OSA_ETC_PATH/openstack_user_config.yml

cp ./template/user_variables.yml.temp $OSA_ETC_PATH/user_variables.yml

cp ./template/cinder.yml.temp $OSA_ETC_PATH/env.d/cinder.yml

ansible-playbook -i inventory playbook.yml #: e "change_source=true" -e pipeline=true 

source ./OpenStackAnsible.sh

#source ./test.sh
