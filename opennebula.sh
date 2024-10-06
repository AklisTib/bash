#!/bin/bash

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
sudo apt-get update
sudo apt-get install -y gnupg wget curl

# Добавление репозитория OpenNebula
echo "Добавление репозитория OpenNebula..."
echo "deb https://downloads.opennebula.io/repo/6.6/Debian/10/ /" | sudo tee /etc/apt/sources.list.d/opennebula.list
wget -q -O- https://downloads.opennebula.io/repo/repo.key | sudo apt-key add -

# Обновление списка пакетов и установка OpenNebula
echo "Обновление списка пакетов и установка OpenNebula..."
sudo apt-get update
sudo apt-get install -y opennebula opennebula-sunstone opennebula-flow opennebula-gate opennebula-provision

# Настройка сети для OpenNebula
echo "Настройка сети для OpenNebula..."
sudo sed -i 's/^ONE_XMLRPC_SERVER=.*/ONE_XMLRPC_SERVER="http:\/\/192.168.88.10:2633\/RPC2"/' /etc/one/oned.conf

# Настройка IP-адреса сервера
echo "Настройка IP-адреса сервера..."
sudo sed -i 's/^ONE_HOST=.*/ONE_HOST="192.168.88.10"/' /etc/one/oned.conf

# Настройка базы данных
echo "Настройка базы данных..."
sudo -u oneadmin /usr/share/one/install_gems
sudo oneuser create oneadmin oneadmin

# Запуск служб OpenNebula
echo "Запуск служб OpenNebula..."
sudo systemctl enable opennebula
sudo systemctl enable opennebula-sunstone
sudo systemctl start opennebula
sudo systemctl start opennebula-sunstone

# Настройка Sunstone
echo "Настройка Sunstone..."
sudo sed -i 's/^:host: .*/:host: 192.168.88.10/' /etc/one/sunstone-server.conf
sudo systemctl restart opennebula-sunstone

# Установка завершена
echo "Установка OpenNebula завершена. Перейдите по адресу http://192.168.88.10:9869 для доступа к Sunstone."
