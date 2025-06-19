# Dependencias 
Para que todo funcione correctamente, instalé las siguientes dependencias: 
```bash
sudo pacman -S wget virt-install virt-manager qlibvirt qemu-img qemu dnsmasq iptables ansible
```
# Configuraciones previas
## Configuraciones de red
Se habilita e inicia el servicio libvirt, se agrega el usuario a los grupos necesarios, se reinicia el servicio. 
```bash
sudo systemctl enable --now libvirtd.service
sudo usermod -aG libvirt $(whoami) 
sudo usermod -aG kvm $(whoami)
sudo systemctl restart libvirtd.service
```
Se crea la red *default* con el archivo XML predeterminado para libvirt
```bash
sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
sudo virsh net-start default
sudo virsh net-autostart default
```
# SSH 
Para poder iniciar sesión correctamente: 
Se crea una llave pública:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/vm_key -N ""  # Sin contraseña para automatización
```
Se modifica el scrip *gen.sh*, editando la variable
```bash
SSH_PUBLIC_KEY="$(cat ~/.ssh/vm_key.pub)"
```
Se configura el acceso directo desde *~/.ssh/config*
```bash
Host 192.168.122.*
  User debian
  IdentityFile ~/.ssh/vm_key
  StrictHostKeyChecking no
```
# Configuración con ansible
El proyecto tiene la siguiente estructura:
```bash
├── ansible.cfg
├── group_vars
│   └── all.yml
├── inventory-generator.sh
├── inventory.ini
└── playbooks
    ├── roles
    │   ├── auto_updates  # Actualizaciones automáticas
    │   │   └── tasks
    │   │       └── main.yml
    │   ├── firewall     # Configuración de nftables
    │   │   ├── tasks
    │   │   │   └── main.yml
    │   │   └── templates
    │   │       └── nftables.conf.j2
    │   ├── nginx       # Instalación y configuración de Nginx
    │   │   ├── handlers
    │   │   │   └── main.yml
    │   │   ├── tasks
    │   │   │   └── main.yml
    │   │   └── templates
    │   │       ├── index.html.j2
    │   │       └── nginx.conf.j2
    │   └── ssh_hardening   # Hardening de SSH
    │       ├── tasks
    │       │   └── main.yml
    │       └── templates
    │           └── sshd_config.j2
    └── site.yml    # Playbook principal
```

Archivo principal, playbooks/site.yml 

```yml
---
- name: Configurar todas las VMs Debian
  hosts: debian_vms
  become: true
  roles:
    - auto_updates
    - firewall
    - ssh_hardening
    - nginx
---
```
## 2. Roles y Tareas
### Role: auto_updates (roles/auto_updates/tasks/main.yml)
Configura actualizaciones automáticas de seguridad con unattended-upgrades:

```yml 
---
- name: Instalar unattended-upgrades
  apt:
    name: unattended-upgrades
    state: present

- name: Configurar actualizaciones automáticas
  copy:
    content: |
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Unattended-Upgrade "1";
      APT::Periodic::AutocleanInterval "7";
    dest: /etc/apt/apt.conf.d/20auto-upgrades
    mode: 0644

- name: Habilitar actualizaciones de seguridad
  lineinfile:
    path: /etc/apt/apt.conf.d/50unattended-upgrades
    regexp: '^Unattended-Upgrade::Allowed-Origins\s*{'
    line: 'Unattended-Upgrade::Allowed-Origins { "origin=Debian,codename=${distro_codename}-security"; };'
    backrefs: yes

- name: Reiniciar el servicio
  systemd:
    name: unattended-upgrades
    enabled: yes
    daemon_reload: yes
```

###  Role: firewall (roles/firewall/tasks/main.yml)
Configura nftables para permitir SSH, HTTP y HTTPS:

```yml
---
- name: Instalar nftables
  apt:
    name: nftables
    state: present

- name: Copiar configuración de firewall
  template:
    src: nftables.conf.j2
    dest: /etc/nftables.conf
    mode: 0644

- name: Aplicar reglas de firewall
  command: nft -f /etc/nftables.conf

- name: Habilitar nftables al inicio
  systemd:
    name: nftables
    enabled: yes
    state: started
```

Plantilla nftables.conf.j2:
```bash
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        # Conexiones establecidas/relacionadas
        ct state established,related accept

        # Loopback
        iif lo accept

        # SSH (22), HTTP (80), HTTPS (443)
        tcp dport { 22, 80, 443 } accept

        # ICMP (ping)
        ip protocol icmp accept
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }

    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
```

### Role: ssh_hardening (roles/ssh_hardening/tasks/main.yml)
Configuración segura de SSH:
```yaml 
---
- name: Instalar template de sshd_config
  template:
    src: sshd_config.j2
    dest: /etc/ssh/sshd_config
    mode: 0600
    validate: /usr/sbin/sshd -t -f %s

- name: Reiniciar SSH
  systemd:
    name: ssh
    state: restarted
```

Plantilla sshd_config.j2:

```bash
# Configuración segura de SSH
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
UsePAM yes
AllowUsers debian  # Ajusta según tu usuario
```

### Role: nginx (roles/nginx/tasks/main.yml)

Instala Nginx y configura una página personalizada:
```yaml
---
- name: Instalar Nginx
  apt:
    name: nginx
    state: present

