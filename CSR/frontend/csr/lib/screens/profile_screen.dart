import 'package:flutter/material.dart';
import 'package:csr/screens/reservation_screen.dart'; // Make sure the path matches your file structure

class ProfileScreenWidget extends StatelessWidget {
  final String username;
  final String email;

  const ProfileScreenWidget({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)]),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: ListView(
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
                  children: <Widget>[
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
                  username,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.list, color: Colors.blue),
            title: Text('View Reservations',
                style: TextStyle(color: Colors.blue.shade900)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationsScreen()),
              );
            },
          ),
          // Add more sections or options as needed
        ],
      ),
    );
  }
}
