#!/bin/bash

status=$(ping -c 1 -q 1.1.1.1 >&/dev/null; echo $?)

# Check the status of the ping command
if [ "$status" != "0" ]; then
    ifname=$(ip link show | grep enp | awk -F': ' '{print $2}')
    echo "[$(date +%D\ %R)] NO INTERNET CONNECTION, trying to restart $ifname interface..."

    # Restart interface
    ip link set $ifname up
    if [ "$?" = "0" ]; then
        echo "[$(date +%D\ %R)] Interface $ifname successfully restarted"
    else
        echo "[$(date +%D\ %R)] ERROR: $ifname could'nt be reset"
    fi
fi
