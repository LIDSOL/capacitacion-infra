
podman run --rm -d -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx