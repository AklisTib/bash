#!/bin/bash

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

apt-get update && apt-get install zabbix-agent -y

sed -i 's/Server=127.0.0.1/Server=10.0.2.15/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/Server=10.0.2.15/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=localhost.localdomain/Hostname=Client1/g' /etc/zabbix/zabbix_agentd.conf

systemctl enable --now zabbix_agentd.service
