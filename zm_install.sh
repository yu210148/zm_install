#!/bin/bash
# A helper script to install and configure ZoneMinder.
# Based on the instructions at:
# https://wiki.zoneminder.com/Ubuntu_Server_16.04_64-bit_with_Zoneminder_1.29.0_the_easy_way
# Copyright 2016
# Kevin Lucas - yu210148@gmail.com
# This script is licenced under the GPLv3 or later.

# Usage: run 'sudo zm_install.sh'

# make sure we're up to date
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

# adjust swap file usage
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl vm.swappiness=10

# install zm and deps.
apt-get -y install mysql-server mysqltuner zoneminder php-gd

# config msyql
rm /etc/mysql/my.cnf
ln -s /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf

# edit mysql config
sed 's/skip-external-locking/skip-external-locking\nsql_mode = NO_ENGINE_SUBSTITUTION/g' /etc/mysql/mysql.conf.d/mysqld.cnf > ~/2mysqld.cnf
cp ~/2mysqld.cnf /etc/mysql/mysql.conf.d/2mysqld.cnf
cp /etc/mysql/mysql.conf.d/2mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
rm -rf ~/2mysqld.cnf

# create zm database
mysql -uroot -p < /usr/share/zoneminder/db/zm_create.sql
mysql -uroot -p -e "grant all on zm.* to 'zmuser'@localhost identified by 'zmpass';"
mysqladmin -uroot -p reload

# set permissions
chmod 740 /etc/zm/zm.conf
chown root:www-data /etc/zm/zm.conf

# create user
adduser www-data video

# Enable CGI, Zoneminder and rewrite configuration in Apache.
a2enmod cgi
a2enconf zoneminder
a2enmod rewrite

# fix permissions
chown -R www-data:www-data /usr/share/zoneminder/

# Fix to allow API to work
sed 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf > ~/2apache2.conf
sed '0,/AllowOverride All/s//AllowOverride None/' ~/2apache2.conf > 3apache2.conf
cp ~/3apache2.conf /etc/apache2/apache2.conf
rm -rf ~/2apache2.conf
rm -rf ~/3apache2.conf

# restart apache and mysql after changes
service apache2 stop
service mysql stop
service mysql start
service apache2 start

# Enable and start Zoneminder
systemctl enable zoneminder
service zoneminder start

# Add timezone to PHP
sed 's/date.timezone =/date.timezone =\ndate.timezone = America\/Los_Angeles/g' /etc/php/7.0/apache2/php.ini > ~/2php.ini
cp ~/2php.ini /etc/php/7.0/apache2/php.ini
rm -rf ~/2php.ini

# reload apache
service apache2 reload

# done
echo 'Done! point a browser to http://localhost/zm'
