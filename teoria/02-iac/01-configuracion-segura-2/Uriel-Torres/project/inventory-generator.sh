#!/bin/bash

# Destino del inventario
INVENTORY_FILE="inventory.ini"

# Encabezado del archivo
echo "[debian_vms]" > "$INVENTORY_FILE"

# Obtener IPs de las VMs (ajusta el filtro 'debian-vm-' según tus nombres)
for vm in $(sudo virsh list --name | grep "^debian-vm-"); do
    ip=$(sudo virsh domifaddr "$vm" | awk '/ipv4/ {print $4}' | cut -d'/' -f1)
    echo "$ip ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_rsa" >> "$INVENTORY_FILE"
done

echo "Inventario generado en: $INVENTORY_FILE"
cat "$INVENTORY_FILE"
