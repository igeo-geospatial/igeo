import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({required this.initialPosition});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select...',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(
                context, _selectedPosition ?? widget.initialPosition),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: widget.initialPosition,
          zoom: 13,
          onTap: (tapPosition, latLng) {
            setState(() => _selectedPosition = latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.app',
          ),
          if (_selectedPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPosition!,
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
    );
  }
}
