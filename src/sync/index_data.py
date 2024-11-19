from elasticsearch import Elasticsearch
import mysql.connector
import time
import logging
from datetime import datetime

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

def index_data():
    time.sleep(30)  # Attendre que les services démarrent

    try:
        # Connexions
        mariadb_conn = connect_to_mariadb()
        es = connect_to_elasticsearch()
        cursor = mariadb_conn.cursor(dictionary=True)

        # Indexer les clients
        cursor.execute("SELECT * FROM clients")
        clients = cursor.fetchall()
        for client in clients:
            for key, value in client.items():
                if isinstance(value, (datetime)):
                    client[key] = value.isoformat()
            es.index(
                index='clients',
                id=client['id_client'],
                document=client
            )
            print(f"Client indexé: {client['id_client']}")

        # Indexer les produits
        cursor.execute("SELECT * FROM produits")
        produits = cursor.fetchall()
        for produit in produits:
            for key, value in produit.items():
                if isinstance(value, (datetime)):
                    produit[key] = value.isoformat()
            es.index(
                index='produits',
                id=produit['id_produit'],
                document=produit
            )
            print(f"Produit indexé: {produit['id_produit']}")

        # Indexer les entrepots
        cursor.execute("SELECT * FROM entrepots")
        entrepots = cursor.fetchall()
        for entrepot in entrepots:
            for key, value in entrepot.items():
                if isinstance(value, (datetime)):
                    entrepot[key] = value.isoformat()
            es.index(
                index='entrepots',
                id=entrepot['id_entrepot'],
                document=entrepot
            )
            print(f"Entrepot indexé: {entrepot['id_entrepot']}")

        # Indexer les expéditions
        cursor.execute("""
            SELECT e.*,
                   c.raison_sociale as client_nom,
                   ed.nom_entrepot as entrepot_depart_nom,
                   ea.nom_entrepot as entrepot_arrivee_nom
            FROM expeditions e
            JOIN clients c ON e.id_client = c.id_client
            JOIN entrepots ed ON e.id_entrepot_depart = ed.id_entrepot
            JOIN entrepots ea ON e.id_entrepot_arrivee = ea.id_entrepot
        """)
        expeditions = cursor.fetchall()
        for expedition in expeditions:
            for key, value in expedition.items():
                if isinstance(value, (datetime)):
                    expedition[key] = value.isoformat()
            es.index(
                index='expeditions',
                id=expedition['id_expedition'],
                document=expedition
            )
            print(f"Expédition indexée: {expedition['id_expedition']}")

        cursor.close()
        mariadb_conn.close()
        print("Indexation terminée avec succès")

    except Exception as e:
        logger.error(f"Erreur pendant l'indexation: {e}")

if __name__ == "__main__":
    while True:
        try:
            index_data()
        except Exception as e:
            print(f"Erreur: {e}")
        time.sleep(60)  # Attendre 1 minute avant la prochaine synchronisation