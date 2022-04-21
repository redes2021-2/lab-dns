#!/bin/bash

echo config dns

sudo su
echo "
domain example.com
nameserver 192.168.10.1
nameserver 192.168.10.2" > /etc/resolv.conf