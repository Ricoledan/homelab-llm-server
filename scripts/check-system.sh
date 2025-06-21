#!/bin/bash

# System requirements checker for LLM models

echo "=== System Information for LLM Model Selection ==="
echo "Date: $(date)"
echo ""

# CPU Information
echo "CPU Information:"
echo "----------------"
lscpu | grep -E "Model name:|CPU\(s\):|Thread\(s\) per core:|Core\(s\) per socket:" | sed 's/^/  /'
echo ""

# Memory Information
echo "System Memory:"
echo "----------------"
free -h | grep -E "Mem:|Swap:" | sed 's/^/  /'
echo ""

# GPU Information (AMD ROCm)
echo "GPU Information (AMD):"
echo "----------------"
if command -v rocminfo &> /dev/null; then
    # Get GPU name
    GPU_NAME=$(rocminfo | grep -A 20 "Agent 2" | grep "Name:" | sed 's/.*Name:[[:space:]]*//' | head -n 1)
    echo "  GPU Model: $GPU_NAME"
    
    # Get VRAM
    if command -v rocm-smi &> /dev/null; then
        echo "  VRAM Details:"
        rocm-smi --showmeminfo vram | grep -E "Total|Used|Free" | sed 's/^/    /'
    fi
    
    # Get compute capability
    echo "  Compute Info:"
    rocminfo | grep -E "Compute Unit:|Max Clock Freq" | head -n 2 | sed 's/^/    /'
else
    echo "  ROCm not detected. Checking for NVIDIA..."
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader | sed 's/^/  /'
    else
        echo "  No GPU detected or GPU tools not installed"
    fi
fi
echo ""

# Disk Space
echo "Disk Space (for models directory):"
echo "----------------"
MODEL_DIR="${MODEL_DIR:-./models}"
df -h "$MODEL_DIR" 2>/dev/null || df -h . | grep -v "Filesystem" | sed 's/^/  /'
echo ""

# Model Recommendations based on VRAM
echo "Model Recommendations Based on Your System:"
echo "----------------"

# Try to get VRAM in GB
VRAM_GB=0
VRAM_USED_GB=0
VRAM_FREE_GB=0

if command -v rocm-smi &> /dev/null; then
    # Try to get VRAM from the detailed output - extract the number after the colon
    VRAM_LINE=$(rocm-smi --showmeminfo vram | grep "VRAM Total Memory" | head -n 1)
    VRAM_USED_LINE=$(rocm-smi --showmeminfo vram | grep "VRAM Total Used Memory" | head -n 1)
    
    # Extract bytes value (the number after the colon and before any other text)
    VRAM_BYTES=$(echo "$VRAM_LINE" | sed 's/.*: \([0-9]\+\).*/\1/')
    VRAM_USED_BYTES=$(echo "$VRAM_USED_LINE" | sed 's/.*: \([0-9]\+\).*/\1/')
    
    if [[ -n "$VRAM_BYTES" ]] && [[ "$VRAM_BYTES" =~ ^[0-9]+$ ]]; then
        VRAM_GB=$((VRAM_BYTES / 1024 / 1024 / 1024))
        VRAM_USED_GB=$((VRAM_USED_BYTES / 1024 / 1024 / 1024))
        VRAM_FREE_GB=$((VRAM_GB - VRAM_USED_GB))
    fi
elif command -v nvidia-smi &> /dev/null; then
    VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)
    if [[ -n "$VRAM_MB" ]] && [[ "$VRAM_MB" =~ ^[0-9]+$ ]]; then
        VRAM_GB=$((VRAM_MB / 1024))
    fi
fi

echo "  Detected VRAM: ${VRAM_GB}GB (${VRAM_USED_GB}GB used, ${VRAM_FREE_GB}GB free)"
echo ""

# Warn if VRAM is mostly used
if [[ $VRAM_FREE_GB -lt 4 ]] && [[ $VRAM_GB -gt 0 ]]; then
    echo "  ⚠️  WARNING: Only ${VRAM_FREE_GB}GB VRAM free!"
    echo "     Current model or other processes are using ${VRAM_USED_GB}GB"
    echo "     You may need to stop the current model before loading a new one"
    echo ""
fi

# Recommendations based on VRAM
if [[ $VRAM_GB -ge 48 ]]; then
    echo "  ✓ Premium Setup (48GB+ VRAM):"
    echo "    - Qwen 2.5 Coder 32B (Q5_K_M or Q6_K) - Best quality"
    echo "    - DeepSeek Coder V2 33B (Q5_K_M) - Excellent for complex tasks"
    echo "    - Multiple 32B models simultaneously"
elif [[ $VRAM_GB -ge 24 ]]; then
    echo "  ✓ Excellent Setup (24GB+ VRAM):"
    echo "    - Qwen 2.5 Coder 32B (Q4_K_M) - ~18-20GB VRAM"
    echo "    - DeepSeek R1 Distill 32B (Q4_K_M) - ~18-20GB VRAM"
    echo "    - CodeLlama 34B (Q4_K_M) - ~20-22GB VRAM"
elif [[ $VRAM_GB -ge 16 ]]; then
    echo "  ✓ Good Setup (16GB+ VRAM):"
    echo "    - DeepSeek Coder V2 16B (Q4_K_M) - ~10-12GB VRAM"
    echo "    - Qwen 2.5 Coder 14B (Q4_K_M) - ~9-11GB VRAM"
    echo "    - CodeLlama 13B (Q5_K_M) - ~10-12GB VRAM"
elif [[ $VRAM_GB -ge 12 ]]; then
    echo "  ✓ Decent Setup (12GB+ VRAM):"
    echo "    - DeepSeek Coder 7B (Q5_K_M) - ~6-8GB VRAM"
    echo "    - CodeLlama 13B (Q4_K_M) - ~8-10GB VRAM"
    echo "    - Mistral 7B (Q6_K) - ~6-8GB VRAM"
elif [[ $VRAM_GB -ge 8 ]]; then
    echo "  ⚠ Limited Setup (8GB+ VRAM):"
    echo "    - DeepSeek Coder 7B (Q4_K_M) - ~5-6GB VRAM"
    echo "    - Phi-3 Mini (Q4_K_M) - ~3-4GB VRAM"
    echo "    - CodeLlama 7B (Q4_K_M) - ~5-6GB VRAM"
else
    echo "  ⚠ Minimal Setup (<8GB VRAM):"
    echo "    - Consider CPU inference or smaller models"
    echo "    - Phi-3 Mini (Q4_K_M) - ~3-4GB VRAM"
    echo "    - Use lower n_gpu_layers setting"
fi

echo ""
echo "Note: Actual VRAM usage depends on context size and n_gpu_layers setting."
echo "For coding with Aider, leave 2-4GB headroom for optimal performance."