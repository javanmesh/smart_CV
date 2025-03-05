# Stage 1: Build environment using Ubuntu 22.04
FROM ubuntu:22.04 AS builder

# Install required dependencies for building
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN apt-get update && apt-get install -y python3.11 python3.11-venv python3.11-dev

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Stage 2: Final environment using Ubuntu 20.04
FROM ubuntu:20.04

# Install required dependencies, including libjpeg8
RUN apt-get update && apt-get install -y \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    libjpeg8 \
    libjpeg8-dev \
    pdf2htmlex \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.9 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Copy necessary files from the build stage if needed
COPY --from=builder /usr/bin/python3.11 /usr/bin/python3.11

# Install application dependencies
WORKDIR /app
COPY requirements.txt .
RUN python3 -m venv venv && . venv/bin/activate && pip install --no-cache-dir -r requirements.txt

# Copy the application source code
COPY . .

# Expose the application port
EXPOSE 10000

# Start the application
CMD ["venv/bin/python", "app.py"]
