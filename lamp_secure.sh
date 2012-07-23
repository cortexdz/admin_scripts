#!/bin/bash
# Author: Omar AKHAM (akham.omar@gmail.com) 2012
## Install a Secure LAMP server on a Clean Debian Installation (Squeeze tested) script
## Source : http://www.linuxbymaster.in/php-security-lamp-server-security

# Install LAMP Server
apt-get install apache2 mysql-server php5 php5-suhosin php5-mysql

# Enable apache2's rewrite mod
a2enmod rewrite

# Secure Installation
## MySQL
mysql_secure_installation

## PHP5
PHP_INI_FILE="/etc/php5/apache2/php.ini"
APACHE_CONF_FILE="/etc/apache2/conf.d/security"
POST_SIZE="3M"
MAX_EXECUTION_TIME="30"
MAX_INPUT_TIME="30"
MEMORY_LIMIT="64M"
PHP_DISABLE_FUNCTIONS="exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"
BASE_DIR="/var/www/"

###> Restrict APACHE/PHP Information Leakage
sed -i 's/^expose_php = On/expose_php = Off/g' PHP_INI_FILE
sed -i 's/^ServerSignature On/ServerSignature Off/g' APACHE_CONF_FILE
sed -i 's/^ServerTokens OS\|Full\|Minimal\|Minor\|Major/ServerTokens Prod/g' APACHE_CONF_FILE

###> Log all php errors
sed -i 's/^display_errors = On/display_errors = Off/g' PHP_INI_FILE
sed -i 's/^log_errors = Off/display_errors = On/g' PHP_INI_FILE
sed -i 's/^;error_log = php_errors.log/error_log = php_errors.log/g' PHP_INI_FILE

###> Turn Off Remote Code Execution
sed -i 's/^allow_url_fopen = On/allow_url_fopen = Off/g' PHP_INI_FILE
sed -i 's/^allow_url_include = On/allow_url_include = Off/g' PHP_INI_FILE

###> Control POST size
sed -i 's/^post_max_size = \(\w\+\)/post_max_size = '$POST_SIZE'/g' PHP_INI_FILE

###> Ressource control
sed -i 's/^max_execution_time = \(\w\+\)/max_execution_time = '$MAX_EXECUTION_TIME'/g' PHP_INI_FILE
sed -i 's/^max_input_time = \(\w\+\)/max_input_time = '$MAX_INPUT_TIME'/g' PHP_INI_FILE
sed -i 's/^memory_limit = \(\w\+\)/memory_limit = '$MEMORY_LIMIT'/g' PHP_INI_FILE

###> Disabling dangerous functions
sed -i 's/^disable_functions =\(\w*\)/disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source/g' PHP_INI_FILE

###> PHP Base dir
sed -i 's/^;open_basedir =\(\w*\)/open_basedir = '$BASE_DIR'/g' PHP_INI_FILE

# Start services
invoke-rc.d apache2 restart
