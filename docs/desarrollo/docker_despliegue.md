# Despliegue con Docker Compose

Configuracion y comandos para ejecutar el proyecto con Docker Compose.

## Configuracion de Servicios

El archivo `docker-compose.yml` define tres servicios:

### MongoDB

```yaml
mongodb:
  image: mongo:6.0
  ports:
    - "27017:27017"
  volumes:
    - mongodb_data:/data/db
    - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
  healthcheck:
    test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/taskdb --quiet
```

- Puerto: 27017
- Volumen persistente: `mongodb_data`
- Script de inicializacion: `mongo-init.js`

### task-api (Backend)

```yaml
task-api:
  build:
    context: ./task-api
    dockerfile: Dockerfile
  ports:
    - "8080:8080"
  environment:
    MONGODB_URI: mongodb://mongodb:27017/taskdb
    JWT_SECRET: ${JWT_SECRET:-supersecretkey123456789012345678901234567890}
    JWT_EXPIRATION_MS: ${JWT_EXPIRATION_MS:-86400000}
  depends_on:
    mongodb:
      condition: service_healthy
```

### task-web (Frontend)

```yaml
task-web:
  build:
    context: ./task-web
    dockerfile: Dockerfile
  ports:
    - "3000:3000"
  environment:
    NEXT_PUBLIC_API_URL: http://localhost:8080
  depends_on:
    - task-api
```

## Comandos Docker Compose

### Levantar todos los servicios

```bash
docker-compose up -d
```

### Ver estado

```bash
docker-compose ps
```

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo un servicio
docker-compose logs -f task-api
docker-compose logs -f task-web
docker-compose logs -f mongodb
```

### Reconstruir imagenes

```bash
docker-compose up -d --build
```

### Detener servicios

```bash
docker-compose down
```

### Limpiar todo (volumenes incluidos)

```bash
docker-compose down -v --remove-orphans
docker system prune -f
```

## Desarrollo con Hot Reload

Los volumenes montados permiten desarrollo con hot reload:

```yaml
task-api:
  volumes:
    - ./task-api:/app
    - maven_cache:/root/.m2

task-web:
  volumes:
    - ./task-web:/app
    - nextjs_cache:/app/.next
```

### Backend (Java)

Los cambios en `src/` se recargan automaticamente. Para reiniciar:

```bash
docker-compose restart task-api
```

### Frontend (Next.js)

Los cambios se recargan automaticamente via Fast Refresh.

## Verificacion Post-Despliegue

### 1. Verificar contenedores

```bash
docker-compose ps
```

### 2. Verificar logs del backend

```bash
docker-compose logs task-api | grep "Started"
```

Deberia aparecer: `Started TaskManagerApplication`

### 3. Probar endpoint de login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'
```

### 4. Verificar base de datos

```bash
docker exec taskmanager_mongodb mongosh --eval "db.users.find()" taskdb
docker exec taskmanager_mongodb mongosh --eval "db.tasks.find()" taskdb
```

## Troubleshooting

### Backend no inicia

```bash
# Ver logs detallados
docker-compose logs task-api

# Verificar que MongoDB esta healthy
docker-compose ps mongodb
```

### Frontend no conecta al API

Verificar que `NEXT_PUBLIC_API_URL` apunta a `http://localhost:8080`.

### MongoDB no esta healthy

```bash
# Ver logs de MongoDB
docker-compose logs mongodb

# Verificar que el puerto 27017 no esta en uso
lsof -i :27017
```
