import 'package:flutter/material.dart';
import 'package:csr/components/custom_my_charger_widget.dart';
import 'package:csr/models/charging_station.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csr/screens/add_my_charger_screen.dart';


class MyChargerScreenWidget extends StatefulWidget {
  const MyChargerScreenWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyChargerScreenWidgetState createState() => _MyChargerScreenWidgetState();
}
class _MyChargerScreenWidgetState extends State<MyChargerScreenWidget> {
  Future<List<ChargingStation>> fetchHouseholdChargingStations() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:5000/getHouseholdChargingStations/1"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final List<dynamic> stationsJson = decodedResponse['data'] as List<dynamic>;
      return stationsJson.map((json) => ChargingStation.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load ChargingStations");
    }
  }

  void refreshStations() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyChargers'),
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
      body: FutureBuilder<List<ChargingStation>>(
        future: fetchHouseholdChargingStations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final chargingStations = snapshot.data!;
            return ListView.builder(
              itemCount: chargingStations.length,
              itemBuilder: (context, index) {
                return MyChargerWidget(chargingStation: chargingStations[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMyChargerPage()),
          );
          if (result == true) {
            refreshStations();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}