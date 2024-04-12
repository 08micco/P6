class ChargingPoint {
  final int id;
  final int chargingStationId;
  final String reservationStatus;

  const ChargingPoint({
    required this.id,
    required this.chargingStationId,
    required this.reservationStatus,
  });

  factory ChargingPoint.fromJson(Map<String, dynamic> json) {
    return ChargingPoint(
      id: json['id'],
      chargingStationId: json['charging_station_id'],
      reservationStatus: json['reservation_status'],
    );
  }
}