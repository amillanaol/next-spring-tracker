# Tests de Ejecucion

Guia para ejecutar y verificar los componentes del proyecto.

## Comandos de Ejecucion

| Comando | Alcance | Requisitos |
| :--- | :--- | :--- |
| make up | Levantar todos los servicios | Docker, Docker Compose |
| make build | Construir imagenes Docker | Docker |
| make logs-api | Ver logs del backend | Servicios corriendo |
| make ps | Estado de contenedores | Docker |

## Verificacion del Backend (task-api)

### Verificar compilacion

```bash
cd task-api
mvn clean compile
```

### Verificar tests unitarios (pendiente)

```bash
cd task-api
mvn test
```

### Construir JAR

```bash
cd task-api
mvn package -DskipTests
```

## Verificacion del Frontend (task-web)

### Instalar dependencias

```bash
cd task-web
npm install
```

### Verificar TypeScript

```bash
cd task-web
npx tsc --noEmit
```

### Verificar ESLint

```bash
cd task-web
npm run lint
```

### Construir produccion

```bash
cd task-web
npm run build
```

## Testing End-to-End Manual

### 1. Registro de usuario

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

Respuesta esperada:

```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "id": "65f...",
  "name": "Test User",
  "email": "test@example.com"
}
```

### 2. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### 3. Crear tarea

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"title":"Mi primera tarea","description":"Descripcion","status":"PENDING"}'
```

### 4. Listar tareas

```bash
curl http://localhost:8080/api/tasks \
  -H "Authorization: Bearer <TOKEN>"
```

## Verificacion en Navegador

1. Abrir http://localhost:3000
2. Click en Register
3. Crear cuenta
4. Verificar redirect a /tasks
5. Crear tarea
6. Editar tarea
7. Eliminar tarea
8. Probar logout
