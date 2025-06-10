# Configuración Segura 2 (Ansible IaC)

## Introducción

Esta actividad se centra en la aplicación de los principios de Infraestructura como Código (IaC) utilizando Ansible. El objetivo es automatizar la configuración segura de servidores Debian, basándose en los conocimientos adquiridos en actividades previas sobre configuración manual de servidores, firewalls, hardening de SSH y despliegue de servidores web. Utilizaran el script `gen.sh` proporcionado para provisionar las máquinas virtuales que serán el objetivo de tus playbooks de Ansible. A través de esta actividad, aprenderás a crear configuraciones de servidor reutilizables, consistentes y automatizadas.

## Instrucciones

1.  **Preparación del Entorno de VMs**:
    *   Lee y siéntete cómodo con el script `gen.sh` ubicado en este directorio. Este script te permitirá crear y gestionar las máquinas virtuales Debian 12 necesarias.
    *   Asegúrate de tener instaladas las dependencias requeridas por el script: `wget`, `virt-install`, `qemu-img`, y `virsh`. Aunque estas las deberías ya tener si seguiste las actividades anteriores.
    *   **Importante**: Modifica la variable `SSH_PUBLIC_KEY` dentro del script `gen.sh` con tu propia clave pública SSH. Esto es crucial para poder acceder a las VMs posteriormente con Ansible.
    *   Ejecuta `bash gen.sh init` en tu terminal para descargar la imagen base de Debian y preparar el entorno de virtualización.
    *   Ejecuta `bash gen.sh create` para aprovisionar las máquinas virtuales (por defecto 3 VMs). Anota las direcciones IP o nombres de host de las VMs creadas, ya que las necesitarás para tu inventario de Ansible.

2.  **Desarrollo de Playbooks de Ansible**:
    *   Crea un inventario de Ansible que incluya las VMs aprovisionadas.
    *   Desarrolla los playbooks de Ansible necesarios para realizar las siguientes configuraciones en todas las VMs:
        *   **Actualizaciones Automáticas del Sistema**: Configura el sistema para que instale automáticamente las actualizaciones de seguridad (e.g., utilizando `unattended-upgrades`).
        *   **Configuración del Firewall**: Implementa reglas de firewall (puedes usar `nftables` a través de los módulos de Ansible correspondientes). Asegúrate de que los puertos para SSH (22), HTTP (80) y HTTPS (443) estén abiertos. Cierra todos los demás puertos innecesarios.
        *   **Hardening de SSHD**: Asegura la configuración del demonio SSH (`sshd`). Esto debe incluir como mínimo:
            *   Deshabilitar el login del usuario `root`.
            *   Deshabilitar la autenticación por contraseña (asegurándote de que la autenticación por clave SSH funcione correctamente).
        *   **Servidor Web Nginx con Contenido Personalizado**:
            *   Instala el servidor web Nginx.
            *   Configura Nginx para servir una página HTML personalizada (`index.html`).
            *   Utiliza una plantilla de Ansible (Jinja2) para generar el archivo `index.html`. La plantilla debe ser capaz de incluir dinámicamente información que haga que la página de cada VM sea ligeramente diferente. Por ejemplo, puedes mostrar el `inventory_hostname` de la VM, un mensaje único basado en variables de Ansible, o cualquier otro dato que permita identificar la VM desde la página web.

3.  **Organización y Pruebas**:
    *   Organiza tus archivos de Ansible de manera lógica. Considera el uso de archivos `task` para estructurar tus configuraciones (por ejemplo, un archivo para `common`, `firewall`, `sshd`, `nginx`).
    *   Asegúrate de que tus playbooks sean idempotentes (pueden ejecutarse múltiples veces sin causar efectos secundarios no deseados).
    *   Prueba tus playbooks varias veces, recuerda que con el script `gen.sh` puedes recrear las VMs fácilmente si es necesario.

## Requisitos

*   **Ansible**: Debes tener Ansible instalado en tu máquina de control (desde donde ejecutarás los comandos `ansible-playbook`).
*   **Máquinas Virtuales**: Utilizar el script `gen.sh` para provisionar al menos 3 máquinas virtuales Debian 12.
*   **Playbooks de Ansible**:
    *   Un playbook principal (`main.yml` o similar) que orqueste todas las configuraciones.
    *   Configuración para actualizaciones automáticas de seguridad habilitada y funcional.
    *   Firewall configurado y activo, permitiendo tráfico únicamente en los puertos SSH (configurado), HTTP (80) y HTTPS (443).
    *   Servidor SSHD configurado de forma segura:
        *   Login de `root` deshabilitado (`PermitRootLogin no`).
        *   Autenticación por contraseña deshabilitada (`PasswordAuthentication no`).
    *   Servidor Nginx instalado, activo y sirviendo una página `index.html` personalizada.
    *   La página `index.html` debe ser generada a partir de una plantilla Jinja2.
    *   El contenido de la página `index.html` debe ser ligeramente diferente para cada VM, mostrando alguna información única de la VM (e.g., su `inventory_hostname`).
*   Todas las configuraciones en las VMs deben ser aplicadas exclusivamente mediante playbooks de Ansible. No se permite la configuración manual en las VMs después de su aprovisionamiento inicial con `gen.sh` (excepto para la resolución de problemas iniciales si Ansible no puede conectarse).

## Archivos de entrega

Sigue las instrucciones generales de entrega del curso (crear una rama, un subdirectorio con tu `nombre-apellido` dentro de `teoria/02-iac/01-configuracion-segura-2/`, y abrir un Pull Request). Tu subdirectorio debe contener:

1.  **Código Ansible**:
    *   Todos tus archivos de playbook (`*.yml`).
    *   La estructura de roles completa, si los utilizaste (`roles/`).
    *   Todos los archivos de plantillas (`templates/*.j2`).
    *   Archivos de variables (`vars/*.yml`, `group_vars/`, `host_vars/`, si aplica).
    *   Tu archivo de inventario de Ansible (e.g., `inventory.ini`, `hosts.yml`).
2.  **Documentación (`README.md`)**: Un archivo `README.md` dentro de tu directorio de entrega que explique:
    *   Cómo ejecutar tus playbooks (incluyendo cualquier comando de preparación o variable extra necesaria).
    *   Una breve descripción de tu estructura de Ansible (tasks, playbooks principales).
    *   Cualquier detalle relevante.

## Material de lectura

*   **Ansible**:
    *   [Documentación Oficial de Ansible](https://docs.ansible.com/)
    *   [Guía de Usuario de Ansible](https://docs.ansible.com/ansible/latest/user_guide/index.html)
    *   [Mejores Prácticas de Ansible](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
    *   [Módulos de Ansible (para buscar módulos específicos)](https://docs.ansible.com/ansible/latest/collections/index.html)
*   **Jinja2 (Templating)**:
    *   [Documentación de Plantillas Jinja2](https://jinja.palletsprojects.com/en/latest/templates/)
*   **Configuraciones Específicas**:
    *   Debian Wiki: [UnattendedUpgrades](https://wiki.debian.org/UnattendedUpgrades)
