#!/bin/bash

# Configuración
TEST_IP="8.8.8.8"
MAX_FAILS=3
LOG_FILE="/var/log/network-watchdog.log"

# Verificar conectividad
check_connectivity() {
    ping -c 2 -W 2 "$TEST_IP" > /dev/null 2>&1
    return $?
}

# Restaurar conexión
restore_network() {
    local iface=$(ip route | awk '/default/ {print $5; exit}')
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] Restaurando interfaz $iface" >> "$LOG_FILE"
    
    ip link set "$iface" down
    sleep 2
    ip link set "$iface" up
    sleep 5  # Esperar a que la interfaz se estabilice
}

# Lógica principal
main() {
    local fails=0
    
    while [ $fails -lt $MAX_FAILS ]; do
        if ! check_connectivity; then
            fails=$((fails + 1))
            sleep 1
        else
            exit 0
        fi
    done
    
    restore_network
}

main
