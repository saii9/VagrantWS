#!/bin/bash

yum install -y epel-release
yum install -y ansible

cp -r /home/vagrant/sync/.vagrant/machines /home/vagrant
chmod 700 /home/vagrant/machines/simbuild.box/virtualbox/private_key 

cat << SET >> /etc/ansible/hosts
[target] 
target ansible_connection=ssh ansible_user=vagrant ansible_pass=vagrant ansible_ssh_private_key_file=/home/vagrant/machines/Ansible.target/virtualbox/private_key
SET
