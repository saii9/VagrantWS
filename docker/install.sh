#!/bin/bash
set -x
set -e
yum install -y epel-release
yum install -y docker
yum install -y python-pip
pip install awscli