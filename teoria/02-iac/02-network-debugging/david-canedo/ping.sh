#!/bin/bash



IPs=$(bash gen.sh info | grep -oP 'ipv4\s+\K[0-9.]+' | head -3)

for ip in $IPs; do
    echo "Conectando a $ip por 10 segundos..."
    
    # Conexión con timeout automático
    ssh -o ConnectTimeout=3 debian@$ip "
        echo 'Comandos rápidos en $(hostname):'
        date
        whoami
        echo 'Desconectando en 3 segundos...'
        sleep 3
    "
    echo "----------------------------------------"
done






