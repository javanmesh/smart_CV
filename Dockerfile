FROM ubuntu:20.04

# Set noninteractive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libpoppler-dev \
    libpoppler-cpp-dev \
    poppler-utils \
    libcairo2-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgif-dev \
    git \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

# Clone pdf2htmlEX repository
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git /pdf2htmlEX

# Build pdf2htmlEX
WORKDIR /pdf2htmlEX
RUN mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install

# Set up entrypoint
ENTRYPOINT ["pdf2htmlEX"]
