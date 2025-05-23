# Configuración segura de un servidor Linux

## Introducción

Un servidor es un sistema que suele estar expuesto a internet, esto lo vuelve un blanco para los atacantes. Por esto es importante que tenga una configuración siguiendo las mejores prácticas de seguridad. Aunque siempre existe el riesgo, lo mejor es reducir la superficie de ataque al mínimo.

### Servicio SSH

SSH es un protocolo de red utilizado para acceder de forma segura a un sistema remoto. Es lo que nos permite conectarnos a la máquina virtual de forma remota, de hecho debieron usarlo para la actividad anterior. Bueno, buscamos una configuración segura de este servicio.

### Firewall

Un firewall es el sistema que limita el acceso a los servicios del servidor. Esto a partir de filtros en la red. Existen muchos firewall aunque linux actualmente suele usar `nftables` como firewall por defecto. Es lo que utilizaremos en esta actividad.

### Actualizaciones automáticas

Las actualizaciones nos pueden proteger de las vulnerabilidades que surgen cada día. Por esto requerimos que nuestro sistema esté siempre actualizado. Para esto utilizaremos `unattended-upgrades` que es una herramienta que permite instalar actualizaciones automáticamente en sistemas Debian y derivados.

## Instrucciones

Configurar un servidor Debian 12 recién instalado de forma segura.

### Requisitos

- Utilizar la máquina virtual creada en la actividad anterior.
- El servidor debe contar con la configuración de SSH:
    - No permitir el acceso al usuario root.
    - No permitir el acceso a usuarios mediante contraseña
    - Permitir el acceso a usuarios mediante clave pública.
    - No permitir X11Forwarding.
- El servidor debe contar con un firewall basado en nftables que permita el acceso al puerto de SSH.
    - Se debe cargar con el comando `nft -f /etc/nftables.conf` o con el servicio `nftables`. Por lo mismo las reglas deben estar en el archivo `/etc/nftables.conf`.
- El servidor debe contar con el servicio de actualizaciones automáticas.
    - Las actualizaciones deben ser automáticas y no requerir interacción del usuario.
    - Las actualizaciones deben incluir las actualizaciones de seguridad.
    - Las actualizaciones deben incluir las actualizaciones recomendadas.
    - Las actualizaciones deben incluir las actualizaciones de paquetes instalados.

## Archivos de entrega

- Archivo de configuración de SSH `/etc/ssh/sshd_config`.
- Archivo de configuración de nftables `/etc/nftables.conf`.
- Archivo con un dry-run de las actualizaciones automáticas.

## Material de consulta

- [SSH](https://www.openssh.com/manual.html)
- [nftables](https://netfilter.org/projects/nftables/index.html)
- [Automatic updates](https://wiki.debian.org/UnattendedUpgrades)

Para el tema de redes, se que si les puede hacer falta algo de contexto. Les recomiento leer el siguiente material:
- [Basics of computer networking](https://wiki.debian.org/UnattendedUpgrades)
- [Linux networking](https://www.geeksforgeeks.org/linux-network-commands-cheat-sheet/)

