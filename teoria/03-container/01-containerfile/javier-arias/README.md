# Containerfile y la construcción de contenedores

### Imagen 1

Este Containerfile usa una versión liviana de Debian, actualiza los paquetes del sistema e instala htop, una herramienta para monitorear procesos en tiempo real. Al iniciar el contenedor, se abre directamente htop.

Comandos

```
podman build -t containerfile1 .
podman run --rm -it containerfile1
```

### Imagen 2

Este Containerfile crea una imagen ligera con Debian y Nginx. Primero actualiza los paquetes e instala Nginx, luego copia un archivo index.html al directorio web del servidor. Expone el puerto 80 y arranca Nginx en primer plano para que el contenedor siga activo.

Comandos

```
podman build -t containerfile2 .
podman run --rm -d -p 8080:80 --name servidor-web containerfile2
```

### Imagen 3

Este Containerfile crea una imagen con Debian y Nginx, instala el servidor web y define dos volúmenes: uno para el contenido (/var/www/html) y otro para la configuración (/etc/nginx/). Esto permite que tanto los archivos del sitio como la config de Nginx se puedan montar desde el host o compartir entre contenedores. Expone el puerto 80 y lanza Nginx en primer plano al iniciar

Comandos

```
podman build -t containerfile3 .
podman run --rm -d \
  -p 8080:80 \
  -v ./html:/var/www/html \
  --name servidor-web-volumen \
  containerfile3

```

### Imagen 4

Este Containerfile crea una imagen mínima que solo ejecuta un programa en C. Primero usa una imagen con GCC para compilar hello-world.c de forma estática, y guarda el binario en /bin/hello. Luego, en una segunda etapa, crea una imagen scratch la cual está vacía y copia solo el ejecutable.

Comandos

```
podman build -t containerfile4 .
podman run -it --name multi-stage containerfile4
```
