# HomeLab LLM Server

Self-hosted AI server with user-friendly CLI for running large language models locally. Optimized for AMD GPUs with ROCm acceleration.

## Quick Start

```bash
# 1. Clone and install
git clone https://github.com/yourusername/homelab-llm-server.git
cd homelab-llm-server
make install

# 2. Download a model
llm model download

# 3. Start the server
llm start

# 4. Chat with the AI
llm chat
```

## Features

- **Easy CLI** - Simple commands for all operations
- **GPU Acceleration** - ROCm support for AMD GPUs
- **Model Management** - Download and switch models easily
- **API Compatible** - Works with Aider, Continue.dev, and OpenAI-compatible tools
- **Interactive Chat** - Built-in chat interface
- **Docker-based** - Clean, isolated environment

## Commands

### Basic Usage

```bash
llm start              # Start the server
llm stop               # Stop the server
llm status             # Check server status
llm chat               # Interactive chat mode
llm query "Hello AI"   # One-off query
```

### Model Management

```bash
llm model list         # Show downloaded & available models
llm model download     # Download a new model
llm model switch       # Switch models (interactive)
llm model current      # Show current model
```

### Advanced

```bash
llm logs -f            # View server logs
llm monitor            # Real-time GPU/CPU monitoring
llm config edit        # Edit configuration
llm restart            # Restart with new settings
```

## Installation

### Prerequisites

- Docker & Docker Compose
- AMD GPU with ROCm drivers (optional, CPU fallback available)
- 16GB+ RAM recommended
- 50GB+ disk space for models

### Install Steps

```bash
# Install CLI
./install.sh

# Or use make
make install
```

## Configuration

Configuration is stored in `.env`. Copy from template:

```bash
cp .env.example .env
```

### Key Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `SERVER_PORT` | API port | `8080` |
| `MODEL_FILENAME` | Active model | `Qwen2.5-Coder-32B-Instruct-Q4_K_M.gguf` |
| `CONTEXT_SIZE` | Context window | `4096` |
| `N_GPU_LAYERS` | GPU layers | `50` |

## Using with Tools

### Aider (AI Pair Programming)

```bash
aider --model http://localhost:8080/v1/chat/completions
```

### Python

```python
import requests

response = requests.post('http://localhost:8080/completion', 
    json={'prompt': 'Hello', 'n_predict': 100})
print(response.json()['content'])
```

### cURL

```bash
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello", "n_predict": 100}'
```

## Models

### Recommended Models

For coding:
- `qwen2.5-coder-32b` - Best for complex coding tasks
- `deepseek-coder-v2-16b` - Faster, good for quick edits

For general use:
- `deepseek-r1-distill-32b` - Excellent reasoning
- `llama3-8b` - Smaller, faster, still capable

### Model Requirements

| Model Size | VRAM Required | System RAM |
|------------|---------------|------------|
| 7B | 6-8GB | 8GB |
| 13B | 10-12GB | 16GB |
| 32B | 20-24GB | 32GB |

## Development

```bash
# Run tests
make test

# View all commands
make help

# Enter container shell
make shell

# Clean up
make clean
```

## Troubleshooting

**Server won't start?**
```bash
llm logs           # Check error messages
docker ps -a       # Check container status
```

**Out of memory?**
- Reduce `N_GPU_LAYERS` in `.env`
- Switch to smaller model
- Reduce `CONTEXT_SIZE`

**Slow responses?**
- Check GPU usage: `llm monitor`
- Use smaller model for faster inference
- Ensure GPU drivers are properly installed

## Project Structure

```
homelab-llm-server/
├── bin/llm              # Main CLI tool
├── scripts/             # Helper scripts
├── models/              # Model files (gitignored)
├── docker-compose.yml   # Docker configuration
├── Dockerfile           # Container image
├── Makefile            # Common tasks
├── .env.example        # Configuration template
└── README.md           # This file
```

## License

MIT License - See LICENSE file for details