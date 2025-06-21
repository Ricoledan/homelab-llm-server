# Architecture

## Overview

HomeLab LLM Server is designed as a containerized solution for running large language models locally with GPU acceleration.

## Components

### 1. Docker Container
- Base image: ROCm/CUDA enabled Ubuntu
- llama.cpp server compiled with GPU support
- Multi-stage build for optimized image size

### 2. CLI Interface (`bin/llm`)
- Bash-based CLI for easy interaction
- Manages Docker lifecycle
- Provides chat interface and model management

### 3. Model Management
- GGUF format models stored in `models/`
- Dynamic model switching without rebuilding
- Built-in downloader for popular models

### 4. API Server
- OpenAI-compatible API endpoints
- HTTP server on configurable port (default: 8080)
- Supports streaming and batch inference

## Directory Structure

```
homelab-llm-server/
├── bin/              # Executable scripts
│   └── llm          # Main CLI interface
├── config/          # Configuration files
│   ├── default.env  # Default environment settings
│   └── README.md    # Config documentation
├── docs/            # Documentation
│   ├── ARCHITECTURE.md
│   └── examples/    # Usage examples
├── models/          # Model storage (gitignored)
├── scripts/         # Utility scripts
│   ├── download-model.sh
│   ├── entrypoint.sh
│   ├── monitor.sh
│   └── quick-start.sh
├── tests/           # Test suites
├── completions/     # Shell completions
├── docker-compose.yml
├── Dockerfile
├── Makefile         # Common tasks
└── README.md        # Main documentation
```

## Data Flow

1. User interacts with CLI (`bin/llm`)
2. CLI manages Docker container lifecycle
3. Container runs llama.cpp server with specified model
4. Server exposes HTTP API on configured port
5. CLI or external tools communicate via API

## GPU Acceleration

- AMD GPUs: ROCm support with HIP backend
- NVIDIA GPUs: CUDA support (future)
- CPU fallback for unsupported hardware