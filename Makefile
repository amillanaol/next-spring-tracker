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
	docker-compose up -d
	@echo ""
	@echo "$(GREEN)Services started:$(NC)"
	@echo "  - MongoDB:  localhost:27017"
	@echo "  - task-api: localhost:8080"
	@echo "  - task-web: localhost:3000"

up-dev: ## Levanta servicios con hot reload y logs visibles
	@echo "$(YELLOW)Starting services with hot reload...$(NC)"
	docker-compose up
	@echo ""
	@echo "$(GREEN)Services started with hot reload:$(NC)"
	@echo "  - MongoDB:  localhost:27017"
	@echo "  - task-api: localhost:8080 (hot reload)"
	@echo "  - task-web: localhost:3000 (hot reload)"

down: ## Detiene todos los servicios
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker-compose down

logs: ## Muestra logs de todos los servicios
	docker-compose logs -f

logs-api: ## Logs solo del API
	docker-compose logs -f task-api

logs-web: ## Logs solo del frontend
	docker-compose logs -f task-web

logs-mongo: ## Logs solo de MongoDB
	docker-compose logs -f mongodb

rebuild: ## Reconstruye y levanta servicios
	@echo "$(YELLOW)Rebuilding services...$(NC)"
	docker-compose up -d --build

build: ## Solo construye las imágenes
	docker-compose build

clean: ## Limpia contenedores, volúmenes y orphan images
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker-compose down -v --remove-orphans
	docker system prune -f

restart: down up ## Reinicia todos los servicios

ps: ## Muestra estado de servicios
	docker-compose ps

mongo-shell: ## Entra al shell de MongoDB
	docker exec -it taskmanager_mongodb mongosh taskdb

mongo-logs: ## Logs de MongoDB
	docker-compose logs -f mongodb

# Kubernetes
k8s-apply: ## Aplica manifiestos de Kubernetes
	kubectl apply -f k8s/

k8s-delete: ## Elimina recursos de Kubernetes
	kubectl delete -f k8s/

# Desarrollo local (sin Docker)
dev-api: ## Levanta API localmente (requiere MongoDB corriendo)
	cd task-api && mvn spring-boot:run

dev-web: ## Levanta frontend localmente
	cd task-web && npm run dev
