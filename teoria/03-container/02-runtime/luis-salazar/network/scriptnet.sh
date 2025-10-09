podman network ls
if podman network ls | grep -q mi_red; then
    podman network rm mi_red
fi
podman network create mi_red
podman run --rm -d --name web1 --network mi_red web
podman run --rm -it --network mi_red busybox sh