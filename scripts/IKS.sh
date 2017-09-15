#!/bin/bash
# Media Services Kill Switch aka Internet Kill Switch

set -aeu

MY_SERVICES='FILL IN'
MY_PUB_IP='FILL IN'
VPN_SERVICE='openvpn@client'
VPN_NIC='FILL IN'
MY_IP=$(curl -s ifconfig.co)

check_vpn_service () { # check if vpn is running
systemctl restart "$VPN_SERVICE"
sleep 10 # give vpn time to initialize
check_vpn_nic
}

check_vpn_nic () { # check if vpn's nic exists
if [[ $(ifconfig "$VPN_NIC" > /dev/null 2>&1 ; echo $?) = '0' ]]; then

    MY_IP=$(curl -s ifconfig.co)
    if [[ "$MY_IP" != "$MY_PUB_IP" ]]; then

        services_start

    fi
fi
}

services_start () {
for SERVICES in $MY_SERVICES; do

    SERVICE_STATE=$(systemctl status "$SERVICES" > /dev/null 2>&1; echo $?) # returns 0 if started

    if [[ "$SERVICE_STATE" != '0' ]]; then

        systemctl start "$SERVICES" > /dev/null 2>&1

    fi

done
}

services_stop () {
for SERVICES in $MY_SERVICES; do

    SERVICE_STATE=$(systemctl status "$SERVICES" > /dev/null 2>&1; echo $?) # returns 3 if stopped

    if [[ "$SERVICE_STATE" != '3' ]]; then

        systemctl stop "$SERVICES" > /dev/null 2>&1

    fi

done
}

if [[ "$MY_IP" = "$MY_PUB_IP" || $(systemctl status "$VPN_SERVICE" > /dev/null 2>&1; echo $?) = '3' ]]; then

    services_stop # ensure services will not be running without vpn
    check_vpn_service

else

    services_start # ensure services are started if vpn is up and public IP does not match vpn IP

fi
