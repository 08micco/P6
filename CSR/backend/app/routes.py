from flask import request, jsonify
from datetime import datetime
from CSR.backend.app.models import User, ChargingStation, ChargingPoint, Reservation
from .extensions import db


def configure_routes(app):

    @app.route('/user/<int:user_id>')
    def get_user(user_id):
        user = User.query.get(user_id)  # Fetch the user instance by its ID
        if user:
            return jsonify(user.serialize()), 200  # Correctly call serialize on the instance
        else:
            return jsonify({"error": "User not found"}), 404


    @app.route('/getChargingStations', methods=['GET'])
    def get_charging_stations():
        try:
            charging_stations = ChargingStation.query.all()
            return jsonify([charging_station.to_json() for charging_station in charging_stations]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/getAvailableChargingStations', methods=['GET'])
    def get_available_charging_stations():
        try:
            charging_stations = ChargingStation.query.filter_by(available=True).all()
            return jsonify([charging_station.to_json() for charging_station in charging_stations]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/getReservedChargingStations', methods=['GET'])
    def get_reserved_charging_stations():
        try:
            charging_stations = ChargingStation.query.filter_by(available=False).all()
            return jsonify([charging_station.to_json() for charging_station in charging_stations]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingStation/get/<string:charging_station_id>', methods=['GET'])
    def get_charging_station_from_charging_station_id(charging_station_id):
        try:
            charging_stations = ChargingStation.query.filter_by(id=charging_station_id).all()
            return jsonify([charging_station.to_json() for charging_station in charging_stations]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500
    
    @app.route('/chargingPoint/getAll/<string:charging_station_id>', methods=['GET'])
    def get_all_charging_points_from_charging_station_id(charging_station_id):
        try:
            charging_points = ChargingPoint.query.filter_by(charging_station_id=charging_station_id)
            return jsonify([charging_point.to_json() for charging_point in charging_points]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingPoint/get/<string:charging_point_id>', methods=['GET'])
    def get_charging_point_from_charging_point_id(charging_point_id):
        try:
            charging_point = ChargingPoint.query.filter_by(id=charging_point_id)
            return jsonify([charging_point.to_json() for charging_point in charging_point]), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingStation/add', methods=['POST'])
    def add_charging_station():
        try:
            data = request.get_json()
            if not data:
                return jsonify({"error": "Bad request", "message": "No data provided"}), 400

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
            return jsonify(charging_station.to_json()), 201
        except KeyError as e:
            return jsonify({"error": "Bad request", "message": f"Missing field: {e}"}), 400
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingPoint/add/<string:charging_station_id>', methods=['POST'])
    def add_charging_point_from_charging_station_id(charging_station_id):
        try:
            data = request.get_json()
            if not data:
                return jsonify({"error": "Bad request", "message": "No data provided"}), 400

            charging_point = ChargingPoint(
                id=data["id"],
                charging_station_id=charging_station_id,
                reservation_status="available",
            )

            db.session.add(charging_point)
            db.session.commit()
            return jsonify(charging_point.to_json()), 201
        except KeyError as e:
            return jsonify({"error": "Bad request", "message": f"Missing field: {e}"}), 400
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingStation/delete/<string:charging_station_id>', methods=['DELETE'])
    def delete_charging_station_from_charging_station_id(charging_station_id):
        try:
            ChargingStation.query.filter_by(id=charging_station_id).delete()
            db.session.commit()
            return jsonify({"Success": True, "message": "Successfully deleted charging station with id " + charging_station_id, "status_code": "200"}), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/chargingPoint/delete/<string:charging_point_id>', methods=['DELETE'])
    def delete_charging_point_from_charging_point_id(charging_point_id):
        try:
            ChargingPoint.query.filter_by(id=charging_point_id).delete()
            db.session.commit()
            return jsonify({"Success": True, "message": "Successfully deleted charging point with id " + charging_point_id, "status_code": "200"}), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500

    @app.route('/reservation/new/<string:charging_point_id>', methods=['POST'])
    def new_reservation_from_charging_point_id(charging_point_id):
        try:
            data = request.get_json()
            if not data:
                return jsonify({"error": "Bad request", "message": "No data provided"}), 400
            
            reservation = Reservation(
                id=data["id"],
                user_id=data["user_id"],
                charging_point_id=charging_point_id,
                reservation_time=datetime.now(),
            )

            db.session.add(reservation)
            db.session.commit()
            return jsonify(reservation.to_json()), 201
        except KeyError as e:
            return jsonify({"error": "Bad request", "message": f"Missing field: {e}"}), 400
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500
    
    @app.route('/reservation/change/<string:reservation_id>', methods=['PUT'])
    def change_reservation_from_reservation_id(reservation_id):
        pass

    @app.route('/reservation/delete/<string:reservation_id>', methods=['DELETE'])
    def delete_reservation_from_reservation_id(reservation_id):
        try:
            Reservation.query.filter_by(id=reservation_id).delete()
            db.session.commit()
            return jsonify({"Success": True, "message": "Successfully deleted reservation with id " + reservation_id, "status_code": "200"}), 200
        except Exception as e:
            return jsonify({"error": "Internal server error", "message": str(e)}), 500
        

    
        
    
