import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

// CustomMarkerWidget can be a StatelessWidget or StatefulWidget depending on your needs
class CustomMarkerWidget extends StatelessWidget {
  final int id;
  final String name;
  final String longitude;
  final String latitude;

  const CustomMarkerWidget({
    Key? key,
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here you can define how your custom marker looks
    return GestureDetector(
      onTap: () {
        // Define what happens when you tap on the marker
        print('Marker $id tapped');
        // You can also show a modal, navigate to another screen, etc.
      },
      child: Icon(Icons.location_pin, size: 48.0, color: Colors.red),
    );
  }
}
