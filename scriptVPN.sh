#!/bin/bash
racine=$(pwd)
profileTxt=profile.txt
profileTxtBackup=profile.txt.bak

install_wget(){
	if [ -e /etc/debian_version ]; then
		apt-get install -y wget
	elif [ -e /etc/centos-release ]; then
		yum install -y wget
	elif [ -e /etc/fedora-release ]; then
		yum install -y wget
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora or CentOS system"
		exit 4
	fi
}

install_prog_required(){
	echo  -e "\033[34m-----------------------------\033[0m"
	echo  -e "\033[1;34mINSTALLATION ABOUT REQUIRED\033[0m"
	echo  -e "\033[34m-----------------------------\033[0m"
	apt-get update

	# lib required	
	apt-get install -y net-tools
	apt-get install -y iptables
	apt-get install -y git
	apt-get install -y openssl
	apt-get install -y openvpn

	#install openvpn2.3.10 because we new features with the buffer
	if [ ! -f ./openvpn-2.3.10.zip ]; then
		wget https://swupdate.openvpn.org/community/releases/openvpn-2.3.10.zip
		unzip openvpn-2.3.10.zip -d ./

		# lib required to compile openvpn 
		apt-get install gcc make automake autoconf dh-autoreconf file patch perl dh-make debhelper devscripts gnupg lintian quilt libtool pkg-config libssl-dev liblzo2-dev libpam0g-dev libpkcs11-helper1-dev -y
	
		#compile and install openvpn
		cd openvpn-2.3.10
		autoreconf -vi
		./configure
		make
		make install
	fi	
}



install_prog_required_centos(){
	echo  -e "\033[34m-----------------------------\033[0m"
	echo  -e "\033[1;34mINSTALLATION ABOUT REQUIRED\033[0m"
	echo  -e "\033[34m-----------------------------\033[0m"

	# lib required	
	yum install -y net-tools
	yum install -y iptables-services
	yum install -y git
	yum install -y lzo-devel
	yum install -y unzip
	yum install -y openssl
	yum install -y openvpn

	#install openvpn2.3.10 because we new features with the buffer
	if [ ! -f ./openvpn-2.3.10.zip ]; then
		wget https://swupdate.openvpn.org/community/releases/openvpn-2.3.10.zip
		unzip openvpn-2.3.10.zip -d ./

		# lib required to compile openvpn 
		yum install gcc make automake autoconf file patch perl gnupg quilt libtool rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel -y
	
		#compile and install openvpn
		cd openvpn-2.3.10
		autoreconf -vi
		./configure
		make
		make install
	fi

	
}


