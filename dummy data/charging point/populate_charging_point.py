import requests
import random

max_charging_station_id = 793
n = 1

def post_data_to_local_server(charging_station_id, n):
    url = f"http://127.0.0.1:5000/chargingPoint/add/{charging_station_id}"
    data= {
        "id": n,
        "title": f"Charging Point {n}",
        "description": "Description",
        "charging_point_number": "1"
    }
    response = requests.post(url, json=data)
    
    print(response.text)

for id in range(1, max_charging_station_id+1):
    for x in range(random.randint(2,10)):
        post_data_to_local_server(id, n)
        n = n + 1