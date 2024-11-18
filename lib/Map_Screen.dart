import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show CameraPosition, GoogleMap, GoogleMapController, LatLng, MapType;

class Map_Screen extends StatefulWidget {
  const Map_Screen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Map_Screen> {
  // Initial position for the map
  static const LatLng _initialPosition = LatLng(37.7749, -122.4194); // Example: San Francisco

  // Google Maps controller
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 12.0,
        ),
        mapType: MapType.normal,
      ),
    );
  }
}
