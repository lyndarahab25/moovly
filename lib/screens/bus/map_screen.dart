import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String letter;
  final String route;
  final Color color;

  const MapScreen({
    super.key,
    this.letter = "A",
    this.route = "Gare Centrale → Aéroport",
    this.color = const Color(0xFF0a1628),
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionStream;

  LatLng _center = const LatLng(36.3749, 3.9020);
  LatLng? _userPosition;

  LatLng _busPosition = const LatLng(36.3749, 3.9020);

  @override
  void initState() {
    super.initState();
    _initLocationPermission();
    _startTrackingUser();
    _simulateBus();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // 🔥 important
    super.dispose();
  }

  // 📍 PERMISSION GPS
  Future<void> _initLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;
  }

  // 📍 TRACK USER
  void _startTrackingUser() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _userPosition = newPos;
        _center = newPos;
      });

      _mapController.move(newPos, 14);
    });
  }

  // 🚌 SIMULATION BUS
  void _simulateBus() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _busPosition = LatLng(
          _busPosition.latitude + 0.0005,
          _busPosition.longitude + 0.0005,
        );
      });

      _simulateBus();
    });
  }

  // 📌 MARKERS
  List<Marker> _markers() {
    return [
      // 🚌 BUS
      Marker(
        point: _busPosition,
        width: 50,
        height: 50,
        child: Icon(
          Icons.directions_bus,
          color: widget.color,
          size: 40,
        ),
      ),

      // 📍 USER
      if (_userPosition != null)
        Marker(
          point: _userPosition!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.red,
            size: 40,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus ${widget.letter}"),
        backgroundColor: widget.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_userPosition != null) {
                _mapController.move(_userPosition!, 15);
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: _markers()),
        ],
      ),
    );
  }
}
