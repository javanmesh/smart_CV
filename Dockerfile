# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required build tools and dependencies, including the private Poppler headers
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
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Clone the pdf2htmlEX repository (the coolwanglu fork)
RUN git clone --depth 1 --recursive https://github.com/coolwanglu/pdf2htmlEX.git

# Correct the pkg-config module name from 'libfontforge' to 'fontforge' in CMakeLists.txt
RUN sed -i 's/libfontforge/fontforge/g' pdf2htmlEX/CMakeLists.txt

# Set PKG_CONFIG_PATH to include the directory with fontforge.pc
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Build pdf2htmlEX using system Poppler and FontForge libraries
RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 -DPDF2HTMLEX_USE_SYSTEM_POPPLER=ON && \
    make -j$(nproc) && \
    make install

# Clean up the source directory
RUN rm -rf pdf2htmlEX

#copy fontforge .pc file
RUN cp /usr/local/lib/pkgconfig/fontforge.pc /usr/lib/x86_64-linux-gnu/pkgconfig/

# Default command: show pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
