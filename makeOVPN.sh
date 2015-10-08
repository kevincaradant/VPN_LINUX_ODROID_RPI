#!/bin/bash 
 
# Default Variable Declarations 
DEFAULT="Default.txt" 
FILEEXT=".ovpn" 
CRT=".crt" 
KEY=".key" 
CA="ca.crt" 
TA="ta.key" 
 
#Ask for a Client name 
echo "Please enter an existing Client Name:"
read NAME 
 
 
#1st Verify that client’s Public Key Exists 
if [ ! -f $NAME$CRT ]; then 
 echo "[ERROR]: Client Public Key Certificate not found: $NAME$CRT" 
 exit 
fi 
echo "Client’s cert found: $NAME$CR" 
 
 
#Then, verify that there is a private key for that client 
if [ ! -f $NAME$KEY ]; then 
 echo "[ERROR]: Client Private Key not found: $NAME$KEY" 
 exit 
fi 
echo "Client’s Private Key found: $NAME$KEY"
 
#Confirm the CA public key exists 
if [ ! -f $CA ]; then 
 echo "[ERROR]: CA Public Key not found: $CA" 
 exit 
fi 
echo "CA public Key found: $CA" 
 
#Confirm the tls-auth ta key file exists 
if [ ! -f $TA ]; then 
 echo "[ERROR]: tls-auth Key not found: $TA" 
 exit 
fi 
echo "tls-auth Private Key found: $TA" 
 
#Ready to make a new .opvn file - Start by populating with the 
#default file 
cat $DEFAULT > $NAME$FILEEXT
echo  "resolv-retry infinite" >> $NAME$FILEEXT
echo  "nobind" >> $NAME$FILEEXT
echo  "ca ca.crt" >> $NAME$FILEEXT
echo  "cert "$NAME".crt" >> $NAME$FILEEXT
echo  "key "$NAME".key" >> $NAME$FILEEXT
echo  "persist-key" >> $NAME$FILEEXT
echo  "persist-tun" >> $NAME$FILEEXT
echo  "comp-lzo" >> $NAME$FILEEXT
echo  "verb 3" >> $NAME$FILEEXT
