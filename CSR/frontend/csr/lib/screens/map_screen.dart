import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:csr/models/charging_station.dart';
import 'package:csr/components/custom_charging_point_widget.dart';

class MapScreenWidget extends StatelessWidget {
  final controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  MapScreenWidget({super.key});

  Future<List<ChargingStation>> fetchAllChargingStations() async {
    final response =
        await http.get(Uri.parse("http://127.0.0.1:5000/getChargingStations"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final List<dynamic> stationsJson =
          decodedResponse['data'] as List<dynamic>;
      return stationsJson
          .map((json) => ChargingStation.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load ChargingStations");
    }
  }

  Future<List<ChargingStation>> fetchChargingStationFromCoordinates(
      GeoPoint geoPoint) async {
    String long = geoPoint.longitude.toString();
    String lat = geoPoint.latitude.toString();
    String coordinates = "$lat;$long";

    final response = await http.get(Uri.parse(
        "http://127.0.0.1:5000/chargingStation/getFromCoordinates/$coordinates"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final List<dynamic> stationsJson = decodedResponse['data'];

      return stationsJson
          .map((json) => ChargingStation.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load ChargingStations");
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        OSMFlutter(
            onMapIsReady: (isReady) async {
              if (isReady) {
                fetchAllChargingStations().then((stations) {
                  for (var station in stations) {
                    controller.addMarker(
                        GeoPoint(
                            latitude: double.parse(station.latitude),
                            longitude: double.parse(station.longitude)),
                        markerIcon:
                            const MarkerIcon(icon: Icon(Icons.location_pin)));
                  }
                }).catchError((error) {
                  throw Exception("Failed to fetch stations: $error");
                });
              }
            },
            controller: controller,
            mapIsLoading: const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            ),
            onGeoPointClicked: (geoPoint) {
              showModalBottomSheet(
                backgroundColor: Colors.blue,
                context: context,
                builder: (context) =>
                    CustomChargingPointWidget(geoPoint: geoPoint),
              );
            },
            osmOption: const OSMOption(
              zoomOption: ZoomOption(
                initZoom: 14,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
            )),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.05, // Height from top
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search for charging stations",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.blue),
              ),
              onSubmitted: (value) {
                // handle search
              },
            ),
          ),
        ),
      ],
    ));
  }
}
