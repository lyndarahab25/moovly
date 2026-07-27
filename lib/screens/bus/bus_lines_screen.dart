import 'package:flutter/material.dart';
import 'package:moovly/screens/bus/bus_line_detail_screen.dart';
import 'package:moovly/screens/home/home_screen.dart';
import 'package:moovly/screens/notifications/notifications_screen.dart';
import 'package:moovly/screens/profile/profile_screen.dart';
import 'package:moovly/screens/qr/qr_payment_screen.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'Toutes';
  final List<String> _filters = ['Toutes', 'Populaires', 'Express', 'Nuit'];
  int _currentIndex = 1; // 1 = Bus

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Palette officielle Bleu / Mauve de l'application
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _accentMauve = const Color(0xFF7C3AED);

  final List<Map<String, dynamic>> _busLines = [
    {
      'letter': 'A',
      'title': 'Ligne A',
      'route': 'Gare Centrale → Aéroport',
      'gradient': const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      'frequency': 'Toutes les 8 min',
      'firstBus': '06:00',
      'lastBus': '22:00',
      'hours': '06:00 - 22:00',
      'next': '3 min',
      'tag': 'Populaires',
      'price': '50 DA',
      'stops': const [
        BusStopInfo("Gare Centrale", "06:00"),
        BusStopInfo("Place Audin", "06:08"),
        BusStopInfo("Aéroport", "06:30"),
      ],
    },
    {
      'letter': 'B',
      'title': 'Ligne B',
      'route': 'Université → Pôle Urbain',
      'gradient': const [Color(0xFF7C3AED), Color(0xFF9333EA)],
      'frequency': 'Toutes les 12 min',
      'firstBus': '06:30',
      'lastBus': '21:00',
      'hours': '06:30 - 21:00',
      'next': '7 min',
      'tag': 'Express',
      'price': '40 DA',
      'stops': const [
        BusStopInfo("Université", "06:30"),
        BusStopInfo("Centre Ville", "06:45"),
        BusStopInfo("Pôle Urbain", "07:00"),
      ],
    },
    {
      'letter': 'C',
      'title': 'Ligne C',
      'route': 'Centre-ville → Zone Industrielle',
      'gradient': const [Color(0xFF4338CA), Color(0xFF6366F1)],
      'frequency': 'Toutes les 15 min',
      'firstBus': '05:30',
      'lastBus': '23:00',
      'hours': '05:30 - 23:00',
      'next': '12 min',
      'tag': 'Nuit',
      'price': '60 DA',
      'stops': const [
        BusStopInfo("Centre-ville", "05:30"),
        BusStopInfo("Gare Routière", "05:50"),
        BusStopInfo("Zone Industrielle", "06:15"),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const QrPaymentScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    } else if (index == 4) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLines = _selectedFilter == 'Toutes'
        ? _busLines
        : _busLines.where((l) => l['tag'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER HAUT DE GAMME AVEC VRAI LOGO & STATS ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue, _accentMauve],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Vrai Logo professionnel Moovly
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.directions_bus_rounded,
                                    color: _primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Moovly",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3 Cartes de statistiques épurées et modernes
                  Row(
                    children: [
                      _buildHeaderStat("5", "Lignes", Icons.alt_route_rounded),
                      const SizedBox(width: 10),
                      _buildHeaderStat(
                          "18", "Arrêts", Icons.location_on_rounded),
                      const SizedBox(width: 10),
                      _buildHeaderStat(
                          "24/7", "Service", Icons.schedule_rounded),
                    ],
                  ),
                ],
              ),
            ),

            // Barre de recherche & Filtres
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher une ligne ou un arrêt...",
                        hintStyle:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Color(0xFF94A3B8), size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedFilter = filter);
                            _animController.reset();
                            _animController.forward();
                          },
                          selectedColor: _primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? _primaryBlue
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- CARTES DE BUS AVEC VISUEL HAUT DE GAMME ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.separated(
                    itemCount: filteredLines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final line = filteredLines[index];
                      final List<Color> gradientColors =
                          line['gradient'] ?? [_primaryBlue, _accentMauve];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Column(
                            children: [
                              // En-tête de carte bicolore avec illustration bus stylisée
                              Container(
                                height: 110,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                line['title'] ?? '',
                                                style: TextStyle(
                                                  color: gradientColors[0],
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                line['tag'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.schedule_rounded,
                                                      size: 13,
                                                      color: gradientColors[0]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Prochain : ${line['next']}",
                                                    style: TextStyle(
                                                      color: gradientColors[0],
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: List.generate(
                                                    4,
                                                    (_) => Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.6),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Icône bus de haute qualité en arrière-plan
                                    Positioned(
                                      right: 5,
                                      bottom: 0,
                                      child: Icon(
                                        Icons.directions_bus_filled_rounded,
                                        size: 55,
                                        color: Colors.white.withOpacity(0.18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Corps de la carte
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            line['route'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            line['price'] ?? '',
                                            style: TextStyle(
                                              color: gradientColors[0],
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.refresh_rounded,
                                            size: 14, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 4),
                                        Text(
                                          line['frequency'] ?? '',
                                          style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 14),
                                        const Icon(Icons.access_time_rounded,
                                            size: 14, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 4),
                                        Text(
                                          line['hours'] ?? '',
                                          style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(
                                          color: Color(0xFFF1F5F9), height: 1),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BusLineDetailScreen(
                                                letter: line['letter'] ?? '',
                                                title: line['title'] ?? '',
                                                route: line['route'] ?? '',
                                                color: gradientColors[0],
                                                frequency:
                                                    line['frequency'] ?? '',
                                                firstBus:
                                                    line['firstBus'] ?? '',
                                                lastBus: line['lastBus'] ?? '',
                                                stops:
                                                    line['stops'] ?? const [],
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: gradientColors),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Voir détails",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_rounded,
                                                  size: 14,
                                                  color: Colors.white),
                                            ],
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
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- NAVBAR HAUT DE GAMME AVEC ICÔNES RAFFINÉES ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, Icons.home_rounded, "Accueil"),
                _buildBottomNavItem(
                    1, Icons.directions_bus_filled_rounded, "Bus"),
                _buildBottomNavItem(2, Icons.qr_code_scanner_rounded, "QR"),
                _buildBottomNavItem(
                    3, Icons.credit_card_rounded, "Abonnements"),
                _buildBottomNavItem(4, Icons.person_rounded, "Profil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onNavTap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
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
              color: isSelected ? _primaryBlue : const Color(0xFF94A3B8),
              size: 22,
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
}
