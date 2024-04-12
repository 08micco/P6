import 'package:intl/intl.dart';

class Reservation {
  final int id;
  final int userId;
  final int chargingPointId;
  final DateTime reservationtime;

  const Reservation({
    required this.id,
    required this.userId,
    required this.chargingPointId,
    required this.reservationtime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      chargingPointId: json['charging_point_id'],
      reservationtime: _parseDateTime(json['reservation_time']),
    );
  }

  static DateTime _parseDateTime(String rawDate) {
    try {
      // Attempt ISO 8601 parsing
      return DateTime.parse(rawDate);
    } catch (_) {
      // Fallback for custom format with timezone
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(rawDate, true);
    }
  }

}