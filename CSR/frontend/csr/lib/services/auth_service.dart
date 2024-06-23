// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://127.0.0.1:5000';
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String? token = responseData['access_token'];
        final String userId = responseData['user_id'].toString();

        if (token != null) {
          await _storage.write(key: 'jwtToken', value: token);
          await _storage.write(key: 'userId', value: userId);
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  Future<bool> isUserLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Registration failed: ${response.body}");
      return false;
    }
  }
}
