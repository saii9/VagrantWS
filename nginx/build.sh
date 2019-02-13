set -x
pushd /home/vagrant/nginx-1.13.12
./configure --sbin-path=/usr/sbin/nginx 					\
            --conf-path=/etc/nginx/nginx.conf 				\
            --error-log-path=/var/log/nginx/error.log 		\
            --http-log-path=/var/log/nginx/access.log 		\
            --with-debug									\
			--with-http_ssl_module 							\
			--with-pcre 									  
			
			# --with-pcre=../pcre-8.40 \
			# --prefix=/etc/nginx \
			# --modules-path=/usr/lib64/nginx/modules \
            # --pid-path=/var/run/nginx.pid \
            # --lock-path=/var/run/nginx.lock \
            # --user=nginx \
            # --group=nginx \
            # --build=CentOS \
            # --builddir=nginx-1.13.2 \
            # --with-select_module \
            # --with-poll_module \
            # --with-threads \
            # --with-file-aio \
            # --with-http_v2_module \
            # --with-http_realip_module \
            # --with-http_addition_module \
            # --with-http_xslt_module=dynamic \
            # --with-http_image_filter_module=dynamic \
            # --with-http_geoip_module=dynamic \
            # --with-http_sub_module \
            # --with-http_dav_module \
            # --with-http_flv_module \
            # --with-http_mp4_module \
            # --with-http_gunzip_module \
            # --with-http_gzip_static_module \
            # --with-http_auth_request_module \
            # --with-http_random_index_module \
            # --with-http_secure_link_module \
            # --with-http_degradation_module \
            # --with-http_slice_module \
            # --with-http_stub_status_module \
            # --http-client-body-temp-path=/var/cache/nginx/client_temp \
            # --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            # --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            # --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            # --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            # --with-mail=dynamic \
            # --with-mail_ssl_module \
            # --with-stream=dynamic \
            # --with-stream_ssl_module \
            # --with-stream_realip_module \
            # --with-stream_geoip_module=dynamic \
            # --with-stream_ssl_preread_module \
            # --with-compat \
            # --with-pcre-jit \
            # --with-zlib=../zlib-1.2.11 \
            # --with-openssl=../openssl-1.1.0f \
            # --with-openssl-opt=no-nextprotoneg 
popd