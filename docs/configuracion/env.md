# Variables de Entorno

Configuracion de variables de entorno para el proyecto.

## Puertos Configurables

| Variable | Descripcion | Valor por defecto |
| :--- | :--- | :--- |
| MONGODB_PORT | Puerto de MongoDB | 27017 |
| API_PORT | Puerto del Backend API | 8080 |
| WEB_PORT | Puerto del Frontend | 3000 |
| DEBUG_PORT | Puerto de Debug (JVM) | 5005 |

### Ejemplo .env con puertos personalizados

```env
# Cambiar puertos si hay conflictos
MONGODB_PORT=27018
API_PORT=8081
WEB_PORT=3001
DEBUG_PORT=5006

# JWT Configuration
JWT_SECRET=your-super-secret-key-minimum-32-characters-long
JWT_EXPIRATION_MS=86400000
```

### .env.example

```env
# Puerto de MongoDB
MONGODB_PORT=27017

# Puerto del Backend API
API_PORT=8080

# Puerto del Frontend
WEB_PORT=3000

# Puerto de Debug (JVM)
DEBUG_PORT=5005

# JWT Configuration
JWT_SECRET=your-super-secret-key-minimum-32-characters-long
JWT_EXPIRATION_MS=86400000
```

## Variables del Backend (task-api)

| Variable | Descripcion | Valor por defecto |
| :--- | :--- | :--- |
| MONGODB_URI | URI de conexion a MongoDB | mongodb://mongodb:27017/taskdb |
| JWT_SECRET | Clave secreta para firmar JWT (min 32 chars) | - |
| JWT_EXPIRATION_MS | Tiempo de expiracion del token en ms | 86400000 (24h) |
| SERVER_PORT | Puerto interno del servidor | 8080 |

## Variables del Frontend (task-web)

| Variable | Descripcion | Valor por defecto |
| :--- | :--- | :--- |
| NEXT_PUBLIC_API_URL | URL base del API | http://localhost:8080 |

**NOTA:** Las variables con prefijo `NEXT_PUBLIC_` son visibles en el cliente.

## Verificacion de Puertos

```bash
# Ver puertos en uso
netstat -ano | findstr :8080
netstat -ano | findstr :3000

# Ver estado de servicios
make ps
```

## Configuracion de Produccion

### Generar JWT_SECRET seguro

```bash
# Linux/Mac
openssl rand -base64 32

# Windows (PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
```

### Ejemplo .env.prod

```env
# Puertos
MONGODB_PORT=27017
API_PORT=8080
WEB_PORT=3000

# Backend
JWT_SECRET=<generar-con-openssl>
JWT_EXPIRATION_MS=86400000

# Frontend
NEXT_PUBLIC_API_URL=https://api.tudominio.com
```

## Verificacion

```bash
# Ver variables de entorno del contenedor
docker exec task-api env | grep -E "MONGODB|JWT"

# Ver contenedores y puertos activos
docker-compose ps
```
