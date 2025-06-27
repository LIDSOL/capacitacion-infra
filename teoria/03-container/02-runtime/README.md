# Opciones de Runtime y Gestión de Contenedores con Podman

## Introducción

En esta actividad aprenderás a utilizar las opciones de ejecución (runtime) de Podman para gestionar contenedores de manera avanzada. Explorarás cómo montar volúmenes, redirigir puertos, configurar redes personalizadas y utilizar Quadlet para integrar contenedores con systemd, permitiendo su gestión como servicios del sistema.

## Instrucciones

### 1. Montaje de Volúmenes

- **Objetivo**: Ejecutar un contenedor montando directorios y archivos del host.
- **Requisitos**:
    - Ejecuta un contenedor de `nginx` y monta un directorio local como `/usr/share/nginx/html` para servir contenido personalizado.
    - Monta un archivo de configuración personalizado de `nginx` desde el host.
- **Comando ejemplo**:

```bash
podman run --rm -d -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx
```

### 2. Redirección de Puertos

- **Objetivo**: Exponer servicios del contenedor en puertos del host.
- **Requisitos**:
    - Ejecuta un contenedor de `nginx` y accede a él desde el navegador en el puerto 8080 del host.
- **Comando ejemplo**:

```bash
podman run --rm -d -p 8080:80 nginx
```

### 3. Opciones de Red

- **Objetivo**: Explorar las opciones de red de Podman.
- **Requisitos**:
    - Lista las redes disponibles.
    - Crea una red personalizada y ejecuta dos contenedores en la misma red para que se comuniquen entre sí.
- **Comandos ejemplo**:

```bash
podman network ls
podman network create mi_red
podman run --rm -d --name web1 --network mi_red nginx
podman run --rm -it --network mi_red busybox sh
# Desde busybox, prueba: wget web1
```

### 4. Quadlet y systemd

- **Objetivo**: Gestionar contenedores como servicios de systemd usando Quadlet.
- **Requisitos**:
    - Crea un archivo `.container` de Quadlet para definir un contenedor como servicio.
    - Habilita y gestiona el servicio con systemd (`systemctl --user`).
- **Pasos**:
    1. Crea un archivo `nginx.container` en `~/.config/containers/systemd/` con el siguiente contenido:

```ini
[Container]
Image=nginx
PublishPort=8080:80
Volume=%h/html:/usr/share/nginx/html:ro
```

    2. Recarga los servicios y habilita el contenedor:

```bash
systemctl --user daemon-reload
systemctl --user enable --now nginx.container
systemctl --user status nginx.container
```

### 5. Instalación de WordPress con Podman

- **Objetivo**: Desplegar una aplicación real multi-contenedor utilizando Podman, redes personalizadas y volúmenes.
- **Requisitos**:
    - Crea una red personalizada llamada `wpnet`.
    - Crea un volumen para los datos de la base de datos (`wp-dbdata`).
    - Lanza un contenedor de base de datos MariaDB configurado para WordPress.
    - Lanza un contenedor de WordPress conectado a la misma red y enlazado a la base de datos.
    - Expón WordPress en el puerto 8081 del host.
- **Comandos ejemplo**:

```bash
# Crear red y volumen
podman network create wpnet
podman volume create wp-dbdata

# Lanzar base de datos
podman run -d --name mariadb --network wpnet \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v wp-dbdata:/var/lib/mysql \
  docker.io/library/mariadb:11

# Lanzar WordPress
podman run -d --name wordpress --network wpnet \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  -p 8081:80 \
  docker.io/library/wordpress:6
```

- Accede a `http://localhost:8081` para completar la instalación de WordPress.

- **Opcional**: Crea archivos Quadlet para definir ambos servicios y gestionarlos con systemd.

## Archivos de entrega

2. **Archivos de configuración**:
    - Archivos de configuración personalizados utilizados (por ejemplo, archivos Quadlet, etc.).
3. **Documentación (`README.md`)**:
    - Este archivo, explicando los pasos y comandos utilizados.
