#!/bin/bash

# Model download helper script

set -e

# Default values
MODEL_DIR="${MODEL_DIR:-./models}"
CHUNK_SIZE="1M"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    echo -e "${2}${1}${NC}"
}

# Function to download with progress
download_with_progress() {
    local url="$1"
    local output="$2"
    
    print_color "Downloading: $url" "$YELLOW"
    print_color "Destination: $output" "$YELLOW"
    
    # Use curl with progress bar
    curl -L --progress-bar \
         --retry 3 \
         --retry-delay 5 \
         -o "$output" \
         "$url"
}

# Popular models
declare -A MODELS=(
    # Coding-focused models
    ["deepseek-coder-33b"]="https://huggingface.co/TheBloke/deepseek-coder-33B-instruct-GGUF/resolve/main/deepseek-coder-33b-instruct.Q4_K_M.gguf"
    ["deepseek-coder-v2-16b"]="https://huggingface.co/bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF/resolve/main/DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf"
    ["qwen2.5-coder-32b"]="https://huggingface.co/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-32B-Instruct-Q4_K_M.gguf"
    ["codellama-34b"]="https://huggingface.co/TheBloke/CodeLlama-34B-Instruct-GGUF/resolve/main/codellama-34b-instruct.Q4_K_M.gguf"
    
    # General purpose models
    ["deepseek-r1-distill-32b"]="https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-32B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-32B-Q4_K_M.gguf"
    ["llama3-8b"]="https://huggingface.co/TheBloke/Llama-3-8B-Instruct-GGUF/resolve/main/llama-3-8b-instruct.Q4_K_M.gguf"
    ["mistral-7b"]="https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
    ["phi3-mini"]="https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
)

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --model NAME     Download a predefined model (see list below)"
    echo "  -u, --url URL        Download from a custom URL"
    echo "  -o, --output FILE    Output filename (default: basename of URL)"
    echo "  -d, --dir DIR        Model directory (default: $MODEL_DIR)"
    echo "  -l, --list           List available predefined models"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Predefined models:"
    for model in "${!MODELS[@]}"; do
        echo "  - $model"
    done
    echo ""
    echo "Examples:"
    echo "  $0 --model deepseek-33b"
    echo "  $0 --url https://example.com/model.gguf --output my-model.gguf"
}

# Parse arguments
MODEL_NAME=""
URL=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL_NAME="$2"
            shift 2
            ;;
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -d|--dir)
            MODEL_DIR="$2"
            shift 2
            ;;
        -l|--list)
            print_color "Available models:" "$GREEN"
            for model in "${!MODELS[@]}"; do
                echo "  - $model: ${MODELS[$model]}"
            done
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_color "Unknown option: $1" "$RED"
            usage
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ -z "$MODEL_NAME" && -z "$URL" ]]; then
    print_color "Error: Either --model or --url must be specified" "$RED"
    usage
    exit 1
fi

# Set URL from model name if provided
if [[ -n "$MODEL_NAME" ]]; then
    if [[ -v MODELS[$MODEL_NAME] ]]; then
        URL="${MODELS[$MODEL_NAME]}"
    else
        print_color "Error: Unknown model '$MODEL_NAME'" "$RED"
        print_color "Available models:" "$YELLOW"
        for model in "${!MODELS[@]}"; do
            echo "  - $model"
        done
        exit 1
    fi
fi

# Set output filename if not provided
if [[ -z "$OUTPUT" ]]; then
    OUTPUT=$(basename "$URL")
fi

# Create model directory if it doesn't exist
mkdir -p "$MODEL_DIR"

# Full output path
FULL_OUTPUT="$MODEL_DIR/$OUTPUT"

# Check if file already exists
if [[ -f "$FULL_OUTPUT" ]]; then
    print_color "Model already exists: $FULL_OUTPUT" "$YELLOW"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color "Download cancelled" "$YELLOW"
        exit 0
    fi
fi

# Download the model
print_color "Starting download..." "$GREEN"
download_with_progress "$URL" "$FULL_OUTPUT"

# Verify download
if [[ -f "$FULL_OUTPUT" ]]; then
    SIZE=$(du -h "$FULL_OUTPUT" | cut -f1)
    print_color "✓ Download complete! Size: $SIZE" "$GREEN"
    print_color "Model saved to: $FULL_OUTPUT" "$GREEN"
    
    # Update .env file if it exists
    if [[ -f ".env" ]]; then
        print_color "Updating .env file..." "$YELLOW"
        sed -i "s|MODEL_FILENAME=.*|MODEL_FILENAME=$OUTPUT|" .env
        print_color "✓ Updated MODEL_FILENAME in .env" "$GREEN"
    fi
else
    print_color "✗ Download failed!" "$RED"
    exit 1
fi