# Install Poppler development libraries
sudo apt update
sudo apt install libpoppler-cpp-dev libpoppler-private-dev

# If libpoppler-private-dev is not available, try:
sudo apt install libpoppler-dev

# Ensure CMake finds Poppler
rm -rf build
mkdir build
cd build
cmake ..
make -j$(nproc)

# Check if the headers exist
dpkg -L libpoppler-dev | grep poppler-config.h

# If the file isn’t found, consider installing an older version of Poppler

# Dockerfile for building pdf2htmlEX using Ubuntu 20.04
FROM ubuntu:20.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libpoppler-dev \
    libpoppler-cpp-dev \
    libpoppler-private-dev \
    poppler-utils \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libboost-all-dev \
    fontforge \
    libfontforge-dev \
    git \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
RUN java -version

# Clone the pdf2htmlEX repository and submodules
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git && \
    cd pdf2htmlEX && git submodule update --init --recursive

# Verify the contents of the cloned repo
RUN ls -l pdf2htmlEX && ls -l pdf2htmlEX/pdf2htmlEX

# Build from the correct subdirectory
RUN cd pdf2htmlEX/pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu && \
    make -j$(nproc) && \
    make install

# Cleanup to reduce image size
RUN rm -rf pdf2htmlEX

# Set the default command
CMD ["pdf2htmlEX", "--help"]