initialize_variable(){

	#pre load all variable
	namevpn=MyVPNServer
	bufferOpenvpn=0
	devicevpn=ethernet
	ippublicvpn=$(wget -qO- https://api.ipify.org/);
	portvpn=443
	protovpn=tcp
	cryptvpn=2048
	countryvpn=US
	provincevpn=NY
	cityvpn=New-York
	orgvpn=OpenVPN
	ounvpn=N/A
	commonvpn=MyVPNServer
	mailvpn=mail@example.com


	# erase all the values of variables
	unset namevpn1
	unset devicevpn1
	unset ipvpn1
	unset ippublicvpn1
	unset portvpn1
	unset protovpn1
	unset cryptvpn1
	unset bufferOpenvpn1
	unset countryvpn1
	unset provincevpn1
	unset cityvpn1
	unset orgvpn1
	unset ounvpn1
	unset commonvpn1
	unset mailvpn1
}

ask_info(){
	echo  -e "\033[34m--------\033[0m"
	echo  -e "\033[1;34mREQUIRED!\033[0m"
	echo  -e "\033[34m--------\033[0m"
	echo  " "
	echo  -e "\033[1;34mNAME OF THE VPN ? (default : "$namevpn") \033[0m"
	read  namevpn1
	echo  -e "\033[1;34mNETWORK OF THE VPN => ethernet or wifi ( default : "$devicevpn") \033[0m"
	read  devicevpn1

	#reset the var after the answer
	if [ "$devicevpn1" != "" ]
	then
		devicevpn=$devicevpn1
	fi
	
	# if you want to be in ethernet or wifi
	if [ $devicevpn = "ethernet" ]; then
		networkName=$(ls /sys/class/net | grep eth0)

		# if you use a new version (ubuntu > 14.04) 
		if [ "$networkName" = "" ]; then
			networkName=$(ls /sys/class/net | grep en)
		fi
	elif [ $devicevpn = "wifi" ]; then
		networkName=$(ls /sys/class/net | grep wl)
	else
		networkName=$(ls /sys/class/net | grep eth0)
		if [ "$networkName" = "" ]; then
			networkName=$(ls /sys/class/net | grep en)
		fi
	fi

	# select in function of your distribution
	if [ -e /etc/debian_version ]; then
		ipvpn=$(ifconfig $networkName 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')
		
		#if you are on a old or new version of linux		
		if [ "$ipvpn" = "" ]; then
			ipvpn=$(ifconfig $networkName 2>/dev/null|awk '/inet adr:/ {print $2}'|sed 's/adr://')
		fi
	elif [ -e /etc/centos-release ]; then
		ipvpn=$(ifconfig $networkName 2>/dev/null|awk '/inet / {print $2}')
	elif [ -e /etc/fedora-release ]; then
		ipvpn=$(ifconfig $networkName 2>/dev/null|awk '/inet / {print $2}')
	else
		unset ipvpn
	fi

	echo   -e "\033[1;34mPRIVATE IP ? (default : "$ipvpn") \033[0m"
	read   ipvpn1
	echo   -e "\033[1;34mPUBLIC IP ?(default : "$ippublicvpn") \033[0m"
	read   ippublicvpn1
	echo   -e "\033[1;34mPROTOCOLE OF THE VPN ? ( default : "$protovpn") \033[0m"
	read   protovpn1
	echo   -e "\033[1;34mPORT OF THE VPN ? ( default : "$portvpn") \033[0m"
	read   portvpn1
	echo   -e "\033[1;34mCRYPTAGE VPN IN BITS ( default : "$cryptvpn") \033[0m"
	read   cryptvpn1
	echo   " "
	echo   -e "\033[31m---------------------------------------------------------------------------\033[0m"
	echo   -e "\033[1;31mWARNING. DO NOT CHANGE THE DEFAULT VALUE IF YOU DON'T KNOW WHAT IS THE BUFFER \033[0m"
	echo   -e "\033[31m---------------------------------------------------------------------------\033[0m"
	echo   -e "\033[1;34mBUFFER OPENVPN ( default : "$bufferOpenvpn") \033[0m"
	read   bufferOpenvpn1	
	echo   " "
	echo   -e "\033[34m----------\033[0m"
	echo   -e "\033[1;34mOPTIONAL\033[0m"
	echo   -e "\033[34m----------\033[0m"
	echo   -e  "\033[1;32m IF YOU WANT , YOU CAN FILL IN EMPTY\033[0m"
	echo   -e "\033[1;34m(OPTIONAL) Your country in 2 caracteres ? (Default :"$countryvpn")\033[0m"
	read   countryvpn1 
	echo   -e "\033[1;34m(OPTIONAL) Your province in 2 caracteres ? (Default :"$provincevpn")\033[0m"
	read   provincevpn1
	echo   -e "\033[1;34m(OPTIONAL) Your city ? (Default :"$cityvpn") \033[0m"
	read   cityvpn1
	echo   -e "\033[1;34m(OPTIONAL) Your Organization Name ? (Default :"$orgvpn") \033[0m"
	read   orgvpn1
	echo   -e "\033[1;34m(OPTIONAL) Your organization unit name? (Default :"$ounvpn") \033[0m"
	read   ounvpn1
	echo   -e "\033[1;34m(OPTIONAL) Your common name? (Default :"$commonvpn") \033[0m"
	read   commonvpn1
	echo   -e "\033[1;34m(OPTIONAL) Your email address ? (Default :"$mailvpn") \033[0m"
	read   mailvpn1


	#replace init value with the new value if it's different with the default value
	
	if [ "$namevpn1" != "" ]
	then
		namevpn=$namevpn1
	fi

	if [ "$ipvpn1" !=  "" ]
	then
		ipvpn=$ipvpn1
	fi
	
	if [ "$ippublicvpn1" !=  "" ]
	then
		ippublicvpn=$ippublicvpn1
	fi

	if [ "$protovpn1" !=  "" ]
	then
		protovpn=$protovpn1
	fi
	
	if [ "$portvpn1" != "" ]
	then
		portvpn=$portvpn1
	fi
	
	if [ "$cryptvpn1" != "" ]
	then
		cryptvpn=$cryptvpn1
	fi
	
	if [ "$countryvpn1" != "" ]
	then
		countryvpn=$countryvpn1
	fi
	
	if [ "$provincevpn1" != "" ]
	then
		provincevpn=$provincevpn1
	fi

	if [ "$cityvpn1" != "" ]
	then
		cityvpn=$cityvpn1
	fi
	
	if [ "$orgvpn1" != "" ]
	then
		orgvpn=$orgvpn1
	fi

	if [ "$commonvpn1" != "" ]
	then
		commonvpn=$commonvpn1
	fi

	if [ "$mailvpn1" != "" ]
	then
		mailvpn=$mailvpn1
	fi

	if [ "$bufferOpenvpn1" != "" ]
	then
		bufferOpenvpn=$bufferOpenvpn1
	fi
}



ask_save_profile(){
if [ ! -f $racine/$profileTxt ]
then
ask_info
cat <<EOF > $racine/$profileTxt
$namevpn
$ipvpn
$ippublicvpn
$devicevpn
$protovpn
$portvpn
$cryptvpn
$bufferOpenvpn
$countryvpn
$provincevpn
$cityvpn
$orgvpn
$ounvpn
$commonvpn
$mailvpn
EOF
		echo -e "\033[32m------------------------------\033[0m"
		echo -e "\033[1;32mPROFILE CREATED WITH SUCCESS\033[0m"
		echo -e "\033[32m------------------------------\033[0m"
cp $racine/$profileTxt $racine/$profileTxtBackup
	else
		echo " "
		echo " "
		echo  -e "\033[31m------------------------\033[0m"
		echo  -e "\033[1;31mA PROFILE ALREADY EXIST\033[0m"
		echo  -e "\033[31m------------------------\033[0m"
		echo " "
		echo " "
		
	fi
}

read_profile_file(){
	declare -a INFO
	while IFS='' read -r line || [[ -n "$line" ]]; do
		INFO+=($line)
	done < $racine/$profileTxt

	#load info in variable appropriate
	namevpn=${INFO[0]}
	ipvpn=${INFO[1]}
	ippublicvpn=${INFO[2]}
	devicevpn=${INFO[3]}
	protovpn=${INFO[4]}
	portvpn=${INFO[5]}
	cryptvpn=${INFO[6]}
	bufferOpenvpn=${INFO[7]}
	countryvpn=${INFO[8]}
	provincevpn=${INFO[9]}
	cityvpn=${INFO[10]}
	orgvpn=${INFO[11]}
	ounvpn=${INFO[12]}
	commonvpn=${INFO[13]}
	mailvpn=${INFO[14]}
}

show_profile(){
 #while there are something to read , we keep the data
	if [ -f $racine/$profileTxt ]; then
		read_profile_file
		echo " "
		echo " "
		echo -e "\033[34m-------------------------\033[0m"
		echo -e "\033[1;34mINFORMATONS ABOUT PROFILE\033[0m"
		echo -e "\033[34m-------------------------\033[0m"
		echo " "
		echo -e "\033[1;34mName : \033[0m"$namevpn
		echo -e "\033[1;34mIP private : \033[0m"$ipvpn
		echo -e "\033[1;34mIP Public : \033[0m"$ippublicvpn
		echo -e "\033[1;34mProtocol : \033[0m"$protovpn
		echo -e "\033[1;34mDevice : \033[0m"$devicevpn
		echo -e "\033[1;34mPort : \033[0m"$portvpn
		echo -e "\033[1;34mCryptage : \033[0m"$cryptvpn" bits"
		echo -e "\033[1;34mBuffer R/W: \033[0m"$bufferOpenvpn
		echo -e "\033[1;34mCountry certificat : \033[0m"$countryvpn
		echo -e "\033[1;34mProvince certificat : \033[0m"$provincevpn
		echo -e "\033[1;34mCity certificat : \033[0m"$cityvpn
		echo -e "\033[1;34mOrganization Name certificat : \033[0m"$orgvpn
		echo -e "\033[1;34mOrganization Unit Name certificat : \033[0m"$ounvpn
		echo -e "\033[1;34mCommon Name certificat : \033[0m"$commonvpn
		echo -e "\033[1;34mEmail certificat : \033[0m"$mailvpn
		echo " "
		echo " "

	else
		echo " "
		echo " "
		echo  -e "\033[31m------------------------\033[0m"
		echo  -e "\033[1;31mANY PROFILE CAN BE SHOWN\033[0m"
		echo  -e "\033[31m------------------------\033[0m"
		echo " "
		echo " "
		
	fi
}

delete_profile(){
	if [ -f $racine/$profileTxt ]; then
		rm $racine/$profileTxt

		initialize_variable

		echo " "
		echo " "
		echo  -e "\033[32m----------------------------\033[0m"
		echo  -e "\033[1;32mPROFILE DELETED WITH SUCCESS\033[0m"
		echo  -e "\033[32m----------------------------\033[0m"
		echo " "
		echo " "
		
	else
		echo " "
		echo " "
		echo -e "\033[31m--------------------------\033[0m"
		echo -e "\033[1;31mANY PROFILE CAN BE DELETED\033[0m"
		echo -e "\033[31m--------------------------\033[0m"
		echo " "
		echo " "
		
	fi
}

restore_profile(){
	if [ -f $racine/$profileTxtBackup ]; then
		cp $racine/$profileTxtBackup $racine/$profileTxt
		echo " "
		echo " "		
		echo  -e "\033[32m-----------------------------\033[0m"
		echo  -e "\033[1;32mPROFILE RESTORED WITH SUCCESS\033[0m"
		echo  -e "\033[32m-----------------------------\033[0m"
		echo " "
		echo " "
	else
		echo " "
		echo " "
		echo -e "\033[31m---------------------------\033[0m"
		echo -e "\033[1;31mANY PROFILE CAN BE RESTORED\033[0m"
		echo -e "\033[31m---------------------------\033[0m"
		echo " "
		echo " "

	fi
}

loop=0
until [ $loop -eq 1 ]
do
	reponse=0

	until [ $reponse -gt 0 > /dev/null 2>&1 ] && [ $reponse -lt 7 > /dev/null 2>&1 ]; do
	echo  -e "\033[1;33mNB: I SUGGEST YOU TO REBOOT AFTER THE INSTALLATION\033[0m"
	echo  -e "\033[34m-----------------------\033[0m"
	echo  -e "\033[1;34mINSTALLATION VPN/CLIENT\033[0m"
	echo  -e "\033[34m-----------------------\033[0m"
	echo  " "
	echo " 1- To create the server VPN"
	echo " 2- To create a client VPN"
	echo " "
	echo -e "\033[34m------------------------\033[0m"
	echo " "
	echo " 3- To create the server profile"
	echo " 4- To show the server profile"
	echo " 5- To delete the server profile"
	echo " 6- To restore the last server profile"
	echo " "
	echo -e "\033[34m------------------------\033[0m"
	echo "To Exit : CTRL-C"
	echo "Write the number option please"
	read reponse
	done

	case "$reponse" in

	"1" )

		if [ -e /etc/debian_version ]; then
			install_prog_required
			install_wget
		elif [ -e /etc/centos-release ]; then
			install_prog_required_centos
			install_wget
		elif [ -e /etc/fedora-release ]; then
			install_prog_required_centos
			install_wget
		else
			echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora or CentOS system"
			exit 4
		fi

		initialize_variable

		until [ $profile -gt 0 > /dev/null 2>&1 ] && [ $profile -lt 3 > /dev/null 2>&1 ]; do
		echo  -e "\033[34m--------------\033[0m"
		echo  -e "\033[1;34mLOAD PROFILE ?\033[0m"
		echo  -e "\033[34m--------------\033[0m"
		echo  " "
		echo " 1- To load the save profile"
		echo " 2- To create a server VPN without profile"
		echo " 3- To Exit / Pour quitter : CTRL-C"
		echo "Write the number option please"
		read profile
		done

		case "$profile" in
		"1" )
			if [ -f $racine/$profileTxt ]
			then
				unset profile
				unset reponse
				read_profile_file
				
			else
				echo -e "\033[31m----------------\033[0m"
				echo -e "\033[1;31mNO PROFILE FOUND\033[0m"
				echo -e "\033[31m----------------\033[0m"
				unset profile
				unset reponse
				ask_info
			fi
		;;

		"2" )
			unset profile
			unset reponse
			ask_info
		
		;;		
		esac

		mkdir -p /etc/openvpn/easyrsa3
		cp -r $racine/easyrsa3/* /etc/openvpn/easyrsa3
		cd /etc/openvpn/easyrsa3
		cp vars.example vars

		#edit vars and put the number cryptage of the key
		sed -i.bak 's/#set_var EASYRSA_KEY_SIZE.*/set_var EASYRSA_KEY_SIZE '$cryptvpn'/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_COUNTRY.*/set_var EASYRSA_REQ_COUNTRY "'$countryvpn'"/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_PROVINCE.*/set_var EASYRSA_REQ_PROVINCE "'$provincevpn'"/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_CITY.*/set_var EASYRSA_REQ_CITY "'$cityvpn'"/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_ORG.*/set_var EASYRSA_REQ_ORG "'$orgvpn'"/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_EMAIL.*/set_var EASYRSA_REQ_EMAIL "'$mailvpn'"/i' /etc/openvpn/easyrsa3/vars;
		sed -i.bak 's/#set_var EASYRSA_REQ_OU.*/set_var EASYRSA_REQ_OU "'$ounvpn'"/i' /etc/openvpn/easyrsa3/vars;

		# build CA certificate and root ca certificate
