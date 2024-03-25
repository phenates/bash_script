#!/bin/bash
# 


# function statement

# validation by enter key
function f_valid_enter () {
	read -s -n 1 -p "!!! To continue press [ENTER]" key  # -s: do not echo input character. -n 1: read only 1 character (separate with space)
	if [[ $key = "" ]]
	then
		echo
	else
		echo
		echo "!!! You pressed [$key], press [ENTER] for continuation or [ctrl + c] for living script\a"
		f_valid_enter
	fi
}

# validation by Y or n key
function f_valid_yn () {
	read -p "!!! To continue press [y] or [n] to skip this step: " key  # -s: do not echo input character. -n 1: read only 1 character (separate with space)
	if [[ "$key" == "y" ]]
	then
		echo
		$1
	elif [[ "$key" == "n" ]]
	then
		echo
	else
		echo -e "!!! You pressed [$key]\a"
		f_valid_yn $1
	fi
}

# information display
function f_display () {
	if [[ "$2" == "1" ]]
	then 
		echo
		echo
		echo "*************************************************************"
		echo "*************************************************************"
		echo -e "--->>	$1	<<---\a"
		echo
	elif [[ "$2" == "2" ]]
	then
		echo
		echo "--->"
		echo -e "\t$1"
		echo "<---"
		echo
	fi
}



function f_fail2ban_config () {
	v_path=$(dirname $0)
echo $v_path
	if [[ -f /etc/fail2ban ]]
	then
		if [[ -f v_path/jail.local ]]
		then
			cp v_path/jail.local /etc/fail2ban/jail.local
		else
			f_display "Missing personal configuration file: jail.local" 2
		fi
		
		if [[ -f v_path/iptables-allports.local ]]
		then
			sed -i.bak -e "s:/home/fanfan/bin/pushbullet.sh \"Pibox Message\" \"Fail2ban-<name> a bloqué l'IP <ip>\":/home/$(users)/bin/pushbullet.sh \"Pibox Message\" \"Fail2ban-<name> a bloqué l'IP <ip>\":" v_path/iptables-allports.local
			cp v_path/iptables-allports.local /etc/fail2ban/action.d/iptables-allports.local
		else
			f_display "Missing personal configuration file: iptables-allports.local" 2
		fi
	else
		f_display "Fail2ban is not present in /etc directory" 2
	fi

	# copy jail.conf file in jail.local, the .local overridden the .conf file
	# cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

	# config.local
	# sed -i.bak -e "s:ignoreip = 127.0.0.1/8:ignoreip = 127.0.0.1/8 192.168.0.1/24:" /etc/fail2ban/jail.local
	# sed -i -e "s:bantime  = 600:bantime  = 86400:" /etc/fail2ban/jail.local
	# sed -i -e "/bantime  = 86400/a\findtime = 86400" /etc/fail2ban/jail.local
	# sed -i -e "s:maxretry = 6:maxretry = 3:g" /etc/fail2ban/jail.local
	# sed -i -e "s:port     = ssh:port     = ssh, sftp, $v_ssh_port_new:" /etc/fail2ban/jail.local
	# sed -i -e "/logpath  = \/var\/log\/auth.log/a\		action = iptables-allports[name=ssh]" /etc/fail2ban/jail.local
	
	# iptables-allports.conf
	# sed -i.bak -e "/actionban = iptables -I fail2ban-<name> 1 -s <ip> -j DROP/a\/home\/$v_user\/bin\/pushbullet.sh '$v_hostname_new Message' 'Fail2ban a bloqué une IP en ssh, fail2ban-client status'" /etc/fail2ban/action.d/iptables-allports.conf
}


# fail2ban configuration
f_display "fail2ban configuration" 1
f_valid_yn f_fail2ban_config