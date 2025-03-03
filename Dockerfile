FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libpoppler-dev \
    libpoppler-cpp-dev \
    libfontforge-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libboost-all-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Check if the repository cloned correctly
RUN ls -l pdf2htmlEX

# Check if CMakeLists.txt exists
RUN cd pdf2htmlEX && ls -l

# Build pdf2htmlEX
RUN cd pdf2htmlEX && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Cleanup
RUN rm -rf pdf2htmlEX