./easyrsa init-pki <<!
yes
!
		./easyrsa --batch build-ca nopass

		#Generate Diffie-Hellman key exchange
		./easyrsa build-server-full $namevpn nopass

		#generate  Diffie-Hellman
        ./easyrsa gen-dh
		mkdir /etc/openvpn/client
		chmod 755 /etc/openvpn/client

		openvpn --genkey --secret tls-auth.key

		#move file in /etc/openvpn
		cp pki/ca.crt /etc/openvpn
		cp pki/private/$namevpn.key /etc/openvpn
		cp pki/issued/$namevpn.crt /etc/openvpn
		cp pki/reqs/$namevpn.req /etc/openvpn
		cp tls-auth.key /etc/openvpn

		#move file in /etc/openvpn
		cp pki/dh.pem /etc/openvpn

		#create server.conf
cat <<EOF > /etc/openvpn/server.conf
port $portvpn
proto $protovpn
dev tun
comp-lzo no
persist-key
persist-tun
keepalive 10 20
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
ca ca.crt 
cert $namevpn.crt
key $namevpn.key
tls-auth tls-auth.key 0
dh dh.pem
sndbuf $bufferOpenvpn
rcvbuf $bufferOpenvpn
push "sndbuf $bufferOpenvpn"
push "rcvbuf $bufferOpenvpn"
cipher AES-256-CBC
auth SHA-256
status openvpn-status.log
verb 3
EOF

		# add TUN/TAP if desabled
		mkdir -p /dev/net
		mknod /dev/net/tun c 10 200

		#This command configures kernel parameters at runtime. The -p tells it to reload the file with the changes you just made.
		sysctl -p
		if [ -e /etc/debian_version ]; then
			sed -i.bak 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/i' /etc/sysctl.conf;
			/etc/init.d/networking reload

			if pgrep systemd-journal; then
				service openvpn restart
			else
				/etc/init.d/openvpn restart
			fi
		elif [ -e /etc/centos-release ]; then
			grep ^net.ipv4.ip_forward /etc/sysctl.conf > /dev/null 2>&1 && \
                    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf  || \
                    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
			/etc/init.d/network restart

		    	if pgrep systemd-journal; then
				systemctl restart openvpn@server.service
				systemctl enable openvpn@server.service
				service iptables restart
			else
				service openvpn restart
				service iptables restart
				chkconfig openvpn on
			fi
		elif [ -e /etc/fedora-release ]; then
			grep ^net.ipv4.ip_forward /etc/sysctl.conf > /dev/null 2>&1 && \
                    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf  || \
                    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
			/etc/init.d/network restart

			if pgrep systemd-journal; then
				systemctl restart openvpn@server.service
				systemctl enable openvpn@server.service
				service iptables restart
			else
				service openvpn restart
				service iptables restart
				chkconfig openvpn on
			fi
		else
			echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora or CentOS system"

		fi

	if [ -e /etc/debian_version ]; then

