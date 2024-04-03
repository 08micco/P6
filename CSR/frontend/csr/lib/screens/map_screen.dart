import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreenWidget extends StatelessWidget {
  final controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  MapScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMFlutter(
          onMapIsReady: (isReady) async {
            if (isReady) {
              await controller.addMarker(
                GeoPoint(
                    latitude: 57.00409300743616, longitude: 9.871225612595508),
                markerIcon: const MarkerIcon(
                  icon: Icon(Icons.location_pin),
                ),
              );
            }
          },
          controller: controller,
          mapIsLoading: const Center(
            child: SizedBox(
              width:
                  50,
              height:
                  50,
              child:
                  CircularProgressIndicator(),
            ),
          ),

          onGeoPointClicked: (geoPoint) {
            showModalBottomSheet(
              backgroundColor: Colors.blue,
              context: context,
              builder: (context) {
                return Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            child: const Text(
                              'Charging Station Tesla Skalborg',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          osmOption: OSMOption(
              userTrackingOption: const UserTrackingOption(
                enableTracking: true,
                unFollowUser: false,
              ),
              zoomOption: const ZoomOption(
                initZoom: 14,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
              userLocationMarker: UserLocationMaker(
                personMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.personal_injury,
                    color: Colors.red,
                    size: 68,
                  ),
                ),
                directionArrowMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              ),
              markerOption: MarkerOption(
                  defaultMarker: const MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.black,
                  size: 48,
                ),
              )))),
    );
  }
}