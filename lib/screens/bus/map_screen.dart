import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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

  // ============================================================
  // MOOVLY COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF111827);
  static const Color mutedText = Color(0xFF64748B);

  // ============================================================
  // POSITION DEMO UTILISATEUR — BOUIRA
  // ============================================================

  static const LatLng _userLocation = LatLng(
    36.374900,
    3.902000,
  );

  static const double _nearbyRadius = 3000;

  // ============================================================
  // CENTRE CARTE
  // ============================================================

  static const LatLng _defaultCenter = LatLng(
    36.374900,
    3.902000,
  );

  // ============================================================
  // OUTILS
  // ============================================================

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.replaceAll(',', '.'),
      );
    }

    return null;
  }

  String get _lineName {
    return widget.line?['name']?.toString() ?? 'Ligne';
  }

  String get _lineId {
    return widget.line?['id']?.toString() ?? '';
  }

  String get _departure {
    return widget.line?['from']?.toString() ?? '';
  }

  String get _destination {
    return widget.line?['to']?.toString() ?? '';
  }

  String _busNumber(Map<String, dynamic> data) {
    return (data['num_bus'] ?? data['matricule'] ?? data['id_bus'] ?? 'Bus')
        .toString();
  }

  bool _isBusActive(Map<String, dynamic> data) {
    final dynamic rawStatus = data['statu'] ?? data['Statu'] ?? data['status'];

    if (rawStatus == null) {
      return true;
    }

    final status = rawStatus.toString().trim().toLowerCase();

    if (status.isEmpty) {
      return true;
    }

    const inactiveStatuses = [
      'hors ligne',
      'offline',
      'inactif',
      'inactive',
      'arrêté',
      'arrete',
      'off',
      'false',
    ];

    return !inactiveStatuses.contains(status);
  }

  bool _isBusNearby(
    double latitude,
    double longitude,
  ) {
    final distance = Geolocator.distanceBetween(
      _userLocation.latitude,
      _userLocation.longitude,
      latitude,
      longitude,
    );

    return distance <= _nearbyRadius;
  }

  // ============================================================
  // VÉRIFICATION DE LA LIGNE
  // ============================================================

  bool _belongsToSelectedLine(
    Map<String, dynamic> busData,
  ) {
    final dynamic reference =
        busData['Id_ligne'] ?? busData['id_ligne'] ?? busData['ligne'];

    if (reference == null) {
      return false;
    }

    // DocumentReference Firestore
    if (reference is DocumentReference) {
      return reference.path == 'ligne/$_lineId';
    }

    // Si Firebase contient directement l'ID
    if (reference is String) {
      return reference == _lineId || reference == _lineName;
    }

    return false;
  }

  // ============================================================
  // TRAJET DEMO
  // ============================================================

  List<LatLng> _buildRoutePoints() {
    final String lineNumber = _lineNumberOnly;

    switch (lineNumber) {
      case '2':
        return const [
          LatLng(36.3718, 3.8888),
          LatLng(36.3730, 3.8930),
          LatLng(36.3740, 3.8970),
          LatLng(36.3749, 3.9020),
          LatLng(36.3765, 3.9070),
          LatLng(36.3785, 3.9120),
          LatLng(36.3810, 3.9170),
        ];

      case '4':
        return const [
          LatLng(36.3655, 3.8920),
          LatLng(36.3690, 3.8960),
          LatLng(36.3720, 3.8990),
          LatLng(36.3749, 3.9020),
          LatLng(36.3780, 3.9050),
          LatLng(36.3820, 3.9090),
          LatLng(36.3860, 3.9130),
        ];

      case '5':
        return const [
          LatLng(36.3810, 3.8870),
          LatLng(36.3790, 3.8910),
          LatLng(36.3770, 3.8950),
          LatLng(36.3749, 3.9020),
          LatLng(36.3720, 3.9070),
          LatLng(36.3690, 3.9120),
          LatLng(36.3660, 3.9170),
        ];

      case '6':
        return const [
          LatLng(36.3650, 3.9070),
          LatLng(36.3680, 3.9050),
          LatLng(36.3710, 3.9035),
          LatLng(36.3749, 3.9020),
          LatLng(36.3790, 3.9000),
          LatLng(36.3830, 3.8980),
          LatLng(36.3870, 3.8960),
        ];

      default:
        return const [
          LatLng(36.3690, 3.8950),
          LatLng(36.3710, 3.8980),
          LatLng(36.3749, 3.9020),
          LatLng(36.3780, 3.9060),
          LatLng(36.3810, 3.9100),
        ];
    }
  }

  String get _lineNumberOnly {
    final match = RegExp(r'\d+').firstMatch(_lineName);

    return match?.group(0) ?? _lineName;
  }

  // ============================================================
  // ARRÊTS DEMO
  // ============================================================

  List<Map<String, dynamic>> _buildStops() {
    final route = _buildRoutePoints();

    final List<String> names = [
      _departure.isNotEmpty ? _departure : 'Aïn Bessem',
      'Cité 1200 Logts',
      'Gare Routière',
      'Cité Administrative',
      'Place de la Liberté',
      'Université',
      _destination.isNotEmpty ? _destination : 'Université',
    ];

    final int count = route.length < names.length ? route.length : names.length;

    return List.generate(
      count,
      (index) => {
        'name': names[index],
        'point': route[index],
      },
    );
  }

  // ============================================================
  // MARQUEUR UTILISATEUR
  // ============================================================

  Marker _buildUserMarker() {
    return Marker(
      point: _userLocation,
      width: 58,
      height: 58,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryBlue,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.30),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.navigation_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MARQUEUR ARRÊT
  // ============================================================

  Marker _buildStopMarker(
    Map<String, dynamic> stop,
  ) {
    return Marker(
      point: stop['point'] as LatLng,
      width: 34,
      height: 34,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.circle,
            color: primaryBlue,
            size: 9,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MARQUEUR BUS
  // ============================================================

  Marker _buildBusMarker({
    required double latitude,
    required double longitude,
    required Map<String, dynamic> data,
  }) {
    final busNumber = _busNumber(data);

    return Marker(
      point: LatLng(
        latitude,
        longitude,
      ),
      width: 52,
      height: 52,
      child: GestureDetector(
        onTap: () {
          _showBusDetails(data);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryBlue,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DÉTAIL BUS
  // ============================================================

  Future<void> _showBusDetails(
    Map<String, dynamic> busData,
  ) async {
    String? lineName;
    String? departure;
    String? destination;

    final dynamic lineReference = busData['Id_ligne'];

    if (lineReference is DocumentReference) {
      try {
        final snapshot = await lineReference.get();

        final rawData = snapshot.data();

        if (rawData is Map) {
          final lineData = Map<String, dynamic>.from(rawData);

          lineName = lineData['nom']?.toString();

          departure = lineData['depart']?.toString();

          destination = lineData['destination']?.toString();
        }
      } catch (_) {}
    }

    if (!mounted) return;

    final busNumber = _busNumber(busData);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              26,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bus $busNumber',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xFF22C55E),
                                size: 9,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'En ligne',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _infoRow(
                  Icons.route_rounded,
                  'Ligne',
                  lineName ?? _lineName,
                ),
                if (departure != null && destination != null)
                  _infoRow(
                    Icons.swap_horiz_rounded,
                    'Trajet',
                    '$departure → $destination',
                  ),
                _infoRow(
                  Icons.location_on_outlined,
                  'Suivi',
                  'Position simulée pour la démonstration',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final routePoints = _buildRoutePoints();
    final stops = _buildStops();

    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // MAP
          // ======================================================

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('bus').snapshots(),
            builder: (context, snapshot) {
              final List<Marker> busMarkers = [];

              if (snapshot.hasData) {
                for (final document in snapshot.data!.docs) {
                  final data = document.data();

                  final latitude = _toDouble(
                    data['latitude'],
                  );

                  final longitude = _toDouble(
                    data['longitude'],
                  );

                  if (latitude == null || longitude == null) {
                    continue;
                  }

                  if (!_isBusActive(data)) {
                    continue;
                  }

                  if (!_belongsToSelectedLine(
                    data,
                  )) {
                    continue;
                  }

                  if (!_isBusNearby(
                    latitude,
                    longitude,
                  )) {
                    continue;
                  }

                  busMarkers.add(
                    _buildBusMarker(
                      latitude: latitude,
                      longitude: longitude,
                      data: data,
                    ),
                  );
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: 15.8,
                  minZoom: 13,
                  maxZoom: 19,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.moovly.app',
                  ),

                  // ==================================================
                  // TRAJET
                  // ==================================================

                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 6,
                        color: primaryBlue,
                        borderStrokeWidth: 2,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),

                  // ==================================================
                  // ARRÊTS
                  // ==================================================

                  MarkerLayer(
                    markers: [
                      ...stops.map(
                        _buildStopMarker,
                      ),
                    ],
                  ),

                  // ==================================================
                  // BUS + UTILISATEUR
                  // ==================================================

                  MarkerLayer(
                    markers: [
                      ...busMarkers,
                      _buildUserMarker(),
                    ],
                  ),
                ],
              );
            },
          ),

          // ======================================================
          // HEADER FLOTTANT
          // ======================================================

          Positioned(
            top: 48,
            left: 18,
            right: 18,
            child: Row(
              children: [
                _mapButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _lineNumberOnly,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lineName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Suivi de la ligne',
                                style: const TextStyle(
                                  color: mutedText,
                                  fontSize: 10,
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
              ],
            ),
          ),

          // ======================================================
          // INFORMATIONS BAS
          // ======================================================

          Positioned(
            left: 18,
            right: 18,
            bottom: 28,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('bus').snapshots(),
              builder: (context, snapshot) {
                int nearbyCount = 0;

                if (snapshot.hasData) {
                  for (final document in snapshot.data!.docs) {
                    final data = document.data();

                    final latitude = _toDouble(
                      data['latitude'],
                    );

                    final longitude = _toDouble(
                      data['longitude'],
                    );

                    if (latitude == null || longitude == null) {
                      continue;
                    }

                    if (!_isBusActive(data)) {
                      continue;
                    }

                    if (!_belongsToSelectedLine(
                      data,
                    )) {
                      continue;
                    }

                    if (_isBusNearby(
                      latitude,
                      longitude,
                    )) {
                      nearbyCount++;
                    }
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            17,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.12,
                              ),
                              blurRadius: 12,
                              offset: const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEFF6FF,
                                ),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: primaryBlue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$nearbyCount bus${nearbyCount > 1 ? 's' : ''} à proximité',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  const Text(
                                    'Position simulée',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: mutedText,
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
                    const SizedBox(
                      width: 10,
                    ),
                    _mapButton(
                      icon: Icons.my_location_rounded,
                      onPressed: () {
                        _mapController.move(
                          _userLocation,
                          15.8,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOUTON FLOTTANT
  // ============================================================

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(
            icon,
            color: const Color(0xFF1D4ED8),
            size: 23,
          ),
        ),
      ),
    );
  }
}
