#!/bin/bash
 
# Default Variable Declarations 
DEFAULT="Default.txt" 
FILEEXT=".ovpn" 
CRT=".crt" 
KEY=".key" 
CA="ca.crt" 
NAME=$1
BUFFER=$2
 
#1st Verify that client’s Public Key Exists 
if [ ! -f easyrsa3/pki/issued/$NAME$CRT ]; then 
 echo "[ERROR]: Client Public Key Certificate not found: $NAME$CRT" 
 exit 
fi 
echo "Client’s cert found: $NAME$CR" 
 
 
#Then, verify that there is a private key for that client 
if [ ! -f easyrsa3/pki/private/$NAME$KEY ]; then 
 echo "[ERROR]: Client Private Key not found: $NAME$KEY" 
 exit 
fi 
echo "Client’s Private Key found: $NAME$KEY"
 
#Confirm the CA public key exists 
if [ ! -f easyrsa3/pki/$CA ]; then 
 echo "[ERROR]: CA Public Key not found: $CA" 
 exit 
fi 
echo "CA public Key found: $CA" 
 
#Confirm the tls-auth ta key file exists 
 
#Ready to make a new .opvn file - Start by populating with the 
#default file 
cat $DEFAULT > ./client/$NAME/$NAME$FILEEXT
echo  "resolv-retry infinite" >> ./client/$NAME/$NAME$FILEEXT
echo  "remote-cert-tls server" >> ./client/$NAME/$NAME$FILEEXT
echo  "nobind" >> ./client/$NAME/$NAME$FILEEXT
echo  "ca ca.crt" >> ./client/$NAME/$NAME$FILEEXT
echo  "cert "$NAME".crt" >> ./client/$NAME/$NAME$FILEEXT
echo  "key "$NAME".key" >> ./client/$NAME/$NAME$FILEEXT
echo  "persist-key" >> ./client/$NAME/$NAME$FILEEXT
echo  "persist-tun" >> ./client/$NAME/$NAME$FILEEXT
echo  "sndbuf $BUFFER""" >> ./client/$NAME/$NAME$FILEEXT
echo  "rcvbuf $BUFFER""" >> ./client/$NAME/$NAME$FILEEXT
echo  "comp-lzo" >> ./client/$NAME/$NAME$FILEEXT
echo  "verb 3" >> ./client/$NAME/$NAME$FILEEXT
