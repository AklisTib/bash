#!/bin/bash

# Create a Docker network
docker network create zabbix-net

# Pull Zabbix Docker images
docker pull zabbix/zabbix-server-mysql:latest
docker pull zabbix/zabbix-web-nginx-mysql:latest

# Run Zabbix server container
docker run -d --name zabbix-server-mysql \
           --network zabbix-net \
           -e DB_SERVER_HOST="zabbix-mysql-server" \
           -e MYSQL_DATABASE="zabbix" \
           -e MYSQL_USER="zabbix" \
           -e MYSQL_PASSWORD="test" \
           -e MYSQL_ROOT_PASSWORD="test" \
           -p 10051:10051 \
           zabbix/zabbix-server-mysql:latest

# Run Zabbix web interface container
docker run -d --name zabbix-web-nginx-mysql \
           --network zabbix-net \
           -e ZBX_SERVER_HOST="zabbix-server-mysql" \
           -e DB_SERVER_HOST="zabbix-mysql-server" \
           -e MYSQL_DATABASE="zabbix" \
           -e MYSQL_USER="zabbix" \
           -e MYSQL_PASSWORD="test" \
           -e MYSQL_ROOT_PASSWORD="test" \
           -p 8080:8080 \
           zabbix/zabbix-web-nginx-mysql:latest

echo "Zabbix server with GUI interface is now running. Access the GUI at http://localhost:8080/zabbix"