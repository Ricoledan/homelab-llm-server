# Use Ubuntu as the base image
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    curl \
    git \
    cmake \
    python3 \
    python3-pip \
    libnuma-dev \
    rocm-libs rocm-dev \
    rocminfo \
    amdgpu-dkms

# Set working directory
WORKDIR /app

# Clone llama.cpp and build it with ROCm support
RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    make -j$(nproc) server LLAMA_ROCM=1

# Verify ROCm installation inside the container
RUN rocminfo && /opt/rocm/bin/rocm-smi || echo "ROCm GPU not detected!"

# Expose the server port
EXPOSE 8080

# Entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Command to run the server
CMD ["/entrypoint.sh"]