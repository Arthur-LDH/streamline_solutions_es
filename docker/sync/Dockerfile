FROM python:3.9-slim

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie des fichiers
COPY src/sync/requirements.txt .
COPY src/sync/index_data.py .

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Nouveau script d'entrée
COPY docker/sync/entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]