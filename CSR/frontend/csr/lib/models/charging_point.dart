class ChargingPoint {
  final int id;
  final String title;
  final String description;
  final int chargingStationId;
  final String reservationStatus;

  const ChargingPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.chargingStationId,
    required this.reservationStatus,
  });

  factory ChargingPoint.fromJson(Map<String, dynamic> json) {
    return ChargingPoint(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      chargingStationId: json['charging_station_id'],
      reservationStatus: json['reservation_status'],
    );
  }
}