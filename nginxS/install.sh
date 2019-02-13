set -e

sudo yum install -y epel-release
sudo yum -y update
sudo yum install -y nginx
sudo systemctl start nginx
