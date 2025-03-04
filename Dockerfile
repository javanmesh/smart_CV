# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libopenjp2-7-dev \
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libboost-all-dev \
    fontforge \
    libfontforge-dev \
    libpango1.0-dev \
    git \
    openjdk-11-jdk \
    npm \
    nodejs \
    python3-pip \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Build and install Poppler 23.12.0 from source,
# disabling NSS3, GPGME, Qt5, Qt6, and LCMS support.
WORKDIR /tmp
RUN git clone --depth 1 --branch poppler-23.12.0 https://gitlab.freedesktop.org/poppler/poppler.git && \
    mkdir -p poppler/build && cd poppler/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DENABLE_NSS3=OFF \
             -DENABLE_GPGME=OFF \
             -DENABLE_QT5=OFF \
             -DENABLE_QT6=OFF \
             -DENABLE_LCMS=OFF && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/poppler

# Ensure the newly built libraries are found at runtime
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Clone the maintained pdf2htmlEX repository
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Build pdf2htmlEX using the new Poppler installation
WORKDIR /tmp/pdf2htmlEX/pdf2htmlEX
RUN mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_CXX_STANDARD=17 \
      -DENABLE_SVG=ON \
      -DPOPPLER_INCLUDE_DIR=/usr/local/include/poppler && \
    make -j$(nproc) && \
    make install

# Clean up the source directory
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Default command: show pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
