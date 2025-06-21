#!/bin/bash

# Simple monitoring script for homelab LLM server

echo "=== LLM Server Monitor ==="
echo "Time: $(date)"
echo ""

# Check if container is running
CONTAINER_NAME="${CONTAINER_NAME:-homelab-llm-server}"
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✓ Container Status: Running"
    
    # Get container stats
    echo ""
    echo "Container Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" "${CONTAINER_NAME}"
    
    # Check GPU usage inside container
    echo ""
    echo "GPU Status:"
    docker exec "${CONTAINER_NAME}" bash -c "rocm-smi --showmeminfo vram --csv | grep -v 'GPU' | head -n 1" 2>/dev/null || echo "Unable to get GPU stats"
    
    # Check server health
    echo ""
    echo "Server Health:"
    if curl -s -f "http://localhost:${SERVER_PORT:-8080}/health" > /dev/null 2>&1; then
        echo "✓ Health endpoint: OK"
    else
        echo "✗ Health endpoint: Not responding"
    fi
    
    # Show recent logs
    echo ""
    echo "Recent Logs (last 10 lines):"
    docker logs --tail 10 "${CONTAINER_NAME}" 2>&1
    
else
    echo "✗ Container Status: Not running"
    echo ""
    echo "To start the server, run:"
    echo "  docker compose up -d"
fi

echo ""
echo "========================="