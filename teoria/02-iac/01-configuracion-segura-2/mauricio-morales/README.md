# Ansible IaC 1

## Inventario

El inventario `inventory.yml` contiene las direcciones IP de las VM y el usuario (`debian`) que comparten cada una de ellas.

## Playbooks

Se hace uso de un playbook principal llamado `main.yml`, en el que se importan las siguientes tareas:

- `unattended-upgrades.yml`
- `firewall.yml`
- `sshd.yml`
- `nginx.yml`

### `unattended-upgrades.yml`

Se encarga de la configuración de las actualizaciones automáticas. Utiliza el módulo `ansible.builtin.apt` para instalar los paquetes `unattended-upgrades` y `apt-listchanges` y modifica los archivos correspondientes para su correcto funcionamiento.

### `firewall.yml`

Configura el firewall utilizando el móulo `ansible.builtin.iptables`, permitiento las conexiones ya establecidas, las de la interfaz loopback y la de los puertos 22, 80 y 443 unicamente.

### `sshd.yml`

Configura de manera segura el servicio sshd, añadiendo al final del archivo `/etc/ssh/sshd_config` las configuraciones correspondientes, con el módulo `ansible.builtin.blockinfile`.

### `nginx.yml` 

Se encaga de la configuracion de un servidor web con nginx. El módulo `ansible.builtin.apt` instala el paquete nginx. Se crea el archvio `index.html` a partir de la plantilla `/templates/index-template.j2`. El servicio nginx se inicia y se habilita con ayuda del módulo `ansible.builtin.service`.

#### Plantilla `index-template.j2`

Plantilla de archivo HTML en la cual se muestra el `ansible_host` en el titulo y el `inventory_hostname` en el contenido de la página.

## Ejecución del playbook principal

`ansible-playbook -i inventory.yml main.yml`
