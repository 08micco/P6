import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReservationService {
  final String _baseUrl = 'http://127.0.0.1:5000';
  final _storage = const FlutterSecureStorage();

  Future<String> get _jwtToken async {
    return await _storage.read(key: "jwt_token") ?? '';
  }

  Future<List<dynamic>> getUserReservations() async {
    String token = await _jwtToken;
    if (token.isEmpty) {
      throw Exception('JWT Token is missing. User might not be logged in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user/reservations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 401:
        throw Exception(
            'Unauthorized. Please check if the JWT token is valid.');
      case 422:
        throw Exception(
            'Unprocessable Entity. The server understands the content type and syntax of the request but was unable to process the contained instructions.');
      default:
        throw Exception(
            'Failed to load reservations. Status code: ${response.statusCode}. Response body: ${response.body}');
    }
  }
}
