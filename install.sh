#!/usr/bin/env bash

# HomeLab LLM Server Installer

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    echo -e "${2}${1}${NC}"
}

print_color "HomeLab LLM Server Installer" "$BLUE"
print_color "=============================" "$BLUE"
echo ""

# Check prerequisites
print_color "Checking prerequisites..." "$YELLOW"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_color "✗ Docker not found" "$RED"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
else
    print_color "✓ Docker found" "$GREEN"
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_color "✗ Docker Compose not found" "$RED"
    echo "Please install Docker Compose first"
    exit 1
else
    print_color "✓ Docker Compose found" "$GREEN"
fi

# Check ROCm (optional)
if command -v rocminfo &> /dev/null; then
    print_color "✓ ROCm found (AMD GPU support enabled)" "$GREEN"
else
    print_color "⚠ ROCm not found (CPU mode only)" "$YELLOW"
fi

echo ""

# Get installation directory
INSTALL_DIR="$HOME/.local/bin"
print_color "Installing to: $INSTALL_DIR" "$BLUE"

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Create wrapper script
cat > "$INSTALL_DIR/llm" << 'EOF'
#!/usr/bin/env bash
# HomeLab LLM Server CLI wrapper

# Find the actual installation directory
if [[ -n "$LLM_HOME" ]]; then
    LLM_DIR="$LLM_HOME"
elif [[ -f "$HOME/dev/homelab-llm-server/bin/llm" ]]; then
    LLM_DIR="$HOME/dev/homelab-llm-server"
else
    echo "Error: Cannot find LLM installation directory"
    echo "Please set LLM_HOME environment variable"
    exit 1
fi

cd "$LLM_DIR" && ./bin/llm "$@"
EOF

chmod +x "$INSTALL_DIR/llm"

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_color "\nAdd this to your shell configuration (.bashrc, .zshrc, etc.):" "$YELLOW"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\""
    echo "export LLM_HOME=\"$(pwd)\""
    echo ""
    
    # Detect shell
    SHELL_RC=""
    if [[ -n "$ZSH_VERSION" ]]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
    fi
    
    # Offer to add automatically
    if [[ -n "$SHELL_RC" ]]; then
        read -p "Add to .$SHELL_NAME rc automatically? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$SHELL_RC"
            echo "# HomeLab LLM Server" >> "$SHELL_RC"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
            echo "export LLM_HOME=\"$(pwd)\"" >> "$SHELL_RC"
            print_color "✓ Added to $SHELL_RC" "$GREEN"
            print_color "Run: source $SHELL_RC" "$YELLOW"
        fi
    fi
fi

echo ""

# Install completions
if [[ -n "$ZSH_VERSION" ]] && [[ -d "$HOME/.oh-my-zsh/custom/plugins" ]]; then
    print_color "Installing zsh completions..." "$YELLOW"
    mkdir -p "$HOME/.oh-my-zsh/custom/plugins/llm"
    cp "$(pwd)/completions/llm.zsh" "$HOME/.oh-my-zsh/custom/plugins/llm/_llm"
    print_color "✓ Zsh completions installed" "$GREEN"
    print_color "Add 'llm' to your plugins in .zshrc for completions" "$YELLOW"
elif [[ -n "$BASH_VERSION" ]]; then
    if [[ -d "/etc/bash_completion.d" ]] && [[ -w "/etc/bash_completion.d" ]]; then
        print_color "Installing bash completions..." "$YELLOW"
        sudo cp "$(pwd)/completions/llm.bash" "/etc/bash_completion.d/llm"
        print_color "✓ Bash completions installed" "$GREEN"
    fi
fi

echo ""
print_color "Installation complete!" "$GREEN"
echo ""
print_color "Quick start:" "$BLUE"
echo "  llm help         # Show available commands"
echo "  llm start        # Start the server"
echo "  llm chat         # Start interactive chat"
echo "  llm status       # Check server status"
echo ""

# Offer to download a model
if [[ ! -d "models" ]] || [[ -z "$(ls -A models/*.gguf 2>/dev/null)" ]]; then
    print_color "No models found. Would you like to download one now?" "$YELLOW"
    read -p "Download a model? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/download-model.sh --list
        echo ""
        read -p "Enter model name (e.g., qwen2.5-coder-32b): " model_name
        ./scripts/download-model.sh --model "$model_name"
    fi
fi