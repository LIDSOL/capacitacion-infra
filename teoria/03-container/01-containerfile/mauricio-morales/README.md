# Containerfiles

Se crearon los siguientes containerfiles:

> Se utilizaron buenas prácticas como agrupar comandos en la instruccion `RUN` y eliminar el caché generado por `apt-get update`, con el objetivo de reducir capas y tamaño en la imagen.

## 01. htop

Es un containerfile sencillo, pues simplemente utiliza la imagen `debian:stable-slim` e instala la herramienta `htop`, para ejecutarla al iniciar el contenedor con la instruccióń `CMD`.

**Creación del contenedor**:

``` bash
cd 01-htop
podman build -t htop . # Construye la imagen
podman run -it --name 01-htop htop # Crea e inicia el contenedor
```

## 02. Nginx

Dentro del containerfile, de manera similar al anterior, se utiliza la imagen `debian:stable-slim` y se instala `nginx`.

También se copia el template `index.html` a `/var/www/html/` dentro del contenedor pasa usarlo como página principal dentro del servidor.

Para poder acceder al sitio web, se utiliza en `EXPOSE` el puerto `80` estándar para HTTP, el cual se mapea en la creaciión del contenedor al puerto `8080` del host.

Debido a que la imagen mencionada no cuenta con `systemctl` para administrar el demonio de `nginx`, el servidor web se inicia con ayuda de la instrucción `CMD ["/bin/nginx", "-g", "daemon off;"]`, la cual permite lanzar `nginx` en el foreground para que el proceso principal siga corriendo.

**Creación del contenedor**:

``` bash
cd 02-nginx
podman build -t nginx-custom-html . # Construye la imagen
podman run -it -p 8080:80 --name 02-nginx nginx-custom-html # Crea e inicia el contenedor
```

## 03. Nginx con volúmenes

Es similar al containerfile anterior, simplemente se agregan las instrucciones `VOLUME /var/www/html` y `VOLUME /etc/nginx/nginx.conf` para indicar que ese directorio y ese archivo seran volúmenes.

Dentro del host, los volumenes son el directorio `html` y el archivo `nginx.conf`. El directorio `html` contiene un archivo html que sirve como template para la página principal del servidor web. Por otro lado, el archivo `nginx.conf` contiene las configuraciones básicas para el servidor web con `nginx`. A la hora de la creación de la imagen se especifica un *bind mount* a las rutas descritas.

**Creación del contenedor**:

``` bash
cd 03-nginx-volumes
podman build -t nginx-volumes . # Construye la imagen
podman run -it -p 8080:80 -v ./html:/var/www/html -v ./nginx.conf:/etc/nginx/nginx.conf --name 03-nginx nginx-volumes:latest # Crea e inicia el contenedor
```

## 04. Multi-Stage build

Este containerfile permite crear un contenedor minimo utilizando una compilación multicapa para programa de lenguaje C.

Para la primera etapa (**a**) se especifica la imagen de `gcc:14.2` y se utiliza el codigo del archivo `main.c` el cual es copiado a un archivo con el mismo nombre.

Posteriormente, en una instrucción `RUN` se compila el código de manera estática y se guarda el ejecutable en `/bin/hola`.

En la segunda etapa (**b**), se utiliza la imagen base `scratch` y se copia el binario mediante la instruccion `COPY --from=0 /bin/hola /bin/hola`, la cual permite copiar sólo el producto de la compilación a esta nueva etapa. Por último, con la instrucción `CMD` se ejecuta el binario recién copiado.

**Creación del contenedor**:

``` bash
cd 04-multi-stage-build
podman build -t hola-multi-stage . # Construye la imagen
podman run -it --name 04-hola-multi-stage hola-multi-stage:latest # Crea e inicia el contenedor
```

---

> Una vez creados los contenedores, se puede volver a ellos iniciándolos nuevamente con el comando `podman start -ai <NOMBRE/ID>`.
