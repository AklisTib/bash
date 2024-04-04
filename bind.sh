#!/bin/bash

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

apt-get update && apt-get install bind bind-utils -y


sed -i 's/listen-on{ none; };/listen-on{ any; };/g' /etc/bind/options.conf
sed -i 's/listen-on-v6{ none; };/listen-on-v6{ any; };/g' /etc/bind/options.conf
sed -i 's/forward only;/forward first;/g' /etc/bind/options.conf
sed -i 's/forwarders{ };/forwarders{ 77.88.8.8; };/g' /etc/bind/options.conf
sed -i 's/allow-query {  localnets; }/allow-query { any; };/g' /etc/bind/options.conf

systemctl enable --now bind
echo name_servers=127.0.0.1 >> /etc/resolvconf.conf
resolvconf -u
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

cat <<EOF > /etc/bind/local.conf
include "/etc/bind/rfc1912.conf"

zone "hq.work" {
        type master;
        file "hq.db";    
};

zone "branch.work" {
        type master;
        file "branch.db";    
};

zone "100.168.192.in-addr.arpa" {
        type master;
        file "100.db";    
};

zone "200.168.192.in-addr.arpa" {
        type master;
        file "200.db";    
};

EOF

cp /etc/bind/zone/{localdomain,hq.db}
cp /etc/bind/zone/{localdomain,branch.db}
cp /etc/bind/zone/{127.in-addr.arpa,100.db}
cp /etc/bind/zone/{127.in-addr.arpa,200.db}
chown root:named /etc/bind/zone/{hq,branch,100,200}.db

rm -rf /etc/bind/zone/hq.db

cat <<EOF > /etc/bind/zone/hq.db

$TTL    1D
@       IN      SOA hq.work. root.hq.work. (
                   2007010401           ; serial
                         3600           ; refresh
                          600           ; retry
                        86400           ; expire
                          600 )         ; ncache
                    }
        IN      NS  hq.work.
        IN      A   127.0.0.0
hq-r    IN      A   192.168.100.62
hq-srv  IN      A   192.168.100.1

EOF

rm -rf /etc/bind/zone/branch.db

cat <<EOF > /etc/bind/zone/branch.db

$TTL    1D
@       IN      SOA branch.work. root.branch.work (
                   2007010401           ; serial
                         3600           ; refresh
                          600           ; retry
                        86400           ; expire
                          600 )         ; ncache
                    }
        IN      NS  branch.work.
        IN      A   127.0.0.0
br-r    IN      A   192.168.200.14
br-srv  IN      A   192.168.200.1

EOF

rm -rf /etc/bind/zone/100.db

cat <<EOF > /etc/bind/zone/100.db
$TTL    1D
@       IN      SOA     hq.work. root.hq.work. (
                        2007010401      ; serial
                         3600           ; refresh
                          600           ; retry
                        86400           ; expire
                          600           ; ncache
                        )
        IN      NS      hq.work.
62      IN      PTR     hq-r.hq.work.
1       IN      PTR     hq-srv.hq.work.

EOF

rm -rf /etc/bind/zone/200.db

cat <<EOF > /etc/bind/zone/200.db

$TTL    1D
@       IN      SOA     branch.work. root.branch.work. (
                        2007010401      ; serial
                         3600           ; refresh
                          600           ; retry
                        86400           ; expire
                          600           ; ncache
                        )
        IN      NS      branch.work.
14      IN      PTR     br-r.branch.work.

EOF

named-checkconf -z

systemctl restart bind

host hq-r.hq.work
host hq-srv.hq.work
host 192.168.100.62
host 192.168.200.14
