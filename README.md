# VPN_LINUX_ODROID_RPI_EASY_RSA3 #

## INTRO ##
You want to create a VPN very easily ? This script is for you.

Here is the summary about at the configuration suggested in the script:

- Auto install of necessary library
- Auto install of the Openvpn 2.3.14 ( last version available and stable )
- Auto Detection of your private and public IP ( for new and old version of linux which don't use the same process to work )


- You can choose:
	- Ethernet or Wifi to create the VPN server
	- The protocol UDP or TCP
	- The buffer size ( can be usefull in some cases )
	- The port to use
	- The size of key about cryptage with EASYRSA 3


- You can't choose for the moment:
	- The authentification and cipher in 256 bits which is the most secure to your VPN
	- The compression lz0 is disable because that seem to decrease performance.
	- The system with tls-auth is enable to be more secure

NB: If you want to have better performance because you use a lowpowerful device as RASPBERRY PI / ODROID. You can remove the auth and cipher lines in the aim to use the default algorythm of openvpn which is less securised but it consumes less CPU.

## HOW CAN I START ? ##
Clone the repository : `git clone https://github.com/kevincaradant/VPN_LINUX_ODROID_RPI.git`   
Launch with root rights , the script shell : scriptVPN.sh     
=> `sudo bash ./scriptVPN.sh`


## CREATE SERVER ##
If you have already a profile.  
Press *1* to create a server and again *1* to load an existing profile.   
Otherwise, press *2* and you have to fill in some informations.

## CREATE PROFILE ##
If you create a profile , you will gain time for the next installation if you would to reinstall it on the server
Press *3* in the main menu

## SHOW A PROFILE ##
If you just want to see the informations of your profile. Press *4* in the main menu.

## DELETE A PROFILE ##
If you want to delete a profile that you created, Press *5* in the main menu.

## RESTORE THE LAST PROFILE ##
If you have delete by error or anything else reasons, you can restore it by pressing *6* in the main menu.


## CREATE / GET CLIENT ##
### Create a client ###
Use the option 2 in the main menu and just enter a name of client.

### On the client computer ###
You have to get five files ( use FTP with filezilla by example)
- NAME_CLIENT.crt
- NAME_CLIENT.key
- ca.crt
- NAME_CLIENT.ovpn
- tls-auth.key

from /etc/openvpn/client/NAME_CLIENT. That's all.
