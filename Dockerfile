FROM rocm/dev-ubuntu-22.04:5.7

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt update && apt install -y \
    build-essential \
    curl \
    git \
    cmake \
    python3 \
    python3-pip \
    libnuma-dev \
    rocminfo \
    rocm-hip-runtime \
    rocm-llvm \
    rocm-smi \
    rocm-utils \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

    # Set the working directory
WORKDIR /app

# Clone the llama.cpp repository and build with ROCm support
RUN git clone https://github.com/ggml-org/llama.cpp.git && \
    cd llama.cpp && \
    mkdir build && cd build && \
    # Configure the build with ROCm support and the specified GPU architecture
    cmake .. -DGGML_HIP=ON -DAMDGPU_TARGETS=gfx1100 -DLLAMA_BUILD_SERVER=ON -G Ninja && \
    # Compile the project
    ninja && \
    # Install the server binary
    cp server /usr/local/bin/

# Verify ROCm installation
RUN rocminfo && /opt/rocm/bin/rocm-smi || echo "ROCm GPU not detected!"

# Expose the server port
EXPOSE 8080

# Copy the entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
CMD ["/entrypoint.sh"]