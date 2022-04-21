#!/bin/bash

echo instalando pacotes bind
sudo apt-get update
sudo apt-get install bind9 bind9utils bind9-doc

echo configurando bind para ipv4
sudo cd /etc/default/
touch bind9
echo "OPTIONS="-u bind -4"" >> bind9

echo reiniciando bind
sudo systemctl restart bind9

sudo su
echo configurando DNS primario
echo "acl "trusted" {
        192.168.10.10 ;    # pc1 - can be set to localhost
        192.168.10.20 ;    # pc2 - host
};

options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable 
        // nameservers, you probably want to use them as forwarders.  
        // Uncomment the following block, and insert the addresses replacing 
        // the all-0's placeholder.

        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients
        listen-on { 192.168.10.10; };   # ns1 private IP address - listen on private network only
        allow-transfer { none; };      # disable zone transfers by default

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

sudo su
echo configurar arquivo local /etc/bind/named.conf.local
echo "zone "example.com" {
    type master;
    file "/etc/bind/zones/db.frcredes"; # zone file path
    //allow-transfer { 10.128.20.12; };           # ns2 private IP address - secondary
};

zone "10.168.192.in-addr.arpa" {
        type master;
        file "etc/bind/zones/db.redesfrc"; #10.168.192.0/24 subnet
        // allow-transfer { second dns reverse ip}
};" > /etc/bind/named.conf.local

sudo su
echo Configurar arquivo de zona - db.frcredes
mkdir /etc/bind/zones
cp /etc/bind/db.local /etc/bind/zones/db.frcredes
echo "
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     pc1.example.com. root.pc1.example.com. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; name servers -NS records
        IN      NS      pc1.example.com.

;name servers -A records
pc1.example.com.        IN      A       192.168.10.10
localhost               IN      A       127.0.0.1
pc2                     IN      A       192.168.10.20" > /etc/bind/zones/db.frcredes

sudo su
echo Configurar arquivo de zona reversa - db.redesfrc
cp /etc/bind/db.127 /etc/bind/zones/db.redesfrc
echo ";
; BIND reverse data file for local loopback interface
;
$TTL    604800
@       IN      SOA     pc1.example.com. root.pc1.example.com. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
        IN      NS      pc1.example.com.
1       IN      PTR     pc1.example.com.
2       IN      PTR     pc2.example.com." > /etc/bind/zones/db.redesfrc

echo Checar errors nos arquivos named.conf*
sudo named-checkconf

echo Checar zona de encaminhamento
sudo named-checkzone example.com /etc/bind/zones/db.frcredes

echo Checar zona reversa
sudo named-checkzone 10.168.192.in-addr.arpa /etc/bind/zones/db.redesfrc

echo restart do bind
sudo systemctl restart bind9