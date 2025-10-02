FROM python:3.11-slim

WORKDIR /app

# instalar dependencias del sistema en una sola capa
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip

# Copiar requirements y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir --timeout=60 -r requirements.txt

COPY ./app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
