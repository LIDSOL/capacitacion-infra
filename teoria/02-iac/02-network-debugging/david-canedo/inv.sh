#!/bin/bash

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

