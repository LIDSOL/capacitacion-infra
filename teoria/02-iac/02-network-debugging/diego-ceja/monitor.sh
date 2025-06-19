#!/bin/bash
IFACE=$(ip route | awk "/default/{print \$5; exit}")
while true; do
	if [ -z $(ip link | awk "/$IFACE/{print \$3; exit}" | awk "/UP/")]; then
		echo "interface down"
		ip link set $IFACE up
	else
		echo "interface up"
	fi
done
