#!/bin/bash
#TODO
export WORK_PATH=$(pwd)
source ./var/env_var.sh





source ./prepare.sh


#export WORK_PATH=$(pwd)
#export OSA_PATH=/opt/openstack-ansible
#export OSA_ETC_PATH=/etc/openstack_deploy

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

figlet -ctf slant Set UP Host !

cd /opt/openstack-ansible/playbooks

openstack-ansible setup-hosts.yml | tee /home/setup-host.log

grep "unreachable=1" /home/setup-host.log>/dev/null
if [ $? -eq 0 ]; then
    openstack-ansible setup-hosts.yml | tee /home/setup-host.log
fi

grep "failed=1" /home/setup-host.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi


'''
openstack-ansible setup-infrastructure.yml | tee /home/setup-infrastructure.log

grep "failed=1" /home/setup-infrastructure.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi
ansible galera_container -m shell \
  -a "mysql -h localhost -e 'show status like \"%wsrep_cluster_%\";'" | tee /home/galera.log

grep "FAILED" /home/galera.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi

openstack-ansible setup-openstack.yml | tee  /home/setup-openstack.log

grep "failed=1" /home/setup-openstack.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi

'''
