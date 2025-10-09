
alias docker=podman

docker network create wpnet
docker volume create wp-data


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

