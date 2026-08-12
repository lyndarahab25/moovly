import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? line;

  const MapScreen({
    super.key,
    this.line,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  // ============================================================
  // BOUIRA ROUTE
  // ============================================================

  final List<LatLng> _routePoints = const [
    LatLng(36.3835, 3.8962),
    LatLng(36.3801, 3.8978),
    LatLng(36.3765, 3.9002),
    LatLng(36.3749, 3.9020),
    LatLng(36.3720, 3.9045),
    LatLng(36.3685, 3.9078),
  ];

  static const LatLng _defaultCenter = LatLng(36.3749, 3.9020);

  // ============================================================
  // DATA
  // ============================================================

  String get lineName {
    return widget.line?['name']?.toString() ?? '—';
  }

  String get from {
    return widget.line?['from']?.toString() ?? 'Départ';
  }

  String get to {
    return widget.line?['to']?.toString() ?? 'Arrivée';
  }

  int get busesCount {
    final value = widget.line?['busesCount'];

    if (value is int) {
      return value;
    }

    return 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // MAP
          // ======================================================

          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.moovly',
              ),

              // ==================================================
              // ROUTE
              // ==================================================

              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6,
                    color: primaryBlue,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

              // ==================================================
              // BUS
              // ==================================================

              MarkerLayer(
                markers: [
                  Marker(
                    point: _defaultCenter,
                    width: 54,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lineName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // BACK BUTTON
          // ======================================================

          Positioned(
            top: 50,
            left: 20,
            child: _mapButton(
              icon: Icons.arrow_back_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          // ======================================================
          // LINE INFO
          // ======================================================

          Positioned(
            top: 50,
            left: 78,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      lineName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ligne $lineName',
                          style: const TextStyle(
                            color: dark,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$from → $to',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // BUS COUNT
          // ======================================================

          Positioned(
            left: 20,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_bus_rounded,
                    color: primaryBlue,
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$busesCount bus${busesCount > 1 ? 's' : ''} en ligne',
                    style: const TextStyle(
                      color: dark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // RECENTER
          // ======================================================

          Positioned(
            right: 20,
            bottom: 40,
            child: FloatingActionButton(
              heroTag: 'recenter_map',
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              elevation: 4,
              onPressed: () {
                _mapController.move(
                  _defaultCenter,
                  14,
                );
              },
              child: const Icon(
                Icons.my_location_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAP BUTTON
  // ============================================================

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: dark,
            size: 21,
          ),
        ),
      ),
    );
  }
}
