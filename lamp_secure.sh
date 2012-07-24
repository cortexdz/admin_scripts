#!/bin/bash
# Author: Omar AKHAM (akham.omar@gmail.com) 2012
## Install a Secure LAMP server on a Clean Debian Installation (Squeeze tested) script
## Source : http://www.linuxbymaster.in/php-security-lamp-server-security


PHP_INI_FILE="/etc/php5/apache2/php.ini"
APACHE_CONF_FILE="/etc/apache2/conf.d/security"
PHP_POST_SIZE="3M"
PHP_MAX_EXECUTION_TIME="30"
MAX_INPUT_TIME="30"
PHP_MEMORY_LIMIT="64M"
PHP_DISABLE_FUNCTIONS="exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"
BASE_DIR="/var/www/"


############### START ################
echo "        Install secure LAMP server"
echo "        --------------------------"
# Install LAMP Server
echo "Install packages ..."
apt-get update
apt-get install apache2 mysql-server php5 php5-suhosin php5-mysql

# Enable apache2's rewrite mod
echo "Enable Apache mod_rewrite ..."
a2enmod rewrite

# Secure Installation
## MySQL
echo "Secure Mysql installation ..."
mysql_secure_installation

## PHP5
echo "Secure Apache2/PHP5 Configuration ..."
###> Restrict APACHE/PHP Information Leakage
sed -i 's/^expose_php = On/expose_php = Off/g' $PHP_INI_FILE
sed -i 's/^ServerSignature On/ServerSignature Off/g' $APACHE_CONF_FILE
sed -i 's/^ServerTokens \(OS\|Full\|Minimal\|Minor\|Major\)/ServerTokens Prod/g' $APACHE_CONF_FILE

###> Log all php errors
sed -i 's/^display_errors = On/display_errors = Off/g' $PHP_INI_FILE
sed -i 's/^log_errors = Off/display_errors = On/g' $PHP_INI_FILE
sed -i 's/^;error_log = php_errors.log/error_log = php_errors.log/g' $PHP_INI_FILE

###> Turn Off Remote Code Execution
sed -i 's/^allow_url_fopen = On/allow_url_fopen = Off/g' $PHP_INI_FILE
sed -i 's/^allow_url_include = On/allow_url_include = Off/g' $PHP_INI_FILE

###> Control POST size
sed -i 's/^post_max_size = \(\w\+\)/post_max_size = '$PHP_POST_SIZE'/g' $PHP_INI_FILE

###> Ressource control
sed -i 's/^max_execution_time = \(\w\+\)/max_execution_time = '$PHP_MAX_EXECUTION_TIME'/g' $PHP_INI_FILE
sed -i 's/^max_input_time = \(\w\+\)/max_input_time = '$MAX_INPUT_TIME'/g' $PHP_INI_FILE
sed -i 's/^memory_limit = \(\w\+\)/memory_limit = '$PHP_MEMORY_LIMIT'/g' $PHP_INI_FILE

###> Disabling dangerous functions
sed -i 's/^disable_functions =\(\w*\)$/disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source/g' $PHP_INI_FILE

###> PHP Base dir
sed -i "s/^;open_basedir =\(\w*\)/open_basedir = $(echo $BASE_DIR|sed -e 's/\//\\\//g')/g" $PHP_INI_FILE

## Write protect Apache, Php, Mysql configuration files
echo "Write protect configuration files ..."
chattr +i /etc/php5/apache2/php.ini
chattr +i /etc/php5/conf.d/*
chattr +i /etc/mysql/my.cnf
chattr +i /etc/apache2/apache2.conf
chattr +i /etc/

# Start services
invoke-rc.d apache2 restart
