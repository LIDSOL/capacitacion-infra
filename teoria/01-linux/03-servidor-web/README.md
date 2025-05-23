# Servidor web

## Introducción

Un servidor web es un sistema que permite almacenar y servir contenido web. Cosas como imágenes, videos, archivos de texto o archivos con formato como HTML, CSS o JavaScript, preparados para ser mostrados en un navegador web. El contenido servido puede ser estático o dinámico. El contenido estático es el sencillo, no cambia y no requerimos procesamiento. Para el segundo se depende de un lenguaje de programación que ejecute cierto código generando el contenido que se mostrará.

## Instrucciones

Configurar en su servidor Debian 12 un servidor web utilizando **Nginx**.

### Requisitos

- Deben servir contenido estático. Es suficiente con que modifiquen el archivo default. Aunque puede ser más interesante crear un nuevo sitio :).
- Deben tener los puertos 80 y 443 abiertos en el firewall.

## Archivos de entrega

- Captura de pantalla del sitio web funcionando desde su computadora host.
- Captura del comando `curl -I http://localhost` ejecutado en el servidor y 
  `curl -I http://<ip_del_servidor>` ejecutado desde su computadora host.

## Material de lectura

- [Nginx](https://www.nginx.com/)
- [Static content](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/)
