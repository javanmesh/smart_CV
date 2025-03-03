# Use Ubuntu 20.04 where libfontforge-dev is available
FROM ubuntu:20.04

# Set non-interactive mode
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
    libfontforge-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the pdf2htmlEX repository
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

# Verify the contents of the cloned repo
RUN ls -l pdf2htmlEX && ls -l pdf2htmlEX/pdf2htmlEX

# Build from the correct subdirectory
RUN cd pdf2htmlEX/pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Cleanup to reduce image size
RUN rm -rf pdf2htmlEX

# Set the default command
CMD ["pdf2htmlEX", "--help"]
