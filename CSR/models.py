from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    reservations = db.relationship('Reservation', backref='user', lazy=True)

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
    charging_points = db.relationship('ChargingPoint', backref='corporate_station', lazy=True)

class HouseholdChargingStation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    longitude = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.String(120), nullable=False)
    charging_points = db.Column(db.Integer, nullable=False)
    charger_type = db.Column(db.String(50), nullable=False)
    phone_number = db.Column(db.String(20), nullable=False)
    charging_points = db.relationship('ChargingPoint', backref='household_station', lazy=True)

class ChargingPoint(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    corporate_station_id = db.Column(db.Integer, db.ForeignKey('corporate_charging_station.id'), nullable=True)
    household_station_id = db.Column(db.Integer, db.ForeignKey('household_charging_station.id'), nullable=True)
    reservation_status = db.Column(db.String(50), nullable=False)
    reservations = db.relationship('Reservation', backref='charging_point', lazy=True)


class Reservation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    charging_point_id = db.Column(db.Integer, db.ForeignKey('charging_point.id'), nullable=False)
    reservation_time = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)



