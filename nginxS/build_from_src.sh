	
#to build from tar ball
cd ~

#download the source code from nginx
wget https://nginx.org/download/nginx-1.13.12.tar.gz
tar -xf nginx-1.13.12.tar.gz

#install all the required dependencies
sudo yum -y install wget gcc gcc-c++ kernel-devel make
sudo yum -y groupinstall "Development Tools"
sudo yum install -y perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel
sudo yum install -y openssl openssl-devel pcre pcre-devel

#options to configure in https://nginx.org/en/docs/configure.html
./configure --sbin-path=/usr/bin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-pcre \
--pid-path=/var/run/nginx.pid
--with-http_ssl_module
#the main benifit of building nginx from source is the ability to add custom modules.
# 	or extend teh standerd nginx functionality
#Nginx modules exit in 2 forms bundled and 3rd party
#	bundled modules that comes with nginx source. --with-http-ssl_modules
#	telling nginx to add and enable ssl.
#	

make clean
make
make install
#sudo firewall-cmd --permanent --zone=public --add-service=http 
#sudo firewall-cmd --permanent --zone=public --add-service=https
#sudo firewall-cmd --reload