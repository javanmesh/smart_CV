FROM python:3.9

WORKDIR /app

COPY . .

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget && \
    wget -qO - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    apt-get install -y pdf2htmlex && \
    pip install -r requirements.txt

CMD ["python", "app.py"]
