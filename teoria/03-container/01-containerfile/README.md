# Containerfile y la construcción de contenedores

## Introducción

Los contenedores son una tecnología que permite empaquetar y aislar aplicaciones con todas sus dependencias en un entorno de ejecución autocontenido. Esto garantiza que la aplicación se comporte de la misma manera independientemente de dónde se ejecute. Para esta actividad, utilizaremos **Podman**, un motor de contenedores nativo de Linux, sin demonios y compatible con el estándar OCI, para aprender los fundamentos de la creación y gestión de imágenes de contenedores.

## Instrucciones

### 1. Instalación y Primeros Pasos

- **Instala Podman**: Asegúrate de tener `podman` instalado en tu máquina.
- **Verifica la instalación**: Ejecuta tu primer contenedor para confirmar que todo funciona correctamente.

```bash
podman run --rm docker.io/library/hello-world
```

  Deberías ver un mensaje de bienvenida, lo que indica que Podman está operativo.

### 2. Creación de Imágenes con `Containerfile`

Ahora, crearás una serie de imágenes de contenedores utilizando `Containerfile`. Cada imagen aumentará en complejidad, permitiéndote explorar diferentes directivas y técnicas.

#### Imagen 1: `htop` en Debian

- **Objetivo**: Crear una imagen simple que ejecute una herramienta de monitoreo.
- **Requisitos**:
    - Usa `debian:stable-slim` como imagen base.
    - Instala la utilidad `htop`.
    - Configura el contenedor para que ejecute `htop` por defecto al iniciarse.

#### Imagen 2: Servidor web Nginx con contenido personalizado

- **Objetivo**: Crear una imagen que sirva una página web estática.
- **Requisitos**:
    - Usa `debian:stable-slim` como imagen base.
    - Instala el servidor web `nginx`.
    - Crea un archivo `index.html` simple y personalizado.
    - Copia tu `index.html` a la imagen para que `nginx` lo sirva como el sitio por defecto.

#### Imagen 3: Servidor web Nginx con volúmenes

- **Objetivo**: Mejorar la imagen anterior para permitir la configuración y el contenido dinámico desde el host.
- **Requisitos**:
    - Basado en la imagen anterior, modifica el `Containerfile` y la ejecución para que:
        - El directorio de contenido web de `nginx` (`/var/www/html`) sea un volumen montado desde el host.
        - El archivo de configuración de `nginx` también se monte como un volumen.
    - Esto te permitirá cambiar la página web y la configuración de `nginx` sin tener que reconstruir la imagen.

#### Imagen 4: Binario estático desde `scratch`

- **Objetivo**: Crear una imagen de contenedor mínimo utilizando una compilación multi-etapa.
- **Requisitos**:
    - Escribe un programa "Hola Mundo" en un lenguaje compilado (Go, Rust, C, etc.).
    - El programa debe ser compilado de forma estática, sin dependencias de bibliotecas externas.
    - Crea un `Containerfile` con una **compilación multi-etapa**:
        1.  **Etapa de construcción**: Usa una imagen con el compilador y las herramientas necesarias para compilar tu programa.
        2.  **Etapa final**: Usa la imagen base `scratch` (una imagen completamente vacía) y copia únicamente el binario compilado de la etapa anterior.
    - El resultado debe ser una imagen extremadamente pequeña que solo contenga tu ejecutable.

## Archivos de entrega

Sigue las instrucciones generales de entrega del curso. Tu subdirectorio debe contener:

1.  **Containerfiles**:
    - Un `Containerfile` para cada una de las cuatro imágenes solicitadas.
2.  **Código Fuente**:
    - El código fuente de tu programa "Hola Mundo" para la imagen 4.
    - El archivo `index.html` para las imágenes 2 y 3.
3.  **Documentación (`README.md`)**:
    - Un archivo `README.md` dentro de tu directorio de entrega que explique:
        - Los comandos `podman build` y `podman run` para cada una de tus imágenes.
        - Una breve descripción de cada `Containerfile`, explicando las decisiones clave.

## Material de lectura

- [Podman Documentation](https://docs.podman.io/)
- [Multi-stage builds for containers](https://docs.docker.com/build/building/multi-stage/)
