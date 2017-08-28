#!/bin/bash
# Media Services Kill Switch aka Internet Kill Switch

set -aeu

MY_SERVICES='sickbeard couchpotato sabnzbd transmission-daemon'
MY_PUB_IP='FILL THIS IN'
#MY_VPN_IP=''
MY_IP=$(curl -s ifconfig.co)

if [[ "$MY_IP" = "$MY_PUB_IP" ]]; then

    for SERVICES in $MY_SERVICES; do

        SERVICE_STATE=$(systemctl status "$SERVICES" | grep -q "Active: inactive (dead)" ; echo $?) # returns 0 if stopped

        if [[ "$SERVICE_STATE" != '0'  ]]; then

            systemctl stop "$SERVICES" > /dev/null 2>&1

        fi

    done

else

    for SERVICES in $MY_SERVICES; do

        SERVICE_STATE=$(systemctl status "$SERVICES" | grep -q "Active: active (running)"; echo $?) # returns 0 if started

        if [[ "$SERVICE_STATE" != '0'  ]]; then

            systemctl start "$SERVICES" > /dev/null 2>&1

        fi

    done

fi
