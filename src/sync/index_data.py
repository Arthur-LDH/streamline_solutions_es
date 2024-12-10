from elasticsearch import Elasticsearch
import mysql.connector
import time
import logging
from datetime import datetime, timedelta
from services.external_api import ExternalApiService
from config.api_config import API_CONFIG

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def connect_to_mariadb():
    try:
        return mysql.connector.connect(
            host="mariadb",
            user="streamline_user",
            password="your_secure_password",
            database="streamline",
            charset='utf8mb4',
            collation='utf8mb4_unicode_ci'  # Changé ici
        )
    except Exception as e:
        logger.error(f"Erreur de connexion à MariaDB: {e}")
        raise

def connect_to_elasticsearch():
    try:
        es = Elasticsearch(['http://elasticsearch:9200'])
        if not es.ping():
            raise ValueError("Connexion à Elasticsearch échouée")
        return es
    except Exception as e:
        logger.error(f"Erreur de connexion à Elasticsearch: {e}")
        raise

def get_sql_query(entity_type):
    with open('resources/sql-queries.sql', 'r') as f:
        sql_content = f.read()
        queries = sql_content.split('--')
        for query in queries:
            if entity_type.lower() in query.lower():
                return query.strip()
    return None

def index_external_data(es: Elasticsearch, api_service: ExternalApiService):
    try:
        endpoints = ['clients', 'products', 'warehouses', 'shipments', 'shipment-items']
        
        for endpoint in endpoints:
            page = 1
            while True:
                response = api_service.get(f'/api/v1/{endpoint}', params={'page': page})
                
                if not response.get('data'):
                    break
                    
                for item in response['data']:
                    es.index(
                        index=endpoint.replace('-', '_'),
                        id=item['id'],
                        document=item
                    )
                
                if page >= response['pagination']['last_page']:
                    break
                    
                page += 1
                
            logger.info(f"Finished indexing {endpoint}")
    except Exception as e:
        logger.error(f"Erreur pendant l'indexation des données externes: {e}")
        raise

def index_data():
    time.sleep(30)  # Attendre que les services démarrent

    try:
        mariadb_conn = connect_to_mariadb()
        es = connect_to_elasticsearch()
        api_service = ExternalApiService(API_CONFIG['base_url'], API_CONFIG['api_key'])
        cursor = mariadb_conn.cursor(dictionary=True)
        
        # Get last sync date
        last_sync_date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S')

        # Liste des entités à synchroniser
        entities = ['clients', 'products', 'warehouses', 'shipments', 'shipment_items']
        
        for entity in entities:
            query = get_sql_query(entity)
            if query:
                cursor.execute(query, {'last_sync_date': last_sync_date})
                rows = cursor.fetchall()
                for row in rows:
                    es.index(
                        index=entity,
                        id=row['id'],
                        document=row
                    )
                logger.info(f"Indexed {len(rows)} {entity}")

        # Index external data
        index_external_data(es, api_service)

        cursor.close()
        mariadb_conn.close()
        logger.info("Indexation terminée avec succès")

    except Exception as e:
        logger.error(f"Erreur pendant l'indexation: {e}")

if __name__ == "__main__":
    while True:
        try:
            index_data()
        except Exception as e:
            print(f"Erreur: {e}")
        time.sleep(60)  # Attendre 1 minute avant la prochaine synchronisation