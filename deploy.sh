#!/bin/bash
#TODO

source ./prepare.sh

ansible-play conf-vms

export OSA_PATH=/opt/openstack-ansible
export OSA_ETC_PATH=/etc/openstack_deploy


git clone https://git.openstack.org/openstack/openstack-ansible $OSA_PATH
cd $OSA_PATH
./scripts/bootstrap-ansible.sh

cd /opt/openstack-ansible/scripts

python pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

cp -r $OSA_PATH/etc/openstack_deploy $OSA_ETC_PATH 

cp ./template/openstack_user_config.yml.temp $OSA_ETC_PATH/openstack_user_config.yml

cp ./template/user_variables.yml.temp $OSA_ETC_PATH/user_variables.yml

cp ./template/cinder.yml.temp $OSA_ETC_PATH/env.d/cinder.yml

ansible-playbook -i inventory playbook.yml

figlet -ctf slant Set UP Host !

cd /opt/openstack-ansible/playbooks

openstack-ansible setup-hosts.yml | tee /home/setup-host.log

grep "failed=1" /home/setup-host.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi

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


