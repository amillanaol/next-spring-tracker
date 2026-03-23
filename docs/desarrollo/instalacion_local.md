# Instalacion Local

Guia paso a paso para instalar y ejecutar el proyecto localmente.

## Requisitos Previos

- Docker Desktop >= 20.10
- Docker Compose >= 2.0
- Make (opcional, para usar Makefile)

## Modo Desarrollo (Hot Reload)

### 1. Levantar todos los servicios

```bash
docker-compose up
```

Esto iniciara:
- **MongoDB** en puerto 27017
- **task-api** en puerto 8080 (hot reload activo)
- **task-web** en puerto 3000 (hot reload activo)

### 2. Verificar servicios

```bash
make ps
```

Deberia mostrar:

| Service | Status | Port |
| :--- | :--- | :--- |
| mongodb | Up | 27017 |
| task-api | Up | 8080 |
| task-web | Up | 3000 |

### 3. Acceder a la aplicacion

Abrir navegador en: http://localhost:3000

### Hot Reload

Los cambios en el codigo se reflejan automaticamente:

- **Backend**: Spring Boot DevTools recarga cambios automaticamente
- **Frontend**: Next.js Fast Refresh recarga cambios automaticamente

Para ver logs en tiempo real:

```bash
docker-compose logs -f
```

## Configurar variables de entorno

```bash
cp .env.example .env
```

```env
JWT_SECRET=your-super-secret-key-minimum-32-characters-long
JWT_EXPIRATION_MS=86400000
NEXT_PUBLIC_API_URL=http://localhost:8080
```

## Comandos Utiles

```bash
make up          # Levantar servicios
make down        # Detener servicios
make logs        # Ver todos los logs
make logs-api    # Ver logs del API
make logs-web    # Ver logs del frontend
make rebuild     # Reconstruir imagenes
make clean       # Limpiar contenedores y volumenes
make ps          # Estado de servicios
```

## Verificar Salud del Backend

```bash
curl http://localhost:8080/api/auth/login
```

Deberia retornar `401 Unauthorized` (esto es correcto, significa que el API esta funcionando).

## Acceder a MongoDB

```bash
make mongo-shell
```

O usando Docker directamente:

```bash
docker exec -it taskmanager_mongodb mongosh taskdb
```

## Desarrollo Sin Docker (Opcional)

Si prefieres ejecutar sin Docker:

### Backend

```bash
cd task-api

# Requiere MongoDB local en puerto 27017
mvn spring-boot:run
```

### Frontend

```bash
cd task-web
npm install
npm run dev
```
