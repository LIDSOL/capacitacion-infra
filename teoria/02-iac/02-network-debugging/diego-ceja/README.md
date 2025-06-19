# Explicacion de archivos de entrega

**transfer-network-debug-solution.yml:** contiene plays que transfieren la solucion al problema de conectividad (`monitor.service`, `monitor.sh`) a las VMs; inicia el servicio transferido

**transfer-bug-service.yml:** se encarga de copiar el archivo bug.service a las VMs e iniciar el servicio descrito por este

**monitor.service:** archivo de tipo systemd service que se encarga de iniciar el monitoreo de la conectividad ejecutando `monitor.sh` 

**monitor.sh:** se obtiene la interfaz default e indefinidamente se repite lo siguiente: se obtiene el estado de la interfaz; si es down, se cambia a up, de lo contrario, no se hace nada
