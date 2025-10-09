# Containerfile

## Podman Build

Podman build creates a Docker image from a Dockerfile.
The general form for the command is:
``` docker build -t name . ```

- -t is for adding a name to the image

## Podman Run

Podman run creates a new container from an existing image.
``` docker run -d -p 80:80 -v host_dir:container:dist image ```
- -d means to run the container in background
- -p means the port mapping
- -v means mounting directories using volumes

### htop

- I downloaded the htop package: `apt-get install htop`
- To execute htop as main process: `CMD [ "htop" ]`

### webserver

- I downloaded the nginx package: `apt-get install nginx`
- I passed the configuration file: `COPY conf/nginx.conf /etc/nginx/nginx.conf`
- To execute nginx: `CMD [ "nginx", "-g", "daemon off;" ]`
- Important to map the ports to see the web: `podman run -d -p 80:80 webserver`

### volumes

- I downloaded the nginx package: `apt-get install nginx`
- I established a directory as the mounting point for a volume: `VOLUME [ "/etc/nginx/sites-enabled", "/var/www/html" ]`
- To execute nginx: `CMD [ "nginx", "-g", "daemon off;" ]`
- Important to map the ports to see the web: `podman run -d -p 80:80 webserver`
- To connect the volumes:
`docker run -d -p 80:80 -v /home/usrvm/volumes/conf:/etc/nginx/sites-enabled -v /home/usrvm/volumes/static:/var/www/html`

### multistage

- I first downloaded debian:slim ``` FROM debian:stable-slim AS COMPILE ```
- I passed my c file and the compiled it 
``` COPY hola.c . ```
``` RUN gcc -static hola.c -o a.out ```

- Finally i just passed my exe to scratch
``` COPY --from=COMPILE /src/a.out . ```
