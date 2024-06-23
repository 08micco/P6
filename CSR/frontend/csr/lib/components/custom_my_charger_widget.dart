// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:csr/models/charging_station.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyChargerWidget extends StatefulWidget {
  final ChargingStation chargingStation;

  const MyChargerWidget({super.key, required this.chargingStation});

  @override
  State<MyChargerWidget> createState() => _MyChargerWidgetState();
}

class _MyChargerWidgetState extends State<MyChargerWidget> {
  String? address;

  @override
  void initState() {
    super.initState();
    fetchAddress(widget.chargingStation.latitude, widget.chargingStation.longitude)
        .then((fetchedAddress) {
      if (fetchedAddress != null) {
        setState(() {
          address = fetchedAddress;
        });
      }
    });
  }

  Future<String?> fetchAddress(String latitude, String longitude) async {
    final uri = Uri.parse('http://127.0.0.1:5000/getAddress?lat=$latitude&lon=$longitude');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['address'];
      } else {
        print('Failed to load address');
      }
    } catch (e) {
      print('Caught error: $e');
    }
    return null;
  }

  String getChargingStationAvailability(bool available) {
    return available ? "Available" : "Not Available";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address ?? "Loading address...",
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.chargingStation.chargerType,
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Status: ${getChargingStationAvailability(widget.chargingStation.available)}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Phone: ${widget.chargingStation.phoneNumber}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
