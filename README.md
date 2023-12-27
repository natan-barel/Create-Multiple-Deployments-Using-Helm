
# Create Multiple Deployments Using Helm

In this project, we'll use Helm 3 to deploy a Ruby on Rails (RoR) application on a Kubernetes cluster.

We'll use a published Helm chart to deploy the database and create our own custom Helm chart to deploy the frontend.

Finally, we'll use ConfigMaps to share common information between different Services.

The application is located in the `/usercode/elearning` directory and is ready to use.

## DevOps Tools / Service Used
+ Docker
+ Kubernetes
+ Helm
+ Kind

## Prerequisites
To deploy the Application on Docker, Kubernetes and Helm, we have the following prerequisites:

+ Install and configure [Docker](https://docs.docker.com/desktop/)

+ Install and configure [Kubernetes](https://kubernetes.io/docs/setup/)

+ Install and configure [Helm](https://helm.sh/docs/intro/quickstart/)

+ Install and configure [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

### Task 1: Create a Cluster

To run Kubernetes, we need a cluster. A **cluster** is a group of computers working together that can be viewed as a single system.

Kubernetes provides several distributions to create a cluster. We can create a Kubernetes cluster by using any of the following distributions or we can use any distribution of our choice:

+ minikube
+ kind
+ Docker Desktop
+ kubeadm

For this project, we will use a `kind` cluster.

For this task, perform the following steps:

+ Change your directory to the `/usercode`.
+ Create a `kind` cluster.
+ display the name of the cluster

We will use the following commands: 

```shell
cd usercode
kind create cluster
kind get clusters
```

### Task 2: Set up Helm

**Helm** is necessary to install and use Helm charts. It’s designed to bundle Kubernetes resource files into a single package that can be easily deployed.

For this task, perform the following steps:

+ Use the following command to download the Helm 3 installation script:

```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
```
+ Use the following command to change access permissions:

```shell
chmod 700 get_helm.sh
```
+ Use the following command to run the Helm installation script:

```shell
./get_helm.sh
```

+ Use the following command to verify the installation:

```shell
helm --help
```

### Task 3: Containerize and Push the Frontend

To deploy the application’s frontend, start by containerizing it. The Dockerfile for the frontend is already created, and it’s located in the `/usercode/elearning` directory.

For this task, perform the following steps:

+ Change the directory to `/usercode/elearning`.

```shell
cd /usercode/elearning
```

+ Use the following command to build the Docker image:

```shell
docker build -t <my-username>/<my-image-name>:<tag> .
```
Here **my-username** is the username of your Docker Hub account, **my-image-name** is the name of your docker image, and **tag** will be the tag of the Docker image


+ Use the following command to log in to Docker Hub:

```shell
docker login -u <my-username> -p <my-password>
```
Here **my-username** is your Docker Hub username, and **my-password** is your Docker Hub password

+ Use the following command to push the image to Docker Hub:

```shell
docker push <my-username>/<my-image-name>:<tag>
```
Here **my-username** is the username of your Docker Hub account, **my-image-name** is the name of your docker image, and **tag** will be the tag of the Docker image

### Task 4: Set up the Chart

A **chart**, also known as a package, is a set of Helm-specific files that install an application on a Kubernetes cluster. A Helm chart helps deploy applications ranging from the simplest to the most complex.

For this task, perform the following steps:

+ use the `remove.sh` file script. Run the file by using the following command:

```shell
bash remove.sh
```

### Task 5: Add the Database

**Artifact Hub** enables users to find, install, and package projects. It contains a wide range of published packages with different, customized applications. To deploy the database, use a published Helm Chart from Artifact Hub.

For this task, perform the following steps:

+ Use the following command to change the current directory:

```shell
cd /usercode/multiple-deployments
```

+ Use the following command to search for the Helm chart:

```shell
helm search hub postgresql
```
+ Add the following code at the end of the `/usercode/multiple-deployments/Chart.yaml` file:

```shell
dependencies:
  - name: postgresql
    version: 12.1.9
    repository: "https://charts.bitnami.com/bitnami"
```
+ Use the following command to download the required dependencies:

```shell
helm dependency update
```
+ Verify that the following files have now been created:

+ `/usercode/multiple-deployments/Chart.lock`
+ `/usercode/multiple-deployments/charts/postgresql-12.1.9.tgz`

Our RoR application is dependent on the `/usercode/multiple-deployments/charts/postgresql-12.1.9.tgz` file. 
The `/usercode/multiple-deployments/Chart.lock` file can be used to rebuild the dependencies to the specifications of an exact version.

### Task 6: Configure the Database

To deploy the database, configure the PostgreSQL Helm chart. The database chart will use the values defined in the `/usercode/multiple-deployments/values.yaml` file.

Open the `/usercode/multiple-deployments/values.yaml` file and configure the helm chart according to the following specifications:

+ Use this [link](https://artifacthub.io/packages/helm/bitnami/postgresql) to view the PostgreSQL bitnami chart.

+ From the “CHART VERSIONS” field, select the “12.1.9” version.

+ From “VALUES SCHEMA,” use the following paths to set the username and password:

```shell
auth.username
auth.password
auth.database
```
+ From the “DEFAULT VALUES", use the following paths to fully override the name and to change the image tag:

```shell
fullnameOverride
image.tag
commonLabels
```
+ After adding the image and overriding the name, the `/usercode/multiple-deployments/values.yaml` will look like this:

```shell
postgresql:
  fullnameOverride: "postgres"
  image:
    tag: 11.14.0-debian-10-r17
```

+ After adding all the required specifications, the `/usercode/multiple-deployments/values.yaml` file will display these parameters:

```shell
postgresql:
  fullnameOverride: "postgres"
  image:
    tag: 11.14.0-debian-10-r17
  auth:
    username: "postgresuser"
    password: "postgrespassword"
    database: "elearning_development"

  commonLabels:
    name: postgres
    component: database
    manager: helm
```

### Task 7: Add Values for ConfigMap

***ConfigMaps** are Kubernetes objects used to store key-value pairs. We can inject environment variables into the containers using these key-value pairs.

To do this, open the `/usercode/multiple-deployments/values.yaml` file. Configure the chart to use the following specifications:

+ `postgresql.databasePort: 5432`
+ `configmap.name: postgres-configmap`

Edit the `/usercode/multiple-deployments/values.yaml` file so that it looks like the code snippet below:

```shell
postgresql:
  fullnameOverride: "postgres"
  image:
    tag: 11.14.0-debian-10-r17
  auth:
    username: "postgresuser"
    password: "postgrespassword"
    database: "elearning_development"
  databasePort: 5432

  commonLabels:
    name: postgres
    component: database
    manager: helm
    
configmap: 
  name: postgres-configmap
```

### Task 8: Create a ConfigMap

Now the task is to create a ConfigMap that will use the values defined in the `/usercode/multiple-deployments/values.yaml` file. This ConfigMap will be used to inject environment variables into the front-end container.

To do this, open the `/usercode/multiple-deployments/templates/configmap.yaml` file and add the following code:

```shell
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.configmap.name }}
data:
  POSTGRES_SVC: {{quote .Values.postgresql.fullnameOverride}}
  POSTGRES_PORT: {{quote .Values.postgresql.databasePort}}
  POSTGRES_DB: {{quote .Values.postgresql.auth.database}}
  POSTGRES_USER: {{quote .Values.postgresql.auth.username}}
  POSTGRES_PASSWORD: {{quote .Values.postgresql.auth.password}}
```

### Task 9: Add Values for Service

To deploy the application as a Service, we have to create another Kubernetes Service object.

To do this, open the `/usercode/multiple-deployments/values.yaml` file, and configure the chart to the following specifications:

+ `app.name: ror`
+ `app.component: frontend`
+ `app.manager: helm`
+ `service.type: NodePort`
+ `service.port: 31111`
+ `service.nodePort: 31111`
+ `service.targetPort: 3000`

Edit your `/usercode/multiple-deployments/values.yaml` file so that it looks like the code snippet below:

```shell
postgresql:
  fullnameOverride: "postgres"
  image:
    tag: 11.14.0-debian-10-r17
  auth:
    username: "postgresuser"
    password: "postgrespassword"
    database: "elearning_development"
  databasePort: 5432

  commonLabels:
    name: postgres
    component: database
    manager: helm
    
configmap: 
  name: postgres-configmap

app:
  name: ror
  component: frontend
  manager: helm

service:
  type: NodePort
  port: 31111         
  nodePort: 31111
  targetPort: 3000
```

### Task 10: Create a Service

The next task is to create a Service for the front-end. Later on, this Service will be used to expose the RoR application. The Service will use the values defined in the `/usercode/multiple-deployments/values.yaml` file.

To get started, open the `/usercode/multiple-deployments/templates/service.yaml` file. The Service should contain the following specifications:


+ `metadata.name: [your-release-name]-service`
+ `spec.type: service.type`
+ `spec.ports.port: service.port`
+ `spec.ports.targetPort: service.targetPort`
+ `spec.ports.nodePort: service.nodePort`
+ `spec.ports.protocol: TCP`
+ `spec.ports.name: http`
+ `spec.selector.app.kubernetes.io/name: app.name`
+ `spec.selector.app.kubernetes.io/component: app.component`
+ `spec.selector.app.kubernetes.io/managed-by: app.managed-by`

Edit your `/usercode/multiple-deployments/templates/service.yaml` file so that it looks like the code snippet below:

```shell
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      nodePort: {{ .Values.service.nodePort }}
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{.Values.app.name}} 
    app.kubernetes.io/component: {{.Values.app.component}}
    app.kubernetes.io/managed-by: {{.Values.app.manager}}
```

### Task 11: Add Values to Deploy the Frontend

To deploy the frontend, we need to create a Deployment. A deployment enables us to keep track of the state of our pods and ReplicaSets. A deployment controller manages this state. You describe a desired state in a deployment, and the deployment controller makes sure that the current state of your deployment matches its desired state.

First, define values for this Deployment. To do this, open the `/usercode/multiple-deployments/values.yaml` file. 
The deployment should contain the following specifications:

+ `image.repository: [your-image-name].`
+ `image.tag: [your-image-tag].`
+ `deployments.name: app`
+ `deployments.containerPort: 3000`
+ `deployments.imagePullPolicy: Always`

+ Declare an `initContainer` that checks port `5432` every five seconds for database availability. This `initContainer` should contain the following specifications: 

+ `initContainers.name: check-db-ready`
+ `initContainers.image: postgres:9.6.5`
+ `initContainers.command: [Write-your-command-here]`

Edit your `/usercode/multiple-deployments/values.yaml` file so that it looks like the code snippet below:

```shell
postgresql:
  fullnameOverride: "postgres"
  image:
    tag: 11.14.0-debian-10-r17
  auth:
    username: "postgresuser"
    password: "postgrespassword"
    database: "elearning_development"
  databasePort: 5432

  commonLabels:
    name: postgres
    component: database
    manager: helm
    
configmap: 
  name: postgres-configmap

app:
  name: ror
  component: frontend
  manager: helm

service:
  type: NodePort
  port: 31111         
  nodePort: 31111
  targetPort: 3000

image:
  repository: ***
  tag: latest 

deployments: 
  name: app
  containerPort: 3000
  imagePullPolicy: Always

initContainers:
  name: check-db-ready
  image: postgres:9.6.5
  command: ['sh', '-c', 
          'until pg_isready -h postgres -p 5432; 
          do echo waiting for database; sleep 5; done;']
```

**Don’t forget to change the `repository` and `tag` in the image section.**

### Task 12: Create a Deployment

To access the application, we have to create a Deployment object. This Deployment object will use the values defined in the `/usercode/multiple-deployments/values.yaml` file.

Open the `/usercode/multiple-deployments/templates/deployment.yaml` file and create a Deployment object that contains the following specifications:

+ `metadata.name: [The.Release.Name]-deployment`
+ `spec.selector.matchLabels.app.kubernetes.io/name: app.name`
+ `spec.selector.matchLabels.app.kubernetes.io/component: app.component`
+ `spec.selector.matchLabels.app.kubernetes.io/managed-by: app.manager`
+ `spec.template.metadata.labels.app.kubernetes.io/name: app.name`
+ `spec.template.metadata.labels.app.kubernetes.io/component: app.component`
+ `spec.template.metadata.labels.app.kubernetes.io/managed-by: app.manager`
+ `spec.template.spec.initContainers.name: initContainers.name`
+ `spec.template.spec.initContainers.image: [initContainers.image]:[initContainers.tag]`
+ `spec.template.spec.initContainers.command: initContainers.command`
+ `spec.template.spec.containers.name: deployments.name`
+ `spec.template.spec.containers.image: [image.repository]:[image.tag]`
+ `spec.template.spec.containers.imagePullPolicy: deployments.imagePullPolicy`
+ `spec.template.spec.containers.ports.containerPort: deployments.containerPort`
+ `spec.template.spec.containers.envFrom.configMapRef.name: configmap.name`

Add the following code to the `/usercode/multiple-deployments/templates/deployment.yaml` file:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{.Values.app.name}}
      app.kubernetes.io/component: {{.Values.app.component}}
      app.kubernetes.io/managed-by: {{.Values.app.manager}}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{.Values.app.name}}
        app.kubernetes.io/component: {{.Values.app.component}}
        app.kubernetes.io/managed-by: {{.Values.app.manager}}
    spec:
      initContainers:
      - name: check-db-ready
        image: postgres:9.6.5
        command: ['sh', '-c', 
          'until pg_isready -h postgres -p 5432; 
          do echo waiting for database; sleep 10; done;']
      containers:
      - name: {{.Values.deployments.name}}
        image: {{.Values.image.repository}}:{{.Values.image.tag}}
        imagePullPolicy: {{.Values.deployments.imagePullPolicy}}
        ports:
        - containerPort: {{.Values.deployments.containerPort}}
        envFrom:
          - configMapRef:
                name: {{ .Values.configmap.name }}
```
### Task 13: Deploy the Chart

it’s time to deploy the application.

You can deploy the chart successfully by doing the following:

+ Change the directory to `/usercode`.
+ In the `/usercode/multiple-deployments/templates/NOTES.txt` file, add some text that will be printed once the application is deployed.
+ Verify that there is no issue with the chart’s formatting.
+ Install the Helm chart.
+ Verify the Pod’s status.

Since Helm uses the name as the key, you cannot install two applications with the same name in the same namespace. This means that if the installation fails, you need to upgrade the chart by using the following command or reinstall the chart with a different name:

```shell
helm upgrade your-release-name ./your-chart-name
```

For this task, perform the following steps:

+ Use the following command to change the current directory:

```shell
cd /usercode
```
+ In the `/usercode/multiple-deployments/templates/NOTES.txt` file, add the following text:

```text
Your application has been successfully deployed.
```

+ Use the following command to verify that there are no syntax errors:

```shell
helm lint ./multiple-deployments
```

You should get `1 chart(s) linted, 0 chart(s) failed` in the output.

+ Use the following command to deploy the chart:

```shell
helm install <your-release-name> ./multiple-deployments
```
Along with some details of the Deployment, the message that you added in the `/usercode/multiple-deployments/templates/NOTES.txt` file will be printed to the screen in the ”Notes” section.

+ Use the following command to check the Pod’s status:

```shell
watch kubectl get pods
```

### Task 14: Access the Application

In the project’s final task, access the already deployed application on the internet.

Follow these two steps to successfully access the application:

+ Check the status of the Service.
+ Access the internal Kubernetes application using the internet. To do this, map the Service port to `31111`.

For this task, perform the following steps:

+ Use the following command to check the status of the Service:

```shell
kubectl get service 
```

+ Use the following command to map the Service to the localhost:

```shell
kubectl port-forward svc/<your-service-name> --address 0.0.0.0 31111:31111
```

Verify that the application is running by refreshing the web browser.






















  
























