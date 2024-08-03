# K8s

## Docker

- **Login to DockerHub**:

```sh
docker login registry-1.docker.io
```

- **Build images**:

```sh
docker build --platform=linux/amd64 -t dmenezesgabriel/ecs-todo-auth:latest ./services/auth
docker build --platform=linux/amd64 -t dmenezesgabriel/ecs-todo-command:latest ./services/command
```

- **Push images**:

```sh
docker push dmenezesgabriel/ecs-todo-auth:latest
docker push dmenezesgabriel/ecs-todo-command:latest
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

### Apply manifests

- **Enable metrics on cluster**:

```sh
kubectl --context=minikube apply -f cluster/components.yaml

kubectl --context=minikube get deployment metrics-server -n kube-system

kubectl --context=minikube top node
```

- **Namespace**:

```sh
kubectl --context=minikube apply -f namespace/namespace.yaml

kubectl --context=minikube get namespaces
```

- **PostgreSQL**:

```sh
kubectl --context=minikube apply -k postgres -n todo-app
kubectl get configmap postgres-init-scripts -n todo-app -o yaml

kubectl --context=minikube apply -f postgres/secret.yaml -n todo-app
kubectl --context=minikube apply -f postgres/pv.yaml -n todo-app
kubectl --context=minikube apply -f postgres/pvc.yaml -n todo-app
kubectl --context=minikube apply -f postgres/deployment.yaml -n todo-app
kubectl --context=minikube apply -f postgres/service.yaml -n todo-app

kubectl exec -it run-postgres-init-scripts-5gmrl -n todo-app -- /bin/sh

kubectl --context=minikube get all -n todo-app
kubectl --context=minikube get deployment -n todo-app
kubectl --context=minikube get services -n todo-app
kubectl --context=minikube get pods -n todo-app
kubectl --context=minikube describe pod postgres-76d896f475-cgnp8 -n todo-app
kubectl --context=minikube logs postgres-76d896f475-8n48q -n todo-app

kubectl --context=minikube delete -f postgres/secret.yaml -n todo-app
kubectl --context=minikube delete -f postgres/pv.yaml -n todo-app
kubectl --context=minikube delete -f postgres/pvc.yaml -n todo-app
kubectl --context=minikube delete -f postgres/deployment.yaml -n todo-app
kubectl --context=minikube delete -f postgres/service.yaml -n todo-app
```

Run SQL files:

```sh
kubectl apply -f postgres/job.yaml && kubectl logs -f $(kubectl get pods -n todo-app --selector=job-name=run-postgres-init-scripts -o=jsonpath='{.items[0].metadata.name}') -n todo-app

# or

kubectl --context=minikube apply -f postgres/job.yaml
kubectl --context=minikube get pods -n todo-app
kubectl --context=minikube logs run-postgres-init-scripts-knf6l -n todo-app

kubectl --context=minikube delete -f postgres/job.yaml -n todo-app
```

Port Forward:

```sh
kubectl port-forward svc/postgres 5432:5432 -n todo-app
```
