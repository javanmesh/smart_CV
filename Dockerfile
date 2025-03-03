# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies (note the addition of libpoppler-private-dev)
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
#   - Delete the bundled poppler directory
#   - Remove the block that adds bundled Poppler source files (starting at the line that sets CAIROOUTPUTDEV_PATH)
#   - Insert an include for /usr/include/poppler so the system headers are found
RUN rm -rf pdf2htmlEX/3rdparty/poppler && \
    sed -i '/set(CAIROOUTPUTDEV_PATH 3rdparty\/poppler\/git)/,+9d' pdf2htmlEX/CMakeLists.txt && \
    sed -i '/^project(/a include_directories(/usr/include/poppler)' pdf2htmlEX/CMakeLists.txt

# Build pdf2htmlEX using system Poppler libraries
RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 -DPDF2HTMLEX_USE_SYSTEM_POPPLER=ON && \
    make -j$(nproc) && \
    make install

# Clean up the source directory
RUN rm -rf pdf2htmlEX

# Default command: display pdf2htmlEX help
CMD ["pdf2htmlEX", "--help"]
