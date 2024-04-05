#!/bin/bash

control bind-chroot disabled

grep -q 'bind-dns' /etc/bind/named.conf || echo 'include "/var/lib/samba/bind-dns/named.conf";' >> /etc/bind/named.conf

sed -i '8a\tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";' /etc/bind/options.conf
sed -i '9a\minimal-responses yes;' /etc/bind/options.conf
sed -i '91a\category lame-servers {null;};' /etc/bind/options.conf
systemctl stop bind

sed -i 's/HOSTNAME=ISP/HOSTNAME=hq-srv.demo.first/g' /etc/sysconfig/network

hostnamectl set-hostname hq-srv.demo.first; exec bash
domainname demo.first

rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba
rm -rf /var/cache/samba
mkdir -p /var/lib/samba/sysvol

samba-tool domain provision --realm=demo.first --domain=demo --adminpass='P@ssw0rd' --dns-backend=BIND9_DLZ --server-role=dc --use-rfc2307

systemctl enable --now samba
systemctl enable --now bind
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

samba-tool domain info 127.0.0.1

host -t SRV _kerberos._udp.demo.first.
host -t SRV _ldap._tcp.demo.first.
host -t A hq-srv.demo.first
