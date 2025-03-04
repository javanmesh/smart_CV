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

# Set the working directory to /app.
WORKDIR /app

# Copy the entire repository (including app.py and buildScripts) into /app.
COPY . /app

# (Optional) Run version environment and report scripts to verify configuration.
RUN chmod +x ./buildScripts/versionEnvs ./buildScripts/reportEnvs && \
    ./buildScripts/versionEnvs && ./buildScripts/reportEnvs

# Run the top-level build script for Debian-based systems to build pdf2htmlEX.
RUN chmod +x ./buildScripts/buildInstallLocallyApt && \
    ./buildScripts/buildInstallLocallyApt

# Expose the port your Flask app listens on (default: 10000).
EXPOSE 10000

# Set the default command to run your Flask application.
CMD ["python3", "app.py"]
