FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages.
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

# Clone, build, and install Poppler 23.12.0 with xpdf headers enabled.
WORKDIR /tmp
RUN git clone --depth 1 --branch poppler-23.12.0 https://gitlab.freedesktop.org/poppler/poppler.git && \
    mkdir -p poppler/build && cd poppler/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DENABLE_NSS3=OFF \
             -DENABLE_GPGME=OFF \
             -DENABLE_QT5=OFF \
             -DENABLE_QT6=OFF \
             -DENABLE_LCMS=OFF \
             -DENABLE_XPDF_HEADERS=ON && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/poppler

# Set CPATH so the compiler automatically looks in /usr/local/include/poppler.
ENV CPATH=/usr/local/include/poppler

# Ensure runtime linker finds libraries.
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Clone pdf2htmlEX repository.
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Build pdf2htmlEX.
WORKDIR /tmp/pdf2htmlEX/pdf2htmlEX
RUN mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_CXX_STANDARD=17 \
      -DENABLE_SVG=ON \
      -DPOPPLER_INCLUDE_DIR=/usr/local/include/poppler \
      -DPOPPLER_LIBRARIES=poppler \
      -DCMAKE_C_FLAGS="-I/usr/local/include/poppler" \
      -DCMAKE_CXX_FLAGS="-I/usr/local/include/poppler" && \
    make -j$(nproc) && \
    make install

# Clean up.
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

CMD ["pdf2htmlEX", "--help"]
