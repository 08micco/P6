// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:csr/models/charging_station.dart';
import 'package:csr/models/charging_point.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomChargingPointWidget extends StatefulWidget {
  final GeoPoint geoPoint;

  const CustomChargingPointWidget({super.key, required this.geoPoint});

  @override
  _CustomChargingPointWidgetState createState() =>
      _CustomChargingPointWidgetState();
}

class _CustomChargingPointWidgetState extends State<CustomChargingPointWidget> {
  Future<ChargingStation?> fetchChargingStationFromCoordinates() async {
    String long = widget.geoPoint.longitude.toString();
    String lat = widget.geoPoint.latitude.toString();
    String coordinates = "$lat;$long";

    final response = await http.get(Uri.parse(
        "http://127.0.0.1:5000/chargingStation/getFromCoordinates/$coordinates"));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] is List && jsonData['data'].isNotEmpty) {
        return ChargingStation.fromJson(jsonData['data'][0]);
      }
    } else {
      throw Exception("Failed to load ChargingStation");
    }
    return null;
  }

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

  Future<void> bookChargingPoint(int id) async {
    final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/reservation/new/$id"),
        body: jsonEncode(
            {"id": "541", "user_id": "1"} // Assuming API takes JSON body
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
    return FutureBuilder<ChargingStation?>(
      future: fetchChargingStationFromCoordinates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final station = snapshot.data;
          return FutureBuilder<List<ChargingPoint>?>(
            future: station != null
                ? fetchChargingPointsFromChargingStation(station.id)
                : Future.value(null),
            builder: (context, cpSnapshot) {
              if (cpSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (cpSnapshot.hasError) {
                return Text(
                    "Error loading charging points: ${cpSnapshot.error}");
              } else if (cpSnapshot.hasData && cpSnapshot.data!.isNotEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            title: Text(station?.companyName ??
                                'Unknown Charging Station'),
                            subtitle: Text(
                                station?.chargingStationType ?? 'Unknown Type'),
                            textColor: Colors.white,
                          ),
                          ...cpSnapshot.data!.map((cp) => ListTile(
                                title: Text("Charging Point ${cp.id}"),
                                subtitle: Text(
                                    "Reservation Status: ${cp.reservationStatus}"),
                                textColor: Colors.white,
                                trailing: ElevatedButton(
                                  onPressed: () => bookChargingPoint(cp.id),
                                  child: const Text("Book for 30 min"),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                );
              } else {
                return const Text("No charging points available.");
              }
            },
          );
        } else {
          return const Text("No data");
        }
      },
    );
  }
}
