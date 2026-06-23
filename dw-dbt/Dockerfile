FROM python:3.12-slim

WORKDIR /usr/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/app/rico_bi

CMD ["tail", "-f", "/dev/null"]