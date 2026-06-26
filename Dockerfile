FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y curl && \
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r sentinel && useradd -r -g sentinel sentinel

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=sentinel:sentinel app/ ./app
COPY --chown=sentinel:sentinel ai/ ./ai

USER sentinel

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
