#!/bin/bash

echo "HOSTNAME="`hostname -f` >> /etc/sysconfig/network
systemctl restart network

echo "Installing dependencies"
yum install epel-release -y
yum install wget git net-tools bind-utils iptables-services bridge-utils bash-completion yum-utils ansible docker -y
echo "Updating all packages"
yum update -y

sed -i 's/requiretty/!requiretty/g' /etc/sudoers

echo "Securing sshd"
echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com" >> /etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256@libssh.org" >> /etc/ssh/sshd_config
systemctl restart sshd

echo "Configuring docker device mapper"
DOCKERVG=$( parted -m /dev/sda print all 2>/dev/null | grep unknown | grep /dev/sd | head -1 | cut -d':' -f1 )
echo "DEVS=${DOCKERVG}" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup

docker-storage-setup
if [ $? -eq 0 ]
then
   echo "Docker thin pool logical volume created successfully"
else
   echo "Error creating logical volume for Docker"
   exit 3
fi

systemctl enable docker
systemctl start docker

echo "Installation finished"
