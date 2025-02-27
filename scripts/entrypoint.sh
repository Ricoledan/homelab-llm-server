#!/bin/bash

echo "Starting Llama.cpp Server..."

if [ -z "$MODEL_PATH" ]; then
    echo "Error: MODEL_PATH is not set. Please check your environment variables."
    exit 1
fi

if [ -z "$SERVER_PORT" ]; then
    echo "Warning: SERVER_PORT is not set. Defaulting to 8080."
    SERVER_PORT=8080
fi

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found at $MODEL_PATH"
    exit 1
fi

if [[ "$ROC_ENABLE" == "1" ]]; then
    echo "ROCm enabled. Checking GPU..."
    if ! command -v rocminfo &>/dev/null || ! /opt/rocm/bin/rocm-smi &>/dev/null; then
        echo "Warning: ROCm GPU not detected!"
    fi
fi

echo "Launching Llama.cpp server with model: $MODEL_PATH on port $SERVER_PORT..."
exec /usr/local/bin/llama-server \
-m "$MODEL_PATH" \
-c "$CONTEXT_SIZE" \
--port "$SERVER_PORT" \
--host 0.0.0.0 \
--websocket