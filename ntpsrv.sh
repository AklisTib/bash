#!/bin/bash

echo "nameserver 8.8.8.8" >> /etc/resolv.conf
apt-get install -y chrony

rm -rf /etc/chrony.conf

cat <<EOF > /etc/chrony.conf

# Please consider joining the pool ( https://www.pool.ntp.org/join.html ). 
# pool pool.ntp.org iburst

server 127.0.0.1 iburst prefer
hwtimestamp ×
local stratum 5
allow 0/0
allow : :/0
#allow 11.11.11.0.24
#allow 22.22.22.0.24
#allow 33.33.33.024
#allow 44.44.44.0.24
#allou 192.168.100.0/26
#allou 192.168.200.0/28
#allou 172.16.100.0/24
#allow 2001:11::/61
#allow 2001:22::/64
#allow 2001:33::/64
#allou 2001:44::/64
#allow 2000:100:: 122
#allow 2000:200::/124
#allow 2001:100::/64

EOF

timedatectl set-timezone Europe/Moscow

systemctl enable --now chronyd

chronyc sources
chronyc tracking | grep Stratum
