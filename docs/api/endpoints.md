# Endpoints REST

Documentacion completa de los endpoints de la API.

## Base URL

```
http://localhost:8080/api
```

## Autenticacion

### POST /api/auth/register

Registra un nuevo usuario.

**Request:**

```json
{
  "name": "Juan Perez",
  "email": "juan@example.com",
  "password": "password123"
}
```

**Respuesta (201 Created):**

```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "id": "65f1a2b3c4d5e6f7a8b9c0d1",
  "name": "Juan Perez",
  "email": "juan@example.com"
}
```

**Errores:**

| Codigo | Mensaje |
| :--- | :--- |
| 400 | Email already exists |

---

### POST /api/auth/login

Inicia sesion y retorna JWT.

**Request:**

```json
{
  "email": "juan@example.com",
  "password": "password123"
}
```

**Respuesta (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "id": "65f1a2b3c4d5e6f7a8b9c0d1",
  "name": "Juan Perez",
  "email": "juan@example.com"
}
```

**Errores:**

| Codigo | Mensaje |
| :--- | :--- |
| 401 | Invalid email or password |

---

## Tareas

**Headers requeridos para todos los endpoints de tareas:**

```
Authorization: Bearer <token>
Content-Type: application/json
```

---

### GET /api/tasks

Lista todas las tareas del usuario autenticado.

**Respuesta (200 OK):**

```json
[
  {
    "id": "65f1a2b3c4d5e6f7a8b9c0d2",
    "title": "Terminar informe",
    "description": "Completar el informe mensual",
    "status": "IN_PROGRESS",
    "userId": "65f1a2b3c4d5e6f7a8b9c0d1",
    "createdAt": "2024-03-15T10:30:00"
  },
  {
    "id": "65f1a2b3c4d5e6f7a8b9c0d3",
    "title": "Reunión con equipo",
    "description": null,
    "status": "PENDING",
    "userId": "65f1a2b3c4d5e6f7a8b9c0d1",
    "createdAt": "2024-03-15T09:00:00"
  }
]
```

---

### POST /api/tasks

Crea una nueva tarea.

**Request:**

```json
{
  "title": "Nueva tarea",
  "description": "Descripcion opcional",
  "status": "PENDING"
}
```

**Nota:** `status` es opcional, por defecto es `PENDING`.

**Respuesta (201 Created):**

```json
{
  "id": "65f1a2b3c4d5e6f7a8b9c0d4",
  "title": "Nueva tarea",
  "description": "Descripcion opcional",
  "status": "PENDING",
  "userId": "65f1a2b3c4d5e6f7a8b9c0d1",
  "createdAt": "2024-03-15T11:00:00"
}
```

---

### PUT /api/tasks/{id}

Actualiza una tarea existente.

**Request:**

```json
{
  "title": "Tarea actualizada",
  "description": "Nueva descripcion",
  "status": "DONE"
}
```

**Respuesta (200 OK):**

```json
{
  "id": "65f1a2b3c4d5e6f7a8b9c0d4",
  "title": "Tarea actualizada",
  "description": "Nueva descripcion",
  "status": "DONE",
  "userId": "65f1a2b3c4d5e6f7a8b9c0d1",
  "createdAt": "2024-03-15T11:00:00"
}
```

**Errores:**

| Codigo | Mensaje |
| :--- | :--- |
| 404 | Task not found |

---

### DELETE /api/tasks/{id}

Elimina una tarea.

**Respuesta (200 OK):** Sin contenido

**Errores:**

| Codigo | Mensaje |
| :--- | :--- |
| 404 | Task not found |

---

## Estados de tarea

| Valor | Descripcion |
| :--- | :--- |
| PENDING | Tarea pendiente |
| IN_PROGRESS | Tarea en progreso |
| DONE | Tarea completada |

## Ejemplos con curl

```bash
# Registro
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"123456"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'

# Crear tarea (reemplazar TOKEN)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -d '{"title":"Mi tarea"}'

# Listar tareas
curl http://localhost:8080/api/tasks \
  -H "Authorization: Bearer TOKEN_AQUI"
```
