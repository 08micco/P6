from flask import request
from sqlalchemy import and_
from datetime import datetime
from CSR.backend.app.models import User, ChargingStation, ChargingPoint, Reservation
from flask_jwt_extended import jwt_required, get_jwt_identity
from .models import Reservation, User
from .extensions import db
from .utils import ApiResponse


def configure_routes(app):

    @app.route('/user/reservations', methods=['GET'])
    @jwt_required()
    def get_user_reservations():
        current_user_id = get_jwt_identity() 
        reservations = Reservation.query.filter_by(user_id=current_user_id).all()
        return jsonify([reservation.to_json() for reservation in reservations]), 200


    @app.route('/user/<int:user_id>')
    def get_user(user_id):
        user = User.query.get(user_id)  
        if user:
            return jsonify(user.serialize()), 200 
        else:
            return jsonify({"error": "User not found"}), 404


    @app.route('/getChargingStations', methods=['GET'])
    def get_charging_stations():
        try:
            charging_stations = ChargingStation.query.all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))
        
    @app.route('/getHouseholdChargingStations/<string:user_id>', methods=['GET'])
    def get_household_charging_stations(user_id):
        try:
            charging_stations = ChargingStation.query.filter_by(owner_id=user_id, charging_station_type="Household").all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))


    @app.route('/getAvailableChargingStations', methods=['GET'])
    def get_available_charging_stations():
        try:
            charging_stations = ChargingStation.query.filter_by(available=True).all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/getReservedChargingStations', methods=['GET'])
    def get_reserved_charging_stations():
        try:
            charging_stations = ChargingStation.query.filter_by(available=False).all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingStation/get/<string:charging_station_id>', methods=['GET'])
    def get_charging_station_from_charging_station_id(charging_station_id):
        try:
            charging_stations = ChargingStation.query.filter_by(id=charging_station_id).all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))
        
    @app.route('/chargingStation/getFromCoordinates/<string:coordinates>')
    def get_charging_station_from_coordinates(coordinates):
        try:
            lat, long  = coordinates.split(';')
            charging_stations = ChargingStation.query.filter_by(latitude=lat, longitude=long).all()
            return ApiResponse.success([charging_station.to_json() for charging_station in charging_stations])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))
    
    @app.route('/chargingPoint/getAll/<string:charging_station_id>', methods=['GET'])
    def get_all_charging_points_from_charging_station_id(charging_station_id):
        try:
            charging_points = ChargingPoint.query.filter_by(charging_station_id=charging_station_id)
            return ApiResponse.success([charging_point.to_json() for charging_point in charging_points])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingPoint/get/<string:charging_point_id>', methods=['GET'])
    def get_charging_point_from_charging_point_id(charging_point_id):
        try:
            charging_point = ChargingPoint.query.filter_by(id=charging_point_id)
            return ApiResponse.success([charging_point.to_json() for charging_point in charging_point])
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingStation/add', methods=['POST'])
    def add_charging_station():
        try:
            data = request.get_json()
            if not data:
                return ApiResponse.bad_request("No data provided")

            charging_station = ChargingStation(
                company_name=data["company_name"],
                owner_id=data["owner_id"],
                charging_station_type=data["charging_station_type"],
                longitude=data["longitude"],
                latitude=data["latitude"],
                charging_points=data["charging_points"],
                charger_type=data["charger_type"],
                phone_number=data["phone_number"],
                available=data["available"],
            )
            
            db.session.add(charging_station)
            db.session.commit()
            return ApiResponse.created(charging_station.to_json())
        except KeyError as e:
            return ApiResponse.bad_request(f"Missing field: {e}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingPoint/add/<string:charging_station_id>', methods=['POST'])
    def add_charging_point_from_charging_station_id(charging_station_id):
        try:
            data = request.get_json()
            if not data:
                return ApiResponse.bad_request("No data provided")

            charging_point = ChargingPoint(
                id=data["id"],
                charging_station_id=charging_station_id,
                reservation_status="available",
            )

            db.session.add(charging_point)
            db.session.commit()
            return ApiResponse.created(charging_point.to_json())
        except KeyError as e:
            return ApiResponse.bad_request(f"Missing field: {e}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingStation/delete/<string:charging_station_id>', methods=['DELETE'])
    def delete_charging_station_from_charging_station_id(charging_station_id):
        try:
            ChargingStation.query.filter_by(id=charging_station_id).delete()
            db.session.commit()
            return ApiResponse.success(f"Successfully deleted charging station with id {charging_station_id}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/chargingPoint/delete/<string:charging_point_id>', methods=['DELETE'])
    def delete_charging_point_from_charging_point_id(charging_point_id):
        try:
            ChargingPoint.query.filter_by(id=charging_point_id).delete()
            db.session.commit()
            return ApiResponse.success(f"Successfully deleted charging point with id {charging_point_id}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))

    @app.route('/reservation/new/<string:charging_point_id>', methods=['POST'])
    def new_reservation_from_charging_point_id(charging_point_id):
        try:
            data = request.get_json()
            if not data:
                return ApiResponse.bad_request("No data provided")
            
            reservation = Reservation(
                id=data["id"],
                user_id=data["user_id"],
                charging_point_id=charging_point_id,
                reservation_time=datetime.now(),
            )

            db.session.add(reservation)
            db.session.commit()
            return ApiResponse.created(reservation.to_json())
        except KeyError as e:
            return ApiResponse.bad_request(f"Missing field: {e}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))
    
    @app.route('/reservation/change/<string:reservation_id>', methods=['PUT'])
    def change_reservation_from_reservation_id(reservation_id):
        pass

    @app.route('/reservation/delete/<string:reservation_id>', methods=['DELETE'])
    def delete_reservation_from_reservation_id(reservation_id):
        try:
            Reservation.query.filter_by(id=reservation_id).delete()
            db.session.commit()
            return ApiResponse.success("Successfully deleted reservation with id {reservation_id}")
        except Exception as e:
            return ApiResponse.internal_server_error(str(e))