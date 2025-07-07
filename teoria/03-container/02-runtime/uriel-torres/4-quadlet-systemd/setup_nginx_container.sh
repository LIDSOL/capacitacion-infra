#!/bin/bash

# Definir la ruta del archivo de configuración
CONFIG_DIR="$HOME/.config/containers/systemd"
CONTAINER_FILE="$CONFIG_DIR/nginx.container"

# Crear el directorio si no existe
mkdir -p "$CONFIG_DIR"

# Crear el archivo nginx.container con el contenido especificado
cat <<EOL > "$CONTAINER_FILE"
[Container]
Image=nginx
PublishPort=8080:80
Volume=%h/html:/usr/share/nginx/html:ro
EOL

# Recargar los servicios de systemd
systemctl --user daemon-reload

# Habilitar y arrancar el contenedor
systemctl --user enable --now nginx.container

# Mostrar el estado del contenedor
systemctl --user status nginx.container
