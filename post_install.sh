#!/usr/bin/env bash
#
# Phenates; v0.2
# Postinstall script, configure bashrc file for user and root, install package.
# Copy and unzip bash_script directory from github (wget https://github.com/phenates/bash_script/archive/refs/heads/master.zip)

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
# Header start & end script.
# Arguments: "start" or "end"
# Outputs: None
#######################################
header() {
  case $1 in
  "start")
    echo ""
    echo ""
    echo "//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo "////////// $(basename "$0") started... \\\\\\\\\\"
    ;;
  "end")
    echo "\\\\\\\\\\ $(basename "$0") finished... //////////"
    echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////"
    echo ""
    echo ""
    ;;
  esac
}

#######################################
# Check if sudo.
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
# User prompt configuration, in .bashrc file.
# Arguments: None
# Outputs: None
#######################################
user_bashrc_conf() {
  read -r -p ">>> Configuration of $USER .bashrc -> Continue [y]/[n] ?"
  case $REPLY in
  [yY]) ;;
  [nN])
    echo "--> Action canceled"
    return 1
    ;;
  *)
    echo "--> Please answer y or n."
    return 1
    ;;
  esac

  # Test .bashrc or .bashrc.bak file exist
  if [[ ! -f "$HOME_BASHRC" || -f "$HOME_BASHRC.bk" ]]; then
    echo "--> No $BASHRC or existing backup found in $HOME."
    return 1
  fi

  # Backup previous .bashrc file
  echo "--> Backup previous $BASHRC to $HOME_BASHRC.bak."
  cp "$HOME_BASHRC" "$HOME_BASHRC.bak"

  # Update .bashrc file
  echo "--> Updating current $BASHRC."
  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' "$HOME_BASHRC"
  {
    echo ""
    echo ""
    echo "# Custom part.:"
    echo "export PATH=$HOME/bash_script:$PATH"
    #echo "set completion-ignore-case on"
    echo "bind -s 'set completion-ignore-case on'"
    # shellcheck disable=SC2028
    echo 'PS1="\[\e[0;32m\]\u@\h\[\e[0;m\]:\[\e[1;35m\]\w\[\e[0;m\] \[\e[1;32m\] \$\[\e[0;m\] "'
    echo "alias ..='cd ..'"
    echo "alias ll='ls -lah'"
    echo "alias sys='systemctl'"
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
  read -r -p ">>> Packages instalation -> Continue [y]/[n] ?"
  case $REPLY in
  [yY]) ;;
  [nN])
    echo "--> Packages instalation canceled"
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
# Uninstall script, remove packages & .bashrc modification.
# Arguments: None
# Outputs: None
#######################################
remove() {
  if [[ -f "$HOME_BASHRC.bak" ]]; then
    echo "--> $BASHRC restored"
    cp -vf "$HOME_BASHRC.bak" "$HOME_BASHRC"
    echo ""
    echo "--> $HOME_BASHRC.bak deleted"
    rm "$HOME_BASHRC.bak"
    echo ""
  else
    echo "--> No $HOME_BASHRC.bak file found, $BASHRC restoration canceled"
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
    header " Install start"
    sudo_ceck
    user_bashrc_conf
    package_inst
    header "end"
    ;;
  -r | --remove)
    header "Remove start"
    remove
    header "end"
    ;;
  *)
    usage
    ;;
  esac
}
main "$*"
