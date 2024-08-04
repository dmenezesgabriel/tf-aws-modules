# K8s

## Requirements

- Docker
- Minikube
- Kubectl
- [Istio.io](https://istio.io/latest/docs/setup/getting-started/#download)

## Istio

```sh
curl -L https://istio.io/downloadIstio | sh -
cd istio-<version>
cd bin
./istioctl install --set profile=default -y
```
## Docker

- **Login to DockerHub**:

```sh
docker login registry-1.docker.io
```

- **Build images**:

```sh
docker build --platform=linux/amd64 -t dmenezesgabriel/cognito-api:latest ./../../../examples/images/cognito_api
docker build --platform=linux/amd64 -t dmenezesgabriel/todo-command:latest ./../../../examples/images/todo_command
```

- **Push images**:

```sh
docker push dmenezesgabriel/cognito-api:latest
docker push dmenezesgabriel/todo-command:latest
```

## Minikube

- **Start**:

```sh
minikube start --driver=docker --install-addons=true --kubernetes-version=stable

```

- **Stop**:

```sh
minikube stop
```

## Kubectl

- **Get all**:
```sh
kubectl get all
```

- **Debug**:

```sh
kubectl --context=minikube get pods -n todo-app
kubectl --context=minikube logs <pod_name> -n todo-app

kubectl --context=minikube describe pod <pod_name> -n todo-app # Check events
kubectl --context=minikube exec -it <pod_name> -n todo-app -- /bin/sh

kubectl --context=minikube get endpoints <pod_name> -n todo-app
kubectl --context=minikube get services -n todo-app # see clusterIP
```

### Apply manifests

#### Enable metrics server

```sh
kubectl --context=minikube apply -f cluster/components.yaml

kubectl --context=minikube get deployment metrics-server -n kube-system

kubectl --context=minikube top node

kubectl --context=minikube delete -f cluster/components.yaml
```

#### Namespace

```sh
kubectl --context=minikube apply -f namespace/namespace.yaml

kubectl --context=minikube get namespaces

kubectl --context=minikube delete -f namespace/namespace.yaml
```


#### Istio

```sh
kubectl label namespace todo-app istio-injection=enabled
```

Gateway

```sh
kubectl --context=minikube apply -f gateway/gateway.yaml -n todo-app
kubectl --context=minikube apply -f gateway/gateway-virtual-service.yaml -n todo-app

kubectl --context=minikube delete -f gateway/gateway.yaml -n todo-app
kubectl --context=minikube delete -f gateway/gateway-virtual-service.yaml -n todo-app
```


#### PostgreSQL

```sh
kubectl --context=minikube apply -f postgres/secret.yaml -n todo-app
kubectl --context=minikube apply -f postgres/pv.yaml -n todo-app
kubectl --context=minikube apply -f postgres/pvc.yaml -n todo-app
kubectl --context=minikube apply -f postgres/deployment.yaml -n todo-app
kubectl --context=minikube apply -f postgres/service.yaml -n todo-app

kubectl --context=minikube delete -f postgres/secret.yaml -n todo-app
kubectl --context=minikube delete -f postgres/pv.yaml -n todo-app
kubectl --context=minikube delete -f postgres/pvc.yaml -n todo-app
kubectl --context=minikube delete -f postgres/deployment.yaml -n todo-app
kubectl --context=minikube delete -f postgres/service.yaml -n todo-app
```

Run SQL files:

```sh
kubectl --context=minikube kustomize postgres -n todo-app

kubectl --context=minikube apply -k postgres -n todo-app

kubectl --context=minikube delete -k postgres -n todo-app
```

Port Forward:

```sh
kubectl port-forward svc/postgres 5432:5432 -n todo-app
```

#### Todo Command

Migrations:

```sh
kubectl --context=minikube apply -f todo_command/secret.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/job.yaml

kubectl --context=minikube delete -f todo_command/secret.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/job.yaml -n todo-app
```

Application:

```sh
kubectl --context=minikube apply -f todo_command/deployment.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/service.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/node-port-service.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/virtual-service.yaml -n todo-app

kubectl --context=minikube delete -f todo_command/deployment.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/service.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/node-port-service.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/virtual-service.yaml -n todo-app
```

Port Forward

```sh
kubectl port-forward service/todo-command --address 0.0.0.0 8000:8000 -n todo-app
```
