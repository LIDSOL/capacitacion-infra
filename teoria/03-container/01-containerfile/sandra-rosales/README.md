Introducción: Para esta actividad se crearon los siguientes containerfiles
Se usa podman para la ejecució de cada uno de los contenedores
#01-htop
En este archivo se crea una imagen simple usando como imagen base debian:stable-slim
> Que realiza este containerfile
	. usa "debian:stable-slim" como imagen base 
	. actualiza el sistema e instala htop 
	. se usa CMD para que el contenedor se ejecute por defecto 
> Cómo ejecutar 
 Para ejeceutar el contenedor se usa
	. podman build -t htop  #Construye la imagen
	. podman run -it --name 01-htop htop #Crea e inicia el contenedor
# 02-servidor
Este archivo se encuentra dentro de la carpeta 02-servidor-opersonalizado
Al igual que en el archivo anterior se crea una imagen simple con la diferencia que esta imagen es utilizada para una página web estática 

> Que realiza 
	. Usa "debian:stable-slim" como imagen base
	. Actualiza el sistema e instala nginx para el servidor
	. Copia el archivo "index.html"
	. usa el puerto 80 hacer la conexión para el servidor 
	. Se usa CMD["nginx","-g","daemin off;] para ejecutar el contenedor en primer plano y que no se ejecute cómo demonio 

> Archivo index.html 
Es un archivo html estático que se usa como página principal dentro del servidor 

> Cómo ejecutar 
	.podman build -t nginx-imagen -f 02-servidor #Construye la imagen le asignamos el nombre de nginx-imagen 
	.podman run -d -p 8080:80 nginx-imagen #Crea e inicia el servidor y mapea el puerto 8080 del host al puerto 80 del contenedor
#03-servidor
Este archivo se encuentra dentro de la carpeta 03-servidor-volumenes
Tomá cómo basé él archivo anterior con la diferencia que usa volumenes para un contenido dinámico desde el host 
>Qué realiza 
	-Tomando cómo basé lo anteriór explicado.con la diferencia de que no copia en archio "index.html"
	-Usa 2 volumenes uno para html con VOLUME /var/www/html
         y otro para nginx con VOLUME etc/nginx/nginx.conf

>Archivo index.html
Este directorió es el mismo que se utilizó para la actividad anterior pero se personalizó para esta actividad

>Archivo nginx.conf
Cóntiene las configuraciones básicas para un servidor  html estático 

>Cómo ejecutar
	.podman build -t nginx-volumenes -f 03-servidor #Construye la imagen lo nombramos nginx-volumenes
	.podman run -d -p 8080:80 -v $(pwd)/index.html:/var/www/html/index.html -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx-volumenes
	#Crea e inicia el contenedor 
#04-scratch
Se crea una imagen de contenedor mínimos usando la compilación multi-etapa

>Que realiza el contenedor 
	
	En la etapa 1 
	.Con WORKDIR direcciona el trabajo a /src
	. se copya el archivo hola.c
	. Se compil el código de manera estatica con gcc 
	
	Etapa 2
	.Se crea la imagen minima usando como base scrath
	.Se copia el binario con COPY
	.Con "CMD" se ejecuta el binario 
> Archivo hola.c
 Es un archivo "hola mundo" en lenguaje C 

> Cómo se ejécuta
	. podman build -t hola-c -f containerfile  #construye la imagen
	.podman run --rm hola-c #Crea e incia el contenedor 
 
	
