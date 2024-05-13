// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:csr/models/charging_station.dart';
import 'package:csr/screens/temp_reservation_screen.dart';

class MapScreenWidget extends StatefulWidget {
  const MapScreenWidget({super.key});

  @override
  _MapScreenWidgetState createState() => _MapScreenWidgetState();
}

class _MapScreenWidgetState extends State<MapScreenWidget> {
  final controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  final TextEditingController _searchController = TextEditingController();

  Future<void> searchAndNavigate(String query, BuildContext context) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a location to search."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    var url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    var response = await http.get(url,
        headers: {'User-Agent': 'CSR/0.1 (bertram.lorenzen93@gmail.com)'});

    if (response.statusCode == 200) {
      var results = jsonDecode(response.body);
      if (results.isNotEmpty) {
        var firstResult = results[0];
        double lat = double.parse(firstResult['lat']);
        double lon = double.parse(firstResult['lon']);
        controller.changeLocation(GeoPoint(latitude: lat, longitude: lon));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Location not found. Try a different location."),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to search locations."),
        backgroundColor: Colors.red,
      ));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search for charging stations",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.blue),
                onPressed: () =>
                    searchAndNavigate(_searchController.text, context),
              ),
            ],
          ),
        ),
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
                            markerIcon: const MarkerIcon(
                                icon: Icon(Icons.location_pin)));
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
                onGeoPointClicked: (geoPoint) async {
                  var station =
                      await fetchChargingStationFromCoordinates(geoPoint);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TempReservationScreen(chargingStation: station[0])),
                  );
                  /*
              showModalBottomSheet(
                backgroundColor: Colors.blue,
                context: context,
                //isScrollControlled: true,
                builder: (context) =>
                    CustomChargingPointWidget(geoPoint: geoPoint),
              );
              */
                },
                osmOption: OSMOption(
                  userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                          icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 48,
                      )),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(Icons.double_arrow, size: 48),
                      )),
                  roadConfiguration: const RoadOption(roadColor: Colors.black),
                  zoomOption: const ZoomOption(
                    initZoom: 14,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                )),

            /*Positioned(
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
            ),*/
          ],
        ));
  }
}
