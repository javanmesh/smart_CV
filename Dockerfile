# Use Ubuntu 20.04
FROM ubuntu:20.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including autotools
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
    && rm -rf /var/lib/apt/lists/*

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Clone the coolwanglu/pdf2htmlEX fork (more up-to-date)
RUN git clone --depth 1 --recursive https://github.com/coolwanglu/pdf2htmlEX.git

# Remove the bundled Poppler to force use of system Poppler
RUN rm -rf pdf2htmlEX/3rdparty/poppler

# Build pdf2htmlEX with system Poppler
RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. \
        -DCMAKE_CXX_STANDARD=11 \
        -DPDF2HTMLEX_USE_SYSTEM_POPPLER=ON \
        && \
    make -j$(nproc) && \
    make install

# Cleanup
RUN rm -rf pdf2htmlEX

CMD ["pdf2htmlEX", "--help"]
