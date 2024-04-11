from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from .extensions import db


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))

    def serialize(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
        }

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    
    

class ChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    company_name = db.Column(db.String(50), nullable=True)
    charging_station_type = db.Column(db.String(50), nullable=False)
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)
    available = db.Column(db.Boolean, nullable=False)
    phone_number = db.Column(db.String(20), nullable=True)

    def to_json(self):
        return {
            'id': self.id,
            'company_name': self.company_name,
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
    charging_station_id = db.Column(db.Integer, db.ForeignKey('charging_station.id'), nullable=True)
    reservation_status = db.Column(db.String(50), nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'charging_station_id': self.charging_station_id,
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