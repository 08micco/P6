import json

# Load the data from the JSON file
with open('charging_stations.json', 'r', encoding='utf-8') as file:
    stations = json.load(file)

# Define a mapping from connector IDs to plug types
connector_map = {
    7: "Type 2 (Mennekes)",
    13: "CCS (Combined Charging System)",
    3: "CHAdeMO",
    15: "SAE J1772 (J-plug)",
    6: "Tesla"
    # Add additional mappings based on available data
}

# Prepare data list
processed_stations = []

for station in stations:
    for substation in station['stations']:
        for outlet in substation['outlets']:
            processed_stations.append({
                "name": station['name'],
                "address": station['address'],
                "latitude": station['latitude'],
                "longitude": station['longitude'],
                "plug_type": connector_map.get(outlet['connector'], "Unknown connector")
            })

# Write the processed data to a new JSON file
with open('processed_charging_stations.json', 'w', encoding='utf-8') as outfile:
    json.dump(processed_stations, outfile, indent=4, ensure_ascii=False)

print("Processed data has been saved to 'processed_charging_stations.json'.")
