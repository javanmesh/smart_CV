# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required build tools and dependencies, including an older Poppler version
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    poppler-utils \
    libpoppler-dev=0.86.1-0ubuntu1 \
    libpoppler-cpp-dev=0.86.1-0ubuntu1 \
    libpoppler-glib-dev=0.86.1-0ubuntu1 \
    libpoppler-private-dev \
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
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Clone the pdf2htmlEX repository (coolwanglu fork)
RUN git clone --depth 1 --recursive https://github.com/coolwanglu/pdf2htmlEX.git

# Build pdf2htmlEX using the older Poppler version
RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 -DPDF2HTMLEX_USE_SYSTEM_POPPLER=ON && \
    make -j$(nproc) && \
    make install

# Clean up
RUN rm -rf pdf2htmlEX

# Default command: show pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
