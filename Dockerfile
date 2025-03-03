# Use Debian as the base image
FROM debian:bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget git cmake g++ make \
    poppler-utils poppler-data \
    libpoppler-dev libpoppler-private-dev \
    libpng-dev libjpeg-dev \
    libfontconfig1-dev libfreetype6-dev pkg-config \
    automake autoconf libtool \
    python3 python3-pip

# Set the working directory
WORKDIR /usr/src

# Clone the pdf2htmlEX repository and build it
RUN git clone --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git && \
    cd pdf2htmlEX && \
    cmake . && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf pdf2htmlEX

# Set the default command
CMD ["pdf2htmlEX", "--help"]
