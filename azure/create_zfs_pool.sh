#!/bin/bash

echo "Install zfs"

yum install ftp://mirror.switch.ch/pool/4/mirror/scientificlinux/7.0/x86_64/updates/security/kernel-devel-3.10.0-123.20.1.el7.x86_64.rpm -y
yum install ftp://bo.mirror.garr.it/1/slc/centos/7.0.1406/updates/x86_64/Packages/kernel-headers-3.10.0-123.20.1.el7.x86_64.rpm -y
yum --enablerepo=epel install dkms -y
yum install http://download.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm -y
yum install zfs zfs-dracut -y
modprobe zfs

ZDISK=$( parted -m /dev/sda print all 2>/dev/null | grep unknown | grep /dev/sd | head -1 | cut -d':' -f1 )
zpool create -f zpool-pg $ZDISK
mkdir -p /var/lib/pgsql/data
zfs create -o mountpoint=/var/lib/pgsql/data zpool-pg/data
chown -R 103:107 /var/lib/pgsql

echo "Installation finished"
