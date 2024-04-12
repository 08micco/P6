import 'package:flutter/material.dart';
import 'package:csr/models/reservation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csr/components/custom_reservation_widget.dart';

class ReservationsScreen extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<List<Reservation>> fetchReservations() async {
    String? userId = await _storage.read(key: "userId");
    if (userId != null) {
      final response = await http
          .get(Uri.parse("http://127.0.0.1:5000/reservation/get/$userId"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['data'];
        return responseData.map((data) => Reservation.fromJson(data)).toList();
      } else {
        throw Exception(
            "Failed to load reservations with status code: ${response.statusCode}");
      }
    }
    throw Exception("User ID is null");
  }

  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        foregroundColor: Colors.white,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: fetchReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final reservation = snapshot.data![index];
                return CustomReservationWidget(reservation: reservation);
              },
            );
          } else {
            return const Center(child: Text("No reservations found."));
          }
        },
      ),
    );
  }
}
