# Primeros pasos
Instalé podman y verifiqué su correcta instalación, como se indica en el README.
```bash
sudo pacman -S podman
podman run --rm docker.io/library/hello-world
```
# Imágenes
Cree cuatro directorios, uno por cada imágen:
```bash
├── 1-htop
│   └── dockerfile
├── 2-nginx
│   ├── dockerfile
│   └── index.html
├── 3-nginx+
│   ├── Containerfile
│   ├── index.html
│   └── nginx.conf
├── 4-hello-world
│   ├── Containerfile
│   └── main.rs
└── README.md
```

## 1: Imágen HTOP en Debian.
Estando en el directorio *1-htop*, se crea un archivo con el nombre *dockerfile* con el siguiente contenido:
```dockerfile
# Usa la imagen base de Debian stable-slim
FROM debian:stable-slim

# Actualiza el sistema e instala htop
RUN apt-get update && \
    apt-get install -y htop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Establece el comando por defecto para ejecutar htop
CMD ["htop"]
```

Con el siguiente comando construimos la imágen:
```bash
podman build -t htop-debian-contenedor -f dockerfile .
```

Ahora podemos ejecutar el contenedor, veremos htop:
```bash
podman run -it htop-debian-contenedor:latest
```

## 2: nginx estático
Estando ubicado en el directorio 2-nginx, se crean los archivos *index.html* y *dockerfile*. El contenido de *index.html* es el siguiente:
```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página de ejemplo 🧑‍💻 </title>
    <style>
        body {
            font-family: 'Courier New', Courier, monospace;
            background-color: #e0e0e0;
            color: #333;
            margin: 0;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #4CAF50;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 10px;
        }
        .post {
            background: #fff;
            margin: 15px 0;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
        }
        .post h2 {
            color: #4CAF50;
            margin: 0 0 10px;
        }
        .post p {
            margin: 5px 0;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 0.8em;
            color: #777;
        }
    </style>
</head>
<body>
    <h1>Página de ejemplo - Contenedores</h1>
    <div class="post">
        <h2>Este index.html se usará en un contenedor </h2>
        <p>Este es un ejemplo de página web que nginx usará como página por defecto</p>
    </div>
    <div class="post">
        <h2>Debian</h2>
        <p>Se está usando Debian (stable slim) como imagen base</p>
    </div>
    <div class="post">

    <div class="footer">
        <p>Capacitación LIDSOL</p>
    </div>
</body>
</html>
```
El contenido del archivo dockerfile es el siguiente:
```docker
# Usa la imagen base de Debian estable
FROM debian:stable

# Actualiza el sistema e instala Nginx
RUN apt-get update && \
    apt-get install -y nginx neovim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia el archivo index.html y la imagen al directorio de Nginx
COPY index.html /var/www/html/index.html
                                                                        
# Expone el puerto 80
EXPOSE 80

# Inicia Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
```

Ahora construimos la imagen: 
```bash
podman build -t nginx-web -f dockerfile .
```

En este caso, para iniciar el contenedor se usa el siguiente comando: 
```bash
 podman run -d -p 8080:80 --name nginx-web localhost/nginx-web:latest
```
Con el comando anterior se mapea el puerto 80 del contenedor al puerto 8080 de la máquina host; esto significa que cualquier tráfico que llegue al puerto 8080 del host se redirigirá al puerto 80 del contenedor, donde Nginx está escuchando.

Para saber cual es la IP, hice:
```bash
podman ps #se busca la ID del contenedor 
podman exec -it <ID> /bin/bash
root@<ID># ip a
```
Una vez que el contenedor esté en ejecución, se puede acceder a la página desde el navegador con *http://<IP>:8080*.

## 3: nginx mejorado
Estando ubicado en el directorio 3*-nginx+* se crean los siguientes tres archivos *Containerfile*, *index.html*, *nginx.conf*. 

Containerfile
```Containerfile
# Usa la imagen base de Debian estable
FROM debian:stable

# Actualiza el sistema e instala Nginx                                     RUN apt-get update && \
    apt-get install -y nginx && \                                              apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Expone el puerto 80                                                      EXPOSE 80
                                                                           # Define los volúmenes para el contenido web y la configuración de Nginx
VOLUME ["/var/www/html"]                                                   VOLUME ["/etc/nginx/conf.d"]
                                                                           # Copia el archivo de configuración de Nginx (opcional, puedes montarlo desde el host)                                                                COPY nginx.conf /etc/nginx/nginx.conf
                                                                           # Inicia Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
```

index.html
```html
<!DOCTYPE html>
<html lang="es">
<head>                                                                         <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página de ejemplo 🧑‍💻 </title>
    <style>
        body {
            font-family: 'Courier New', Courier, monospace;                            background-color: #e0e0e0;
            color: #333;                                                               margin: 0;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #4CAF50;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 10px;
        }
        .post {
            background: #fff;
            margin: 15px 0;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
        }
        .post h2 {
            color: #4CAF50;
            margin: 0 0 10px;
        }
        .post p {
            margin: 5px 0;
        }
        .footer {                                                                      text-align: center;
            margin-top: 20px;
            font-size: 0.8em;                                                          color: #777;
        }
    </style>
</head>
<body>
    <h1>Página de ejemplo - Contenedores</h1>
    <div class="post">
        <h2>Este index.html se usará en un contenedor </h2>
        <p>Este es un ejemplo de página web que nginx usará como página por defecto</p>
    </div>
    <div class="post">
        <h2>Debian</h2>
        <p>Se está usando Debian (stable slim) como imagen base</p>
    </div>
    <div class="post">

    </div>

    <div class="footer">
        <p>Capacitación LIDSOL</p>
    </div>
</body>
</html>
```

nginx.conf
```conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /var/www/html;
            index index.html index.htm;
        }
    }
}
```

Construmos la imágen con el siguiente comando:
```bash
podman build -t nginx-2 .
```

Iniciamos
```bash
podman run -p 8080:80 -v ./index.html:/var/www/html/index.html -v ./nginx.conf:/etc/nginx/nginx.conf localhost/nginx-2:latest
```

En este caso, se puede ver el contenido de la página desde el navegador con *http://127.0.0.1:8080*, o en la terminal con el comando *curl http://127.0.0.1:8080*.

## 4: Hola mundo
Estando ubicado en el directorio *4-hello-world*, se crean los siguientes dos archivos:

Un main.rs:
```rust
fn main() {
    println!("Hola, mundo!");
}
```

Y un archivo Containerfile:
```rust
# Etapa de construcción
FROM rust:1.70 as builder

# Establecer el directorio de trabajo
WORKDIR /usr/src/hello

# Copiar el archivo fuente
COPY main.rs .

# Instalar el objetivo musl
RUN rustup target add x86_64-unknown-linux-musl

# Compilar el programa de forma estática
RUN cargo new --bin hello && \
    mv main.rs hello/src/main.rs && \
    cd hello && \
    cargo build --release --target=x86_64-unknown-linux-musl

# Etapa final
FROM scratch

# Copiar el binario compilado desde la etapa de construcción
COPY --from=builder /usr/src/hello/hello/target/x86_64-unknown-linux-musl/release/hello .

# Comando por defecto
CMD ["./hello"]
```

Construmos la imágen con el siguiente comando:
```rust
podman build -t rust-hello .
```

Después se ejecuta el contenedor: 
```rust
podman run --rm rust-hello:latest
```
