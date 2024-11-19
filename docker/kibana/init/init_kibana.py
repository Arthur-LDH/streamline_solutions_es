import json
import requests
import time
import os

KIBANA_URL = "http://kibana:5601"
HEADERS = {"kbn-xsrf": "true", "Content-Type": "application/json"}

def wait_for_kibana():
    while True:
        try:
            if requests.get(f"{KIBANA_URL}/api/status").status_code == 200:
                return
        except:
            time.sleep(10)

def create_data_views():
    data_views_dir = "/usr/share/kibana/init/data_views"
    for filename in os.listdir(data_views_dir):
        if filename.endswith('.json'):
            with open(os.path.join(data_views_dir, filename)) as f:
                data_view = json.load(f)
                response = requests.post(
                    f"{KIBANA_URL}/api/data_views/data_view",
                    headers=HEADERS,
                    json=data_view
                )
                print(f"Data view {filename}: Status {response.status_code}")
                print(f"Response: {response.text}")

def create_dashboards():
    dashboards_dir = "/usr/share/kibana/init/dashboards"
    for filename in os.listdir(dashboards_dir):
        if filename.endswith('.json'):
            with open(os.path.join(dashboards_dir, filename)) as f:
                dashboard = json.load(f)
                response = requests.post(
                    f"{KIBANA_URL}/api/saved_objects/dashboard",
                    headers=HEADERS,
                    json=dashboard
                )
                print(f"Dashboard {filename}: Status {response.status_code}")
                print(f"Response: {response.text}")

if __name__ == "__main__":
    wait_for_kibana()
    create_data_views()
    create_dashboards()