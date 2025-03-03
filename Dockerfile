FROM ubuntu:latest

# Set non-interactive mode for installations
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    make \
    g++ \
    pkg-config \
    poppler-utils \
    libpoppler-dev \
    libpoppler-private-dev \
    libpoppler-glib-dev \
    libcairo2-dev \
    libjpeg-dev \
    libpng-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    git

# Clone pdf2htmlEX repository
RUN git clone https://github.com/pdf2htmlEX/pdf2htmlEX.git /pdf2htmlEX

# Create build directory and compile
WORKDIR /pdf2htmlEX
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/pdf2htmlEX"]