# We still want the firewall to protect us from most incoming and outgoing network traffi
cat <<EOF > /etc/firewall.rules
*nat
:PREROUTING ACCEPT
:INPUT ACCEPT
:OUTPUT ACCEPT
:POSTROUTING ACCEPT
-A POSTROUTING -s 10.8.0.0/24 -o $networkName -j MASQUERADE
-A POSTROUTING -o $networkName -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT
:FORWARD DROP
:OUTPUT ACCEPT
-A FORWARD -i $networkName -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i tun0 -o $networkName -j ACCEPT
COMMIT
EOF
		chmod 755 /etc/firewall.rules

cat <<EOF > /etc/init.d/firewall
#!/bin/sh
/sbin/iptables-restore /etc/firewall.rules
EOF

		chmod 755 /etc/init.d/firewall
		#Et on indique au système que ce script doit être lancé automatiquement au démarrage du système
		update-rc.d firewall defaults
		#restart service
		service openvpn start

	elif [ -e /etc/centos-release ]; then
		sed -i.bak 's/IPTABLES_SAVE_ON_STOP="no"/IPTABLES_SAVE_ON_STOP="yes"/i' /etc/sysconfig/iptables-config
		sed -i.bak 's/IPTABLES_SAVE_ON_RESTART="no"/IPTABLES_SAVE_ON_RESTART="yes"/i' /etc/sysconfig/iptables-config
		sed -i.bak 's/IPTABLES_SAVE_ON_COUNTER="no"/IPTABLES_SAVE_ON_COUNTER="yes"/i' /etc/sysconfig/iptables-config

		#Load IPTABLE
		iptables -F
		iptables -X
		iptables -t nat -F
		iptables -t nat -X
		iptables -t mangle -F
		iptables -t mangle -X
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $networkName -j MASQUERADE
		iptables -t nat -A POSTROUTING -o $networkName -j MASQUERADE
		service iptables restart


