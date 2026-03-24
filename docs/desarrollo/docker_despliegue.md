# Despliegue con Docker Compose

Configuracion y comandos para ejecutar el proyecto con Docker Compose.

## Configuracion de Servicios

El archivo `docker-compose.yml` define tres servicios:

### PostgreSQL

```yaml
postgres:
  image: postgres:15-alpine
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
  environment:
    POSTGRES_DB: taskdb
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
```

- Puerto: 5432
- Volumen persistente: `postgres_data`
- Base de datos: `taskdb`

### task-api (Backend)

```yaml
task-api:
  build:
    context: ./task-api
    dockerfile: Dockerfile
  ports:
    - "8080:8080"
  environment:
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/taskdb
    SPRING_DATASOURCE_USERNAME: postgres
    SPRING_DATASOURCE_PASSWORD: postgres
    JWT_SECRET: ${JWT_SECRET:-supersecretkey123456789012345678901234567890}
    JWT_EXPIRATION_MS: ${JWT_EXPIRATION_MS:-86400000}
  depends_on:
    postgres:
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
docker-compose logs -f postgres
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
docker exec taskmanager_postgres psql -U postgres -d taskdb -c "SELECT * FROM users;"
docker exec taskmanager_postgres psql -U postgres -d taskdb -c "SELECT * FROM tasks;"
```

## Troubleshooting

### Backend no inicia

```bash
# Ver logs detallados
docker-compose logs task-api

# Verificar que PostgreSQL esta healthy
docker-compose ps postgres
```

### Frontend no conecta al API

Verificar que `NEXT_PUBLIC_API_URL` apunta a `http://localhost:8080`.

### PostgreSQL no esta healthy

```bash
# Ver logs de PostgreSQL
docker-compose logs postgres

# Verificar que el puerto 5432 no esta en uso
lsof -i :5432
```
