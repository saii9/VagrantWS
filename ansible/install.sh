#!/bin/bash
set -x
set -e
yum install -y epel-release
yum install -y ansible

sudo cp -r /home/vagrant/sync/.vagrant/machines /home/vagrant
sudo chown -R vagrant:vagrant /home/vagrant/machines
chmod 700 /home/vagrant/machines/Ansible.target/virtualbox/private_key 

cat << SET >> /etc/ansible/hosts
[target] 
target ansible_connection=ssh ansible_user=vagrant ansible_pass=vagrant ansible_ssh_private_key_file=/home/vagrant/machines/Ansible.target/virtualbox/private_key
SET
