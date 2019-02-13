#!/bin/bash
set -x
set -e
sudo yum install -y epel-release
sudo yum install -y docker
sudo yum install -y python-pip
sudo pip install awscli
sudo usermod vagrant  -aG docker
sudo systemctl enable docker
sudo systemctl start docker
