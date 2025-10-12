#!/bin/bash

#!/bin/bash

DEFAULT_IFACE=$(ip route | awk '/default/ {print $5; exit}')

ip monitor link | while read -r line; do
    # Solo actúa si la línea indica que la interfaz principal está DOWN
    if echo "$line" | grep -q "$DEFAULT_IFACE.*state DOWN"; then
        ip link set "$DEFAULT_IFACE" up
    fi
done