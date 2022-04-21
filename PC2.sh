#!/bin/bash
echo Colocando 127.0.1.1  como hosts com o nome PC1
sudo su
rm /etc/hosts
echo " 127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost   ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
192.168.10.20             pc2.labFRC PC2 " >>  /etc/hosts
exit

echo Alterando Hostname para PC1
sudo su
rm /etc/hostname
touch /etc/hostname
echo PC2 > /etc/hostname
exit

echo "PC2" > /proc/sys/kernel/hostname

echo precisa Reboot sistema para troca hostname


echo Alterando Hostname para PC1
sudo su
rm /etc/hostname
touch /etc/hostname
echo PC1 > /etc/hostname
exit

echo "PC1" > /proc/sys/kernel/hostname

echo Reboot sistema para troca hostname
reboot

echo ping pc1.labFRC
ping  -c4 pc1.labFRC

echo dnsdomainname:
dnsdomainname

echo dnsdomainname -f:
dnsdomainname -f



