FROM centos:7

COPY set_default.py /set_default.py
COPY entrypoint.sh /entrypoint.sh
COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

RUN mkdir -p /www/letsencrypt \
    && ln -s /www/letsencrypt /etc/letsencrypt \
    && rm -f /etc/init.d \
    && mkdir /www/init.d \
    && ln -s /www/init.d /etc/init.d \
    && chmod +x /entrypoint.sh \
    && cd /home \
    && yum yum makecache \
    && yum -y update \
    && yum -y install wget openssh-server \
    && echo 'Port 63322' > /etc/ssh/sshd_config \
    && wget -O install.sh http://download.bt.cn/install/install_6.0.sh \
    && echo y | bash install.sh \
    && python /set_default.py \
    && bash /www/server/panel/install/install_soft.sh 0 install nginx 1.16 \
    && bash /www/server/panel/install/install_soft.sh 0 install php 7.4 || echo 'Ignore Error' \
    && bash /www/server/panel/install/install_soft.sh 0 install mysql mariadb_10.4 \
    && bash /www/server/panel/install/install_soft.sh 0 install phpmyadmin 4.9 || echo 'Ignore Error' \
    && echo '["linuxsys", "webssh", "nginx", "php-7.4", "mysql", "phpmyadmin"]' > /www/server/panel/config/index.json \
    && rm -rf /www/wwwroot/default \
    && rm -rf /www/server/nginx/src \
    && rm -rf /www/server/php/74/src \
    && yum clean all

EXPOSE 8888 888 21 20 443 80

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:8888/ && curl -fs http://localhost/ || exit 1
