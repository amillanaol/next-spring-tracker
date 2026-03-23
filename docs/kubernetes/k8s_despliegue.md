# Despliegue en Kubernetes

Guia para desplegar el proyecto en un cluster de Kubernetes.

## Requisitos

- kubectl configurado
- Cluster Kubernetes >= 1.28
- Ingress controller (nginx-ingress recomendado)

## Estructura de Manifiestos

```
k8s/
├── task-api/
│   ├── deployment.yaml    # Deployment del API
│   ├── service.yaml       # Service ClusterIP
│   ├── hpa.yaml          # Auto-scaling
│   └── secret.yaml       # Secrets (JWT, MongoDB)
├── task-web/
│   ├── deployment.yaml    # Deployment del frontend
│   └── service.yaml       # Service ClusterIP
└── ingress.yaml           # Ingress rules
```

## Preparacion

### 1. Crear Secret con credenciales

```bash
# Editar k8s/task-api/secret.yaml con valores reales
kubectl apply -f k8s/task-api/secret.yaml
```

### 2. Construir y subir imagenes

```bash
# Construir imagenes
docker build -t task-api:latest ./task-api
docker build -t task-web:latest ./task-web

# Taggear para registry
docker tag task-api:latest your-registry.com/task-api:latest
docker tag task-web:latest your-registry.com/task-web:latest

# Subir a registry
docker push your-registry.com/task-api:latest
docker push your-registry.com/task-web:latest
```

### 3. Actualizar imagenes en deployments

Editar `k8s/task-api/deployment.yaml`:

```yaml
spec:
  containers:
    - name: task-api
      image: your-registry.com/task-api:latest
```

## Despliegue

### 1. Desplegar MongoDB (si no existe)

```bash
# Usar Helm o operador de MongoDB
helm install mongodb bitnami/mongodb --namespace default
```

### 2. Aplicar manifiestos

```bash
# Crear namespace
kubectl create namespace task-manager

# Aplicar todo
kubectl apply -f k8s/ -n task-manager
```

### 3. Verificar estado

```bash
# Ver pods
kubectl get pods -n task-manager

# Ver servicios
kubectl get svc -n task-manager

# Ver deployments
kubectl get deploy -n task-manager
```

## Acceso desde outside

### Opcion 1: Ingress (recomendado)

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: task-manager-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: taskmanager.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: task-api
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: task-web
                port:
                  number: 80
```

### Opcion 2: NodePort

```yaml
# Modificar services para usar NodePort
kubectl patch svc task-web -n task-manager -p '{"spec":{"type":"NodePort"}}'
```

## Auto-scaling

El HPA escala automaticamente basado en CPU:

```yaml
# k8s/task-api/hpa.yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

Verificar HPA:

```bash
kubectl get hpa -n task-manager
```

## Monitoreo

### Ver logs

```bash
# Logs de un pod
kubectl logs -f task-api-xxx -n task-manager

# Logs de todos los pods
kubectl logs -f -l app=task-api -n task-manager
```

### Ver eventos

```bash
kubectl get events -n task-manager --sort-by='.lastTimestamp'
```

### Describe pod

```bash
kubectl describe pod task-api-xxx -n task-manager
```

## Comandos Utiles

```bash
# Ver estado
kubectl get all -n task-manager

# Reiniciar deployment
kubectl rollout restart deployment/task-api -n task-manager

# Ver historial de rollouts
kubectl rollout history deployment/task-api -n task-manager

# Rollback
kubectl rollout undo deployment/task-api -n task-manager

# Eliminar todo
kubectl delete -f k8s/ -n task-manager
```

## Troubleshooting

### Pod en Pending

```bash
kubectl describe pod <pod-name>
# Posible causa: recursos insuficientes o PVC pendiente
```

### ImagePullBackOff

```bash
# Verificar nombre de imagen
kubectl describe pod <pod-name>
# Causa: imagen no existe en registry
```

### CrashLoopBackOff

```bash
kubectl logs <pod-name>
# Ver causa del crash
```
