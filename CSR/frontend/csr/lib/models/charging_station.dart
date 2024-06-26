class ChargingStation {
  final int id;
  final int? ownerId;
  final String? companyName;
  final String? title;
  final String chargingStationType;
  final String address;
  final String longitude;
  final String latitude;
  final int chargingPoints;
  final String chargerType;
  final bool available;
  final String? phoneNumber;

  const ChargingStation({
    required this.id,
    required this.ownerId,
    required this.companyName,
    required this.title,
    required this.chargingStationType,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.chargingPoints,
    required this.chargerType,
    required this.available,
    required this.phoneNumber,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      id: json['id'],
      ownerId: json['owner_id'],
      companyName: json['company_name'],
      title: json['title'],
      chargingStationType: json['charging_station_type'],
      address: json['address'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      chargingPoints: json['charging_points'],
      chargerType: json['charger_type'],
      available: json['available'],
      phoneNumber: json['phone_number'],
    );
  }
}