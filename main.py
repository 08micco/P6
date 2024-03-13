from flask import Flask
from flask_sqlalchemy import SQLAlchemy

import json

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///charging_stations.db'
db = SQLAlchemy(app)

class ChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    location = db.Column(db.String(120))
    charging_points = db.Column(db.Integer)
    charger_type = db.Column(db.String(50))
    availability = db.Column(db.String(50))
    reservation_status = db.Column(db.String(50))

# Create the database
with app.app_context():
    db.create_all()


#####################
######## API ########
#####################
@app.route('/')
def index():
    return 'Index'

@app.route('/getChargingStations')
def get_charging_stations():
    return json.loads(SAMPLEJSON)


@app.route('/getAvailableChargingStations')
def get_available_charging_stations():
    return json.loads(SAMPLEJSON)

@app.route('/getReservedChargingStations')
def get_reserved_charging_stations():
    return json.loads(SAMPLEJSON)
    





SAMPLEJSON = """
[
   {
      "_id":"23",
      "location":"hejsavej 123",
      "charger_type":"type c",
      "reservation_status":"available"
   },
   {
      "_id":"24",
      "location":"hejsavej 456",
      "charger_type":"DisplayPort",
      "reservation_status":"reserved"
   }
]"""