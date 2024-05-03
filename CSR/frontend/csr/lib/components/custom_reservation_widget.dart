import 'package:flutter/material.dart';
import 'package:csr/models/reservation.dart'; // Adjust the import path to wherever your Reservation model is located.

class CustomReservationWidget extends StatelessWidget {
  final Reservation reservation;

  const CustomReservationWidget({
    super.key,
    required this.reservation,
  });

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
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Reservation ID: ${reservation.id}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('User ID: ${reservation.userId}'),
          const SizedBox(height: 4),
          Text('Charging Point ID: ${reservation.chargingPointId}'),
          const SizedBox(height: 4),
          Text('Reservation Time: ${reservation.reservationTime}'),
        ],
      ),
    );
  }
}
