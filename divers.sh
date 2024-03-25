# config-post-install 10/03/2015 by Fanfan Lefou
# Do upgrade/install many packages, create new sudo user, configure many option

#!/bin/bash

# var statement

# v_packages_install="raspi-config unzip nano sudo git-core etherwake ca-certificates binutils whois fail2ban perl-modules curl manpages-fr manpages-fr-extra"

v_packages_install="raspi-config unzip nano sudo git-core etherwake ca-certificates binutils fail2ban curl"

v_newuser_groups="sudo,adm,dialout,cdrom,audio,video,plugdev,games,users"

# function statement

# validation by enter key
function f_valid_enter() {
	read -s -n 1 -p "!!! To continue press [ENTER]" key # -s: do not echo input character. -n 1: read only 1 character (separate with space)
	if [[ $key != "" ]]; then
		echo "!!! You pressed [$key], press [ENTER] for continuation or [ctrl + c] for living script"
		f_valid_enter
	fi
}

# validation by Y or n key
function f_valid_yn() {
	read -p "!!! To continue press [y] or [n] to skip this step: " key # -s: do not echo input character. -n 1: read only 1 character (separate with space)
	if [[ "$key" == "y" ]]; then
		echo
		$1
	elif [[ "$key" == "n" ]]; then
		echo
	else
		echo "!!! You pressed [$key]"
		f_valid_yn $1
	fi
}

# information display
function f_display() {
	if [[ "$2" == "1" ]]; then
		echo
		echo
		echo "*************************************************************"
		echo "*************************************************************"
		echo "--->>	$1	<<---"
		echo
	elif [[ "$2" == "2" ]]; then
		echo
		echo "-------------------------------------------------------------"
		echo "--->	$1	<---"
		echo
	fi
}

# script duration calcul
function f_diff_time() {
	v_t_stop=$(date +%s)
	v_diff_sec=$(($v_t_stop - $v_t_start))
	v_diff_min=$(($v_diff_sec / 60))
	# f_display "Durée du script: " $diff "sec (~"$(( $diff / 60 )) "min)" 2
	echo
}

# packages update
function f_maj_packages() {
	# mise a jour des paquets
	# echo "*** Mise a jour des paquets ***"
	# echo
	f_display "apt-get update" 2
	apt-get update
	f_display "apt-get upgrade" 2
	apt-get -y upgrade
	f_display "apt-get dist-upgrade" 2
	apt-get -y dist-upgrade
	echo
}

# install packages
function f_install_packages() {
	# installation des paquets apt
	# echo "*** Installation des nouveaux paquets: ***"
	f_display "Packages list: $v_packages_install" 2
	apt-get install -y $v_packages_install
	echo

	# install rpi-update
	f_display "Firmware and Kernell update with rpi-update" 2
	wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update
	cp rpi-update /usr/local/bin/rpi-update
	chmod +x /usr/local/bin/rpi-update
	# f_display "rpi-update" 2
	rpi-update
	f_maj_packages
	echo
}

# new user created
function f_newuser() {
	# New user creation
	# echo "*** Création nouveau utilisateur ***"
	echo
	read -p "---> Entrer le nom d'utilisateur (identifiant): " v_user
	read -p "---> Entrer le mot de passe utilisateur (password): " v_mdp1
	read -p "---> Confirmer le mot de passe utilisateur (password): " v_mdp2
	if [[ "$v_mdp1" == "$v_mdp2" ]]; then
		useradd -m --groups $v_newuser_groups --shell /bin/bash --password $(mkpasswd $v_mdp1) $v_user
		f_display "Nouvel utilisateur créer" 2
		mkdir /home/$v_user/bin
		f_display "Repertoire: /home/$v_user/bin crée, vous pouvez transférer vos script personels, puis taper [ENTER]" 2 &
		f_valid_enter

	else
		f_display "!!! Attention: Mots de passe different, recommencez" 2
		echo
		f_newuser
	fi

	# gestion des droit root: fanfan ALL=(ALL) NOPASSWD: ALL
	echo
}

# hostname change
function f_hostname() {
	# new hostname
	# echo "*** Changement du hostname ***"
	echo
	f_display "Hostname actuel: $(hostname)" 2
	read -p "---> Entrer le nouveau hostname: " newHost
	old=$(hostname)
	for file in \
		/etc/hostname \
		/etc/hosts; do
		[ -f $file ] && sed -i.old -e "s:$old:$newHost:g" $file
	done
	echo
}

# ssh configuration sshd_config file
function f_ssh_config() {
	# sed -i -e "s/chaines1/chaine2/g" fichier # -i: modifie directement le fichier, .bak: avec sauvegarde; -e: command,  s: substitution, g: global ds le fichier;

	# port ssh
	read -p "---> Choice Port number: " key
	v_ssh_port_new="Port $key"
	v_ssh_port_old="Port 22"

	# Permit Root Login
	read -p "---> Permit Root Login [yes/no]: " key
	v_ssh_rootlogin_new="PermitRootLogin $key"
	v_ssh_rootlogin_old="PermitRootLogin yes"

	# AllowUsers list
	v_allowusers="AllowUsers $v_user"

	sed -i.bak -e "s/$v_ssh_port_old/$v_ssh_port_new/g" -e "s/$v_ssh_rootlogin_old/$v_ssh_rootlogin_new/g" -e "5a$v_allowusers" /etc/ssh/sshd_config

	f_display "sshd_config file modified" 2
}

function f_rebbot() {
	reboot
}

# main block
echo
echo
echo '//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
echo '//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
echo '//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
echo "*************   config-post-install - Start  ***************"
echo "*************  $(date)  ***************"
echo '//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
echo '//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
echo
echo

v_t_start=$(date +%s)

# Mise a jour des paquets
f_display "Mise a jour des paquets" 1
f_valid_yn f_maj_packages

# Installation des nouveaux paquets
f_display "Installation des nouveaux paquets" 1
f_valid_yn f_install_packages

# Création nouveau utilisateur
f_display "Création nouveau utilisateur" 1
f_valid_yn f_newuser

# Changement du hostname
f_display "Changement du hostname" 1
f_valid_yn f_hostname

# ssh configuration
f_display "ssh configuration" 1
f_valid_yn f_ssh_config

# fail2ban configuration
# ???

# Mise a jour des paquets
# f_display "Mise a jour des paquets" 1
# f_valid_yn f_maj_packages

# desactivation de root user ???

f_diff_time

echo
echo
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////'
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////'
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////'
echo "*************   config-post-install - Finish ***************"
echo "*************   Duration: $v_diff_sec sec (~$v_diff_min min) *************"
f_display "!!!	WARNING:
			The system will be rebooted
			Just the new user: $v_user can log after the reboot
			The 'root' identifiant will be desactivated
			SSH connection will be accepted just for the new user $v_user, on port v_ssh_port_new
			After rebbot use 'raspi-cnfig' command for some settings: overload, langange, etc...
	!!!" 2
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////'
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////'
echo
f_valid_yn f_rebbot

exit 0
