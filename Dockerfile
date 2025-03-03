FROM debian:bookworm

# Install dependencies
RUN apt-get update && apt-get install -y wget

# Download and extract prebuilt pdf2htmlex binary
RUN wget https://github.com/pdf2htmlEX/pdf2htmlEX/releases/download/v0.18.8.rc1/pdf2htmlEX-0.18.8.rc1-linux-64bit.tar.gz && \
    tar -xvf pdf2htmlEX-0.18.8.rc1-linux-64bit.tar.gz && \
    mv pdf2htmlEX /usr/local/bin/ && \
    rm pdf2htmlEX-0.18.8.rc1-linux-64bit.tar.gz

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

CMD ["/bin/bash"]
