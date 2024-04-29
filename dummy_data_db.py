import json
import requests
import random

# Helper functions as defined previously
def random_phone_number():
    return "".join(str(random.randint(0, 9)) for _ in range(8))

def random_company_name():
    prefixes = ['Grøn', 'Øko', 'Urban', 'Smart', 'Fremtid', 'Kraft', 'Sol', 'Vind']
    suffixes = ['Energi', 'Kraft', 'Elektrisk', 'Drev', 'Ladning', 'Station']
    return random.choice(prefixes) + random.choice(suffixes)

def random_title_subtitle_description():
    titles = ["Ladestation", "Hurtigladestation", "Energi Hub"]
    subtitles = ["Hurtig opladning", "24/7 service", "Miljøvenlig strøm", None]
    descriptions = [
        "Tilbyder døgnåben, højhastighedsopladning for erhvervskøretøjer.",
        "Bæredygtigt drevet station med grønne energiløsninger.",
        "Beliggende bekvemt med let adgang for alle erhvervskøretøjer.",
        None
    ]
    return random.choice(titles), random.choice(subtitles), random.choice(descriptions)

def random_charging_points():
    return random.randint(4, 10)

def random_charger_type():
    types = [
        "Type 2 (Mennekes)",
        "SAE J1772 (J-plug)",
        "CCS (Combined Charging System)",
        "CHAdeMO",
        "Tesla"
    ]
    return random.choice(types)

def get_address(latitude, longitude):
    url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={latitude}&lon={longitude}"
    headers = {'User-Agent': 'CSR'}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        return data.get('display_name')
    else:
        return "Address not found"

def post_data_to_local_server(data):
    url = "http://127.0.0.1:5000/chargingStation/add"
    response = requests.post(url, json=data)
    return response.text

# Load processed charging stations data
with open('processed_charging_stations.json', 'r', encoding='utf-8') as file:
    charging_stations = json.load(file)

# Create enriched data for each charging station
enriched_stations = []
for station in charging_stations:
    company_name = random_company_name()
    title, subtitle, description = random_title_subtitle_description()
    enriched_stations.append({
        "company_name": company_name,
        "owner_id": None,
        "title": station['name'],
        "subtitle": subtitle,
        "description": description,
        "address": station['address'],
        "charging_station_type": "Corporate",
        "longitude": station['longitude'],
        "latitude": station['latitude'],
        "charging_points": random_charging_points(),
        "charger_type": station['plug_type'],
        "phone_number": random_phone_number(),
        "available": True
    })

# Post each station to the local server
for station in enriched_stations:
    result = post_data_to_local_server(station)
    print(f"Server response: {result}")
