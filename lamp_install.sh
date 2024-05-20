#!/usr/bin/env bash

#######################################
# Script name : lamp_install.sh
# Description : Install a LAMP stack.
# Args        : option -i; -u; -h
# Author      : Phenates
# Date        : 2024-04
# Version     : 0.1
#######################################

#######################################
# Variables:
#######################################
# Config:
PURPOSE="LAMP stack installation script"
APACHE_PACKAGES="apache2 libapache2-mod-php"
PHP_PACKAGES="php php-common php-cli php-mysql php-xml php-xmlrpc php-curl php-json php-gd php-imagick php-dev php-imap php-mbstring php-opcache php-soap php-zip php-intl"
MYSQL_REPOSITOTY="https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb"
MYSQL_PACKAGE="mysql-server"
MARIADB_PACKAGES="mariadb-server"

# Text format
RESET="\e[0m"
NOCOLOR='\033[0m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN="\033[32;40m"
WHITE_ON_BLUE="\e[104;37m"

#######################################
# Show script usage.
# Arguments: Options (h,i,r)
# Outputs: None
#######################################
usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Purpose: $PURPOSE"
  echo "Options:"
  echo "  -h, --help: Display usage"
  echo "  -i, --install: Script installation"
  echo "  -u, --uninstall: Script uninstallation"
}

#######################################
# Print info
# Arguments: string
#######################################
info() {
  echo -e "${BLUE}$1 ${RESET}"
}

#######################################
# Packages update & upgrade
# Arguments: None
# Outputs: None
#######################################
package_upgrade() {
  info "\n>>> Packages Update & Upgrade"
  sudo apt update && sudo apt upgrade -y
  return 0
}

#######################################
# Apache install
# Arguments: None
# Outputs: None
#######################################
apache_install() {
  info "\n>>> Apache2 installation."
  info "--> Installed packages: $APACHE_PACKAGES"
  info "--> Continue ? [y/n] "
  read -r
  case $REPLY in
  [yY])
    # shellcheck disable=SC2086
    sudo apt install $APACHE_PACKAGES
    info "\n--> Enable Apache2"
    sudo systemctl enable apache2
    # sudo a2enmod rewrite
    info "\n--> Restart Apache2"
    sudo systemctl restart apache2
    info "\n--> Status Apache2"
    sudo systemctl status apache2
    ;;
  [nN])
    info "--> Aborded"
    return 1
    ;;
  esac
  return 0
}

#######################################
# PHP install
# Arguments: None
# Outputs: None
#######################################
php_install() {
  info "\n>>> PHP installation."
  info "--> Installed packages: $PHP_PACKAGES"
  info "--> Continue ? [y/n] "
  read -r
  case $REPLY in
  [yY])
    # shellcheck disable=SC2086
    sudo apt install -y $PHP_PACKAGES
    info "\n--> Version PHP"
    sudo php --version
    ;;
  [nN])
    info "--> Aborded"
    return 1
    ;;
  esac
  return 0
}

#######################################
# SQL DB install
# Arguments: None
# Outputs: None
#######################################
sql_install() {
  info "\n>>> SQL Database installation."
  info "--> Choice: MariaDB [1] / MySQL [2] ? "
  read -r
  case $REPLY in
  [1])
    info "--> MaraiDB installation:"
    sudo apt install -y $MARIADB_PACKAGES
    ;;
  [2])
    info "--> MySQL installation:"
    info "--> Download & install MySQL APT repository from $MYSQL_REPOSITOTY"
    wget -O /tmp/mysql-apt-config.deb $MYSQL_REPOSITOTY
    sudo apt install -y /tmp/mysql-apt-config.deb
    sudo apt update -y
    info "\n--> Install $MYSQL_PACKAGE"
    sudo apt install -y $MYSQL_PACKAGE
    info "\n--> MySQL version:"
    mysql -v
    info "\n--> MySQL status:"
    sudo systemctl status mysql
    ;;
  [A])
    info "--> Aborded"
    return 1
    ;;
  esac

  info "\n--> Run mysql_secure_installation ? [y/n] "
  read -r
  case $REPLY in
  [yY])
    sudo mysql_secure_installation
    ;;
  [nN])
    info "--> Aborded"
    return 1
    ;;
  esac

  return 0
}

#######################################
# LAMP remove
# Arguments: None
# Outputs: None
#######################################
lamp_uninstall() {
  info "\n>>> LAMP Uninstallation."
  info "--> Packages: $APACHE_PACKAGES $PHP_PACKAGES $MYSQL_PACKAGE $MARIADB_PACKAGES, will be removed."
  info "--> Continue ? [y/n] "
  read -r
  case $REPLY in
  [yY]) ;;
  [nN])
    info "--> Action canceled"
    return 1
    ;;
  esac
  sudo apt remove -y $APACHE_PACKAGES $PHP_PACKAGES $MYSQL_PACKAGE $MARIADB_PACKAGES
  sudo apt autoremove
  return 0
}

#######################################
# Main function.
# Arguments: None
# Outputs: None
#######################################
main() {
  info "\n\n############################################"
  info "######## $(basename "$0") started ##########"

  case "$1" in
  -i | --install)
    package_upgrade
    apache_install
    php_install
    sql_install
    ;;

  -u | --uninstall)
    lamp_uninstall
    ;;

  -h | --help)
    usage
    ;;

  *)
    usage
    ;;
  esac
  info "\n######## $(basename "$0") finished ##########"
  info "############################################\n\n"
}

main "$*"
