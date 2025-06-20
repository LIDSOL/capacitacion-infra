# 02 Debugging de Red con Ansible

## Playbooks

### `bug-injection.yml`

Se encarga de copiar el servicio `bug.service` a la carpeta `/etc/systemd/system/` y de activarlo.

### `network-watchdog.yml`

Es el encargado de copiar el servicio `net-watchdog.service` y el timer `net-watchdog.timer` a `/etc/systemd/system/` y de iniciar y habilitar el timer. De igual manera copia el script `network-watchdog.sh` a `/usr/local/bin`.

## Archivos extras

### Servicio y timer `net-watchdog`

- **`net-watchdog.service`**: es el servicio encargado de ejecutar el script `network-watchdog.sh`.

- **`net-watchdog.timer`**: es el timer encargado de iniciar cada 30 segundos el servicio `net-watchdog.service`.

### Script

El script `network-watchdog.sh` se ocupa de verificar mediante el comando `ping` si hay conexión a internet. En caso de que no haya, reinicia la interfaz de red con el comando `ip`.

## Pruebas

Para probar el sistema de troubleshooting descrito anteriormente, primero es nesarios indicar los host dentro del archivo `inventory.yml`.

### Bug Injection

`ansible-playbook -i inventory.yml bug-injection.yml`

### Watchdog

`ansible-playbook -i inventory.yml network-watchdog.yml`