#little hack because the iptable does not work after the boot if we don't restart the service before
cat <<EOF > /etc/rc.d/rc.local
#!/bin/sh
service iptables restart
EOF
		chmod +x /etc/rc.d/rc.local

	elif [ -e /etc/fedora-release ]; then
               	sed -i.bak 's/IPTABLES_SAVE_ON_STOP="no"/IPTABLES_SAVE_ON_STOP="yes"/i' /etc/sysconfig/iptables-config
                sed -i.bak 's/IPTABLES_SAVE_ON_RESTART="no"/IPTABLES_SAVE_ON_RESTART="yes"/i' /etc/sysconfig/iptables-config
		sed -i.bak 's/IPTABLES_SAVE_ON_COUNTER="no"/IPTABLES_SAVE_ON_COUNTER="yes"/i' /etc/sysconfig/iptables-config

		#Load IPTABLE
		iptables -F
		iptables -X
		iptables -t nat -F
		iptables -t nat -X
		iptables -t mangle -F
		iptables -t mangle -X
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $networkName -j MASQUERADE
		iptables -t nat -A POSTROUTING -o $networkName -j MASQUERADE
		service iptables restart

#little hack because the iptable does not work after the boot if we don't restart the service before
cat <<EOF > /etc/rc.d/rc.local
#!/bin/sh
service iptables restart
EOF
		chmod +x /etc/rc.d/rc.local

	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora or CentOS system"

	fi

	

	#initialize the config for client
	cd /etc/openvpn/easyrsa3
	source vars

