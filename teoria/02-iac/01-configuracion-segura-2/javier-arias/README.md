# Ansible IaC

### Archivos

* main.yml: Playbook principal desde el que se importan las tareas de los otros playbooks
* inventory.ini: Contiene las ip de las distintas máquinas virtuales.
* sshd.yml: Configuración del archivo `sshd_config`  usando lineinfile para reemplazar las conifguraciones especifcadas en el archivo.
* updates.yml: Configuración de `unattended-upgrades`. Se copia la configuración directamente al archivo.
* firewall.yml: Configuración de `nftables`. Se copia la configuración directamente al archivo.
* nginx.yml: Se instala nginx, se comprueba que el servicio esté activo y se crea el archivo html a partir de la plantilla sustituyendo las variables indicadas.
* index.html.j2: Plantilla de html para mostrar por medio del servidor web. Se indica el nombre de la máquina virtual desde donde se hostea.

### Ejecución del playbook
```
ansible-playbook -i inventory.ini main.yml
