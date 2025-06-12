# Debugging de Red con Ansible

## Introducción

En esta actividad pondrás en práctica tus habilidades de troubleshooting y automatización con Ansible. El objetivo es simular un entorno donde existe un problema intermitente de red causado por un servicio del sistema, y deberás idear una solución automatizada para mitigar el impacto, sin desactivar el servicio problemático.

### Contexto

Ya sabes que existe un servicio (bug.service) que ocasionalmente corta la conectividad de red en las máquinas virtuales. Sin embargo, este servicio es crítico y no puede ser desactivado. Tu reto será encontrar una forma de restaurar la conectividad de red automáticamente cada vez que se pierda, utilizando herramientas de automatización.

## Instrucciones

### Inyección del Bug de Red

Utiliza el servicio `bug.service` proporcionado en este directorio para instalar el servicio problemático en todas tus VMs. Automatiza la ejecución de este script en todas las máquinas usando ansible para copiar el archivo `bug.service` y habilitarlo.

### Diagnóstico y Mitigación

Observa el comportamiento de las VMs tras instalar el bug. Notarás que la red se cae de forma aleatoria aunque igualmente se recupera sola tras unos minutos. Sin embargo, esto no es aceptable para un entorno de producción, ya que la conectividad intermitente puede causar problemas graves.

Tu tarea es crear un playbook de Ansible que implemente una solución para recuperar automáticamente la conectividad de red cada vez que se pierda, sin desactivar ni modificar el servicio bug.service.
Puedes apoyarte en scripts de monitoreo (por ejemplo, un script en bash que detecte la caída de la red y la reinicie), timers de systemd, o cualquier otra técnica automatizada que consideres adecuada.

## Entrega

Entrega tu playbook de Ansible y cualquier script auxiliar que utilices para mitigar el problema. Tu solución debe ser idempotente y automatizada: una vez aplicada, la red debe recuperarse sola cada vez que se caiga, sin intervención manual.

### Requisitos

- No está permitido desactivar, detener o modificar el servicio bug.service.
- La solución debe ser completamente automatizada y gestionada desde Ansible.
- Puedes usar scripts adicionales, timers, watchdogs, etc., pero todo debe ser desplegado y gestionado por Ansible.
- Entrega tu playbook principal y cualquier archivo auxiliar (scripts, plantillas, etc.) en tu subdirectorio de entrega.

### Sugerencias

- Puedes crear un script que monitoree la conectividad (por ejemplo, haciendo ping a una IP externa) y reinicie la red si detecta que está caída.
- Considera usar un systemd timer para ejecutar periódicamente tu script de recuperación.
- Asegúrate de que tu solución no cause bucles infinitos ni reinicios innecesarios de la red.

### Archivos de entrega

- Playbook(s) de Ansible (*.yml).
- Scripts auxiliares (por ejemplo, network-watchdog.sh).
- Plantillas o archivos de configuración necesarios.
- Un archivo README.md en tu subdirectorio explicando brevemente tu solución y cómo probarla.
