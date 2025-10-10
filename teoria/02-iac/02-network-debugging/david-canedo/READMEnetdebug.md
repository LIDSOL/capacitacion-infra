Este sistema implementa un monitoreo periodico en la conectividad y levanta la interfaz de red si se detecta caída.  
La ejecución se gestiona con un **servicio systemd** y un **timer systemd**, evitando que el script corra en bucle infinito.
- El **script** hace un `ping` de prueba a `8.8.8.8`.
    - Si falla, levanta la interfaz predeterminada (`ip link set up`) y lo guarda en un log 
    - Si funciona, registra que la conectividad está activa en un log
- El **servicio** ejecuta el script una sola vez,
- El **timer** controla la periodicidad (ejemplo: cada 5 segundos).
- 