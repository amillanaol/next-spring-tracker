.PHONY: help up down logs rebuild clean build lint test

# Colores
GREEN  := \033[0;32m
YELLOW := \033[0;33m
NC     := \033[0m

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-12s$(NC) %s\n", $$1, $$2}'

up: ## Levanta todos los servicios en background
	@echo "$(YELLOW)Starting services...$(NC)"
	docker compose up -d
	@echo ""
	@echo "$(GREEN)Services started:$(NC)"
	@echo "  - PostgreSQL: localhost:5432"
	@echo "  - task-api:   localhost:8080"
	@echo "  - task-web:   localhost:3000"

up-dev: ## Levanta servicios con hot reload y logs visibles
	@echo "$(YELLOW)Starting services with hot reload...$(NC)"
	docker compose up
	@echo ""
	@echo "$(GREEN)Services started with hot reload:$(NC)"
	@echo "  - PostgreSQL: localhost:5432"
	@echo "  - task-api:   localhost:8080 (hot reload)"
	@echo "  - task-web:   localhost:3000 (hot reload)"

down: ## Detiene todos los servicios
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker compose down

logs: ## Muestra logs de todos los servicios
	docker compose logs -f

logs-api: ## Logs solo del API
	docker compose logs -f task-api

logs-web: ## Logs solo del frontend
	docker compose logs -f task-web

logs-postgres: ## Logs solo de PostgreSQL
	docker compose logs -f postgres

rebuild: ## Reconstruye y levanta servicios
	@echo "$(YELLOW)Rebuilding services...$(NC)"
	docker compose up -d --build

build: ## Solo construye las imágenes
	docker compose build

clean: ## Limpia contenedores, volúmenes y orphan images
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker compose down -v --remove-orphans
	docker system prune -f

restart: down up ## Reinicia todos los servicios

ps: ## Muestra estado de servicios
	docker compose ps

psql-shell: ## Entra al shell de PostgreSQL
	docker exec -it taskmanager_postgres psql -U postgres -d taskdb

psql-logs: ## Logs de PostgreSQL
	docker compose logs -f postgres

# Kubernetes
k8s-apply: ## Aplica manifiestos de Kubernetes
	kubectl apply -f k8s/

k8s-delete: ## Elimina recursos de Kubernetes
	kubectl delete -f k8s/

# Desarrollo local (sin Docker)
dev-api: ## Levanta API localmente (requiere PostgreSQL corriendo)
	cd task-api && mvn spring-boot:run

dev-web: ## Levanta frontend localmente
	cd task-web && npm run dev
