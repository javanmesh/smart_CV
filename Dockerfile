FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required build tools and libraries.
RUN apt-get update && apt-get install -y \
    sudo \
    build-essential \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libopenjp2-7-dev \
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libboost-all-dev \
    fontforge \
    libpango1.0-dev \
    git \
    openjdk-11-jdk \
    npm \
    nodejs \
    python3-pip \
    poppler-utils \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the pdf2htmlEX repository.
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

WORKDIR /tmp/pdf2htmlEX

# Set up environment variables (versions, paths, etc.).
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs

# Run the top-level build script for Debian-based systems.
RUN ./buildScripts/buildInstallLocallyApt

# Clean up the build directory.
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Instead of exiting immediately by running pdf2htmlEX --help,
# keep the container alive. You can later exec into the container and run pdf2htmlEX.
CMD ["tail", "-f", "/dev/null"]
