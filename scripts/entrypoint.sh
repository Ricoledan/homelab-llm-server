#!/bin/bash

echo "Starting llama.cpp server..."

if [ -z "$MODEL_PATH" ]; then
    echo "Error: MODEL_PATH is not set. Please check your environment variables."
    exit 1
fi

if [ -z "$SERVER_PORT" ]; then
    echo "Warning: SERVER_PORT is not set. Defaulting to 8080."
    SERVER_PORT=8080
fi

if [ -z "$CONTEXT_SIZE" ]; then
    echo "Warning: CONTEXT_SIZE is not set. Defaulting to 4096."
    CONTEXT_SIZE=4096
fi

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found! Expected at $MODEL_PATH"
    exit 1
fi

if [[ "$ROC_ENABLE" == "1" ]]; then
    echo "ROCm enabled. Checking GPU..."
    if ! command -v rocminfo &>/dev/null || ! /opt/rocm/bin/rocm-smi &>/dev/null; then
        echo "Warning: ROCm GPU not detected!"
    fi
fi

echo "Launching Llama server with model: $MODEL_PATH on port $SERVER_PORT..."
exec /usr/local/bin/server \
-m "$MODEL_PATH" \
-c "$CONTEXT_SIZE" \
--port "$SERVER_PORT" \
--websocket
