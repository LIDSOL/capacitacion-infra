# Explanation of Podman Commands

## Volumes and Ports

Mounting a volume inside a container means that in very simplified terms,
you connect a directory to another inside the container, so that they share 
information between them. This allows us to save information from a container even when we delete it, and also we can modify the container from outside without
the necessity of executing a bash terminal in the container.

Port mapping is an important aspect because it's kind of a connection between your host and container. So when you want to see the work of your container beyond a simple message, you need to establish a port and through that port you can see the work. For instance, when you develop a web page and
need the IP, you can't connect using the IP of the container; you must use the IP of your own host and use the port that connects to your container so that you can see the web page.

```
podman run --rm -d -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx
```

Explaining the flags:
- -p: is for mapping the ports from the host to the container ``` hostport:containerport ```
- -v: is for mounting the volumes in the form ``` hostvolume:mounting_dir ```

## Networks

In Podman and Docker we can connect our containers through networks. Each container can send information or download information from the other one. A network uses a device which specifies restrictions in the type of information you can access.

For creating a new network
```
  podman network create mi_red
```
This command is for attaching a container 
```
  podman run --rm -d --name web1 --network mi_red web
```
Explaining the flags:
- --network: specifies the name of the network

Suppose you attach two containers to the same network. The first is a web server and the second opens a terminal for you. If you execute ```wget name_webserver``` you can download the html content. 

## Quadlet

Quadlet is a tool for using systemd with Podman, so that
you can have services that automatically manage containers. Quadlet defines the
```.container``` files for writing your Podman services.

A simple Quadlet file would be:
```
  [Container]
  Image=nginx
  PublishPort=8080:80
  Volume=%h/html:/usr/share/nginx/html:ro
```
- ```[Container]``` : defines the section that keeps the container configuration.

- ``` Image=nginx ```: defines that our container will use the nginx image
- ``` PublishPort ```: defines the port mapping, in this case we will be able to see our web page on port 8080.
- ``` Volume ```: defines that our container will have a volume from the user's html directory.

Executing this service will allow you to see a webpage on port 8080. The web page will display the content inside your own html directory.

## WordPress

This activity was the union of previous ones, where you connect two containers through a network. One manages a database using volumes for saving all the information, and the other one manages web pages.
 
```
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
The only new flag here is:
- -e: Specifies environment variables for the container