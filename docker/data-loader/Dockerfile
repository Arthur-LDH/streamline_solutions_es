FROM python:3.9-slim

WORKDIR /app

COPY src/sync/requirements.txt .
RUN pip install -r requirements.txt

COPY src/sync/index_data.py .
COPY docker/sync/entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]