
>Actividad 1
Se utilizarón tres archivos para esta actigivas, 01-nginx, index.html, nginx.conf
        -EL archivo 01-nginx es el contenedor que ingresa a nginx.conf y obtener las configuraciones de ahí, igual genera una imgen de nginx
        -En index.html esta el contenido para el html que se va a mostrar 
        -En nginx.conf esta la configuración necesaria para un html en nginx
Para montar los archivos 
Primer forma, creamos una imagen propia y la ejecutamos 
podman build -f 01-nginx -t mi-nginx
podman run -d -v ~/index.html:/usr/share/nginx/html -p 8080:80 mi-nginx


Segunda opción, usamos la imagen oficial de nginx desde Docker Hub
podman run --rm -d -p 8080:80 -v $(pwd)/index.html:/usr/share/nginx/index.html:ro -v $(pwd)/nginx.conf:/etc/nginx.conf:ro nginx
>Actividad 2
Se usaron los archivos de la actividad anterior y se siguieron los mismos pasos solo que en esta ocación al final, cuando se montan los archivos, en la parte de podman run hay unos cambios para poder elejir otro puerto 
Para el caso 1
podman run -d -v ~/index.html:/usr/share/nginx/html -p 8081:80 mi-nginx
Para el caso 2 
podman run --rm -d -p 8081:80

Se mapea el puerto 80 del contenedor al pueto 81 del host 
>Actividad 3

	-Se siguierón los paso que se presentan en la asignación las redes se nombraron cómo nginx1 y nginx2 con el comando "podman run --rm -d --name web1 --network mi_red nginx"
	-Se ingreso a busybox sh con el comando "podman run --rm -it --network mi_red busybox sh" y para probar cada una de las redes se uso el comando "wget -O - nginx1"con los nombres r	espectivos de la red
Que se observó al final.	
Al ejecutar el comando podman rum -rm -it --network mi_red busybox se observa la conexion de ambos contenedores, y se puede observar el archivo html de ambos

>Actividad 4

	-Se creo un archivo nginx.container en la dirección ~/.config/containers/systemd/, el contenido se encuentra en la carpeta 04-quadlet 
	en el archivo se uso la imagen oficial de nginx en el puerto 81 y se monto una carpeta como contenigo web 
	-Se recargo el sistemd con systemctl --user daemon-reload
	-y se activó el sistema con systemctl --user enable --now nginx.service, el nombre final de nginx.container es nginx.service que se transforma al recargar sistemd 

Finalmente se puede observar el sitio web con http://localhost:8081

>Actividad 5 
Siguiendo los pasos que se indicaron en la actividad se logró instalar WordPress de manera exitosa
Una ves ingresando a http://localhost:8081 se observa la pantalla de configuración de WordPress donde seleccionas el idioma y despues pide unos datos para finalmente llegar a la pantalla de inicio 

