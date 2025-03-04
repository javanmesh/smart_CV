FROM ubuntu:22.04

# Set noninteractive mode for apt-get.
ENV DEBIAN_FRONTEND=noninteractive

# Install basic build tools and utilities required by the build scripts.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    git \
    wget \
    curl \
    unzip \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Clone the pdf2htmlEX repository (using the official GitHub repo).
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

WORKDIR /tmp/pdf2htmlEX

# (Optional) Set and report versions – these scripts set key environment variables.
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs

# Run the top-level build script for Debian-based systems.
# This script downloads and builds the correct versions of Poppler, FontForge, and then pdf2htmlEX.
RUN ./buildScripts/buildInstallLocallyApt

# Clean up the build directory if desired.
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Default command: display pdf2htmlEX help.
CMD ["pdf2htmlEX", "--help"]
