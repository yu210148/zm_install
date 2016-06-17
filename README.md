# zm_install
A simple bash script to install and configure ZoneMinder
on Ubuntu Server 16.04.
Based on 
https://wiki.zoneminder.com/Ubuntu_Server_16.04_64-bit_with_Zoneminder_1.29.0_the_easy_way#Install_Zoneminder

Usage:
Install Ubuntu 16.04 then run ./zm_install.sh and follow the prompts
to set a DB password. Then enter the same db password to configure
the ZM database when prompted. Once done point a browser to 
http://<address or hostname of server>/zm to add your cameras.

--
kev.