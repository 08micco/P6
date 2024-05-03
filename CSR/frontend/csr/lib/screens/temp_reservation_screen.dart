// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:csr/models/charging_station.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csr/models/charging_point.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TempReservationScreen extends StatefulWidget {
  final ChargingStation chargingStation;

  const TempReservationScreen({super.key, required this.chargingStation});

  @override
  // ignore: library_private_types_in_public_api
  _TempReservationScreenState createState() => _TempReservationScreenState();
}

class _TempReservationScreenState extends State<TempReservationScreen> {

  final _storage = const FlutterSecureStorage();

  Future<List<ChargingPoint>?> fetchChargingPointsFromChargingStation(
      int chargingStationId) async {
    final response = await http.get(Uri.parse(
        "http://127.0.0.1:5000/chargingPoint/getAll/$chargingStationId"));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] is List && jsonData['data'].isNotEmpty) {
        return List<ChargingPoint>.from(
            jsonData['data'].map((cp) => ChargingPoint.fromJson(cp)));
      }
    } else {
      throw Exception("Failed to load ChargingPoints");
    }
    return null;
  }

  Future<void> bookChargingPoint(int chargingPointId) async {
    String? userId = await _storage.read(key: "userId");
    final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/reservation/new/$chargingPointId"),
        body: jsonEncode(
            {"user_id": userId}
            ),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully booked for 30 minutes"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to book the charging point"),
        backgroundColor: Colors.red,
      ));
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chargingStation.title ?? 'Unknown Station'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)],
              stops: [0.5, 0.9],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
             widget.chargingStation.address,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ChargingPoint>?>(
              future: fetchChargingPointsFromChargingStation(widget.chargingStation.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final chargingPoints = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: chargingPoints.length,
                    itemBuilder: (context, index) {
                      final point = chargingPoints[index];
                      return ListTile(
                        title: Text('Point ID: ${point.id}'),
                        subtitle: Text('Status: ${point.reservationStatus}'),
                        trailing: ElevatedButton(
                          onPressed: () => bookChargingPoint(point.id),
                          child: const Text('Reserve'),
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('No charging points available.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
  