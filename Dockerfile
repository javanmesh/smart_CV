# Stage 1: Build pdf2htmlEX using Ubuntu 22.04
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and libraries for pdf2htmlEX.
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

# Set up environment variables (versions, paths, etc.)
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs

# Run the top-level build script for Debian-based systems.
RUN ./buildScripts/buildInstallLocallyApt

# Clean up build artifacts.
WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Stage 2: Final image for your Flask application.
# Use Ubuntu 20.04 to get libjpeg8.
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime libraries and Python.
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libjpeg8 \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy the built pdf2htmlEX binary from the builder stage.
COPY --from=builder /usr/local/bin/pdf2htmlEX /usr/local/bin/pdf2htmlEX

WORKDIR /app

# Copy your application code.
COPY . /app

# Install Python dependencies.
# This assumes you have a requirements.txt in your project.
RUN pip3 install -r requirements.txt

# Explicitly install Flask in case it is missing.
RUN pip3 install flask

# Expose the port your Flask app listens on.
EXPOSE 10000

# Start your Flask application.
CMD ["python3", "app.py"]
