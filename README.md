#VPN_LINUX_ODROID_RPI_EASY_RSA3#

##INTRO##
You want to create a script VPN very easily ? This script is for you.

When you launch the script , you have some possibilities like create a profil which allow to you to reload it quickly ( IP public/private , name of the VPN )

In the script , you have some interesting tricks, the script will suggest to you your public IP and your private IP  , check if it's good and just put "ENTER" after

##HOW CAN I START ?##
Clone the repository : `git clone https://github.com/kevincaradant/VPN_LINUX_ODROID_RPI.git`
Launch with root rights , the script shell : ./scriptVPN.sh
`sudo bash ./scriptVPN.sh`

##CREATE SERVER##
If you have already a profile. Press *1* to create a server and again *1* to load an existing profil. Otherwise, automatically , you will be moved on the second option which will ask you to fill in some informations.

##CREATE PROFILE##
If you create a profile , you will gain time for the next installation if you would to reinstall it on the server
Press *3* in the main menu 

##SHOW A PROFILE##
If you just want to see the informations of profile. Press *4* in the main menu.

##DELETE A PROFILE##
If you want to delete a profile that you created, Press *5* in the main menu. 

##RESTORE THE LAST PROFILE##
If you have delete by error or anything else reasons, you can restore it by pressing *6* in the main menu.


##CREATE / GET CLIENT##
###Create a client###
Use the option 2 in the main menu and just enter a name of client. 

###On the client computer###
You have to get three files ( use FTP with filezilla by example)
- NAME_CLIENT.crt
- NAME_CLIENT.key
- ca.crt
- NAME_CLIENT.OVPN
from /etc/openvpn/client/NAME_CLIENT. That's all.


Sorry if the description is light , it's my first personal repository 

