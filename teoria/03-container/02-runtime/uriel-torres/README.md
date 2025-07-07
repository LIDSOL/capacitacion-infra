# 1,2. Montaje de volúmenes, redirección de puertos.
## Estructura del proyecto
Se crearon los siguientes directorios y archivos:
```bash
.
└── nginx
    ├── html
    │   └── index.html
    └── nginx.conf
```

## Contenido del archivo nginx.conf
```conf
# nginx.conf
user  nginx;
worker_processes  auto;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }

        error_page 404 /404.html;
        location = /404.html {
            internal;
        }
    }
}
```
## Ejecución del contenedor
Se usó el siguiente comando:
```bash
podman run --rm -it -p 8080:80 -v ./nginx/html/:/usr/share/nginx/html:ro -v ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro docker.io/library/nginx
```
Primeramente se crea y ejecuta un contenedor a partir de la imágen `podman run`, se usa el parámetro `--rm` para eliminar el contenedor automáticamente al ser detenido, para evitar la acumulación de contenedores en el sistema, `-it` combina dos parámetros, permitiendo la interacción con el contenedor y la salida como en una "terminal normal. El parámetro `-p 8080:80` permite mapear puertos entre el host y el contenedor, primero el puerto de la máquina host *8080* y luego el puerto del contenedor *80*, donde nginx está escuchando, así cualquier solicitud que llegue al puerto 8080 de la máquina host se redirigirá al puerto 80 del contenedor. Los siguientes dos parámetros son similares entre si; `-v`, se usa para montar volúmenes, primero se especifica la ruta del host, después de los dos puntos `:` se coloca la ruta del contenedor; `:ro` indica que el contenedor solo puede leer pero no escribir en el directorio, está en modo solo lectura 

Después se puede acceder desde el navegador a la página, usando la url `http://localhost:8080/`. Ahora si el archivo index.html es modificado, desde el directorio del host, los cambios efectuados se puede visualizar en el navegador al recargar la página, *Ctrl+F5*.

# 3. Opciones de red.  
Para este apartado cree tres archivos, dos con el nombre Dockerfile y un script de bash; el script lista las redes y crea una nueva (o usa la ya existente) y genera dos contenedores (o los usa si ya fueron creados), una de las máquinas hace `ping` a la otra, para comprobar el funcionamiento correcto de la red. El contenido de los archivos es el siguiente:
```bash
/bin/cat Dockerfile2
# Usa la imagen base de Debian stable-slim
FROM debian:stable-slim

# Establece el comando por defecto para ejecutar un shell
CMD ["sh"]
```

```bash
 /bin/cat Dockerfile1
# Usa la imagen base de Debian stable-slim
FROM debian:stable-slim
                                                                           # Actualiza el sistema e instala iputils-ping                              RUN apt-get update && \                                                        apt-get install -y iputils-ping && \                                       apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Establece el comando por defecto para ejecutar un shell
CMD ["sh"]
```

