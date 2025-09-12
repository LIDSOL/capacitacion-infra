# 1. Montaje de Volúmenes

Para el montaje de volumenes se utiliza -v. En este ejemplo se utiliza para indicar que la carpeta `html` en el host se utilizará dentro del contenedor en la carpeta `/usr/share/nginx/html`. Lo mismo con el archivo `nginx.conf` y `/etc/nginx/nginx.conf`.

~~~
podman run -d -p 8080:80 \
  -v ./html:/usr/share/nginx/html:ro \
  -v ./nginx.conf:/etc/nginx/nginx.conf:ro \ nginx
~~~

Para comprobar que funcionó y que se cargó el archivo de configuración correspondiente y el html, se puede verificar en el navegador (localhost:8080)

# 2. Redirección de puertos

Para la redireccióń de puertos se utiliza -p, que permite indicar que puertos del host exponen que puertos del contenedor. En este ejemplo se usó nginx y se expuso el puerto 80 en el 8080 del host.

~~~
podman run --rm -d -p 8080:80 nginx
~~~

Igual que en el anterior ejemplo, para comprobar que funcionó se puede verificar en el navegador.

# 3. Opciones de Red

Para administrar redes de contenedores se usa `podman network`. Para este ejemplo se crea la red `mi_red` y se prueba con un contenedor de `nginx` y `busybox` dentro de la red.

~~~
podman network ls
podman network create mi_red
podman run --rm -d --name web1 --network mi_red nginx
podman run --rm -it --network mi_red busybox sh
~~~

Desde busybox, al ejecutar `wget web1`, se puede ver que se realiza la petición al web server del contenedor de `nginx` y devuelve el html.

Un detalle importante a tener en mente es que debe de estar instalado el paquete de `aardvark-dns` que es el que hace que haya un dns que permite usar el nombre del contenedor `web1` en el comando `wget` en lugar de la ip.

# 4. Quadlet y systemd

Para probar la gestión de contenedores como servicios de systemd se utiliza Quadlet.

Para el ejemplo, debe existir el archivo `~/.config/containers/systemd/nginx.container` y la carpeta `~/html` la cual será montada como volumen en dicho archivo.

Una vez con el archivo y la carpeta, se pueden recargar los servicios.

~~~
systemctl --user daemon-reload
~~~

Al recargar los servicios del usuario, se genera el servicio a partir del archivo `.container` y ya sólo resta iniciarlo.

~~~
systemctl --user enable --now nginx.service
systemctl --user status nginx.service
~~~

# 5. Instalación de WordPress con Podman

Para ello se crea la red  por la que se comunicaran y el volumen para la base de datos con los siguientes comandos.

~~~
podman network create wpnet
podman volume create wp-dbdata
~~~

Después se inicia el contenedor de la base de datos, con las variables de entorno necesarias para configurarla correctamente

~~~
podman run -d --name mariadb --network wpnet \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v wp-dbdata:/var/lib/mysql \
  docker.io/library/mariadb:11
~~~

Y lo mismo con el con contenedor de WordPress, que se conecta con la base de datos a través de la red `wpnet` creada anteriormente y con ayuda de las variables de entorno que contienen el host, el nombre de la DB, el usuario y la contraseña.

~~~
podman run -d --name wordpress --network wpnet \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  -p 8081:80 \
  docker.io/library/wordpress:6
~~~

Para probarlo se abre en el navegador (localhost:8081) yya se puede terminar de configurar WP.
