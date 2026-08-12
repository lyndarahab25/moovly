import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:geolocator/geolocator.dart';
import '../bus/map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_screen.dart';
import '../bus/bus_lines_screen.dart';
import '../wallet/wallet_screen.dart';
import '../ai/gold_required_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Design Tokens validés (Standards urbains premium: Citymapper / Uber)
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _primaryBlue = const Color(0xFF1953FF);
  final Color _surfaceWhite = Colors.white;
  final Color _textDark = const Color(0xFF0F172A);
  final Color _textMuted = const Color(0xFF64748B);
  final Color _successColor = const Color(0xFF16A34A);
  final Color _goldColor = const Color(0xFFD4AF37);
  final Color _borderColor = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: _getSelectedScreen(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Gestion rigoureuse de la navigation par index
  Widget _getSelectedScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const BusLinesScreen();
      case 2:
        return const QrScreen();
      case 3:
        return const WalletScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  // Contenu principal de l'accueil
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          _buildHeader(),
          const SizedBox(height: 24),

          // 2. CARTE PORTEFEUILLE
          _buildWalletCard(),
          const SizedBox(height: 28),

          // 3. MES SERVICES
          _buildSectionHeader("services"),
          const SizedBox(height: 14),
          _buildQuickServices(),
          const SizedBox(height: 28),

          // 4. SUIVI DES BUS (GRATUIT, STYLE CARTE DE MOBILITÉ)
          _buildSectionHeader("Bus à proximité"),
          const SizedBox(height: 14),
          _buildNearbyBusCard(),
          const SizedBox(height: 24),

          // 5. MOOVLY AI (COMPACT, PREMIUM GOLD)
          _buildMoovlyAiCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour, Lynda 👋",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: _primaryBlue),
                const SizedBox(width: 4),
                Text(
                  "Bouira, Algérie",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: _surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: _textDark, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
              ),
              Positioned(
                top: 11,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _successColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2855D9),
            Color(0xFF111A3D),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1953FF).withOpacity(0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Forme décorative 1
            Positioned(
              right: -55,
              top: -65,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5CFF).withOpacity(0.22),
                ),
              ),
            ),

            // Forme décorative 2
            Positioned(
              right: -20,
              bottom: -85,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Forme décorative 3
            Positioned(
              left: -70,
              bottom: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5CFF).withOpacity(0.12),
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP : Wallet + QR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Wallet",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      // QR
                      GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // SOLDE
                  Text(
                    "Solde disponible",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    "0 DZD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // RECHARGER
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _currentIndex = 3);
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        "Recharger",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.96),
                        foregroundColor: const Color(0xFF2855D9),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. SERVICES RAPIDES
  Widget _buildQuickServices() {
    final List<Map<String, dynamic>> services = [
      {
        "icon": Icons.directions_bus_rounded,
        "label": "Bus",
        "index": 1,
        "colors": [
          Color(0xFF3B82F6),
          Color(0xFF1746D2),
        ],
      },
      {
        "icon": Icons.qr_code_2_rounded,
        "label": "QR",
        "index": 2,
        "colors": [
          Color(0xFF35D6A0),
          Color(0xFF13A978),
        ],
      },
      {
        "icon": Icons.account_balance_wallet_rounded,
        "label": "Wallet",
        "index": 3,
        "colors": [
          Color(0xFF9B72FF),
          Color(0xFF6040D8),
        ],
      },
      {
        "icon": Icons.person_rounded,
        "label": "Profil",
        "index": 4,
        "colors": [
          Color(0xFF60A5FA),
          Color(0xFF2878E8),
        ],
      },
    ];

    return Row(
      children: services.map((service) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = service["index"] as int;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.fromLTRB(7, 9, 7, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: const Color(0xFFE4E9F2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône colorée
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: List<Color>.from(
                          service["colors"] as List,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (service["colors"] as List<Color>)[0]
                              .withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      service["icon"] as IconData,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Nom
                  Text(
                    service["label"] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. SUIVI DES BUS (CARTE DE MOBILITÉ ÉLÉGANTE ET GRATUITE)
  Widget _buildNearbyBusCard() {
    const bouira = LatLng(36.3749, 3.9020);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(),
          ),
        );
      },
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 🗺️ VRAIE CARTE
              Positioned.fill(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: bouira,
                    initialZoom: 14,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.moovly.app',
                    ),

                    // 🚌 BUS À PROXIMITÉ
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(36.3765, 3.9040),
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryBlue.withOpacity(0.35),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        Marker(
                          point: const LatLng(36.3728, 3.8995),
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        Marker(
                          point: const LatLng(36.3780, 3.8985),
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        // 📍 POSITION UTILISATEUR
                        Marker(
                          point: bouira,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🌫️ DÉGRADÉ EN BAS POUR LA LISIBILITÉ
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 95,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.96),
                      ],
                    ),
                  ),
                ),
              ),

              // 📍 INFOS
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _surfaceWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.near_me_rounded,
                        color: _primaryBlue,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bus à proximité",
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "3 bus détectés près de vous",
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _textDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Voir la carte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. MOOVLY AI — CARTE GOLD
  Widget _buildMoovlyAiCard() {
    return Container(
      width: double.infinity,
      height: 145,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1953FF),
            Color(0xFF111A3D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _goldColor.withOpacity(0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Petite touche lumineuse bleue
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE + GOLD
                Row(
                  children: [
                    const Text(
                      "Moovly AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _goldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "GOLD",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                const SizedBox(
                  width: 190,
                  child: Text(
                    "Votre assistant intelligent\nde mobilité",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // BOUTON GOLD
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoldRequiredScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      "Découvrir Gold",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VISUEL AI SIMPLE
          Positioned(
            right: 22,
            top: 27,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. BOTTOM NAVIGATION MODERNE
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Accueil"),
            _buildNavItem(1, Icons.directions_bus_filled_rounded, "Bus"),
            _buildQrNavItem(2, Icons.qr_code_rounded),
            _buildNavItem(3, Icons.account_balance_wallet_rounded, "Wallet"),
            _buildNavItem(4, Icons.person_rounded, "Profil"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? _primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryBlue : _textMuted,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQrNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _textDark,
        letterSpacing: -0.3,
      ),
    );
  }
}

// Peintre personnalisé discret pour simuler un fond de carte de transport urbain
class _MapGridPainter extends CustomPainter {
  final Color lineColor;

  _MapGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width,
      size.height * 0.4,
    );

    path.moveTo(size.width * 0.2, 0);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.7,
      size.width * 0.8,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
