ARG UBUNTU_VERSION=22.04
ARG ROCM_VERSION=5.7
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION} AS build

ENV DEBIAN_FRONTEND=noninteractive

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

WORKDIR /app

RUN git clone --depth=1 https://github.com/ggerganov/llama.cpp.git

WORKDIR /app/llama.cpp
RUN mkdir build && cd build && \
cmake .. -DGGML_HIP=ON \
         -DAMDGPU_TARGETS=gfx1100 \
         -DLLAMA_BUILD_SERVER=ON \
         -G Ninja \
         -DCMAKE_PREFIX_PATH=/opt/rocm \
&& ninja && cp bin/llama-server /usr/local/bin/llama-server

FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION} AS server

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y libnuma1 curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/llama-server /usr/local/bin/

WORKDIR /app

EXPOSE 8080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK CMD ["curl", "-f", "http://localhost:8080/health"]

ENTRYPOINT ["/entrypoint.sh"]