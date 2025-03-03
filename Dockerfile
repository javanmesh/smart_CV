# Use the official Debian Bookworm base image
FROM debian:bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget git cmake g++ make poppler-utils poppler-data \
    libpoppler-dev libpoppler-private-dev \
    libpng-dev libjpeg-dev fontforge libcairo2-dev \
    libpoppler-glib-dev libglib2.0-dev libfontconfig1-dev \
    pkg-config libfreetype6-dev

# Clone the latest pdf2htmlEX source code and build it
WORKDIR /usr/src
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git && \
    cd pdf2htmlEX && \
    cmake . && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf pdf2htmlEX

# Set the default command
CMD ["pdf2htmlEX", "--help"]
