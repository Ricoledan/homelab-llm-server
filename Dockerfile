FROM rocm/dev-ubuntu-22.04:5.7

ENV DEBIAN_FRONTEND=noninteractive

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

WORKDIR /app

RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    mkdir build && cd build && \
    cmake .. -DLLAMA_ROCM=ON -DLLAMA_BUILD_SERVER=ON -G Ninja && \
    ninja && \
    cp server /usr/local/bin/

RUN rocminfo && /opt/rocm/bin/rocm-smi || echo "ROCm GPU not detected!"

EXPOSE 8080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
CMD ["/entrypoint.sh"]
