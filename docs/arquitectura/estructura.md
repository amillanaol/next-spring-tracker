# Arquitectura del Proyecto

Descripcion de la estructura y patrones arquitectonicos utilizados.

## Vision General

El proyecto sigue una arquitectura cliente-servidor clasica con:

- **Frontend**: SPA con Next.js 14 (App Router)
- **Backend**: API REST con Spring Boot 2.7
- **Base de datos**: PostgreSQL 15 (relacional)
- **Autenticacion**: JWT (stateless)

## Arquitectura Backend (task-api)

### Estructura de paquetes

```
task-api/src/main/java/com/taskmanager/
  controller/        # REST Controllers
    AuthController.java
    TaskController.java

  service/           # Logica de negocio
    AuthService.java
    TaskService.java

  repository/        # Acceso a datos JPA
    UserRepository.java
    TaskRepository.java

  model/             # Entidades JPA
    User.java
    Task.java
    TaskStatus.java

  dto/               # Data Transfer Objects
    LoginRequest.java
    RegisterRequest.java
    TaskRequest.java
    TaskResponse.java
    AuthResponse.java

  security/         # Seguridad Spring
    JwtUtils.java
    JwtAuthFilter.java
    JwtAuthEntryPoint.java
    SecurityConfig.java
    UserDetailsServiceImpl.java
```

### Flujo de una peticion

<div align="center">
    <img src="https://github.com/amillanaol/next-spring-tracker/blob/main/docs/arquitectura/Adjuntos/flujo_peticion.cliente_db.png"
        alt="flujo_peticion.cliente_db"
        width="700" />
</div>

## Arquitectura Frontend (task-web)

### Estructura de carpetas

```
task-web/
  app/                    # App Router (Next.js 14)
    page.tsx              # Pagina inicio
    layout.tsx            # Layout raiz
    login/page.tsx        # Pagina login
    register/page.tsx     # Pagina registro
    tasks/page.tsx        # Dashboard de tareas

  components/             # Componentes React
    Navbar.tsx            # Barra de navegacion
    TaskCard.tsx          # Tarjeta de tarea
    TaskModal.tsx         # Modal crear/editar tarea

  lib/                    # Utilidades
    axios.ts              # Instancia Axios con interceptors
    auth.ts               # Helpers de autenticacion

  types/                  # Tipos TypeScript
    index.ts              # Interfaces Task, User, etc.
```

### Flujo de autenticacion

<div align="center">
    <img src="https://github.com/amillanaol/next-spring-tracker/blob/main/docs/arquitectura/Adjuntos/autenticacion-aislamiento_datos.png"
        alt="autenticacion-aislamiento_datos"
        width="700" />
</div>

<div align="center">
    <img src="https://github.com/amillanaol/next-spring-tracker/blob/main/docs/arquitectura/Adjuntos/request_flow-autenticacion_jwt.png"
        alt="request_flow-autenticacion_jwt"
        width="700" />
</div>

## Modelo de datos

### User

```json
{
  "id": 1,
  "name": "string",
  "email": "string (unico)",
  "password": "string (bcrypt hash)",
  "createdAt": "2024-03-15T10:00:00"
}
```

### Task

```json
{
  "id": 1,
  "title": "string",
  "description": "string",
  "status": "PENDING | IN_PROGRESS | DONE",
  "userId": 1,
  "createdAt": "2024-03-15T10:00:00"
}
```

## Patrones utilizados

| Patron | Ubicacion | Descripcion |
| :--- | :--- | :--- |
| Repository | task-api/repository | Abstraccion de acceso a datos JPA |
| Service Layer | task-api/service | Logica de negocio |
| DTO | task-api/dto | Transferencia de datos API |
| Singleton | Frontend lib/* | Instancias compartidas |
| Interceptor | lib/axios.ts | Modificacion automatica de requests |

## Aislamiento de datos

Cada usuario solo ve sus propias tareas:

```java
// TaskRepository.java
List<Task> findByUserIdOrderByCreatedAtDesc(Long userId);

// TaskController.java extrae userId del JWT
Long userId = getCurrentUserId();
List<TaskResponse> tasks = taskService.findAllByUserId(userId);
```

El `userId` se extrae del token JWT, no de parametros de entrada, garantizando que un usuario no pueda acceder a tareas de otro.
