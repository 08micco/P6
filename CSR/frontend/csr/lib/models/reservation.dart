import 'package:intl/intl.dart';

class Reservation {
  final int id;
  final int userId;
  final int chargingPointId;
  final int reservationTime;
  final DateTime reservationStartTime;
  final DateTime reservationEndTime;

  const Reservation({
    required this.id,
    required this.userId,
    required this.chargingPointId,
    required this.reservationTime,
    required this.reservationStartTime,
    required this.reservationEndTime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      chargingPointId: json['charging_point_id'],
      reservationTime: json['reservation_time'],
      reservationStartTime: _parseDateTime(json['reservation_start_time']),
      reservationEndTime: _parseDateTime(json['reservation_start_time']),
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