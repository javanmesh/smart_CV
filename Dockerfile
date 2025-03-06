# Stage 1: Build pdf2htmlEX using Ubuntu 22.04
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
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
    python3-pip \
    poppler-utils \
    libcurl4-openssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium manually to prevent runtime downloads
RUN apt-get update && apt-get install -y chromium-browser

# Clone pdf2htmlEX repository
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/pdf2htmlEX/pdf2htmlEX.git

WORKDIR /tmp/pdf2htmlEX

# Build pdf2htmlEX
RUN ./buildScripts/versionEnvs && ./buildScripts/reportEnvs
RUN ./buildScripts/buildInstallLocallyApt

# Stage 2: Final runtime image
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies plus missing Playwright dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libglib2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libjpeg-turbo8 \
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Copy pdf2htmlEX from builder stage
COPY --from=builder /usr/local/bin/pdf2htmlEX /usr/local/bin/pdf2htmlEX
COPY --from=builder /usr/local/share/pdf2htmlEX /usr/local/share/pdf2htmlEX

# Environment variable for pdf2htmlEX data directory
ENV PDF2HTMLEX_DATA_DIR=/usr/local/share/pdf2htmlEX

WORKDIR /app

# Copy application code
COPY . /app

# Install Python dependencies and then Playwright browsers
RUN pip3 install -r requirements.txt && playwright install

# Expose the port
EXPOSE 10000

# Start Flask application
CMD ["python3", "app.py"]
