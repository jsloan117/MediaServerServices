#!/bin/bash
# Media Services Kill Switch aka Internet Kill Switch

set -aeu

MY_SERVICES='sickbeard couchpotato sabnzbd transmission-daemon'
MY_PUB_IP='FILL THIS IN'
#MY_VPN_IP=''
MY_IP=$(curl -s ifconfig.co)

if [[ $MY_IP = $MY_PUB_IP ]]; then

    for SERVICES in $MY_SERVICES; do

        systemctl stop $SERVICES > /dev/null 2>&1

    done

else

    for SERVICES in $MY_SERVICES; do

        systemctl start $SERVICES > /dev/null 2>&1

    done

fi
