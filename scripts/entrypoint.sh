#!/bin/bash

set -e  # Exit on error

echo "=== Llama.cpp Server Startup ==="
echo "Time: $(date)"
echo ""

# Function to log with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Validate required environment variables
log "Validating configuration..."

if [ -z "$MODEL_PATH" ]; then
    log "ERROR: MODEL_PATH is not set. Please check your environment variables."
    exit 1
fi

# Set defaults
SERVER_PORT="${SERVER_PORT:-8080}"
CONTEXT_SIZE="${CONTEXT_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-50}"
ROC_ENABLE="${ROC_ENABLE:-1}"

log "Configuration:"
log "  Model Path: $MODEL_PATH"
log "  Server Port: $SERVER_PORT"
log "  Context Size: $CONTEXT_SIZE"
log "  GPU Layers: $N_GPU_LAYERS"
log "  ROCm Enabled: $ROC_ENABLE"

# Verify the model file exists
if [ ! -f "$MODEL_PATH" ]; then
    log "ERROR: Model file not found at $MODEL_PATH"
    log "Contents of model directory:"
    ls -la "$(dirname "$MODEL_PATH")" || true
    exit 1
fi

# Get model file size
MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
log "Model size: $MODEL_SIZE"

# Check for ROCm enablement
if [[ "$ROC_ENABLE" == "1" ]]; then
    log "Checking ROCm GPU availability..."
    if command -v rocminfo &>/dev/null; then
        GPU_INFO=$(rocminfo | grep -E "Name:|Device Type:" | head -n 2 | tr '\n' ' ' || echo "Unknown")
        log "GPU detected: $GPU_INFO"
        
        # Check available VRAM
        if command -v rocm-smi &>/dev/null; then
            VRAM_INFO=$(rocm-smi --showmeminfo vram | grep -E "Total|Used" | head -n 2 | tr '\n' ' ' || echo "Unknown")
            log "VRAM info: $VRAM_INFO"
        fi
    else
        log "WARNING: ROCm tools not available. GPU acceleration may not work!"
    fi
else
    log "ROCm disabled. Running in CPU mode."
fi

log ""
log "Starting server..."
log "Command: llama-server -m $MODEL_PATH -c $CONTEXT_SIZE --port $SERVER_PORT --host 0.0.0.0 --n-gpu-layers $N_GPU_LAYERS"
log ""

# Trap signals for graceful shutdown
trap 'log "Shutting down server..."; exit 0' SIGTERM SIGINT

# Start the server
exec /usr/local/bin/llama-server \
  -m "$MODEL_PATH" \
  -c "$CONTEXT_SIZE" \
  --port "$SERVER_PORT" \
  --host 0.0.0.0 \
  --n-gpu-layers "$N_GPU_LAYERS" \
  --log-disable