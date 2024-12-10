#!/bin/bash
set -e

# Démarrer Kibana
/usr/share/kibana/bin/kibana &

## Attendre que Kibana soit prêt
#until curl -s http://localhost:5601/api/status | grep -q '"overall":{"level":"available"'
#do
#    echo "Waiting for Kibana..."
#    sleep 10
#done
#
## Initialiser Kibana
#python3 /usr/local/bin/init_kibana.py

# Maintenir le conteneur actif
wait