## Script setup.sh
Aquí se hace una explicación del funcionamiento del script:
### Listar las redes disponibles
```bash
echo -e "${GREEN}[*] Listando redes disponibles...${NC}"
podman network ls
```
Se imprime un mensaje de color verde indicando que se están listando las redes disponibles, seguido del comando de podman que hace esto `podman network ls`. 
### Creación de red personalizada.
```bash
# Crear la red solo si no existe
if ! podman network inspect ping_red &>/dev/null; then
    echo -e "${GREEN}[*] Creando una red personalizada llamada 'ping_red'...${NC}"
    podman network create ping_red
else
    echo -e "${YELLOW}[*] La red 'ping_red' ya existe.${NC}"
fi
```
Se usa una estructura de decisión if-else; se verifica si la red llamada `ping_red` existe usando el comando `podman network inspect ping_red`, si tenemos un resultado lógico negativo (! indica negación) se procede a crear la red con `podman network create ping_red` y se imprime un mensaje de color amarillo; si la red existe, simplemente se imprime un mensaje verde en la terminal informando que la red ya está disponible.
### Construcción de imágenes
```bash
echo -e "${GREEN}[*] Construyendo la primera imagen (Debian con ping)...${NC}"
podman build -t debian-ping -f Dockerfile1 .

echo -e "${GREEN}[*] Construyendo la segunda imagen (Debian vacío)...${NC}"
podman build -t debian-empty -f Dockerfile2 .
```
Se construyen las dos imágenes usando los archivos Dockerfile (similar a la construcción del contenedor con htop de la actividad pasada).
### Se verifica si el contenedor vacío existe
```bash
# Verificar si el contenedor vacío ya existe
if podman ps -a --format '{{.Names}}' | grep -q 'empty_container'; then
    echo -e "${YELLOW}[*] El contenedor 'empty_container' ya existe. Iniciándolo...${NC}"
    podman start empty_container
else
    echo -e "${GREEN}[*] Ejecutando el contenedor vacío...${NC}"
    podman run --rm -d --name empty_container --network ping_red debian-empty sh -c "while true; do sleep 3600; done"
fi
```
Se usa una estructura de decisión if-else para verificar si `empty_container` existe; se listan todos los contenedores con el comando `podman ps -a` y se usa `grep -q 'empty_container'` para filtrar la salida y encontrar el nombre; si tenemos `True`, se inicia el contenedor con `podman start empty_container`; por el contrario, si tenemos `False`,  se crea y ejecuta un nuevo contenedor en segundo plano (-d) con el nombre *empty_container*, conectado a la red *ping_red*, y ejecutando un comando que mantiene el contenedor en ejecución (`while true; do sleep 3600; done`).
### Dirección ip, ping
```bash
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
```
Se espera un momento `sleep 2` para que el contenedor vacío (al cuál se le hará `ping`) termine de iniciar; se obtiene la dirección IP de susodicho contenedor con el comando `podman inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' empty_container` y se almacena en la variable *EMPY_IP*. Se usa un _if-else_ para verificar si se obtuvo correctamente la IP; el parámetro `-z` devuelve _True_ si la longitud de la cadena es cero, con esto se verifica si la variable está vacía y por lo tanto no se obtuvo la IP, si esta condicción es verdadera el programa termina y genera el código de salida 0, se imprime el mensaje *Error: No se pudo obtener la dirección IP del contenedor vacío.* de color rojo; si la cadena no está vacia, se imprime su contenido y se empieza el `ping`. El comando que se usa para hacer ping es: `podman run --rm -it --cap-add=NET_RAW --network ping_red --name ping_container debian-ping sh -c "while true; do ping -c 1 $EMPTY_IP; sleep 2; done"`. Es un poco largo, así que se desglosa aquí:
- `podman run`: Inicia un nuevo contenedor.
- `--rm`: El contenedor se eliminará automáticamente cuando se detenga.
- `-it`: Permite la interacción con el contenedor (modo interactivo y asignación de terminal).
- `--cap-add=NET_RAW`: Agrega la capacidad NET_RAW al contenedor, lo que permite realizar operaciones de red de bajo nivel, como el uso de ping.
- `--network ping_red`: Conecta el contenedor a la red personalizada.
- `--name ping_container`: Asigna el nombre ping_container al nuevo contenedor.
- `debian-ping`: Es la imagen que se utilizará para crear el contenedor.
- `sh -c "while true; do ping -c 1 $EMPTY_IP; sleep 2; done"`: Este comando se ejecuta dentro del contenedor. Realiza un ping a la dirección IP del contenedor vacío ($EMPTY_IP) cada 2 segundos. El -c 1 indica que se enviará un solo paquete de ping en cada intento.

# 4. Quadlet
```bash
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
```

# 5. Instalación de WordPress con podman
Para este apartado se usó un script llamado `install_wordpress.sh`.
## Configuración inicial
```bash
#!/bin/bash

# Salir si hay algún error
set -e

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color
```
El shebang indica que el script se debe ejecutar usando el intérprete `bash`; `set -e` hace que el script se detenga inmediatamente en caso de producirse un error, así se evita que el script se ejecute por tiempo indeterminado; después se defiden algunas variables con colores, para mejorar el aspecto visual de los mensajes que se imprimen en la terminal.
## Función para crear la red si no existe
```bash
create_network() {
    if ! podman network inspect wpnet &>/dev/null; then
        echo -e "${YELLOW}Creando red personalizada 'wpnet'...${NC}"
        podman network create wpnet
    else
        echo -e "${GREEN}La red 'wpnet' ya existe.${NC}"
    fi
}
```
En la función se usa una estructura _if-else_; con el comando `podman network inspect wpnet` se verifica que la red `wpnet` exista y si se obtiene *False* se usa el parámetro `!` que "niega la negación", provocando un True, se que crea la red y se imprime un mensaje en color amarillo indicando al usuario lo que ha sucedido; si la red existe, simplemente se imprime un mensaje indicandolo. La salida de los comandos de podman se mandan al /dev/null para no verlos en pantalla.
## Función para crear el volumen si no existe.
```bash
create_volume() {
    if ! podman volume inspect wp-dbdata &>/dev/null; then
        echo -e "${YELLOW}Creando volumen 'wp-dbdata'...${NC}"
        podman volume create wp-dbdata
    else
        echo -e "${GREEN}El volumen 'wp-dbdata' ya existe.${NC}"
    fi
}
```
Esta función usa la misma lógica que la anterior, verifica que el volumen exista, no si no es así, lo crea.

## Creación de contenedores
```bash
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
```
Esta función verifica si el contenedor de MariaDB ya está en ejecución o existe. Si no existe, lanza un nuevo contenedor de MariaDB con las variables de entorno necesarias para la configuración de la base de datos y lo conecta a la red wpnet. Si el contenedor ya existe, muestra un mensaje en verde.

```bash
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
```
Esta función verifica si el contenedor de WordPress ya está en ejecución o existe. Si no existe, lanza un nuevo contenedor de WordPress, configurándolo para conectarse a la base de datos de MariaDB y exponiendo el puerto 8081.

## Se inician las funciones y contenedores 
```bash
# Crear red y volumen
create_network
create_volume

# Lanzar contenedores
run_mariadb
run_wordpress

echo -e "${GREEN}Instalación completada. Accede a WordPress en http://localhost:8081 para completar la instalación.${NC}"
```
