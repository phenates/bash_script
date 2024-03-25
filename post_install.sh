#!/usr/bin/env bash
#
# Phenates; v0.1
# Postinstall script, configure bashrc file, install package.

#Variables:
BASHRC=".bashrc"
HOME_BASHRC="$HOME/$BASHRC"
PACKAGES=("tree" "unzip")

#######################################
# Show script usage.
# Arguments: Options (h,i,r)
# Outputs: None
#######################################
usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Options:"
  echo "  -i, --install: Install personal configuration"
  echo "  -r, --remove: Remove personal configuration"
  echo "  -h, --help: Display usage"
}

#######################################
# Check if sudo is used.
# Arguments: None
# Outputs: None
#######################################
sudo_ceck() {
  local temp
  temp=$(sudo -v 2>&1)
  if [ $? != 0 ]; then
    echo "User must be in the sudo group..."
    echo "As root, install sudo package and/or add $USERNAME user in the sudo group:"
    echo "[sudo adduser <username> sudo]"
    exit
  fi
}

#######################################
# Prompt configuration, in .bashrc file.
# Arguments: None
# Outputs: None
#######################################
bashrc_conf() {
  ASKING="Configuration of .bashrc"
  read -r -p ">>> $ASKING -> Continue [y]/[n] ?" yn
  case $yn in
  [yY]) ;;
  [nN])
    echo "--> $ASKING canceled"
    return 1
    ;;
  *)
    echo "Please answer yes or no."
    return 1
    ;;
  esac

  # Backup previous .bashrc file
  if [[ -f "$HOME_BASHRC" && ! -f "$HOME_BASHRC.bk" ]]; then
    echo "--> Backup previous $BASHRC."
    cp -v "   $HOME_BASHRC" "$HOME_BASHRC.bk"
  else
    echo "--> No $BASHRC or existing backup found in $HOME."
  fi

  # Update .bashrc file
  echo "--> Updating current $BASHRC."
  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' $BASHRC
  {
    echo ""
    echo ""
    echo "# Custom part.:"
    # shellcheck disable=SC2028
    echo 'PS1="\[\e[0;32m\]\u@\h\[\e[0;m\]:\[\e[1;35m\]\w\[\e[0;m\] \[\e[1;32m\] \$\[\e[0;m\] "'
    echo "alias ll='ls -lah'"
    echo "alias ..='cd ..'"
  } >>"$HOME_BASHRC"
  echo "!!! To update prompt, use 'source $BASHRC'"
  echo ""
}

#######################################
# Import & copy some script.
# Arguments: None
# Outputs: None
#######################################
script_install() {
  ASKING="Script utils installation"
  read -r -p ">>> $ASKING -> Continue [y]/[n] ?" yn
  case $yn in
  [yY]) ;;
  [nN])
    echo "--> $ASKING canceled"
    return 1
    ;;
  *)
    echo "Please answer yes or no."
    return 1
    ;;
  esac

}

#######################################
# Packages installation from $PACKAGES.
# Arguments: None
# Outputs: None
#######################################
package_inst() {
  ASKING="Packages instalation"
  read -r -p ">>> $ASKING -> Continue [y]/[n] ?" yn
  case $yn in
  [yY]) ;;
  [nN])
    echo "--> $ASKING canceled"
    return 1
    ;;
  *)
    echo "Please answer yes or no."
    return 1
    ;;
  esac

  echo "--> Package update"
  sudo apt update -y
  echo ""
  echo "--> Package upgrade"
  sudo apt update -y
  echo ""
  for i in "${PACKAGES[@]}"; do
    echo "--> Package $i install"
    sudo apt install "$i" -y
    echo ""
  done
}

#######################################
# Uninstall actions, remove packages & .bashrc modification.
# Arguments: None
# Outputs: None
#######################################
remove() {
  if [[ -f "$HOME_BASHRC.bk" ]]; then
    echo "--> $BASHRC restored"
    cp -vf "$HOME_BASHRC.bk" "$HOME_BASHRC"
    echo ""
    echo "--> $HOME_BASHRC.bk deleted"
    rm "$HOME_BASHRC.bk"
    echo ""
  fi
  for i in "${PACKAGES[@]}"; do
    echo "--> Package $i remove"
    sudo apt remove "$i" -y
    echo ""
  done
}

#######################################
# Main function.
# Arguments: None
# Outputs: None
#######################################
main() {
  case "$1" in
  -h | --help)
    usage
    ;;
  -i | --install)
    echo ""
    echo "---------- $(basename "$0") installation started... ----------"
    sudo_ceck
    bashrc_conf
    package_inst
    echo "---------- $(basename "$0") installation finished... ----------"
    echo ""
    ;;
  -r | --remove)
    echo ""
    echo "---------- $(basename "$0") remove started... ----------"
    remove
    echo "---------- $(basename "$0") remove finished... ----------"
    echo ""
    ;;
  *)
    usage
    ;;
  esac
}
main "$*"
