Archivos para desplegar aplicación
Para desplegar la nuestro Frontend en Kubernetes se utilizó un archivo dockerfile, un deploy.yml y un service.yml para poder levantarlo en un cluster.

Nuestro Dockerfile se compone de la siguiente forma:

    FROM node:14 as build
    WORKDIR /usr/local/app
    COPY package*.json ./
    RUN npm install
    COPY . .
    EXPOSE 3800
    CMD [ "node", "index.js" ]
Con el FROM extraemos una versión de node para generar el build de nuestra aplicación para posteriormente levantar un servidor nginx y montar nuestra app y exponerla desde ese servidor.

Nuestro archivo deploy.yml sirve para levantar nuestros pods del frontend, teniendo la siguiente estructura:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
        name: backend
    spec:
        replicas: 3
        selector:
            matchLabels:
                role: backend
        minReadySeconds: 20
        strategy:
            rollingUpdate:
                maxSurge: 1
                maxUnavailable: 0
            type: RollingUpdate
        template:
            metadata:
                labels:
                    role: backend
            spec:
                containers:
                - name: backend
                    image: dianmz22/backend
                    ports:
                    - containerPort: 3800
El archivo nos muestra la versión que le queremos asignar a nuestro deployment y el tipo de archivo yaml/yml que deseamos utilizar, en este caso será un tipo Deployment, le colocamos la cantidad de replicas que necesitamos en este caso serán 3, y le agregamos la estrategia RollingUpdate que nos permite actualizar el sistema Kubernetes con solo un efecto menor en el rendimiento y sin tiempo de inactividad. En esta estrategia, la implementación selecciona un Pod con la programación anterior, lo desactiva y crea un Pod actualizado para reemplazarlo.

Para finalizar los archivos necesitamos el archivo del service.yml para poder generar nuestro balanceador de cargas de los pods generados con el archivo deploy. La estructura del archivo es el siguiente:

    apiVersion: v1
    kind: Service
    metadata:
        name: backend-lb
    spec:
        type: LoadBalancer
        ports:
            - protocol: TCP
            port: 80
            targetPort: 3800
            name: http
        selector:
            role: backend
La diferencia con el archivo anterior es que acá el tipo a levantar es un servicio, y el servicio es de tipo LoadBalancer.

Comandos para desplegar aplicación
Los comandos necesarios para levantar nuestra aplicación en Kubernetes son los siguientes:

Primero debemos crear nuestra imágen de docker con el archivo Dockerfile:

$ docker build -t [docker_hub_user]/backend .

Ahora debemos subir nuestra imágen a Docker HUB:

$ docker push [docker_hub_user]/backend

Debemos seleccionar el namespace en el que queremos realizar el despliegue de nuestra aplicación:

$ kubectl config set-context --current --namespace=[name]

Realizamos el deploy de nuestros pods con el siguiente comando:

$ kubectl apply -f deploy.yml

Debemos esperar a que nuestros pods se levanten correctamente y posteriormente levantamos nuestro servicio con el siguiente comando:

$ kubectl apply -f service.yml

Y listo ya hemos levantado nuestro backend en kubernetes

Para cambiar imágen de nuestro backend lo único que debemos hacer es ejecutar el siguiente comando:

$ kubectl set image deployment/backend backend=[nueva imagen]

Para regresar a una versión anterior de nuestro backend utilizamos el siguiente comando:

$ kubectl rollout undo deployment/backend

Para eliminar un deployment se utiliza el siguiente comando:

$ kubectl delete deployment backend

Para eliminar un service se utiliza el siguiente comando:

$ kubectl delete service backend-lb
