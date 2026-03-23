# Resolucion de Errores

Guia de solucion para errores comunes del proyecto.

## Errores Comunes

| Sintoma | Causa Raiz | Solucion Tecnica |
| :--- | :--- | :--- |
| `Device or resource busy` al eliminar carpeta | LSP del IDE mantiene lock | Cerrar VS Code y eliminar manualmente |
| `connection refused` al conectar frontend a API | API no ha terminado de iniciar | Esperar ~30s o verificar `make logs-api` |
| `401 Unauthorized` en todas las peticiones | Token expirado o no se envia | Verificar que Axios interceptor agrega el header |
| `MongoDB connection refused` | MongoDB no esta corriendo | `make up` o `docker-compose start mongodb` |
| `JWT validation failed` | Secret diferente en produccion | Verificar JWT_SECRET coincide en todos los contenedores |
| `503 Service Unavailable` | task-api no esta healthy | `make logs-api` para ver errores de inicio |
| `CORS error` en navegador | Origen no permitido | Verificar `cors.allowed-origins` en SecurityConfig |

## Errores de Docker

### Container task-api no inicia

```bash
# Ver logs
docker-compose logs task-api

# Causa comun: MongoDB no listo
# Solucion: esperar healthcheck de MongoDB
docker-compose up -d
```

### Puerto ya en uso

```bash
# Ver que proceso usa el puerto
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080

# Matar proceso o cambiar puerto en docker-compose.yml
```

### Imagen no se construye

```bash
# Limpiar cache de Docker
docker-compose build --no-cache

# O limpiar todo
docker system prune -a
```

## Errores del Backend (Spring Boot)

### `Unable to acquire JDBC Connection`

```
Could not open JPA EntityManager for transaction
Unable to acquire JDBC Connection
```

**Causa:** MongoDB no disponible
**Solucion:**

```bash
# Verificar que MongoDB esta corriendo
docker-compose ps mongodb

# Ver logs
docker-compose logs mongodb
```

### `JWT validation failed`

```
JwtException: Unsupported Jwt token
```

**Causa:** Token mal formado o secret incorrecto
**Solucion:** Verificar que `jwt.secret` es igual en application.properties y variables de entorno

### `Email already exists`

**Causa:** Intento de registro con email ya usado
**Solucion:** Usar otro email o hacer login

## Errores del Frontend (Next.js)

### `AxiosError: Network Error`

**Causa:** CORS o API no disponible
**Solucion:**

```bash
# Verificar que el API esta corriendo
curl http://localhost:8080/api/auth/login

# Verificar NEXT_PUBLIC_API_URL en .env
```

### `localStorage is not defined`

**Causa:** Codigo usa localStorage en server-side
**Solucion:** Verificar que se usa `'use client'` en componentes Next.js

### `TypeError: Cannot read properties of undefined`

**Causa:** Datos no cargados aun (async)
**Solucion:** Usar estados de carga (`isLoading`)

## Errores de Kubernetes

### Pod en CrashLoopBackOff

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### PVC stuck en Pending

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

### Ingress no funcionando

```bash
kubectl get ingress
kubectl describe ingress task-manager-ingress
```

Verificar que el Ingress controller esta instalado:

```bash
kubectl get pods -n ingress-nginx
```

## Scripts de Diagnostico

```bash
# Estado de todos los servicios
make ps

# Logs del API
make logs-api

# Logs del frontend
make logs-web

# Logs de MongoDB
make logs-mongo

# Entrar a MongoDB shell
make mongo-shell

# Reiniciar un servicio
docker-compose restart task-api
```
