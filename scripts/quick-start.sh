#!/bin/bash

# Quick start script for homelab LLM server

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_color() {
    echo -e "${2}${1}${NC}"
}

print_color "=== HomeLab LLM Server Quick Start ===" "$GREEN"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    print_color "Error: Docker is not installed" "$RED"
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_color "Error: Docker Compose is not installed" "$RED"
    exit 1
fi

# Load environment variables
if [[ -f .env ]]; then
    export $(grep -v '^#' .env | xargs)
else
    print_color "Warning: .env file not found" "$YELLOW"
fi

# Check if model exists
MODEL_PATH="${MODEL_DIR}/${MODEL_FILENAME}"
if [[ ! -f "$MODEL_PATH" ]]; then
    print_color "Model not found: $MODEL_PATH" "$YELLOW"
    echo ""
    echo "Would you like to download a model? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        ./scripts/download-model.sh --list
        echo ""
        echo "Enter model name (e.g., deepseek-33b):"
        read -r model_name
        ./scripts/download-model.sh --model "$model_name"
    else
        print_color "Please download a model first using:" "$YELLOW"
        print_color "  ./scripts/download-model.sh --help" "$YELLOW"
        exit 1
    fi
fi

# Build the container
print_color "Building Docker image..." "$GREEN"
docker compose build --no-cache

# Start the server
print_color "Starting server..." "$GREEN"
docker compose up -d

# Wait for server to be ready
print_color "Waiting for server to start..." "$YELLOW"
sleep 5

# Check if server is running
if docker ps | grep -q "${CONTAINER_NAME:-homelab-llm-server}"; then
    print_color "✓ Server is running!" "$GREEN"
    echo ""
    print_color "Server URL: http://localhost:${SERVER_PORT:-8080}" "$GREEN"
    echo ""
    print_color "Test the server with:" "$YELLOW"
    echo "curl -X POST http://localhost:${SERVER_PORT:-8080}/completion \\"
    echo "  -H \"Content-Type: application/json\" \\"
    echo "  -d '{\"prompt\": \"Hello, how are you?\", \"n_predict\": 50}'"
    echo ""
    print_color "Monitor server status:" "$YELLOW"
    echo "./scripts/monitor.sh"
    echo ""
    print_color "View logs:" "$YELLOW"
    echo "docker logs -f ${CONTAINER_NAME:-homelab-llm-server}"
else
    print_color "✗ Server failed to start" "$RED"
    print_color "Check logs with: docker logs ${CONTAINER_NAME:-homelab-llm-server}" "$YELLOW"
    exit 1
fi