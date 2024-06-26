#!/usr/bin/env bash
#
# Phenates; v0.5
# Postinstall script: packages installation, zsh shell & oh-my-zsh instalation, dotfiles management by chezmoi.
# Run: bash -c "$(wget https://raw.githubusercontent.com/phenates/bash_script/master/post_install.sh)" -i

#Variables:
ME=$(basename "$0")
SCRIPT_DIR="https://github.com/phenates/bash_script/archive/refs/heads/master.zip"
CHEZMOI_GITHUB_URL="https://github.com/phenates/chezmoi.git"
PACKAGES=("exa" "tree" "unzip" "git")

#######################################
# Terminal output helpers
#######################################

# echo_header() outputs a title padded by =, in yellow.
function echo_header() {
  TITLE="$ME > $1"
  NCOLS=$(tput cols)
  NEQUALS=$(((NCOLS - ${#TITLE}) / 2 - 1))
  echo ""
  tput setaf 3 # 3 = yellow
  COUNTER=0
  while [ $COUNTER -lt "$NEQUALS" ]; do
    printf '/'
    ((COUNTER = COUNTER + 1))
  done
  printf " %s " "$TITLE"
  COUNTER=0
  while [ $COUNTER -lt "$NEQUALS" ]; do
    printf '\'
    ((COUNTER = COUNTER + 1))
  done

  tput sgr0 # reset terminal
  echo
}

# echo_step() outputs a step collored in cyan, with newline.
function echo_step() {
  tput setaf 6 # 6 = cyan
  echo ""
  echo "$1"
  tput sgr0 # reset terminal
}

# echo_step_info() outputs additional step info in cyan, with newline.
function echo_step_info() {
  tput setaf 6 # 6 = cyan
  echo ""
  echo "--> $1"
  tput sgr0 # reset terminal
}

# echo_step_info() outputs additional step info in cyan, with newline.
function echo_ask() {
  tput setaf 6 # 6 = cyan
  read -r -p "> $1 "
  tput sgr0 # reset terminal
}

function echo_failure() {
  local txt="${1:-}"
  tput setaf 1 # 1 = red
  echo -e " [ FAILED ] $txt"
  tput sgr0 # reset terminal
}

# shellcheck disable=SC2120
function echo_success() {
  local txt="${1:-}"
  tput setaf 2 # 2 = green
  echo " [ OK ] $txt"
  tput sgr0 # reset terminal
}

function echo_canceled() {
  local txt="${1:-}"
  tput setaf 3 # 3 = yellow
  echo -e " [ CANCELED ] $txt"
  tput sgr0 # reset terminal
}

#######################################
# Show script usage.
# Arguments: Options
#######################################
usage() {
  echo "post_install.sh usage: $ME [OPTIONS]"
  echo "Options:"
  echo "  --install: Install personal configuration"
  echo "  --remove: Remove personal configuration"
  echo "  --help: Display usage"
}

#######################################
# Check if sudo.
#######################################
sudo_check() {
  echo_step "Checking sudo privileges"
  # shellcheck disable=SC2034
  # shellcheck disable=SC2155
  local temp
  temp=$(sudo -nv 2>&1)
  if [ $? != 0 ]; then
    echo_failure "$ME should be run with sudo privileges.\n As root, install sudo package and/or add $USER user in the sudo group (command: sudo adduser <username> sudo)"
    exit 1
  fi
  echo_success
}

#######################################
# Check if root or exit
#######################################
root_check() {
  echo_step "Checking root privileges"
  if [[ $(id -u) != 0 ]]; then
    echo_failure "$ME should be run as root"
    exit 1
  fi
  echo_success
}

#######################################
# Packages installation from $PACKAGES.
#######################################
package_inst() {
  echo_step "Packages instalation:"
  echo_ask "Continue [y]/[n] ?"
  case $REPLY in
  [yY])
    echo_step_info "Package update"
    sudo apt update -y
    echo_step_info "Package upgrade"
    sudo apt update -y
    echo_step_info "Package installation"
    for i in "${PACKAGES[@]}"; do
      echo_step_info "$i install"
      sudo apt install "$i" -y
      echo_success
    done
    ;;
  [nN])
    echo_canceled "by user"
    return 1
    ;;
  *)
    echo_failure "Please answer yes or no."
    return 1
    ;;
  esac
}

#######################################
# zsh shell and ohmyzsh installation.
#######################################
zsh_inst() {
  echo_step "Zsh shell & oh-my-zsh plugin installation:"
  echo_ask "Continue [y]/[n] ?"
  case $REPLY in
  [yY])
    if [[ ! $(zsh --version) ]]; then
      echo_step_info "zsh package"
      sudo apt install zsh fonts-powerline
      echo_success
    else
      echo_step_info "zsh already installed"
      echo_success
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
      echo_step_info "Install oh-my-zsh"
      sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      echo_success
    else
      echo_step_info "ohmyzsh already installed"
    fi

    echo_ask "Change your default shell to zsh? [Y/n]"
    if [[ $REPLY == [yY] ]]; then
      chsh -s $(which zsh)
    fi
    echo_success
    ;;
  [nN])
    echo_canceled "by user"
    return 1
    ;;
  *)
    echo_failure "Please answer yes or no."
    return 1
    ;;
  esac
}

#######################################
# Dotfiles management with chezmoi package.
#######################################
dotfiles_inst() {
  echo_step "Dotfiles management with chezmoi package:"
  echo_ask "Continue [y]/[n] ?"
  case $REPLY in
  [yY])
    if [[ $(apt-cache show chezmoi) != 0 ]]; then
      echo_step_info "Install chezmoi package"
      sh -c "$(wget -qO- get.chezmoi.io)"
      echo_success
    else
      echo_step_info "chezmoi already installed"
    fi
    echo_step_info "chezmoi init and apply dotfiles configurations"
    chezmoi init --apply ${CHEZMOI_GITHUB_URL}
    echo_success
    ;;
  [nN])
    echo_canceled "by user"
    return 1
    ;;
  *)
    echo_failure "Please answer yes or no."
    return 1
    ;;
  esac
}

