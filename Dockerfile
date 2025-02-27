# Base image with ROCm support for Ubuntu 22.04 and ROCm 5.7
ARG UBUNTU_VERSION=22.04
ARG ROCM_VERSION=5.7
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION} AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies, including hipBLAS
RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    python3 \
    python3-pip \
    ninja-build \
    libnuma-dev \
    rocminfo \
    rocm-hip-runtime \
    rocm-llvm \
    rocm-smi \
    rocm-utils \
    hipblas \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the llama.cpp repository
RUN git clone --depth=1 https://github.com/ggerganov/llama.cpp.git

# Build the llama.cpp server
WORKDIR /app/llama.cpp
RUN mkdir build && cd build && \
cmake .. -DGGML_HIP=ON \
         -DAMDGPU_TARGETS=gfx1100 \
         -DLLAMA_BUILD_SERVER=ON \
         -G Ninja \
         -DCMAKE_PREFIX_PATH=/opt/rocm \
&& ninja && cp bin/llama-server /usr/local/bin/llama-server

# Create a runtime image with only the necessary dependencies
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION} AS server

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal runtime dependencies
RUN apt update && apt install -y libnuma1 curl && \
    rm -rf /var/lib/apt/lists/*

# Copy the built server from the build stage
COPY --from=build /usr/local/bin/llama-server /usr/local/bin/

# Set working directory
WORKDIR /app

# Expose the server port
EXPOSE 8080

# Copy the entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Healthcheck to verify the server is running
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8080/health"]

# Set the entrypoint to start the server
ENTRYPOINT ["/entrypoint.sh"]