- name: Copiar configuración de Nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    validate: nginx -t -c %s

- name: Crear directorio del sitio web
  file:
    path: /var/www/html
    state: directory
    mode: 0755

- name: Generar index.html personalizado
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    mode: 0644

- name: Reiniciar Nginx
  systemd:
    name: nginx
    state: restarted
    enabled: yes
```

Plantilla index.html.j2 (personalizada por VM):
```html
<!DOCTYPE html>
<html>
<head>
    <title>VM {{ inventory_hostname }}</title>
</head>
<body>
    <h1>Bienvenido a {{ inventory_hostname }}</h1>
    <p>Hostname: {{ ansible_hostname }}</p>
    <p>IP: {{ ansible_default_ipv4.address }}</p>
    <p>Este servidor fue configurado automáticamente con Ansible</p>
    <p>Mensaje único: "{{ custom_message }}"</p>
</body>
</html>
```

## Ejecución del proyecto 
Para generar el inventario se usa el script *inventory-generator.sh*: 

```bash 
#!/bin/bash

# Destino del inventario
INVENTORY_FILE="inventory.ini"

# Encabezado del archivo
echo "[debian_vms]" > "$INVENTORY_FILE"

# Obtener IPs de las VMs (ajusta el filtro 'debian-vm-' según tus nombres)
for vm in $(sudo virsh list --name | grep "^debian-vm-"); do
    ip=$(sudo virsh domifaddr "$vm" | awk '/ipv4/ {print $4}' | cut -d'/' -f1)
    echo "$ip ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_rsa" >> "$INVENTORY_FILE"
done

echo "Inventario generado en: $INVENTORY_FILE"
cat "$INVENTORY_FILE"
```
Así generamos el archivo *inventory.ini*, el contenido (en este caso), sería el siguiente: 
```bash
[debian_vms]
192.168.122.176 ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_rsa
192.168.122.179 ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_rsa
192.168.122.234 ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Por último ejecutamos el ansible-playbook de la siguiente manera: 
```bash
ansible-playbook -i inventory.ini playbooks/site.yml 
```
En este caso, la salida sería la siguiente:
```bash 
TASK [auto_updates : Instalar unattended-upgrades] ***********************************
ok: [192.168.122.234]
ok: [192.168.122.179]
ok: [192.168.122.176]

TASK [auto_updates : Configurar actualizaciones automáticas] *************************
ok: [192.168.122.234]
ok: [192.168.122.179]
ok: [192.168.122.176]

TASK [auto_updates : Habilitar actualizaciones de seguridad] *************************
ok: [192.168.122.179]
ok: [192.168.122.234]
ok: [192.168.122.176]

TASK [auto_updates : Reiniciar el servicio] ******************************************
ok: [192.168.122.179]
ok: [192.168.122.176]
ok: [192.168.122.234]

TASK [firewall : Actualizar repositorios] ********************************************
ok: [192.168.122.176]
ok: [192.168.122.179]
ok: [192.168.122.234]

TASK [firewall : Instalar nftables] **************************************************
ok: [192.168.122.179]
ok: [192.168.122.176]
ok: [192.168.122.234]

TASK [firewall : Instalar nftables] **************************************************
ok: [192.168.122.234]
ok: [192.168.122.179]
ok: [192.168.122.176]

TASK [firewall : Copiar configuración de firewall] ***********************************
ok: [192.168.122.179]
ok: [192.168.122.176]
ok: [192.168.122.234]

TASK [firewall : Aplicar reglas de firewall] *****************************************
changed: [192.168.122.179]
changed: [192.168.122.176]
changed: [192.168.122.234]

TASK [firewall : Habilitar nftables al inicio] ***************************************
ok: [192.168.122.234]
ok: [192.168.122.179]
ok: [192.168.122.176]

TASK [ssh_hardening : Instalar template de sshd_config] ******************************
ok: [192.168.122.176]
ok: [192.168.122.179]
ok: [192.168.122.234]

TASK [ssh_hardening : Reiniciar SSH] *************************************************
changed: [192.168.122.176]
changed: [192.168.122.179]
changed: [192.168.122.234]

TASK [nginx : Instalar Nginx] ********************************************************
ok: [192.168.122.234]
ok: [192.168.122.176]
ok: [192.168.122.179]

TASK [nginx : Copiar configuración de Nginx] *****************************************
ok: [192.168.122.176]
ok: [192.168.122.179]
ok: [192.168.122.234]

TASK [nginx : Crear directorio del sitio web] ****************************************
ok: [192.168.122.176]
ok: [192.168.122.179]
ok: [192.168.122.234]

TASK [nginx : Generar index.html personalizado] **************************************
ok: [192.168.122.176]
ok: [192.168.122.179]
ok: [192.168.122.234]

TASK [nginx : Reiniciar Nginx] *******************************************************
changed: [192.168.122.179]
changed: [192.168.122.176]
changed: [192.168.122.234]

PLAY RECAP ***************************************************************************
192.168.122.176            : ok=18   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.122.179            : ok=18   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.122.234            : ok=18   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


