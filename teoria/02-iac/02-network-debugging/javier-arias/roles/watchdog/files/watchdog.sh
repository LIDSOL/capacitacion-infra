#!/bin/bash

TARGET=8.8.8.8
COUNT=3
IFACE=$(ip route | grep default | awk '{print $5}')

if ! ping -c $COUNT -W 1 $TARGET > /dev/null; then
    echo "$(date) - Red caída. Reiniciando interfaz $IFACE..." >> /var/log/watchdog.log
    ip link set $IFACE down
    sleep 2
    ip link set $IFACE up
else
    echo "$(date) - Red OK." >> /var/log/watchdog.log
fi
