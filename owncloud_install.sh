#!/usr/bin/env bash
# Author: Omar AKHAM (akham.omar@gmail.com) 2012
## Install Owncloud on Fresh Debian Squeeze
## Source : http://owncloud.org/support/install/

_WWW="/srv/www"

# Install Lamp
apt-get install apache2 php5 mysql-server php5-gd php5-mysql php5-common mp3info curl libcurl3 libcurl4-openssl-dev php5-curl zip bzip2

# Download latest
wget "http://owncloud.org/releases/owncloud-latest.tar.bz2" -O /tmp/owncloud-latest.tar.bz2
tar -xjf /tmp/owncloud-latest.tar.bz2
mkdir $_WWW
mv owncloud $_WWW/
chown -R www-data:www-data $_WWW/owncloud
