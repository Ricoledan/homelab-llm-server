ARG UBUNTU_VERSION=22.04
ARG ROCM_VERSION=6.0

# Build stage
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION}-complete AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    libcurl4-openssl-dev \
    ninja-build \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone and build llama.cpp
RUN git clone --depth=1 https://github.com/ggerganov/llama.cpp.git

WORKDIR /build/llama.cpp

RUN mkdir -p build && cd build && \
    cmake .. -DGGML_HIP=ON \
             -DAMDGPU_TARGETS=gfx1100 \
             -DLLAMA_BUILD_SERVER=ON \
             -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_INSTALL_PREFIX=/usr/local \
             -G Ninja \
             -DCMAKE_PREFIX_PATH=/opt/rocm \
    && ninja && ninja install

# Runtime stage
FROM rocm/dev-ubuntu-${UBUNTU_VERSION}:${ROCM_VERSION}-complete

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Install only runtime dependencies
RUN apt update && apt install -y \
    curl \
    libnuma1 \
    rocminfo \
    rocm-smi \
    && rm -rf /var/lib/apt/lists/*

# Copy built binaries and libraries from builder
COPY --from=builder /usr/local /usr/local

# Setup library path
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/llama.conf && ldconfig

WORKDIR /app

EXPOSE 8080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]