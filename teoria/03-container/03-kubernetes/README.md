# Kubernetes 101

## Introducción

Kubernetes es un sistema de orquestación de contenedores de código abierto que automatiza la implementación, el escalado y la gestión de aplicaciones en contenedores. En esta actividad, utilizarás `minikube` para crear un clúster de Kubernetes local en tu máquina y aprenderás a desplegar aplicaciones, desde un simple servidor web hasta una aplicación completa como WordPress.

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado lo siguiente:

-   **`kubectl`**: La herramienta de línea de comandos de Kubernetes.
-   **`minikube`**: La herramienta para ejecutar un clúster de Kubernetes de un solo nodo localmente.
-   **Un hipervisor**: Como KVM/QEMU, VirtualBox o Hyper-V. Para esta guía, usaremos KVM, que es el recomendado para Linux.

## 1. Iniciar un clúster local con Minikube

El primer paso es iniciar un clúster de Kubernetes. Usaremos el driver `kvm2` para crear una máquina virtual que actuará como nuestro nodo de Kubernetes.

1.  **Inicia Minikube**:
    ```bash
    minikube start --driver=kvm2
    ```
    Este comando descargará la imagen necesaria y configurará el clúster. Puede tardar unos minutos.

2.  **Verifica el estado del clúster**:
    Una vez que `minikube` haya terminado, verifica que tu nodo esté listo:
    ```bash
    kubectl get nodes
    ```
    Deberías ver un nodo con el estado `Ready`.

## 2. Desplegar un servidor web Nginx

Ahora, desplegarás tu primera aplicación: un servidor web Nginx.

1.  **Crea un Deployment**:
    Un `Deployment` en Kubernetes se encarga de mantener un conjunto de réplicas de tu aplicación en ejecución.
    ```bash
    kubectl create deployment nginx --image=nginx
    ```

2.  **Expón el Deployment con un Service**:
    Para acceder a tu aplicación desde fuera del clúster, necesitas un `Service`. Usaremos un servicio de tipo `NodePort`, que expone la aplicación en un puerto estático en el nodo.
    ```bash
    kubectl expose deployment nginx --type=NodePort --port=80
    ```

3.  **Accede al servicio**:
    Minikube proporciona un comando para obtener la URL de acceso al servicio:
    ```bash
    minikube service nginx --url
    ```
    Abre la URL que te proporciona en tu navegador. Deberías ver la página de bienvenida de Nginx.

## 3. Desplegar WordPress

Desplegar WordPress es más complejo, ya que requiere una base de datos y almacenamiento persistente. Utilizaremos archivos de configuración YAML para definir todos los recursos necesarios.

### 3.1. Secreto para la base de datos

Primero, crea un `Secret` para almacenar la contraseña y el usuario de la base de datos de forma segura.

1.  Crea un archivo llamado `mysql-secret.yaml` con el siguiente contenido. **Recuerda cambiar `YOUR_PASSWORD` y `YOUR_USERNAME` por credenciales seguras.**
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: mysql-pass
    type: Opaque
    stringData:
      password: "YOUR_PASSWORD"
      username: "YOUR_USERNAME"
    ```

2.  Aplica el `Secret` al clúster:
    ```bash
    kubectl apply -f mysql-secret.yaml
    ```

### 3.2. Despliegue de la base de datos (MariaDB)

Ahora, despliega la base de datos MariaDB. Este despliegue incluirá un `PersistentVolumeClaim` para que los datos no se pierdan si el contenedor se reinicia.

1.  Crea un archivo `mysql-deployment.yaml` con el siguiente contenido:
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: wordpress-mysql
    spec:
      selector:
        app: wordpress
        tier: mysql
      ports:
        - port: 3306
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: mysql-pv-claim
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: wordpress-mysql
    spec:
      selector:
        matchLabels:
          app: wordpress
          tier: mysql
      template:
        metadata:
          labels:
            app: wordpress
            tier: mysql
        spec:
          containers:
          - image: mariadb:10.6
            name: mysql
            env:
            - name: MYSQL_DATABASE
              value: wordpress
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: username
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: password
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: password
            ports:
            - containerPort: 3306
              name: mysql
            volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
          volumes:
          - name: mysql-persistent-storage
            persistentVolumeClaim:
              claimName: mysql-pv-claim
    ```

2.  Aplica el despliegue de la base de datos:
    ```bash
    kubectl apply -f mysql-deployment.yaml
    ```

### 3.3. Despliegue de WordPress

Finalmente, despliega la aplicación de WordPress.

1.  Crea un archivo `wordpress-deployment.yaml` con el siguiente contenido:
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: wordpress
    spec:
      type: NodePort
      selector:
        app: wordpress
        tier: frontend
      ports:
        - protocol: TCP
          port: 80
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: wp-pv-claim
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: wordpress
    spec:
      selector:
        matchLabels:
          app: wordpress
          tier: frontend
      template:
        metadata:
          labels:
            app: wordpress
            tier: frontend
        spec:
          containers:
          - image: wordpress:latest
            name: wordpress
            env:
            - name: WORDPRESS_DB_HOST
              value: wordpress-mysql
            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: password
            - name: WORDPRESS_DB_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: username
            - name: WORDPRESS_DB_NAME
              value: wordpress
            ports:
            - containerPort: 80
              name: wordpress
            volumeMounts:
            - name: wordpress-persistent-storage
              mountPath: /var/www/html
          volumes:
          - name: wordpress-persistent-storage
            persistentVolumeClaim:
              claimName: wp-pv-claim
    ```

2.  Aplica el despliegue de WordPress:
    ```bash
    kubectl apply -f wordpress-deployment.yaml
    ```

### 3.4. Accede a WordPress

1.  Espera a que los contenedores se inicien. Puedes verificar el estado con `kubectl get pods -l app=wordpress`.
2.  Obtén la URL del servicio de WordPress:
    ```bash
    minikube service wordpress --url
    ```
3.  Abre la URL en tu navegador para completar la instalación de WordPress.

## Archivos de entrega

Sigue las instrucciones generales de entrega del curso. Tu subdirectorio debe contener los archivos que se proporcionarion en esta actividad, incluyendo:

-   `mysql-secret.yaml`
-   `mysql-deployment.yaml`
-   `wordpress-deployment.yaml`

Debes incluir comentarios en cada archivo YAML explicando su propósito y cómo se relaciona con el despliegue dentro de Kubernetes.
