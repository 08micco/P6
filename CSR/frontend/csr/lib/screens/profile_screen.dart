import 'package:flutter/material.dart';
import 'package:csr/screens/reservation_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csr/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreenWidget extends StatelessWidget {
  const ProfileScreenWidget({super.key});

  final _storage = const FlutterSecureStorage();

  Future<User?> fetchUser() async {
    String? userId = await _storage.read(key: "userId");
    if (userId != null) {
      final response = await http.get(Uri.parse("http://127.0.0.1:5000/user/$userId"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        return User.fromJson(decodedResponse['data']);
      }
    }
    throw Exception("Failed to load User");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(future: fetchUser(), builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return ListView(
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.5, 0.9],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:  <Widget>[
                          ClipOval(
                            child: Image.network(
                              'https://www.tesla.com/ownersmanual/images/GUID-A016FC6C-5896-4495-9DD8-2B074869A838-online-en-US.png',
                              width: 200.0,
                              height: 125.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.list, color: Colors.blue),
                  title: Text('View Reservations',
                      style: TextStyle(color: Colors.blue.shade900)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReservationsScreen()),
                    );
                  },
                ),
              ],
            );
          } else {
          return const Center(child: Text("No user data found."));
        }
      }))
    );
  }
}
