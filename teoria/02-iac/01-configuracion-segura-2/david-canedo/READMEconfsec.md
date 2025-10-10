## Requisitos Previos
Antes de llevar a cabo el uso de los playbooks con Ansible es importante levantar las VMs con las cuales trabaremos, en este para generar las 3 VMs se usa el script **gen.sh** para inicializarlas:

```bash
bash gen.sh init
```
Previo a la creación, es indispensable contar con una **llave pública SSH** generada con:

```bash
ssh-keygen -t rsa -b 4096
```

Las llaves pueden nombrarse, por ejemplo, como _my_key_. Esto generará los archivos `my_key` y `my_key.pub`, los cuales deben copiarse al directorio `~/.ssh/` en la máquina host.

Posteriormente, el contenido de `my_key.pub` debe añadirse en el script **gen.sh**, en el apartado **SSH_PUBLIC_KEY**:

```bash
 SSH_PUBLIC_KEY="ssh-rsa AAAAAA.... usuario@host"
```

Una vez configurada la llave, se procede a la creación de las VMs:

```bash
bash gen.sh init
bash gen.sh create
```

El proceso de creación puede tardar algunos minutos. Para verificar que las VMs se hayan creado correctamente, se utiliza:

```bash
bash gen.sh info
```

## Configuración Previa

Con las VMs ya creadas, dentro de la carpeta que contiene los archivos descargados se puede iniciar la validación de conexión mediante Ansible. Para ello se ejecuta:

```bash
./app.sh ping
```

Lo que generara una conexión ssh con cada VM de unos breves Este comando establecerá una conexión SSH breve con cada VM. Durante la primera ejecución, se solicitará confirmación para aceptar las claves de las máquinas, por lo que será necesario escribir `yes` en cada caso.

Después, se debe generar el archivo `inventory.ini`, donde se almacenará la información de las VMs (usuario e IP). Este archivo se crea con:

```bash
./app.sh inv
```

Para confirmar que se generó correctamente, se puede visualizar con:
```bash
cat inventory.ini
```
y verificar que las direcciones IP coincidan con las obtenidas en:
```bash
bash gen.sh info
```

## Opciones del Script `app.sh`

El script `app.sh` facilita la interacción con las VMs y la ejecución de los **playbooks de Ansible**. A continuación, se describen las opciones disponibles:
### 1. `ping`

Prueba la conectividad SSH con cada VM
```bash 
./app.sh ping
```

### 2. `inv`

Genera el archivo `inventory.ini` con las direcciones IP de las VMs creadas.

```bash
./app.sh inv
```

Este archivo es fundamental, ya que se utiliza como inventario para Ansible.

### 3. `todos`

Ejecuta todos los playbooks en orden:

1. `common.yml` – Configuraciones básicas de seguridad.
2. `firewall.yml` – Configuración de reglas de firewall.
3. `sshd.yml` – Ajustes de seguridad y acceso vía SSH.
4. `nginx.yml` – Instalación y configuración del servidor web Nginx.

```bash
./app.sh todos
```

Alternativa manual:
 actualizado.
```bash 
ansible-playbook -i inventory.ini common.yml
ansible-playbook -i inventory.ini firewall.yml
ansible-playbook -i inventory.ini sshd.yml
ansible-playbook -i inventory.ini nginx.yml
```

### 4. `common`

Ejecuta únicamente el playbook de configuración de seguridad común:

```bash
./app.sh common
```

Alternativa manual: 

```bash
ansible-playbook -i inventory.ini common.yml
```
### 5. `firewall`

Ejecuta solo el playbook de configuración de firewall:

```bash
./app.sh firewall
```

Alternativa manual: 

```bash
ansible-playbook -i inventory.ini firewall.yml
```

### 6. `sshd`

Ejecuta únicamente el playbook para configurar y asegurar el servicio SSH:

```bash
./app.sh sshd
```

Alternativa manual: 

```bash
ansible-playbook -i inventory.ini sshd.yml
```

### 7. `nginx`

Ejecuta exclusivamente el playbook para instalar y configurar **Nginx**:

```bash
./app.sh nginx
```

Alternativa manual: 

```bash
ansible-playbook -i inventory.ini nginx.yml
```

---

### Notas adicionales:

- Todos los comandos usan el inventario `inventory.ini`.
- El script `app.sh` es útil para automatizar y simplificar las ejecuciones, pero siempre existe la opción de correr los **playbooks directamente con `ansible-playbook -i playbook_name.yml`**
- Es recomendable primero ejecutar `./app.sh inv` para asegurarse de que el inventario esté creado
- El comando `todos` permite configurar todas las VMs en una sola ejecución.
