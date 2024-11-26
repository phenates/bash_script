#!/usr/bin/env bash
set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Usage display:
#/ Usage: ./AutoMountSettup OPTION
#/ Description: Setting up a shared folder auto-mount for a defined user group during logon.
#/ Examples:
#/ Options:
#/   --install: Install the auto-mount shared folder
#/   --remove: Remove the auto-mount shared folder
#/   --help: Display this help message
#
# phenates  v0.1: Initial version
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}
expr "$*" : ".*--help" >/dev/null && usage

## Variables:
SCRIPT_NAME=$(basename "$0")
MODE=${1:-"--help"}

SudoersFilePath="/etc/sudoers.d/BarziniSudoers"
MountScript="/etc/profile.d/BarziniPartageMount.sh"
MountPoint="/media/Barzini-Partage"
DomainUserGroupID=355000513

## Log (add "| tee -a "$LOG_FILE" >&2" into fct to log in a file):
readonly LOG_FILE="/tmp/$(basename "$0").log"
info() { echo -e "\033[0;36m[INFO]    $*"; }
warning() { echo -e "\033[1;33m[WARNING] $*"; }
error() { echo -e "\033[0;31m[ERROR]   $*"; }

## Main
case "$MODE" in
--install)
  # Install packages:
  sudo apt install -y cifs-utils keyutils krb5-user >/dev/null
  info "Packages installed"

  # Create sudoers file for giving mount & umount rights to users group:
  if [ ! -f $SudoersFilePath ]; then
    echo '"%utilisateurs du domaine@barzini.com" ALL=NOPASSWD: /bin/mount, /bin/umount, /sbin/mount.cifs' | sudo tee -a /etc/sudoers.d/BarziniSudoers >/dev/null
    info "Sudoers file for group: $SudoersFilePath created"
  fi

  # Create mount pointfolder:
  if [ ! -d $MountPoint ]; then
    sudo mkdir /media/Barzini-Partage
    info "Mounting point: $MountPoint created"
  fi

  # Add script to profile.d:
  if [ ! -f $MountScript ]; then
    cat <<'EOF' | sudo tee -a /etc/profile.d/BarziniPartageMount.sh >/dev/null
if [ "$(id -g)" -eq 371800513 ]
then
  sudo mount.cifs //svr-ad-01/partage /media/Barzini-Partage/ -o sec=krb5,username=$USER,uid=$(id -u),gid=$(id -g),dir_mode=0770,file_mode=0770,iocharset=utf8
fi
EOF
    info "Mounting script: $MountScript created"

    # Mount script execution right
    sudo chmod +x /etc/profile.d/BarziniPartageMount.sh
  fi
  ;;

--remove)
  # Remove sudoers file:
  if [ -f $SudoersFilePath ]; then
    sudo rm /etc/sudoers.d/BarziniSudoers
    info " sudoers file for group: $SudoersFilePath" removed
  fi

  # Create mount pointfolder:
  if [ -d $MountPoint ]; then
    sudo rm -r /media/Barzini-Partage
    info "Create mounting point: $MountPoint"
  fi

  # Add script to profile.d:
  if [ -f $MountScript ]; then
    sudo rm /etc/profile.d/BarziniPartageMount.sh
    info "Mounting script: $MountScript removed"

  fi
  ;;

*)
  usage
  ;;
esac
