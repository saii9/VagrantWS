#!/bin/bash

yum install -y epel-release
yum install -y ansible

echo "" >> /etc/ansible/hosts
echo "[target]" >> /etc/ansible/hosts
echo "target ansible_connection=ssh ansible_user=vagrant ansible_pass=vagrant" >> /etc/ansible/hosts
