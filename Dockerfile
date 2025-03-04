# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required build tools and dependencies (plus extra dependencies for the maintained fork)
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libpoppler-dev \
    libpoppler-cpp-dev \
    libpoppler-glib-dev \
    libpoppler-private-dev \
    poppler-utils \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libboost-all-dev \
    fontforge \
    libfontforge-dev \
    libpango1.0-dev \
    poppler-data \
    git \
    openjdk-11-jdk \
    npm \
    nodejs \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Clone the maintained pdf2htmlEX repository
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Build pdf2htmlEX using system Poppler libraries with SVG enabled.
# We change into the subdirectory that holds the CMakeLists.txt and add extra include flags
RUN cd pdf2htmlEX/pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_CXX_STANDARD=17 \
      -DENABLE_SVG=ON \
      -DPOPPLER_INCLUDE_DIR=/usr/include/poppler \
      -DCMAKE_CXX_FLAGS="-I/usr/include/poppler" && \
    make -j$(nproc) && \
    make install

# Clean up the source directory
RUN rm -rf pdf2htmlEX

# Default command: show pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
