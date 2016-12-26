#!/bin/bash

cd $PLAYBOOK_PATH
figlet -ctf slant Set UP Host !

openstack-ansible setup-hosts.yml | tee /home/setup-host.log

grep "unreachable=1" /home/setup-host.log>/dev/null
if [ $? -eq 0 ]; then
    openstack-ansible setup-hosts.yml | tee /home/setup-host.log
fi

grep "failed=1" /home/setup-host.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry setup-host!"
    exit 1
fi


figlet -ctf slant Set UP Infrastructure !

openstack-ansible setup-infrastructure.yml | tee /home/setup-infrastructure.log

grep "failed=1" /home/setup-infrastructure.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry setup-infrastructure!"
    exit 1
fi
ansible galera_container -m shell \
  -a "mysql -h localhost -e 'show status like \"%wsrep_cluster_%\";'" | tee /home/galera.log

grep "FAILED" /home/galera.log>/dev/null
if [ $? -eq 0 ]; then
    echo "failed retry!"
    exit 1
fi

figlet -ctf slant Set UP OpenStack !
i=0
for i < 5
do
  openstack-ansible setup-openstack.yml | tee  /home/setup-openstack.log
  i=i+1
  grep "failed=1" /home/setup-openstack.log>/dev/null
  if [ $? -eq 0 ]; then
      echo "failed retry setup-openstack $1!"
      continue
  else 
      break
  fi
done
