#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo >&2 "This script must be run as root"
   exit 1
fi

USERS=`awk -F= '{if($1 == "USERS") print $2}' .env`
HOST_DATA=`awk -F= '{if($1 == "HOST_DATA") print $2}' .env`

if [ -z "$USERS" ]
then
    echo >&2 "USERS variable is not declared in .env file"
    exit 1
fi

if [ -z "$HOST_DATA" ]
then
    echo >&2 "HOST_DATA variable is not declared in .env file"
    exit 1
fi

for i in $USERS; do
    _USR=`echo $i | awk -F: '{print $1}' -`
    _UID=`echo $i | awk -F: '{print $2}' -`
    mkdir -p conf/$_USR
    touch conf/$_USR/authorized_keys
    chown $_UID:$_UID conf/$_USR -R
    chmod 0600 conf/$_USR/authorized_keys
done;

echo "$(tput bold) $(tput setaf 1) ---- NOTE 1---- $(tput sgr 0)"
echo "$(tput bold) For security reasons this script does not change the permissions for data folder. You might want to run the following commands (after the thorough review):$(tput sgr 0)"

for i in $USERS; do
    _USR=`echo $i | awk -F: '{print $1}' -`
    _UID=`echo $i | awk -F: '{print $2}' -`
    echo "  mkdir -p $HOST_DATA/$_USR && sudo chown $_UID:$_UID $HOST_DATA/$_USR -R && sudo chmod 0700 $HOST_DATA/$_USR"
done;

echo "$(tput bold) $(tput setaf 1) ---- NOTE 2---- $(tput sgr 0)"
echo "$(tput bold)Now edit the authorized_keys files:$(tput sgr 0)"
for i in $USERS; do
    _USR=`echo $i | awk -F: '{print $1}' -`
    echo "  sudo nano conf/$_USR/authorized_keys"
done;
