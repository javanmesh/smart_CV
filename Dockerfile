# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies, including CURL dev package.
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
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build and install Poppler 23.12.0 from source,
# disabling NSS3, GPGME, QT5, QT6, and LCMS support.
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

# Create symlinks in /usr/local/include so headers are accessible
RUN ln -s /usr/local/include/poppler/poppler-config.h /usr/local/include/poppler-config.h && \
    ln -s /usr/local/include/poppler/OutputDev.h /usr/local/include/OutputDev.h && \
    ln -s /usr/local/include/poppler/GlobalParams.h /usr/local/include/GlobalParams.h && \
    ln -s /usr/local/include/poppler/CairoOutputDev.h /usr/local/include/CairoOutputDev.h && \
    ln -s /usr/local/include/poppler/Link.h /usr/local/include/Link.h

# Ensure the newly built libraries are found at runtime.
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Clone the maintained pdf2htmlEX repository.
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Build pdf2htmlEX using the new Poppler installation.
WORKDIR /tmp/pdf2htmlEX/pdf2htmlEX
RUN mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_CXX_STANDARD=17 \
      -DENABLE_SVG=ON \
      -DPOPPLER_INCLUDE_DIR=/usr/local/include/poppler \
      -DPOPPLER_LIBRARIES=/usr/local/lib \
      -DCMAKE_CXX_FLAGS="-I/usr/local/include" && \
    make -j$(nproc) && \
    make install

# Clean up the source directory.
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Default command: show pdf2htmlEX help.
CMD ["pdf2htmlEX", "--help"]
