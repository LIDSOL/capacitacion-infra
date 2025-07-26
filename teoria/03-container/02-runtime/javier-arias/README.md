
# Opciones de Runtime y Gestión de Contenedores con Podman

## Actividad 1

Se ejecutó un contenedor de nginx usando podman y se montaron volumenes en los directorios
especificados para servir contenido html desde el contenedor y cargar la configuración
de nginx. El servidor fue montado en el puerto 8080 del host.

Comandos utilizados

```bash
podman run --rm -d -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx
```

## Actividad 2

Se ejecutó un contenedor de nginx usando podman. El servidor fue montado en el
puerto 80 del contenedor sobre el puerto 8080 del host.

Comandos utilizados

```bash
podman run --rm -d -p 8080:80 nginx
```

## Actividad 3

Se creó una nueva red de podman con el nombre de 'red1', depués se crearon 2 contenedores
conectados a esta red y se estableció comunicación entre ellos, obteniendo el contenido
servido por nignx desde el contenedor de busybox.

Comandos utilizados

```bash
podman network ls
podman network create red1
podman run --rm -d --name web1 --network red1 nginx
podman run --rm -it --network red1 busybox sh
```

## Actividad 5

Se desplegó una aplicación multi-contenedor con Podman.
Se creó una red wpnet y un volumen wp-dbdata para la base de datos MariaDB.
Se levantaron los contenedores de MariaDB y WordPress, configurados para
comunicarse a través de la red y persistir datos. WordPress quedó expuesto en el
puerto 8081 del host.

Comandos utilizados

```bash
podman network create wpnet
podman volume create wp-dbdata

podman run -d --name mariadb --network wpnet \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v wp-dbdata:/var/lib/mysql \
  docker.io/library/mariadb:11

podman run -d --name wordpress --network wpnet \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  -p 8081:80 \
  docker.io/library/wordpress:6
```
