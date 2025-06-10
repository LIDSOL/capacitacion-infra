# Explicacion de archivos de entrega

**main.yml:** playbook principal, realiza imports de los archivos que contienen los tasks

**inventory.ini:** contiene IPs de las VM; se indica la ruta de la clave ssh a utilizar para acceder a las VM

#### archivos de tasks
* **config-sshd.yml:** 4 tasks de `lineinfile`; se modifican renglones de la configuracion de sshd existente; se reinicia sshd.service
* **config-ua.yml:** 2 tasks de `lineinfile`; se quita el simbolo de comentario (//) de 2 lineas de la configuracion de unattended-upgrades existente
* **firewall.yml:** se utiliza el modulo `iptables` para para configurar la filtracion de la cadena INPUT
* **install-nginx.yml:** se installa nginx, se modifica el archivo `index.nginx-debian.html` de acuerdo a la plantilla `wp_template.j2`, se modifica el estado de nginx.service: reloaded + started
* **wp_template.j2:** plantilla para generar contenido web estatico con modificaiones especificas a cada VM

## ejecutar palybook: ansible-playbook -i inventory.ini main.yml
