import 'package:flutter/material.dart';

class Charger {
  final String location;
  final String status;
  final double costThisMonth;

  Charger({required this.location, required this.status, required this.costThisMonth});
}

class MyChargerWidget extends StatelessWidget {
  final Charger charger;

  const MyChargerWidget({super.key, required this.charger});

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
            charger.location,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Status: ${charger.status}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Cost this month: ${charger.costThisMonth.toStringAsFixed(2)} dkk',
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}