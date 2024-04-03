import 'package:flutter/material.dart';
import 'package:csr/components/custom_my_charger_widget.dart';

class MyChargerScreenWidget extends StatelessWidget {
  MyChargerScreenWidget({super.key});

  final List<Charger> chargers = [
    Charger(location: "Aalborgvej 72, 9000 Aalborg", status: "In Use", costThisMonth: 20.50),
    Charger(
        location: "Hadsundvej 89, 9220 Aalborg", status: "Available", costThisMonth: 15.75),
  ];

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
          title: const Text('My Chargers')),
      body: ListView.builder(
        itemCount: chargers.length,
        itemBuilder: (context, index) {
          return MyChargerWidget(charger: chargers[index]);
        },
      ),
    );
  }
}