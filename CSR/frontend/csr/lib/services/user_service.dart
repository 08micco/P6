// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  static const String _baseUrl = 'http://127.0.0.1:5000/user/';

  static Future<Map<String, dynamic>?> fetchUserData(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load user data');
      return null;
    }
  }
}
