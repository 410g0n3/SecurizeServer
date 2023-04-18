#!/usr/bin/env bash

#Script to automate some configurations in Debian-based system deployments
#Autor: 410.g0n3

#colors
magenta="\e[1;35m"
green="\e[1;32m"
red="\e[1;31m"
yellow="\e[1;33m"
endcolor="\e[0m"


### FAIL 2 BAN ###
# install
echo -e "${magenta}[+] Installing Fail2ban...${endcolor}"
apt install fail2ban -y 1>&- 

# config
cp /etc/fail2ban/jail.{conf,local}

# edit .local file
echo " "
echo "#Configuration introduced by script" >> /etc/fail2ban/jail.local

# ask for IPs whitelist
echo -e "${yellow}[?] Enter IPs for the whitelist: (example: 192.168.1.1 10.0.1.20)${endcolor}"
read whitelist
echo "ignoreip =  ${whitelist}" >> /etc/fail2ban/jail.local

#ask for ban time
echo -e "${yellow}[?] Enter ban time: (example: 1d, 2w)${endcolor}"
read btime
echo "bantime = ${btime}" >> /etc/fail2ban/jail.local

#ask for number of failures before an IP is banned
echo -e "${yellow}[?] Enter number of login attempts:${endcolor}"
read maxtry
echo "maxretry = ${maxtry}" >> /etc/fail2ban/jail.local


### DISABLE IPV6 ###
echo " "
echo -e "${red}[-] Disabling IPv6...${endcolor}"
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null
sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null


### REMOVE INSECURE SERVICES ###
echo " "
echo -e "${red}[-] Uninstalling non-secure services (telnet)...${endcolor}"
apt --purge remove telnetd -y 1>&- 2>&-


### INSTALL NETWORK TOOLS ###
#some networks tools to make troubleshooting in case it is necesary
echo " "
echo -e "${magenta}[+] Installing network tools: iptraf-ng, mtr & nethogs${endcolor}"
apt install iptraf-ng mtr nethogs -y 1>&-

### STRONGS PASSWORDS ###
echo " "
echo -e "${magenta}[+] Installing library for password security... ${endcolor}"
apt install libpam-cracklib -y 1>&- 2>&-
echo "password        requisite                       pam_cracklib.so retry=3 minlen=16 difok=3 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1" > /etc/pam.d/common-password
echo -e "${magenta}[+] Password security criteria added. Minimum 16 characters, minimum 1 lowercase, minimum 2 uppercase, minimum 1 number and 1 symbol. ${endcolor}"

### CHANGE SSHD CONFIG ###
echo "Port 28971" >> /etc/ssh/sshd_config
systemctl restart sshd.service
