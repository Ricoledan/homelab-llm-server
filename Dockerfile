ARG UBUNTU_VERSION=22.04
ARG ROCM_VERSION=5.7
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

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

RUN mkdir -p build && cd build && \
    cmake .. -DGGML_HIP=ON \
             -DAMDGPU_TARGETS=gfx1100 \
             -DLLAMA_BUILD_SERVER=ON \
             -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_INSTALL_PREFIX=/usr/local \
             -G Ninja \
             -DCMAKE_PREFIX_PATH=/opt/rocm \
    && ninja && ninja install

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/llama.conf && ldconfig

WORKDIR /app

EXPOSE 8080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK CMD ["curl", "-f", "http://localhost:8080/health"]

ENTRYPOINT ["/entrypoint.sh"]