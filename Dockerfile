FROM python:3.9

WORKDIR /app

COPY . .

RUN apt-get update && \
    apt-get install -y pdf2htmlEX && \
    pip install -r requirements.txt

CMD ["gunicorn", "-b", "0.0.0.0:10000", "app:app"]
