#!/bin/bash

mkdir /home/vagrant/local
cd /home/vagrant/local


sudo echo "" >>/etc/apt/sources.list 
sudo echo "deb http://mirrors.kernel.org/ubuntu xenial main"  >> /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get install -y autoconf automake libtool-bin libexpat1-dev \
libncurses5-dev bison flex patch curl cvs texinfo git bc \
build-essential subversion gawk python-dev gperf unzip \
pkg-config help2man wget

wget http://bootlin.com/doc/training/embedded-linux/embedded-linux-labs.tar.xz
tar xvf embedded-linux-labs.tar.xz

cd embedded-linux-labs


git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng/
git checkout crosstool-ng-1.23.0
autoreconf
./configure --enable-local
make
make install

#build toolchain
#./ct-ng arm-unknown-linux-gnueabi
#./ct-ng build