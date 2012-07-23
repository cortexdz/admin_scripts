#!/bin/bash
# Author: Omar AKHAM (akham.omar@gmail.com) 2012
## Install a chrooted Bind9 on Debian (Squeeze tested) script
## Source : http://wiki.debian.org/Bind9#Bind_Chroot

#install bind9
apt-get install bind9 bind9utils &&

#Stop bind service
/etc/init.d/bind9 stop

#Switch Bind9 to use the chroot
sed -i 's/OPTIONS="-u bind"/OPTIONS="-u bind -t \/var\/bind9\/chroot"/g' /etc/default/bind9

#Create chroot
mkdir -p /var/bind9/chroot/{etc,dev,var/cache/bind,var/run/bind/run}
chown -R bind:bind /var/bind9/chroot/var/*
mknod /var/bind9/chroot/dev/null c 1 3
mknod /var/bind9/chroot/dev/random c 1 8
chmod 660 /var/bind9/chroot/dev/{null,random}

#Move config file to chroot
mv /etc/bind /var/bind9/chroot/etc
ln -s /var/bind9/chroot/etc/bind /etc/bind 

chown -R bind:bind /etc/bind/*

#Set correct PIDFILE
sed -i 's/PIDFILE=\/var\/run\/named\/named.pid/PIDFILE=\/var\/bind9\/chroot\/var\/run\/named\/named.pid/g' /etc/init.d/bind9

#Tell rsyslog to listen to the bind logs in the correct place
echo "\$AddUnixListenSocket /var/bind9/chroot/dev/log" > /etc/rsyslog.d/bind-chroot.conf

#Start services
/etc/init.d/rsyslog restart;
/etc/init.d/bind9 start

