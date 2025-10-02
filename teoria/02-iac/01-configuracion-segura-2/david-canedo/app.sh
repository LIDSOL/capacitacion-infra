#!/bin/bash

# Funciones que corresponden a cada script
ping() {

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




}
inv() {


INVENTORY_FILE="inventory.ini"


echo "Generando $INVENTORY_FILE..."
bash gen.sh info | grep -oP 'ipv4\s+\K[0-9.]+' | head -3 > temp_ips.txt

cat > $INVENTORY_FILE << EOF
[myhosts]
$(cat temp_ips.txt)

[all:vars]
ansible_user=debian
EOF

rm temp_ips.txt
echo "Inventory creado:"
cat $INVENTORY_FILE

}

todos() {
    echo "Ejecutando comando3..."
    PLAYBOOKS=(
    "common.yml"
    "firewall.yml" 
    "sshd.yml"
    "nginx.yml"
)

for playbook in "${PLAYBOOKS[@]}"; do
    echo "Ejecutando: $playbook"
    ansible-playbook -i inventory.ini "$playbook"
    
    
    if [ $? -ne 0 ]; then
        echo "Error al ejecutar $playbook"
        exit 1
    fi
    
    echo "$playbook completado"
    echo "---"
done

echo "Todos los playbooks ejecutados exitosamente"

    
}


common(){


	ansible-playbook -i inventory.ini common.yml
}

firewall(){
	
	ansible-playbook -i inventory.ini firewall.yml

}

sshd(){

	ansible-playbook -i inventory.ini sshd.yml

}

nginx(){
	ansible-playbook -i inventory.ini nginx.yml
}


# Verificar que se proporcionó un comando
if [ $# -eq 0 ]; then
    echo "Error: Debes especificar un comando"
    exit 1
fi

# Procesar el comando
case $1 in
    ping)
        ping
        ;;
    inv)
        inv
        ;;
    todos)
        todos
        ;;
    common)
    	common
	;;
    firewall)
	firewall
	;;
    sshd)
	sshd
	;;
    nginx)
	nginx
	;;
    *)
        echo "Error: Comando '$1' no reconocido"
        exit 1
        ;;
esac