#######################################
# User prompt .bashrc file configuration
#######################################
# user_bashrc_conf() {
#   echo_step "Configuration of $USER .bashrc file:"
#   echo_ask "Continue [y]/[n] ?"
#   case $REPLY in
#   [yY])
#     # Test .bashrc or .bashrc.bak file exist
#     if [[ ! -f "$HOME/.bashrc" || -f "$HOME/.bashrc.bak" ]]; then
#       echo_failure "No .bashrc or existing .bashrc.bak file backup found in $HOME."
#       return 1
#     fi

#     # Backup previous .bashrc file
#     echo_step_info "Backup previous .bashrc file to $HOME/.bashrc.bak"
#     cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
#     echo_success

#     # Update .bashrc file
#     echo_step_info "Updating current .bashrc file"
#     sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' "$HOME/.bashrc"
#     {
#       echo ""
#       echo ""
#       echo "# Custom part.:"
#       echo "export PATH='$HOME/bash_script:$PATH'"
#       echo "bind -s 'set completion-ignore-case on'"
#       # shellcheck disable=SC2028
#       echo 'PS1="\[\e[38;5;34m\]\u\[\e[38;5;244m\]@\[\e[38;5;214m\]\h \[\e[38;5;129m\]\w \[\033[0m\]$ "'
#       echo "alias ..='cd ..'"
#       echo "alias ll='ls -lah'"
#       echo "alias sys='systemctl'"
#     } >>"$HOME/.bashrc"
#     echo_success "!!! To update prompt, use command: 'source .bashrc' or reconnect user"
#     ;;
#   [nN])
#     echo_canceled "by user"
#     return 1
#     ;;
#   *)
#     echo_failure "Please answer y or n."
#     return 1
#     ;;
#   esac
# }

#######################################
# User .nanorc file configuration
#######################################
# user_nano_conf() {
#   echo_step "Configuration of .nanorc file for $USER:"
#   echo_ask "Continue [y]/[n] ?"
#   case $REPLY in
#   [yY])
#     # Test .nanorc or .nanorc.bak file exist
#     if [[ -f "$HOME/.nanorc" ]]; then
#       echo_failure ".nanorc file already existing."
#       return 1
#     fi

#     # Create .nanorc file based on /etc/nanorc
#     echo_step_info "Create $HOME/.nanorc based on /etc/nanorc"
#     cp /etc/nanorc "$HOME/.nanorc"
#     echo_success

#     # Update .bashrc file
#     echo_step_info "Updating $HOME/.nanorc file"
#     sed -i 's/# set autoindent/set autoindent/g' "$HOME/.nanorc"
#     sed -i 's/# set indicator/set indicator/g' "$HOME/.nanorc"
#     sed -i 's/# set positionlog/set positionlog/g' "$HOME/.nanorc"
#     {
#       echo include "/usr/share/nano/*.nanorc"
#     } >>"$HOME/.nanorc"
#     echo_success
#     ;;
#   [nN])
#     echo_canceled "by user"
#     return 1
#     ;;
#   *)
#     echo_failure "Please answer y or n."
#     return 1
#     ;;
#   esac
# }

#######################################
# Import & copy some script.
#######################################
script_import() {
  echo_step "Script import"
  echo_ask "Continue [y]/[n] ?"
  case $REPLY in
  [yY])
    # Test bash_script directory
    if [[ -d "$HOME/bash_script" ]]; then
      echo_failure "bash_script directory already existing."
      return 1
    fi

    # import & copy bash_script directory
    wget $SCRIPT_DIR -P /tmp
    unzip /tmp/master.zip -d /tmp
    cp -r /tmp/bash_script-master /$HOME/bash_script
    rm -r /tmp/master.zip /tmp/bash_script-master
    echo_success

    ;;
  [nN])
    echo_canceled "by user"
    return 1
    ;;
  *)
    echo_failure "Please answer y or n."
    return 1
    ;;
  esac
}

#######################################
# Uninstall script, remove packages & .bashrc modification.
#######################################
# remove() {
#   echo_step "Restore .bashrc file"
#   if [[ -f "$HOME/.bashrc.bak" ]]; then
#     cp -vf "$HOME/.bashrc.bak" "$HOME/.bashrc"
#     rm "$HOME/.bashrc.bak"
#     echo_success
#   else
#     echo_failure "No $HOME/.bashrc.bak file found, .bashrc restoration canceled"
#   fi

#   if [[ -f "$HOME/.nanorc" ]]; then
#     echo_step "Restore nano configuration"
#     rm "$HOME/.nanorc"
#     echo_success
#   fi

#   for i in "${PACKAGES[@]}"; do
#     echo_step_info "Uninstall $i package"
#     sudo apt remove "$i" -y
#     echo_success
#   done

#   if [[ -d "$HOME/bash_script" ]]; then
#     echo_step "Delete $HOME/bash_script directory"
#     rm -r "$HOME/bash_script"
#     echo_success
#   fi

# }

#######################################
# Main function
#######################################
main() {
  echo_header $1
  case "$1" in
  -h | --help)
    usage
    ;;
  -i | --install)
    sudo_check
    package_inst
    zsh_inst
    dotfiles_inst
    echo_step "Log out and log back in again to use your new default shell..."
    ;;
  -r | --remove)
    remove
    ;;
  -t) ;;
  *)
    usage
    ;;
  esac
  echo_header "END"
}
main "$*"
