import requests
import json

def query_overpass(query):
    url = "http://overpass-api.de/api/interpreter"
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    response = requests.post(url, data={'data': query}, headers=headers)
    if response.status_code == 200:
        return response.json()  # Return JSON response
    else:
        raise Exception(f"Query failed with status code {response.status_code}: {response.text}")

query = """
[out:json];
(
  node["amenity"="charging_station"](around:100000,56.236306,10.537671);
  way["amenity"="charging_station"](around:100000,56.236306,10.537671);
  relation["amenity"="charging_station"](around:100000,56.236306,10.537671);
);
out body;
"""


result = query_overpass(query)


with open('jylland_charging_stations.json', 'w', encoding='utf-8') as file:
    json.dump(result, file, ensure_ascii=False, indent=4)