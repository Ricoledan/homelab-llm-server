# homelab-llm-server

🔬 HomeLab LLM Server is a self-hosted AI server leveraging llama.cpp and the DeepSeek 3 33B Q4_K model for local
inference. This setup is optimized for AMD GPUs with ROCm acceleration and can be deployed via Docker Compose.

Features:

- Run your own private AI assistant at home
- Integrate with home automation & chatbots
- Experiment with self-hosted AI models
- Deploy on edge devices or homelab servers

## Project Structure

```text
homelab-llm-server/
│── docker-compose.yml     # Docker Compose configuration
│── Dockerfile             # Container setup with ROCm support
│── .env                   # Environment variables (configurable)
│── .gitignore             # Prevents committing sensitive files
│── README.md              # Project documentation
│── models/                # Model storage (mount in container)
└── scripts/
    ├── entrypoint.sh      # Server startup script
```

## Prerequisites

### Install ROCm on Host Machine

Before running the container, ensure your system supports ROCm:

```bash
rocminfo
```

If ROCm is not installed, follow the official AMD guide:

```bash
wget https://repo.radeon.com/amdgpu-install/6.0/ubuntu/jammy/amdgpu-install_6.0.60000-1_all.deb
sudo dpkg -i amdgpu-install_6.0.60000-1_all.deb
sudo amdgpu-install --usecase=rocm,graphics
```

### Install Docker & Docker Compose

```
sudo apt update && sudo apt install -y docker.io docker-compose
```

### Configure Environment Variables

```
CONTAINER_NAME=homelab-llm-server
SERVER_PORT=8080
MODEL_DIR=./models
MODEL_PATH=/models/deepseek-3-33b-q4_k.gguf
CONTEXT_SIZE=4096
ROC_ENABLE=1
```

### Place the Model in models/ Directory

Download model and place it in models/:

```bash
mkdir -p models
mv /path/to/DeepSeek-R1-Distill-Qwen-32B-IQ4_XS.gguf models/
```

### Build & Run the Container

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Verify GPU Utilization

Check if the ROCm GPU is being used:

```bash
docker exec -it homelab-llm-server rocminfo
```

## API Usage

Once running, you can send inference requests via HTTP:

```bash
curl -X POST http://localhost:8080/completion \
     -H "Content-Type: application/json" \
     -d '{"prompt": "Explain blockchain technology.", "n_predict": 100}'
```

## Commands

```bash
docker-compose build --no-cache
```

```bash
docker-compose up -d
```

```bash
docker logs homelab-llm-server
```