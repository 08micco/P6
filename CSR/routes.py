from flask import Flask, render_template, redirect, url_for, flash, request, jsonify
from flask_login import login_user, logout_user, current_user
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import check_password_hash
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
#from models import User, CorporateChargingStation, HouseholdChargingStation, ChargingPoint, Reservation

import json

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///charging_stations.db'
db = SQLAlchemy(app)


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)


class CorporateChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    company_name = db.Column(db.String(50), nullable=False)
    charging_station_type = db.Column(db.String(50), nullable=False)
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)
    available = db.Column(db.Boolean, nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'company_name': self.company_name,
            'charging_station_type': self.charging_station_type,
            'longitude': self.longitude,
            'latitude': self.latitude,
            'charging_points': self.charging_points,
            'charger_type': self.charger_type,
            'available': self.available,
        }



class HouseholdChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    charging_station_type = db.Column(db.String(50), nullable=False)
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)
    phone_number = db.Column(db.String(20), nullable=False)
    available = db.Column(db.Boolean, nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'owner_id': self.owner_id,
            'charging_station_type': self.charging_station_type,
            'longitude': self.longitude,
            'latitude': self.latitude,
            'charging_points': self.charging_points,
            'charger_type': self.charger_type,
            'phone_number': self.phone_number,
            'available': self.available,
        }



class ChargingPoint(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    corporate_station_id = db.Column(db.Integer, db.ForeignKey('corporate_charging_station.id'), nullable=True)
    household_station_id = db.Column(db.Integer, db.ForeignKey('household_charging_station.id'), nullable=True)
    reservation_status = db.Column(db.String(50), nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'corporate_station_id': self.corporate_station_id,
            'household_station_id': self.household_station_id,
            'reservation_status': self.reservation_status,
        }



class Reservation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    charging_point_id = db.Column(db.Integer, db.ForeignKey('charging_point.id'), nullable=False)
    reservation_time = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    def to_json(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'charging_point_id': self.charging_point_id,
            'reservation_time': self.reservation_time,
        }



def populate_dummy_data():
    db.session.query(User).delete()
    db.session.query(CorporateChargingStation).delete()
    db.session.query(HouseholdChargingStation).delete()
    db.session.query(ChargingPoint).delete()
    db.session.query(Reservation).delete()

    user1 = User(username='user1', email='user1@example.com')
    user1.set_password('password1')
    
    user2 = User(username='user2', email='user2@example.com')
    user2.set_password('password2')
    
    db.session.add(user1)
    db.session.add(user2)
     
    db.session.commit()
    db.session.refresh(user1)
    db.session.refresh(user2)
    
    corporate_station1 = CorporateChargingStation(
        company_name="Corp Charging Co",
        charging_station_type="Corporate",
        longitude="12.34",
        latitude="56.78",
        charging_points=4,
        charger_type="Type C",
        available=True
    )
    corporate_station2 = CorporateChargingStation(
        company_name="Electric Charge Ltd",
        charging_station_type="Corporate",
        longitude="98.76",
        latitude="54.32",
        charging_points=6,
        charger_type="Type C",
        available=False
    )
    
    household_station1 = HouseholdChargingStation(
        owner_id=1,
        charging_station_type="Corporate",
        longitude="90.12",
        latitude="34.56",
        charging_points=2,
        charger_type="Type A",
        phone_number="1234567890",
        available=True
    )
    household_station2 = HouseholdChargingStation(
        owner_id=1,
        charging_station_type="Corporate",
        longitude="78.90",
        latitude="12.34",
        charging_points=1,
        charger_type="Type A",
        phone_number="0987654321",
        available=False
    )


    db.session.add(corporate_station1)
    db.session.add(corporate_station2)
    db.session.add(household_station1)
    db.session.add(household_station2)

    db.session.commit()
    db.session.refresh(corporate_station1)
    db.session.refresh(corporate_station2)
    db.session.refresh(household_station1)
    db.session.refresh(household_station2)


    cp1 = ChargingPoint(corporate_station_id=corporate_station1.id, reservation_status="available")
    cp2 = ChargingPoint(corporate_station_id=corporate_station2.id, reservation_status="reserved")
    cp3 = ChargingPoint(household_station_id=household_station1.id, reservation_status="available")
    cp4 = ChargingPoint(household_station_id=household_station2.id, reservation_status="reserved")
    
    db.session.add(cp1)
    db.session.add(cp2)
    db.session.add(cp3)
    db.session.add(cp4)
    
    db.session.commit()

    reservation1 = Reservation(user_id=user1.id, charging_point_id=cp1.id, reservation_time=datetime.utcnow())
    reservation2 = Reservation(user_id=user2.id, charging_point_id=cp2.id, reservation_time=datetime.utcnow() + timedelta(days=1))
    
    db.session.add(reservation1)
    db.session.add(reservation2)
    
    db.session.commit()



with app.app_context():
        db.create_all()
        populate_dummy_data()


########## LOGIN ##########

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash('its Fucking WRONG username or password')
        return render_template('login.html')

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('index'))