cat <<EOF > /etc/openvpn/Default.txt
client
dev tun
proto $protovpn
remote $ippublicvpn $portvpn
EOF

	cp  $racine/makeOVPN.sh /etc/openvpn/
	chmod 755 -R /etc/openvpn

	#reboot to finish to install some last things	
	service openvpn restart
	chmod 755 -R /etc/openvpn
	  ;;

	"2" )
		#default value
		buffer=0
		unset buffer1

	  	echo  -e "\033[34m--------------\033[0m"
		echo  -e "\033[1;34mINFORMATION\033[0m"
		echo  -e "\033[34m--------------\033[0m"
		echo  "Name of the client ?"
		read -e -p "$nameclient" nameclient
		echo " "
		echo -e "\033[31m---------------------------------------------------------------------------\033[0m"
		echo -e "\033[1;31mWARNING. DO NOT CHANGE THE DEFAULT VALUE IF YOU DON'T KNOW WHAT IS THE BUFFER \033[0m"
		echo -e "\033[31m---------------------------------------------------------------------------\033[0m"
		echo -e "\033[1;34mBUFFER OPENVPN ( default : "$buffer") \033[0m"
		read  buffer1	
		echo " "

		if [ "$buffer1" != "" ]
		then
			buffer=$buffer1
		fi

		#build the  key  but without pass
		cd /etc/openvpn/easyrsa3/
		source ./vars
		./easyrsa build-client-full $nameclient nopass

		#move file in /etc/openvpn
		mkdir /etc/openvpn/client/$nameclient
		chmod 755 /etc/openvpn/client/$nameclient

        	cp /etc/openvpn/ca.crt /etc/openvpn/client/$nameclient
		cp pki/private/$nameclient.key /etc/openvpn/client/$nameclient
        	cp pki/issued/$nameclient.crt /etc/openvpn/client/$nameclient
        	cp pki/reqs/$nameclient.req /etc/openvpn/client/$nameclient
		cp tls-auth.key /etc/openvpn/client/$nameclient

		# start the script to create the client
		cd /etc/openvpn
		./makeOVPN.sh $nameclient $buffer
		chmod 755 -R /etc/openvpn
		chmod 755 -R /etc/openvpn/easyrsa3/pki
		unset nameclient
	  ;;

	  "3" )
		ask_save_profile
	  ;;

	  "4" )
		show_profile
	  ;;

	  "5" )
		delete_profile
	  ;;

	 "6" )
		restore_profile
	  ;;

	esac
done
exit

