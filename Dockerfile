FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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

WORKDIR /app

RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    make -j$(nproc) server LLAMA_ROCM=1

RUN rocminfo && /opt/rocm/bin/rocm-smi || echo "ROCm GPU not detected!"

EXPOSE 8080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]