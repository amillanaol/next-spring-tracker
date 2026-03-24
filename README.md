---
tags: MOCs
---

# Task Manager

> Aplicacion web fullstack para gestion de tareas con autenticacion JWT.

<!-- Badges -->

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue)](#)

<div align="center">

**Task Manager** es una aplicacion fullstack para gestion de tareas personales con autenticacion JWT. Cada usuario gestiona sus propias tareas de forma aislada.

**[Getting started](#inicio-rapido) | [Arquitectura](#arquitectura) | [API](#api) | [Despliegue](#despliegue) | [Documentacion](#documentacion)**

</div>

## Descripcion

Task Manager es una aplicacion fullstack para gestion de tareas personales con autenticacion JWT. Implementada con Next.js 14 (frontend) y Spring Boot 2.7 (backend), conectada a PostgreSQL 15. Sigue arquitectura REST con comunicacion stateless y esta containerizada para desarrollo local con Docker Compose y preparada para despliegues en Kubernetes.

## Indice de la documentacion

| Necesidad | Ubicacion |
| :--- | :--- |
| Instalar y ejecutar localmente | [docs/desarrollo/instalacion_local.md](docs/desarrollo/instalacion_local.md) |
| Configurar variables de entorno | [docs/configuracion/env.md](docs/configuracion/env.md) |
| Entender la arquitectura del proyecto | [docs/arquitectura/estructura.md](docs/arquitectura/estructura.md) |
| Consultar endpoints de la API REST | [docs/api/endpoints.md](docs/api/endpoints.md) |
| Ejecutar con Docker Compose | [docs/desarrollo/docker_despliegue.md](docs/desarrollo/docker_despliegue.md) |
| Desplegar en Kubernetes | [docs/kubernetes/k8s_despliegue.md](docs/kubernetes/k8s_despliegue.md) |
| Resolucion de errores comunes | [docs/errores/resolucion.md](docs/errores/resolucion.md) |
| Seguridad y autenticacion JWT | [docs/seguridad/jwt.md](docs/seguridad/jwt.md) |

## Stack Tecnico del proyecto

| Componente | Tecnologia | Version |
| :--- | :--- | :--- |
| Frontend | Next.js + React | 14.2 / 18 |
| Backend | Spring Boot + Java | 2.7 / 8 |
| Base de datos | PostgreSQL | 15 |
| Estilos | Tailwind CSS | 3.x |
| HTTP Client | Axios | 1.x |
| Formularios | React Hook Form | 7.x |
| Autenticacion | JWT (jjwt) | 0.11.5 |
| Contenedores | Docker + Compose | multi-stage |
| Orquestacion | Kubernetes | 1.28+ |
| Build Frontend | npm | 10.x |
| Build Backend | Maven | 3.9+ |

## Estructura del Proyecto

```
NextSpringTracker/
  task-api/              # Backend Spring Boot (Java 8)
    src/main/java/com/taskmanager/
      controller/        # REST Controllers (Auth, Task)
      service/           # Logica de negocio
      repository/        # Acceso a datos JPA
      model/             # Entidades JPA (User, Task, TaskStatus)
      dto/               # Data Transfer Objects
      security/          # JWT, Filtros, Configuracion
    Dockerfile           # Multi-stage build (produccion)
    Dockerfile.dev       # Desarrollo con hot reload
    pom.xml              # Dependencias Maven

  task-web/              # Frontend Next.js 14
    app/                 # App Router pages
      login/             # Pagina de login
      register/          # Pagina de registro
      tasks/             # Dashboard de tareas
    components/          # Componentes React
    lib/                 # Axios, helpers auth
    types/               # Interfaces TypeScript
    Dockerfile           # Multi-stage build (produccion)
    Dockerfile.dev       # Desarrollo con hot reload

  k8s/                   # Manifiestos Kubernetes
    task-api/            # Deployment, Service, HPA, Secret
    task-web/            # Deployment, Service
    ingress.yaml         # Ingress controller

  docker-compose.yml     # Desarrollo local
  Makefile               # Comandos de automation
  docs/                  # Documentacion del proyecto
```

## Inicio Rapido

```bash
# 1. Levantar servicios con Docker Compose
make up

# 2. Esperar a que los servicios esten healthy (~2-3 minutos)
make ps

# 3. Abrir la aplicacion en el navegador
# http://localhost:3000
```

Servicios disponibles:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- PostgreSQL: localhost:5432

## Ejecucion de Tests

| Comando | Alcance | Requisitos |
| :--- | :--- | :--- |
| make build | Construir imagenes Docker | Docker instalado |
| make logs-api | Ver logs del backend | Servicios corriendo |
| pytest (N/A) | Tests unitarios | Pendiente implementar |

**NOTA:** Para ejecucion detallada de tests consulta [docs/desarrollo/tests_ejecucion.md](docs/desarrollo/tests_ejecucion.md).

## Resolucion de Errores

Consulta la guia completa de resolucion de problemas en [docs/errores/resolucion.md](docs/errores/resolucion.md).

## Documentacion

Documentacion detallada disponible en la carpeta `docs/`:

- [Arquitectura](docs/arquitectura/) - Estructura y patrones
- [API](docs/api/) - Endpoints REST
- [Configuracion](docs/configuracion/) - Variables de entorno
- [Desarrollo](docs/desarrollo/) - Instalacion y pruebas
- [Errores](docs/errores/) - Resolucion de problemas
- [Kubernetes](docs/kubernetes/) - Despliegue K8s
- [Seguridad](docs/seguridad/) - Autenticacion JWT

## Control de versiones

| Campo | Valor |
| :--- | :--- |
| **Mantenedor** | amillanaol |
| **Estado** | En desarrollo |
| **Ultima Actualizacion** | 2026-03-23 |
