#!/bin/bash

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

apt-get update && apt-get install bind bind-utils chrony task-samba-dc -y

cat <<EOF > /etc/bind/options.conf
options {
	version "unknown";
	directory "/etc/bind/zone";
	dump-file "/var/run/named_dump.db";
	statistics-file "/var/run/named.stats";
	recursing-file "/var/run/recursing";

	// disables the use of a PID file
	pid-file none;

	/*
	 * Oftenly used directives are listed below.
	 */

	listen-on { any; };
	listen-on-v6 { any; };

	/*
	 * If the forward directive is set to "only", the server will only
	 * query the forwarders.
	 */
	forward only;
	forwarders { 77.88.8.8; };
	include "/etc/bind/resolvconf-options.conf";

	/*
	 * Specifies which hosts are allowed to ask ordinary questions.
	 */
	allow-query { any; };

	/*
	 * This lets "allow-query" be used to specify the default zone access
	 * level rather than having to have every zone override the global
	 * value. "allow-query-cache" can be set at both the options and view
	 * levels.  If "allow-query-cache" is not set then "allow-recursion" is
	 * used if set, otherwise "allow-query" is used if set unless
	 * "recursion no;" is set in which case "none;" is used, otherwise the
	 * default (localhost; localnets;) is used.
	 */
	//allow-query-cache { localnets; };

	/*
	 * Specifies which hosts are allowed to make recursive queries
	 * through this server.  If not specified, the default is to allow
	 * recursive queries from all hosts.  Note that disallowing recursive
	 * queries for a host does not prevent the host from retrieving data
	 * that is already in the server's cache.
	 */
	//allow-recursion { localnets; };

	/*
	 * Sets the maximum time for which the server will cache ordinary
	 * (positive) answers.  The default is one week (7 days).
	 */
	//max-cache-ttl 86400;

	/*
	 * The server will scan the network interface list every
	 * interface-interval minutes.  The default is 60 minutes.
	 * If set to 0, interface scanning will only occur when the
	 * configuration file is loaded.  After the scan, listeners will
	 * be started on any new interfaces (provided they are allowed by
	 * the listen-on configuration).  Listeners on interfaces that
	 * have gone away will be cleaned up.
	 */
	//interface-interval 0;
};

logging {
	// The default_debug channel has the special property that it only
	// produces output when the server’s debug level is non-zero. It
	// normally writes to a file called named.run in the server’s working
	// directory.

	// For security reasons, when the -u command-line option is used, the
	// named.run file is created only after named has changed to the new
	// UID, and any debug output generated while named is starting - and
	// still running as root - is discarded. To capture this output, run
	// the server with the -L option to specify a default logfile, or the
	// -g option to log to standard error which can be redirected to a
	// file.

	// channel default_debug {
	// 	file "/var/log/named/named.run" versions 10 size 20m;
	// 	print-time yes;
	// 	print-category yes;
	// 	print-severity yes;
	// 	severity dynamic;
	// };
};
EOF

systemctl enable --now bind
echo name_servers=127.0.0.1 >> /etc/resolvconf.conf
resolvconf -u
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

cat <<EOF > /etc/bind/local.conf
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

$TTL	1D
@	IN	SOA	hq.work root.hq.work. (
				2024021400	; serial
				12H		; refresh
				1H		; retry
				1W		; expire
				1H		; ncache
			)
	IN	NS	hq.work.
	IN	A	127.0.0.0
hq-r	IN	A	192.168.100.62
hq-srv	IN	A	192.168.100.5
 

EOF

rm -rf /etc/bind/zone/branch.db


cat <<EOF > /etc/bind/zone/branch.db

$TTL	1D
@	IN	SOA	branch.work root.branch.work. (
				2024021400	; serial
				12H		; refresh
				1H		; retry
				1W		; expire
				1H		; ncache
			)
	IN	NS	branch.work.
	IN	A	127.0.0.0
br-r	IN	A	192.168.200.14
br-srv	IN	A	192.168.200.1
EOF

rm -rf /etc/bind/zone/100.db

cat <<EOF > /etc/bind/zone/100.db

$TTL	1D
@	IN	SOA	hq.work root.hq.work. (
				2024021400	; serial
				12H		; refresh
				1H		; retry
				1W		; expire
				1H		; ncache
			)
	IN	NS	hq.work.
62	IN	PTR	hq-r.hq.work.
5	IN	PTR	hq-srv.hq.work.
EOF

rm -rf /etc/bind/zone/200.db

cat <<EOF > /etc/bind/zone/200.db

$TTL	1D
@	IN	SOA	branch.work. root.branch.work. (
				2024021400	; serial
				12H		; refresh
				1H		; retry
				1W		; expire
				1H		; ncache
			)
	IN	NS	branch.work.
14	IN	PTR	br-r.branch.work.
 
EOF

named-checkconf -z

systemctl restart bind

host hq-r.hq.work
host hq-srv.hq.work
host 192.168.100.62
host 192.168.200.14

timedatectl set-timezone Europe/Moscow

Cat <<EOF > /etc/chrony.conf
# Use piblic servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
# pool pool.ntp.org iburst

server 192.168.100.62 iburst prefer
server 2000:100::3f iburst
EOF

systemctl enable --now chronyd

control bind-chroot disabled

grep -q 'bind-dns' /etc/bind/named.conf || echo 'include "/var/lib/samba/bind-dns/named.conf";' >> /etc/bind/named.conf

sed -i '8a\tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";'
sed -i '9a\minimal-responses yes;'
sed -i '91a\category lame-servers {null;};'
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

kinit administrator@DEMO.FIRST

