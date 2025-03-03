FROM debian:bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget git cmake g++ make poppler-utils poppler-data \
    libpoppler-dev libpoppler-private-dev \
    libfontforge-dev libpng-dev libjpeg-dev

# Clone and build pdf2htmlex
RUN git clone https://github.com/pdf2htmlEX/pdf2htmlEX.git && \
    cd pdf2htmlEX && \
    cmake . && make -j$(nproc) && make install

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

CMD ["/bin/bash"]
