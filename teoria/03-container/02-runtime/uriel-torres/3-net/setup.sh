#!/bin/bash

# Salir si hay un error
set -e

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

echo -e "${GREEN}[*] Listando redes disponibles...${NC}"
podman network ls

# Crear la red solo si no existe
if ! podman network inspect ping_red &>/dev/null; then
    echo -e "${YELLOW}[*] Creando una red personalizada llamada 'ping_red'...${NC}"
    podman network create ping_red
else
    echo -e "${GREEN}[*] La red 'ping_red' ya existe.${NC}"
fi

echo -e "${GREEN}[*] Construyendo la primera imagen (Debian con ping)...${NC}"
podman build -t debian-ping -f Dockerfile1 .

echo -e "${GREEN}[*] Construyendo la segunda imagen (Debian vacío)...${NC}"
podman build -t debian-empty -f Dockerfile2 .

# Verificar si el contenedor vacío ya existe
if podman ps -a --format '{{.Names}}' | grep -q 'empty_container'; then
    echo -e "${YELLOW}[*] El contenedor 'empty_container' ya existe. Iniciándolo...${NC}"
    podman start empty_container
else
    echo -e "${GREEN}[*] Ejecutando el contenedor vacío...${NC}"
    podman run --rm -d --name empty_container --network ping_red debian-empty sh -c "while true; do sleep 3600; done"
fi

# Esperar un momento para asegurarse de que el contenedor vacío esté en funcionamiento
sleep 2

# Obtener la dirección IP del contenedor vacío
EMPTY_IP=$(podman inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' empty_container)

# Verificar si se obtuvo la dirección IP
if [ -z "$EMPTY_IP" ]; then
    echo -e "${RED}[*] Error: No se pudo obtener la dirección IP del contenedor vacío.${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] La dirección IP del contenedor vacío es: ${GREEN}$EMPTY_IP${NC}"

echo -e "${GREEN}[*] Ejecutando el contenedor con ping...${NC}"
podman run --rm -it --cap-add=NET_RAW --network ping_red --name ping_container debian-ping sh -c "while true; do ping -c 1 $EMPTY_IP; sleep 2; done"
