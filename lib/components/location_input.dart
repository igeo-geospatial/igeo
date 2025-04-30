import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../screens/map_screen.dart';
import '../models/point.dart';

class LocationInput extends StatefulWidget {
  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  late final MapController _mapController = MapController();
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
      await _checkConnectivityAndGPS();
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
      await _checkConnectivityAndGPS();
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

  void _showManualInputDialog() {
    final latController = TextEditingController();
    final longController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Coordinates'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: 'Latitude (ex.: -23.2)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  final cleaned = value.replaceAll(',', '.');
                  final lat = double.tryParse(cleaned);
                  if (lat == null) return 'Invalid number';
                  if (lat < -90 || lat > 90) return 'Between -90 and 90';
                  return null;
                },
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: longController,
                decoration: InputDecoration(
                  labelText: 'Longitude (ex.: -44.2)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  final cleaned = value.replaceAll(',', '.');
                  final long = double.tryParse(cleaned);
                  if (long == null) return 'Invalid number';
                  if (long < -180 || long > 180) return 'Between -180 and 180';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final lat =
                    double.parse(latController.text.replaceAll(',', '.'));
                final long =
                    double.parse(longController.text.replaceAll(',', '.'));
                final pointProvider =
                    Provider.of<PointProvider>(context, listen: false);
                pointProvider.updateCoordinates(lat, long);

                setState(() {});

                setState(() {
                  _point.changeCoordinates(lat, long);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkConnectivityAndGPS() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

      if (connectivityResult == ConnectivityResult.none) {
        throw 'No internet connection';
      }

      if (!isLocationEnabled) {
        throw 'Location services are disabled';
      }
    } catch (e) {
      _showNetworkErrorDialog(e.toString());
      throw e; // Re-throw to prevent further execution
    }
  }

  void _showNetworkErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connection Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error),
            const SizedBox(height: 10),
            const Text('Would you like to:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showManualInputDialog();
            },
            child: const Text('Enter Manually'),
          ),
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Enable GPS'),
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
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _getCurrentUserLocation,
                  icon: const Icon(Icons.location_on,
                      size: 16, color: Colors.amber),
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
            TextButton.icon(
              onPressed: _showManualInputDialog,
              icon: const Icon(Icons.edit, size: 16, color: Colors.amber),
              label: const Text("Enter coords. manually",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          ],
        )
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
