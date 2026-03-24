# Resolucion de Errores

Guia de solucion para errores comunes del proyecto.

## Errores de Docker Compose

### make: docker-compose: No such file or directory

**Sintoma:** Error al ejecutar `make up`

**Causa Raiz:** Las versiones nuevas de Docker CLI integran compose como subcomando

**Solucion Tecnica:**
```bash
# Usar espacio en vez de guion
docker compose up -d

# O actualizar el Makefile替换 todas las ocurrencias de docker-compose por docker compose
```

### no configuration file provided: not found

**Sintoma:** `docker compose up -d` falla con este error

**Causa Raiz:** El comando no se ejecuta desde el directorio del proyecto

**Solucion Tecnica:**
```bash
cd ~/src/NextSpringTracker
docker compose up -d
```

### Container taskmanager_postgres is unhealthy

**Sintoma:** El contenedor de PostgreSQL no pasa el healthcheck

**Causa Raiz:** El healthcheck usa `pg_isready` pero puede fallar si PostgreSQL esta inicializando

**Solucion Tecnica:**
```yaml
# En docker-compose.yml, el healthcheck ya esta configurado:
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 5s
  timeout: 5s
  retries: 5
  start_period: 10s
```

### dependency failed to start: postgres

**Sintoma:** Los otros contenedores no inician porque PostgreSQL no esta healthy

**Causa Raiz:** Healthcheck de PostgreSQL fallando o red de Docker no funciona

**Solucion Tecnica:**
```bash
# Ver logs de PostgreSQL
docker logs taskmanager_postgres

# En WSL, configurar DNS
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# O reiniciar WSL
wsl --shutdown
```

### Temporary failure in name resolution

**Sintoma:** Maven o npm no pueden descargar dependencias

**Causa Raiz:** DNS no funciona en el contenedor o en WSL

**Solucion Tecnica:**
```bash
# En WSL
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# En Docker, verificar configuracion de red
docker network inspect bridge
```

## Errores del Backend (Spring Boot)

### Missing artifact io.jsonwebtoken:jjwt

**Sintoma:** Maven no puede resolver dependencias JWT

**Causa Raiz:** La dependencia `jjwt` no existe. Solo existen `jjwt-api`, `jjwt-impl` y `jjwt-jackson`

**Solucion Tecnica:**
```xml
<!-- Eliminar del pom.xml -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>  <!-- ELIMINAR ESTA LINEA -->
    <version>${jjwt.version}</version>
</dependency>
```

### Version de JWT incorrecta

**Sintoma:** Errores de compatibilidad con jjwt 0.9.1

**Causa Raiz:** Version muy vieja con problemas conhecidos

**Solucion Tecnica:** Actualizar a version 0.11.5 en pom.xml:

```xml
<properties>
    <jjwt.version>0.11.5</jjwt.version>
</properties>
```

### Port 8080 was already in use

**Sintoma:** Spring Boot no puede iniciar

**Causa Raiz:** Otro proceso usa el puerto 8080 (posiblemente Docker task-api)

**Solucion Tecnica:**
```cmd
# Windows
netstat -ano | findstr :8080
taskkill /PID <pid> /F
```

O cambiar el puerto en `application.properties`:

```properties
server.port=8081
```

### Can't import project from workspace folder

**Sintoma:** Eclipse no puede importar el proyecto Maven

**Causa Raiz:** La carpeta de workspace esta dentro del proyecto

**Solucion Tecnica:**
1. Cerrar Eclipse
2. Mover la carpeta `eclipse-workspace` fuera de `task-api`
3. Abrir Eclipse con el nuevo workspace
4. Volver a importar el proyecto

### src/main/java/taskmanager does not exist

**Sintoma:** Error de build path en Eclipse

**Causa Raiz:** El paquete real es `com.taskmanager`, no `taskmanager`

**Solucion Tecnica:**
1. Click derecho en proyecto → Maven → Update Project
2. Seleccionar "Force Update of Snapshots/Releases"
3. OK

### Errors exist in required projects

**Sintoma:** Errores de dependencias en Eclipse

**Causa Raiz:** Maven no ha descargado las dependencias

**Solucion Tecnica:**
1. Project → Clean → Clean
2. Project → Build Automatically (verificar que este activado)
3. Click derecho → Maven → Update Project → OK

## Errores del Frontend (Next.js)

### sh: next: not found

**Sintoma:** El contenedor task-web no inicia

**Causa Raiz:** El volumen de desarrollo sobrescribe `node_modules`

**Solucion Tecnica:**
```dockerfile
# En Dockerfile.dev, usar:
CMD ["sh", "-c", "npm install && npm run dev"]
```

Luego reconstruir:

```bash
docker compose build task-web
docker compose up -d task-web
```

### Connection refused localhost:8080

**Sintoma:** Frontend no puede conectar al backend

**Causa Raiz:** API no esta corriendo o esta en otro puerto

**Solucion Tecnica:**
1. Verificar que la API esta corriendo
2. Verificar `NEXT_PUBLIC_API_URL` en variables de entorno
3. Verificar que la API usa el puerto 8080 (o actualizar la variable)

## Errores de Base de Datos

### PostgreSQL connection refused

**Sintoma:** Aplicacion no puede conectar a PostgreSQL

**Causa Raiz:** PostgreSQL no esta corriendo o la URL JDBC es incorrecta

**Solucion Tecnica:**
```bash
# Verificar que PostgreSQL esta corriendo
docker compose ps postgres

# Ver logs
docker compose logs postgres

# Reiniciar si es necesario
docker compose restart postgres
```

### PostgreSQL container starts but unhealthy

**Sintoma:** PostgreSQL corre pero el healthcheck falla

**Causa Raiz:** PostgreSQL aun esta inicializando

**Solucion Tecnica:**
```bash
# Esperar unos segundos y verificar
sleep 10
docker compose ps postgres
```

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

## Scripts de Diagnostico

```bash
# Estado de todos los servicios
make ps
docker compose ps

# Logs del API
make logs-api
docker compose logs task-api

# Logs del frontend
make logs-web
docker compose logs task-web

# Logs de PostgreSQL
make logs-postgres
docker compose logs postgres

# Entrar a PostgreSQL shell
make psql-shell

# Reiniciar un servicio especifico
docker compose restart postgres

# Reconstruir todo desde cero
docker compose down
docker compose up -d --build
```
