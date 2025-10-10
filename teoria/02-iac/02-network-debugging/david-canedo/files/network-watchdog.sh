#!/bin/bash
# Watchdog que se ejecuta una sola vez por invocación
TARGET="8.8.8.8"

# Detectar interfaz de salida (default gateway)
IFACE=$(ip route | awk '/default/ {print $5; exit}')

if ! ping -c 2 $TARGET > /dev/null 2>&1; then
    echo "$(date): Conectividad perdida en $IFACE. Levantando interfaz..." >> /var/log/network-watchdog.log
    ip link set "$IFACE" up
else
    echo "$(date): Conectividad OK en $IFACE" >> /var/log/network-watchdog.log
fi

