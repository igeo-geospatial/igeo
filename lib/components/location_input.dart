import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/map_screen.dart';
import '../models/point.dart';

class LocationInput extends StatefulWidget {
  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final MapController _mapController = MapController();
  final Point _point = Point(); // Initialize here instead of widget

  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      await _handleLocationPermission();
      final position = await Geolocator.getCurrentPosition();
      _updatePosition(position.latitude, position.longitude);
      print("****************************** " + position.latitude.toString());
    } catch (e) {
      //_showErrorDialog(e.toString());
    }
  }

  Future<void> _selectOnMap() async {
    try {
      await _handleLocationPermission();
      final position = await Geolocator.getCurrentPosition();
      final initialPosition = LatLng(position.latitude, position.longitude);

      final selectedPosition = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (ctx) => MapScreen(initialPosition: initialPosition),
          fullscreenDialog: true,
        ),
      );

      if (selectedPosition != null) {
        _updatePosition(selectedPosition.latitude, selectedPosition.longitude);
      }
    } catch (e) {
      //_showErrorDialog(e.toString());
    }
  }

  void _updatePosition(double lat, double long) {
    final pointProvider = Provider.of<PointProvider>(context, listen: false);
    pointProvider.updateCoordinates(lat, long);

    setState(() {
      _point.changeCoordinates(lat, long);
      _mapController.move(LatLng(lat, long), 13);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointProvider = Provider.of<PointProvider>(context);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            color: Colors.black12,
          ),
          child: pointProvider.lat == null || pointProvider.long == null
              ? const Center(child: Text('No location added'))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(pointProvider.lat!, pointProvider.long!),
                    zoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point:
                              LatLng(pointProvider.lat!, pointProvider.long!),
                          builder: (ctx) => const Icon(
                            Icons.location_pin,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _getCurrentUserLocation,
              icon:
                  const Icon(Icons.location_on, size: 16, color: Colors.amber),
              label: const Text("Get location",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map, size: 16, color: Colors.amber),
              label: const Text("Select on map",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          ],
        ),
      ],
    );
  }
}

class PointProvider with ChangeNotifier {
  Point _point = Point();

  double? get lat => _point.lat;
  double? get long => _point.long;

  void updateCoordinates(double latitude, double longitude) {
    _point.changeCoordinates(latitude, longitude);
    notifyListeners();
  }
}
