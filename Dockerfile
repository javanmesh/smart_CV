# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and dependencies (including libpoppler-private-dev)
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

# Clone the pdf2htmlEX repository (coolwanglu fork)
RUN git clone --depth 1 --recursive https://github.com/coolwanglu/pdf2htmlEX.git

# Remove bundled Poppler and patch CMakeLists.txt:
#  - Delete the bundled poppler directory.
#  - Remove the block that adds bundled Poppler source files (starting at CAIROOUTPUTDEV_PATH).
#  - Insert include directories for system Poppler headers (both public and private).
RUN rm -rf pdf2htmlEX/3rdparty/poppler && \
    sed -i '/set(CAIROOUTPUTDEV_PATH 3rdparty\/poppler\/git)/,+9d' pdf2htmlEX/CMakeLists.txt && \
    sed -i '/^project(/a include_directories(/usr/include/poppler)\ninclude_directories(/usr/include/poppler-private)' pdf2htmlEX/CMakeLists.txt && \
    echo 'target_include_directories(pdf2htmlEX PRIVATE /usr/include/poppler /usr/include/poppler-private)' >> pdf2htmlEX/CMakeLists.txt

# Build pdf2htmlEX using system Poppler libraries
RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 -DPDF2HTMLEX_USE_SYSTEM_POPPLER=ON && \
    make -j$(nproc) && \
    make install

# Clean up source directory
RUN rm -rf pdf2htmlEX

# Set default command to show pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
