# Use an older Ubuntu version where libfontforge-dev is available
FROM ubuntu:22.04

# Set non-interactive mode to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libpoppler-dev \
    libpoppler-cpp-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libboost-all-dev \
    fontforge \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the pdf2htmlEX repository and verify
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git && \
    ls -l pdf2htmlEX && \
    cd pdf2htmlEX && ls -l

# Build pdf2htmlEX
RUN cd pdf2htmlEX && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Cleanup to reduce image size
RUN rm -rf pdf2htmlEX

# Set the default command
CMD ["pdf2htmlEX", "--help"]
