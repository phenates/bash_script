#!/usr/bin/env bash
#
# Phenates; v0.1
# LAMP stack installation script

#Variables:
PURPOSE="LAMP stack installation script"
NOCOLOR='\033[0m'
BLUE='\033[0;34m'
RED='\033[0;31m'
APACHE_PACKAGES="apache2 libapache2-mod-php"
PHP_PACKAGES="php php-common php-cli php-mysql php-xml php-xmlrpc php-curl php-json php-gd php-imagick php-dev php-imap php-mbstring php-opcache php-soap php-zip php-intl"
MYSQL_PACKAGES=""
MARIADB_PACKAGES="mariadb-server"

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
}

#######################################
# Header start & end script.
# Arguments: "start" or "end"
# Outputs: None
#######################################
header() {
  case $1 in
  "start")
    echo -e "\n\n//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "////////// $(basename "$0") started... \\\\\\\\\\"
    ;;
  "end")
    echo -e "\n\\\\\\\\\\ $(basename "$0") finished... //////////"
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////\n\n"
    ;;
  esac
}

#######################################
# Packages update & upgrade
# Arguments: None
# Outputs: None
#######################################
package_upgrade() {
  echo -e "\n>>> Packages Update & Upgrade"
  sudo apt update && sudo apt upgrade -y
  return 0
}

#######################################
# Apache install
# Arguments: None
# Outputs: None
#######################################
apache_install() {
  echo -e "\n>>> Apache2 installation."
  echo -e "--> Installed packages: $APACHE_PACKAGES"
  read -r -p "--> Continue ? [y/n]"
  case $REPLY in
  [yY]) ;;
  [nN])
    echo -e "--> Action canceled"
    return 1
    ;;
  esac
  # shellcheck disable=SC2086
  sudo apt install -y $APACHE_PACKAGES
  echo -e "\n--> Enable Apache2"
  sudo systemctl enable apache2
  # sudo a2enmod rewrite
  echo -e "\n--> Restart Apache2"
  sudo systemctl restart apache2
  echo -e "\n--> Status Apache2"
  sudo systemctl status apache2
  return 0
}

#######################################
# PHP install
# Arguments: None
# Outputs: None
#######################################
php_install() {
  echo -e "\n>>> PHP installation."
  echo -e "--> Installed packages: $PHP_PACKAGES"
  read -r -p "--> Continue ? [y/n]"
  case $REPLY in
  [yY]) ;;
  [nN])
    echo -e "--> Action canceled"
    return 1
    ;;
  esac
  # shellcheck disable=SC2086
  sudo apt install -y $PHP_PACKAGES
  echo -e "\n--> Version PHP"
  sudo php --version
  return 0
}

#######################################
# LAMP remove
# Arguments: None
# Outputs: None
#######################################
lamp_uninstall() {
  echo -e "\n>>> LAMP Uninstallation."
  echo -e "--> Packages: $APACHE_PACKAGES $PHP_PACKAGES, will be removed."
  read -p "--> Continue ? [y/n]"
  case $REPLY in
  [yY]) ;;
  [nN])
    echo -e "--> Action canceled"
    return 1
    ;;
  esac
  sudo apt remove -y $APACHE_PACKAGES $PHP_PACKAGES
  sudo apt autoremove
  return 0
}

#######################################
# Main function.
# Arguments: None
# Outputs: None
#######################################
main() {
  case "$1" in
  -i | --install)
    header "start"
    package_upgrade
    apache_install
    php_install
    header "end"
    ;;

  -r | --remove)
    header "start"
    lamp_uninstall
    header "end"
    ;;

  -h | --help)
    usage
    ;;

  *)
    usage
    ;;
  esac
}
main "$*"
