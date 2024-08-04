# K8s

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

kubectl describe pod <pod_name> -n todo-app # Check events
kubectl exec -it <pod_name> -n todo-app -- /bin/sh

kubectl get endpoints <pod_name> -n todo-app
kubectl get services -n todo-app # see clusterIP
```

### Apply manifests

- **Enable metrics on cluster**:

```sh
kubectl --context=minikube apply -f cluster/components.yaml

kubectl --context=minikube get deployment metrics-server -n kube-system

kubectl --context=minikube top node

kubectl --context=minikube delete -f cluster/components.yaml
```

- **Namespace**:

```sh
kubectl --context=minikube apply -f namespace/namespace.yaml

kubectl --context=minikube get namespaces

kubectl --context=minikube delete -f namespace/namespace.yaml
```

- **PostgreSQL**:

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

kubectl --context=minikube get configmaps -n todo-app

kubectl --context=minikube delete -k postgres -n todo-app
```

Port Forward:

```sh
kubectl port-forward svc/postgres 5432:5432 -n todo-app
```

- **Todo Command**:

Migrations:

```sh
kubectl --context=minikube apply -f todo_command/secret.yaml -n todo-app

kubectl --context=minikube apply -f todo_command/job.yaml && \
kubectl --context=minikube wait --for=condition=complete --timeout=5m job/todo-command-migrations -n todo-app && \
kubectl --context=minikube logs $(kubectl get pods -n todo-app --selector=job-name=todo-command-migrations -o=jsonpath='{.items[0].metadata.name}') -n todo-app

kubectl --context=minikube get pods -n todo-app

kubectl --context=minikube delete -f todo_command/secret.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/job.yaml -n todo-app
```

Application:

```sh
kubectl --context=minikube apply -f todo_command/deployment.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/service.yaml -n todo-app
kubectl --context=minikube apply -f todo_command/node-port-service.yaml -n todo-app

kubectl --context=minikube get pods -n todo-app
kubectl --context=minikube logs todo-command-757545fb9f-k6zst  -n todo-app

kubectl --context=minikube delete -f todo_command/deployment.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/service.yaml -n todo-app
kubectl --context=minikube delete -f todo_command/node-port-service.yaml -n todo-app
```

Port Forward

```sh
kubectl port-forward service/todo-command --address 0.0.0.0 8000:8000 -n todo-app
```
