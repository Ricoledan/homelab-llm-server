.PHONY: help install build start stop restart status logs clean test lint

# Default target
help:
	@echo "HomeLab LLM Server - Available commands:"
	@echo ""
	@echo "  make install    - Install the CLI tool"
	@echo "  make build      - Build the Docker image"
	@echo "  make start      - Start the server"
	@echo "  make stop       - Stop the server"
	@echo "  make restart    - Restart the server"
	@echo "  make status     - Show server status"
	@echo "  make logs       - View server logs"
	@echo "  make clean      - Clean up containers and images"
	@echo "  make test       - Run tests"
	@echo "  make lint       - Run linters"
	@echo ""
	@echo "Model Management:"
	@echo "  make model-list     - List available models"
	@echo "  make model-download - Download a new model"
	@echo ""
	@echo "Development:"
	@echo "  make dev        - Start in development mode"
	@echo "  make shell      - Enter container shell"

# Installation
install:
	@echo "Installing HomeLab LLM Server CLI..."
	@./install.sh

# Build Docker image
build:
	docker compose build --no-cache

# Server management
start:
	@bin/llm start

stop:
	@bin/llm stop

restart:
	@bin/llm restart

status:
	@bin/llm status

logs:
	docker compose logs -f

# Model management
model-list:
	@bin/llm model list

model-download:
	@bin/llm model download

# Development
dev:
	docker compose up

shell:
	docker exec -it $(shell grep CONTAINER_NAME .env | cut -d'=' -f2) /bin/bash

# Cleanup
clean:
	docker compose down -v
	docker rmi homelab-llm-server_llama-server || true

# Testing
test:
	@echo "Running tests..."
	@bash tests/test_cli.sh

# Linting
lint:
	@echo "Running shellcheck on scripts..."
	@find . -name "*.sh" -type f | xargs shellcheck || true
	@shellcheck bin/llm || true

# Docker shortcuts
docker-prune:
	docker system prune -af

# Check prerequisites
check-deps:
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed."; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1 || { echo "Docker Compose is required but not installed."; exit 1; }
	@echo "All dependencies are installed."