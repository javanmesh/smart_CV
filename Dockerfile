# Stage 1: Build pdf2htmlEX using Ubuntu 22.04 (remains unchanged)
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

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

WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

WORKDIR /tmp/pdf2htmlEX
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs
RUN ./buildScripts/buildInstallLocallyApt

WORKDIR /
RUN rm -rf /tmp/pdf2htmlEX

# Stage 2: Switch final stage to Ubuntu 22.04 to ensure libjpeg-turbo8 compatibility
FROM ubuntu:22.04

# Install system libraries and Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libglib2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libjpeg-turbo8 \  # This provides libjpeg.so.8 with LIBJPEG_8.0
    && rm -rf /var/lib/apt/lists/*

# Copy the pdf2htmlEX binary from the builder
COPY --from=builder /usr/local/bin/pdf2htmlEX /usr/local/bin/pdf2htmlEX

WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip3 install -r requirements.txt

EXPOSE 10000
CMD ["python3", "app.py"]
