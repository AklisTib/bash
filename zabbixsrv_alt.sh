#!/bin/bash
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

apt-get update && apt-get install postgresql13-server zabbix-server-pgsql fping apache2 apache2-mod_php8.1  -y
apt-get update  && apt-get install php8.1 php8.1-mbstring php8.1-sockets php8.1-gd php8.1-xmlreader php8.1-pgsql php8.1-ldap php8.1-openssl zabbix-phpfrontend-apache2 zabbix-phpfrontend-php8.1 -y


/etc/init.d/postgresql initdb
systemctl enable --now postgresql

su - postgres -s /bin/sh -c 'createuser --no-superuser --no-createdb --no-createrole --encrypted --pwprompt zabbix'
su - postgres -s /bin/sh -c 'createdb -O zabbix zabbix'
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/schema.sql zabbix'
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/images.sql zabbix'
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/data.sql zabbix'

systemctl enable --now httpd2


sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/8.1/apache2-mod_php/php.ini 
sed -i 's/post_max_size = 20M/ post_max_size = 32M/g' /etc/php/8.1/apache2-mod_php/php.ini 
sed -i 's/max_execution_time = 240/max_execution_time = 600/g' /etc/php/8.1/apache2-mod_php/php.ini 
sed -i 's/max_input_time = 240/max_input_time = 600/g' /etc/php/8.1/apache2-mod_php/php.ini 
sed -i 's/date.timezone = Europe/Moscow/date.timezone = Europe/Samara/g' /etc/php/8.1/apache2-mod_php/php.ini 

systemctl restart httpd2

sed -i 's/#DBHost=localhost/ DBHost=localhost/g' /etc/zabbix/zabbix_server.conf
sed -i 's/DBPassword=/DBPassword=P@ssw0rd/g' /etc/zabbix/zabbix_server.conf

systemctl enable --now zabbix_pgsql

ln -s /etc/httpd2/conf/addon.d/A.zabbix.conf /etc/httpd2/conf/extra-enabled/
service httpd2 restart
chown apache2:apache2 /var/www/webapps/zabbix/ui/conf
