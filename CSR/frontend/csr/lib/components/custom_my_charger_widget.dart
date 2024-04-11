import 'package:flutter/material.dart';
import 'package:csr/models/charging_station.dart';


class MyChargerWidget extends StatelessWidget {
  final ChargingStation chargingStation;

  const MyChargerWidget({super.key, required this.chargingStation});

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
            'Location: ${chargingStation.latitude} : ${chargingStation.longitude}',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Status: ${chargingStation.available}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Phone: ${chargingStation.phoneNumber}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}