# Servicio
Colocamos el archivo **bug.service** en el directorio `/etc/systemd/system/`, recargamos systemd para que reconozca el nuevo servicio:
```bash 
sudo systemctl daemon-reload
```
Se habilita el servicio para que se ejecute al inicio y de manera imediata:
```bash
sudo systemctl enable bug.service
sudo systemctl start bug.service
```
Podemos verificar que el servicio esté activo de la sigueiente manera:
```bash
sudo systemctl status bug.service
```
# Solución para Mitigación de Fallos de Red

Esta solución implementa un sistema de watchdog que monitorea constantemente la conectividad de red y la restaura automáticamente cuando detecta fallos, sin modificar el servicio problemático `bug.service`.

## Explicación de la solución
- 1. **Enfoque no invasivo**: No modificamos ni desactivamos el servicio problemático, cumpliendo con los requisitos.
- 2. **Monitoreo activo**: El script verifica la conectividad haciendo ping a una IP externa (8.8.8.8 por defecto).
- 3. **Restauración segura**: Solo actúa después de múltiples fallos consecutivos (3 por defecto) para evitar falsos positivos.
- 4. **Eficiencia de recursos**: Usa un timer de systemd en lugar de un servicio siempre activo, reduciendo el uso de CPU.
- 6. **Configurable**: Los parámetros principales (IP de prueba, intervalo) son variables en el playbook.

