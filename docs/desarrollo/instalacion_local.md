# Instalacion Local

Guia paso a paso para instalar y ejecutar el proyecto localmente.

## Requisitos Previos

- Docker Desktop >= 20.10 (o Docker Engine en Linux/WSL)
- Docker Compose >= 2.0 (CLI integrado, usar `docker compose` con espacio)
- Make (opcional, para usar Makefile)
- Maven >= 3.9 (para desarrollo backend sin Docker)
- Node.js >= 18 (para desarrollo frontend sin Docker)

## Modo Docker Compose

### 1. Levantar todos los servicios

```bash
docker compose up -d
```

**NOTA:** Usar `docker compose` (con espacio), no `docker-compose` (con guion). Las versiones nuevas de Docker CLI integran compose como subcomando.

Esto iniciara:
- **MongoDB** en puerto 27017
- **task-api** en puerto 8080 (hot reload activo)
- **task-web** en puerto 3000 (hot reload activo)

### 2. Verificar servicios

```bash
docker compose ps
```

O usando Make:

```bash
make ps
```

### 3. Acceder a la aplicacion

Abrir navegador en: http://localhost:3000

Servicios disponibles:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- MongoDB: localhost:27017

## Desarrollo con Eclipse IDE (Backend)

### Configuracion del Workspace

1. **Crear workspace fuera del proyecto:**
   - No usar la carpeta `task-api` como workspace
   - Crear una carpeta separada, por ejemplo: `NextSpringTracker/eclipse-workspace`

2. **Importar proyecto como Maven:**
   - `File → Import → Maven → Existing Maven Projects`
   - Browse: seleccionar la carpeta `task-api`
   - Finish

3. **Si aparece error "Invalid project description":**
   - Verificar que el workspace no esta dentro de la carpeta del proyecto
   - Mover la carpeta del workspace fuera de `task-api`

### Configurar Puerto del Backend

Si el puerto 8080 esta ocupado:

1. Editar `task-api/src/main/resources/application.properties`
2. Agregar o modificar:

```properties
server.port=8081
```

O crear `application.yml`:

```yaml
server:
  port: 8081
```

### Resolver Dependencias Maven

Si Eclipse muestra errores de dependencias:

```cmd
cd C:\Users\alexi\src\amillanaol\NextSpringTracker\task-api
mvn dependency:resolve
```

Si hay errores de cache:

```cmd
mvn dependency:resolve -U
```

### Ejecutar desde Eclipse

1. Asegurarse de que MongoDB este corriendo:
   ```bash
   docker compose up -d mongodb
   ```

2. En Eclipse: **Run → Run As → Spring Boot App**

3. La API estara disponible en http://localhost:8080 (o el puerto configurado)

## Desarrollo con WSL

Si ejecutas Docker desde WSL (Windows Subsystem for Linux):

### Configurar DNS de WSL

Si hay errores de red como `Temporary failure in name resolution`:

```bash
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
```

O reiniciar WSL:

```powershell
wsl --shutdown
```

### Comandos Docker en WSL

Los comandos Docker deben ejecutarse desde WSL directamente:

```bash
cd ~/src/NextSpringTracker
docker compose up -d
```

## Desarrollo Frontend (task-web)

### Opcion 1: Con Docker

```bash
docker compose up -d task-web
```

### Opcion 2: Localmente

```bash
cd task-web
npm install
npm run dev
```

El frontend se conectara a la API en `http://localhost:8080` (o el puerto configurado).

## Configurar variables de entorno

Crear archivo `.env` si no existe:

```bash
cp .env.example .env
```

Variables principales:

```env
JWT_SECRET=your-super-secret-key-minimum-32-characters-long
JWT_EXPIRATION_MS=86400000
NEXT_PUBLIC_API_URL=http://localhost:8080
```

## Comandos Utiles

```bash
make up          # Levantar servicios
make up-dev      # Levantar con logs visibles (hot reload)
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

## Solucionar Problemas Comunes

### Contenedor task-web no inicia (sh: next: not found)

El volumen de desarrollo sobrescribe `node_modules`. Los Dockerfiles ya incluyen solucion:

```dockerfile
CMD ["sh", "-c", "npm install && npm run dev"]
```

Si persiste, reconstruir imagen:

```bash
docker compose build --no-cache task-web
docker compose up -d task-web
```

### MongoDB container unhealthy

Verificar que el healthcheck usa `mongosh` (no `mongo`):

```yaml
healthcheck:
  test: ["CMD-SHELL", "mongosh --eval 'db.adminCommand(\"ping\")' --quiet"]
```

### Puerto ya en uso

Windows:
```cmd
netstat -ano | findstr :8080
taskkill /PID <numero_pid> /F
```

Linux/WSL:
```bash
lsof -i :8080
kill <pid>
```
