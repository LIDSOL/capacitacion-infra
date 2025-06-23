# Debugging de red con Ansible

Para esta actividad se realizó una solución que reinicia el servicio de red de la máquina virtual si este no funciona comprobando si la conexión es correcta cada cierto tiempo.

### Archivos

* playbook.yml: Este playbook de ansible aplica el rol watchdog a las máquinas virtuales indicadas en el inventario.
* inventory.ini: Contiene las ip de las distintas máquinas virtuales.
* watchdog.service: Es la descripción del servicio de systemd watchdog indica el tipo de servicio y qué script debe de ejecutar.
* watchdog.timer: Es el timer para el servicio watchdog, en este archivo se indica cada cuanto tiempo se debe de ejcutar el servicio.
* watchdog.sh: Es el script de bash que comprueba la conexión de la máquina virtual mediante un ping. Si el ping no devuelve nada entonces se reinicia el servicio de red.
* watchdog/main.yml: Estea archivo contiene las tareas que serán ejecutadas cuando el rol de watchdog sea llamado.

### Ejecución del playbook
```
ansible-playbook -i inventory.ini playbook.yml

```
