from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from . import db


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
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'company_name': self.company_name,
            'longitude': self.longitude,
            'latitude': self.latitude,
            'charging_points': self.charging_points,
            'charger_type': self.charger_type,
        }


class HouseholdChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)
    phone_number = db.Column(db.String(20), nullable=False)

    def to_json(self):
        return {
            'id': self.id,
            'owner_id': self.owner_id,
            'longitude': self.longitude,
            'latitude': self.latitude,
            'charging_points': self.charging_points,
            'charger_type': self.charger_type,
            'phone_number': self.phone_number,
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
