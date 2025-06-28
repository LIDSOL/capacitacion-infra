# Explicacion de archivos de entrega   
## Archivos Containerfile
* **Imagen1:** utiliza la imagen `debian:stable-slim` como base; establece que los comandos posteriores se deben ejecutar como root; realiza una actualizacion de las fuentes de `apt` e instala `htop`; crea la variable de entorno `TERM` y establece su contenido con el valor "linux"; establece que al iniciar un contenedor construido a base de esta imagen se ha de ejecutar el programa `htop`

* **Imagen2:** utiliza la imagen `debian:stable-slim` como base; establece que los comandos posteriores se deben ejecutar como root; realiza una actualizacion de las fuentes de `apt` e instala `nginx`; establece que los contenedores construidos a base de esta imagen han de **recibir trafico** de la red en el **puerto 80**; copia los archivos `index.html` y `lidsol_logo.png` presentes en el directorio de la maquina host en el cual se encuentra el Containerfile al directorio `/var/www/html` de la imagen; establece que al iniciar un contenedor construido a base de esta imagen se ha de ejecutar el programa `nginx` con el argumento `-g daemon off`;

* **Imagen3:** utiliza las **mismas instrucciones** que el Containerfile de la **Imagen 2** para instalar y ejecutar `nginx`, con la differencia de no copiar archivos; establece que los directorios `/var/www/html` y `/etc/nginx` de los contenedores construidos a base de esta imagen han de ser **mountpoints** para volumenes externos a estos contenedores

* **Imagen4:** en la *primer etapa*, utiliza la imagen `gcc:13.4.0` como base; establece `/src` como el directorio de trabajo; copia el archivo `container-hello.c`
presente en el directorio de la maquina host en el cual se encuentra el Containerfile al directorio `/src` de la imagen; compila y enlaza estaticamente el archivo fuente en un archivo ejecutable; en la *segunda etapa*, utiliza una imagen vacia; se copia el archivo ejecutable creado en la *primer etapa* a la imagen vacia y se establece que los contenedores construidos a base de esta imagen han de ejecutar el archivo mencionado al ser iniciados

## Commandos `podman`
**[todas las imagenes]:** `podman build --tag [nombre_de_imagen] .` construye una imagen con el nombre `[nombre_de_imagen]` a partir del Containerfile presente en el directorio actual

* **Imagen 1 y 4:** `podman run --rm localhost/[imagen1|imagen4]` instancia un contenedor a base de la imagen especificada y lo ejecuta; al concluir la ejecucion, se elimina el contenedor instanciado

* **Imagen 2:** `podman run --detach --publish [puerto_host]:[puerto_contenedor] localhost/imagen2` instancia un contenedor a base de imagen2 y lo ejecuta como un proceso por separado; a un puerto de la maquina host se mapea un puerto del contenedor instanciado (en este caso el puerto ocupado por nginx)

* **Imagen 3:** `podman run --detach --volume=[volumen_contenido_estatico]:/var/www/html --volume=[volumen_nginx_conf]:/etc/nginx --publish [puerto_host]:[puerto_contenedor] localhost/imagen3` instancia un contenedor a base de imagen3, lo ejecuta como un proceso por separado y mapea un puerto de la maquina host a un puerto del contenedor; se montan 2 volumenes (`[volumen_contenido_estatico]` y `[volumen_nginx_conf]`) en los directorios del contenedor especificados, habilitando el acceso a estos desde la maquina host
