import 'package:flutter/material.dart';

class ReservationsScreen extends StatelessWidget {
  // Dummy list for illustration. Replace with actual data fetching logic.
  final List<String> reservations =
      List.generate(5, (index) => "Reservation ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reservations[index]),
            // Additional reservation details can be added here.
          );
        },
      ),
    );
  }
}
