#!/bin/bash

# Salir si hay algún error
set -e

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# Función para crear la red si no existe
create_network() {
    if ! podman network inspect wpnet &>/dev/null; then
        echo -e "${YELLOW}Creando red personalizada 'wpnet'...${NC}"
        podman network create wpnet
    else
        echo -e "${GREEN}La red 'wpnet' ya existe.${NC}"
    fi
}

# Función para crear el volumen si no existe
create_volume() {
    if ! podman volume inspect wp-dbdata &>/dev/null; then
        echo -e "${YELLOW}Creando volumen 'wp-dbdata'...${NC}"
        podman volume create wp-dbdata
    else
        echo -e "${GREEN}El volumen 'wp-dbdata' ya existe.${NC}"
    fi
}

# Función para lanzar el contenedor de MariaDB
run_mariadb() {
    if ! podman ps -a --format '{{.Names}}' | grep -q 'mariadb'; then
        echo -e "${YELLOW}Lanzando contenedor de MariaDB...${NC}"
        podman run -d --name mariadb --network wpnet \
          -e MYSQL_DATABASE=wordpress \
          -e MYSQL_USER=wpuser \
          -e MYSQL_PASSWORD=wppass \
          -e MYSQL_ROOT_PASSWORD=rootpass \
          -v wp-dbdata:/var/lib/mysql \
          docker.io/library/mariadb:11
    else
        echo -e "${GREEN}El contenedor de MariaDB ya existe.${NC}"
    fi
}

# Función para lanzar el contenedor de WordPress
run_wordpress() {
    if ! podman ps -a --format '{{.Names}}' | grep -q 'wordpress'; then
        echo -e "${YELLOW}Lanzando contenedor de WordPress...${NC}"
        podman run -d --name wordpress --network wpnet \
          -e WORDPRESS_DB_HOST=mariadb \
          -e WORDPRESS_DB_USER=wpuser \
          -e WORDPRESS_DB_PASSWORD=wppass \
          -e WORDPRESS_DB_NAME=wordpress \
          -p 8081:80 \
          docker.io/library/wordpress:6
    else
        echo -e "${GREEN}El contenedor de WordPress ya existe.${NC}"
    fi
}

# Crear red y volumen
create_network
create_volume

# Lanzar contenedores
run_mariadb
run_wordpress

echo -e "${GREEN}Instalación completada. Accede a WordPress en http://localhost:8081 para completar la instalación.${NC}"