########## CSR API ##########

@app.route('/getChargingStations', methods=['GET'])
def get_charging_stations():
    corporate_stations = CorporateChargingStation.query.all()
    household_stations = HouseholdChargingStation.query.all()
    return jsonify([station.to_json() for station in corporate_stations]+ \
                   [station.to_json() for station in household_stations])

@app.route('/getAvailableChargingStations', methods=['GET'])
def get_available_charging_stations():
    corporate_stations = CorporateChargingStation.query.filter_by(available=True).all()
    household_stations = HouseholdChargingStation.query.filter_by(available=True).all()
    return jsonify([station.to_json() for station in corporate_stations]+ \
                   [station.to_json() for station in household_stations])

@app.route('/getReservedChargingStations', methods=['GET'])
def get_reserved_charging_stations():
    corporate_stations = CorporateChargingStation.query.filter_by(available=False).all()
    household_stations = HouseholdChargingStation.query.filter_by(available=False).all()
    return jsonify([station.to_json() for station in corporate_stations]+ \
                   [station.to_json() for station in household_stations])

@app.route('/chargingStation/get/<string:chargingstationID>', methods=['GET'])
def get_charging_station_from_charging_station_id(chargingstationID):
    corporate_station = CorporateChargingStation.query.filter_by(id=chargingstationID).all()
    household_station = HouseholdChargingStation.query.filter_by(id=chargingstationID).all()
    return jsonify([station.to_json() for station in corporate_station]+ \
                   [station.to_json() for station in household_station])

@app.route('/chargingPoint/getAll/<string:chargingstationID>', methods=['GET'])
def get_all_charging_point_from_charging_station_id(chargingstationID):
    corporate_charging_point = ChargingPoint.query.filter_by(corporate_station_id=chargingstationID)
    household_charging_point = ChargingPoint.query.filter_by(household_station_id=chargingstationID)
    return jsonify([point.to_json() for point in corporate_charging_point]+ \
                   [point.to_json() for point in household_charging_point])

@app.route('/chargingpoint/get/<string:chargingpointID>', methods=['GET'])
def get_charging_point_from_charging_point_id(chargingpointID):
    charging_point = ChargingPoint.query.filter_by(id=chargingpointID)
    return jsonify([point.to_json() for point in charging_point])

@app.route('/chargingstation/add', methods=['POST'])
def add_charging_station():
    pass

@app.route('/chargingpoint/add/{chargingstationID}', methods=['POST'])
def add_charging_point_from_charging_station_id():
    pass

@app.route('/chargingstation/delete/{chargingstationID}', methods=['DELETE'])
def delete_charging_station_from_charging_station_id():
    pass

@app.route('/chargingpoint/delete/{chargingpointID}', methods=['DELETE'])
def delete_charging_point_from_charging_point_id():
    pass

@app.route('/reservation/newreservation/{chargingpointID}', methods=['POST'])
def new_reservation_from_charging_point_id():
    pass

@app.route('/reservation/changereservation/{reservationID}', methods=['PUT'])
def change_reservation_from_reservation_id():
    pass

@app.route('/reservation/deletereservation/{reservationID}', methods=['DELETE'])
def delete_reservation_from_reservation_id():
    pass






