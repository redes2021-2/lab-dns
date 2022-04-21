# lab-dns
laboratorio de dns
# 1. Pré requistos

Vagrant => 2.2.19
Virtual Box => 6.1.32

## 1.1 Como subir as VM

```
vagrat up
```

## 1.2 Entrar em cada VM

PC1

```
vagrant ssh PC1
```

PC2

```
vagrant ssh PC2
```

PC3

```
vagrant ssh PC3
```
> Foram feitos arquivos bash para configurar automaticamente as 3 primeiras etapas
> - PC1.sh
> - PC2.sh

# Tabela de HOST

| Host  | Função | FQDN privado | Endereço IP privado|
|:--:   |:--:    |:--:          |:--:                |
| PC1 | DNS Servidor| pc1.labFRC.exemplo.com    | 192.168.10.1 |
| PC2 | DNS Cliente | pc2.labFRC.exemplo.com  | 192.168.10.2 |
| PC3 | host genérico | pc3.labFRC.exemplo.com   | 192.168.10.3 |

## Etapas

## 1. Colocando IP desejado

```
$ sudo su
$ rm /etc/hosts
$ echo " 127.0.0.1       localhost

    # The following lines are desirable for IPv6 capable hosts
    ::1     ip6-localhost   ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    192.168.10.10             pc1.labFRC.exemplo.com PC1 " >>  /etc/hosts

$ exit
```

## 2.Trocando nome de hostname

```
$sudo su
$ rm /etc/hostname
$ touch /etc/hostname
$ echo PC1 > /etc/hostname
$ echo "PC1" > /proc/sys/kernel/hostname
$ exit
$ reboot
```

## 3. Verficaçōes

```
echo ping pc1.labFRC
ping  -c4 pc1.labFRC

echo dnsdomainname:
dnsdomainname

echo dnsdomainname -f:
dnsdomainname -f
```

## 4. Configuração do servidor DNS

#### install bind
```
sudo apt-get update
sudo apt-get install bind9 bind9utils bind9-doc
```

#### Configurar bind para IPV4

```
sudo nano /etc/default/bind9
```

```
OPTIONS="-u bind -4"
```

#### Reiniciar o bind

```
sudo systemctl restart bind9
```

#### Configurar o DNS primario

```
sudo nano /etc/bind/named.conf.options
```

###### Preencher com
```
acl "trusted" {
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
};
```

#### Configurar arquivo local - named.conf.local

```
sudo nano /etc/bind/named.conf.local
```

```
zone "example.com" {
    type master;
    file "/etc/bind/zones/db.frcredes"; # zone file path
    //allow-transfer { 10.128.20.12; };           # ns2 private IP address - secondary
};

zone "10.168.192.in-addr.arpa" {
        type master;
        file "etc/bind/zones/db.redesfrc"; #10.168.192.0/24 subnet
        // allow-transfer { second dns reverse ip}
};
```

#### Configurar arquivo de zona - db.frcredes

```
sudo mkdir /etc/bind/zones
sudo cp /etc/bind/db.local /etc/bind/zones/db.frcredes
```

```
sudo nano /etc/bind/zones/db.frcredes
```

###### Preencher com:

```
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
pc2                     IN      A       192.168.10.20
```

#### Configurar arquivo de zona reversa - db.redesfrc

```
sudo cp /etc/bind/db.127 /etc/bind/zones/db.redesfrc
```

```
sudo nano /etc/bind/zones/db.redesfrc
```

###### Preencher com:

```
;
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
2       IN      PTR     pc2.example.com.
```

## 5. Checar erros

#### Checar errors nos arquivos named.conf*

```
sudo named-checkconf
```

#### Checar zona de encaminhamento

```
sudo named-checkzone example.com /etc/bind/zones/db.frcredes
```

#### Checar zona reversa

```
sudo named-checkzone 10.168.192.in-addr.arpa /etc/bind/zones/db.redesfrc
```

#### Restart do bind

```
sudo systemctl restart bind9
```

## 6. Configuração do Cliente DNS

```
sudo nano /etc/resolv.conf
```

```
domain example.com
nameserver 192.168.10.1
nameserver 192.168.10.2
options edns0 trust-ad
```
## 7. Testar
    
