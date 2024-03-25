# LAMP installation script
# 13/02/2024 - SP

#!/bin/bash

echo -e "\n\n-->> LAMP Stack Installation started <<--"

# Update & upgrade apt package
echo -e "\n--> Updating and Upgrading Apt packages"
apt update -y && apt upgrade -y

# Installation, auto-run, module for Apache2 web server
echo -e "\n--> Installing Apache2 web server"
apt install -y apache2
systemclt enable apache2
a2enmod rewrite
systemclt restart apache2

# Installation PHP & Requirements
echo -e "\n--> Installing PHP & Requirements"
apt install php libapache2-mod-php

# Installation PHP Requirements for GLPI
echo -e "\n--> Installing PHP Requirements for GLPI"
apt install php-xml php-common php-json php-mysql php-mbstring php-curl php-gd php-intl php-zip php-bz2 php-imap php-apcu

# Installation & config of MariaDB
echo -e "\n--> Installing MariaDB"
apt install mariadb-server
mysql_secure_installation

echo -e "\n-->> LAMP Installation completed <<--\n\n"
exit 0
