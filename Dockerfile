# Stage 1: Build pdf2htmlEX using Debian Bookworm to match runtime environment
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and required libraries
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

# Clone and build pdf2htmlEX
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

WORKDIR /tmp/pdf2htmlEX
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs
RUN ./buildScripts/buildInstallLocallyApt

# Cleanup
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Stage 2: Use Python image based on Debian Bookworm
FROM python:3.11

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies (now using Bookworm's libjpeg62-turbo)
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libjpeg62-turbo \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for libjpeg.so.8
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/x86_64-linux-gnu/libjpeg.so.8

# Copy built binary from builder
COPY --from=builder /usr/local/bin/pdf2htmlEX /usr/local/bin/pdf2htmlEX

# Application setup
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
EXPOSE 10000
CMD ["python", "app.py"]
