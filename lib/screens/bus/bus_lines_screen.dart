import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moovly/screens/subscriptions/subscriptions_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_payment_screen.dart';
import 'bus_line_detail_screen.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const sky = Color(0xFF2196F3);
  static const bg = Color(0xFFF0F6FF);
  static const muted = Color(0xFF6B7280);

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  String _selectedFilter = 'Toutes';
  String _searchText = '';

  final List<_BusLine> _lines = const [
    _BusLine(
      letter: 'A',
      title: 'Gare Centrale → Aéroport',
      subtitle: 'Toutes les 8 min',
      time: '06:00 - 22:00',
      color: Color(0xFF2196F3),
      darkColor: Color(0xFF0a1628),
      category: 'Populaires',
      nextBus: '3 min',
      price: '50 DA',
    ),
    _BusLine(
      letter: 'B',
      title: 'Université → Centre-ville',
      subtitle: 'Toutes les 10 min',
      time: '05:30 - 21:30',
      color: Color(0xFF1D9E75),
      darkColor: Color(0xFF085041),
      category: 'Populaires',
      nextBus: '7 min',
      price: '50 DA',
    ),
    _BusLine(
      letter: 'C',
      title: 'Port → Gare Routière',
      subtitle: 'Toutes les 12 min',
      time: '06:15 - 22:15',
      color: Color(0xFFFF7A1A),
      darkColor: Color(0xFF633806),
      category: 'Express',
      nextBus: '12 min',
      price: '75 DA',
    ),
    _BusLine(
      letter: 'D',
      title: 'Zone Industrielle → Centre',
      subtitle: 'Toutes les 15 min',
      time: '05:45 - 21:45',
      color: Color(0xFF6D4DE6),
      darkColor: Color(0xFF26215C),
      category: 'Express',
      nextBus: '15 min',
      price: '75 DA',
    ),
    _BusLine(
      letter: 'N1',
      title: 'Centre-ville → Aéroport',
      subtitle: 'Toutes les 30 min',
      time: '22:00 - 06:00',
      color: Color(0xFFE24B4A),
      darkColor: Color(0xFF501313),
      category: 'Nuit',
      nextBus: '25 min',
      price: '100 DA',
    ),
  ];

  List<_BusLine> get _filtered {
    return _lines.where((l) {
      final matchFilter =
          _selectedFilter == 'Toutes' || l.category == _selectedFilter;
      final q = _searchText.toLowerCase();
      final matchSearch = q.isEmpty ||
          l.letter.toLowerCase().contains(q) ||
          l.title.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  List<BusStopInfo> _stopsForLine(String letter) {
    switch (letter) {
      case 'A':
        return const [
          BusStopInfo('Gare Centrale', '06:00'),
          BusStopInfo('Place Audin', '06:08'),
          BusStopInfo('Khelifa Boukhalfa', '06:16'),
          BusStopInfo('1er Mai', '06:22'),
          BusStopInfo('Aéroport Houari Boumédiène', '06:30'),
        ];
      case 'B':
        return const [
          BusStopInfo('Université', '05:30'),
          BusStopInfo('Ben Aknoun', '05:40'),
          BusStopInfo('Didouche Mourad', '05:50'),
          BusStopInfo('Centre-ville', '06:00'),
        ];
      case 'C':
        return const [
          BusStopInfo('Port', '06:15'),
          BusStopInfo('El Biar', '06:27'),
          BusStopInfo('Place Audin', '06:38'),
          BusStopInfo('Gare Routière', '06:50'),
        ];
      case 'D':
        return const [
          BusStopInfo('Zone Industrielle', '05:45'),
          BusStopInfo('1er Mai', '05:58'),
          BusStopInfo('Didouche Mourad', '06:10'),
          BusStopInfo('Centre', '06:22'),
        ];
      default:
        return const [
          BusStopInfo('Centre-ville', '22:00'),
          BusStopInfo('Gare Centrale', '22:15'),
          BusStopInfo('Aéroport', '22:30'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: BusLinesScreen.bg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: BusLinesScreen.blue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0a1628), Color(0xFF185FA5)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: BusLinesScreen.sky,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.directions_bus,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text('Moovly',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text('Lignes de bus',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  // ── Stats ──────────────────────────────────────
                  Row(
                    children: [
                      _StatCard(
                        value: '${_lines.length}',
                        label: 'Lignes',
                        icon: Icons.route_rounded,
                        color: BusLinesScreen.sky,
                      ),
                      const SizedBox(width: 10),
                      const _StatCard(
                        value: '18',
                        label: 'Arrêts',
                        icon: Icons.location_on_rounded,
                        color: Color(0xFF1D9E75),
                      ),
                      const SizedBox(width: 10),
                      const _StatCard(
                        value: '24/7',
                        label: 'Service',
                        icon: Icons.access_time_rounded,
                        color: Color(0xFFFF7A1A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Search ──────────────────────────────────────
                  TextField(
                    onChanged: (v) => setState(() => _searchText = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une ligne ou un arrêt...',
                      hintStyle: const TextStyle(
                          color: BusLinesScreen.muted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: BusLinesScreen.muted, size: 20),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              onPressed: () => setState(() => _searchText = ''),
                              icon: const Icon(Icons.close_rounded, size: 18))
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDCE8F8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDCE8F8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: BusLinesScreen.sky, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Filtres ─────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Toutes', 'Populaires', 'Express', 'Nuit']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: f,
                                  active: _selectedFilter == f,
                                  onTap: () =>
                                      setState(() => _selectedFilter = f),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Liste ──────────────────────────────────────────────
          results.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: _EmptyState(),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _LineCard(
                          line: results[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BusLineDetailScreen(
                                letter: results[i].letter,
                                title: 'Ligne ${results[i].letter}',
                                route: results[i].title,
                                color: results[i].color,
                                frequency: results[i]
                                    .subtitle
                                    .replaceAll('Toutes les ', ''),
                                firstBus: results[i].time.split(' - ').first,
                                lastBus: results[i].time.split(' - ').last,
                                stops: _stopsForLine(results[i].letter),
                              ),
                            ),
                          ),
                        ),
                      ),
                      childCount: results.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
    );
  }
}

// ── Bus Line Model ─────────────────────────────────────────────────────────────

class _BusLine {
  final String letter;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final Color darkColor;
  final String category;
  final String nextBus;
  final String price;

  const _BusLine({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.darkColor,
    required this.category,
    required this.nextBus,
    required this.price,
  });
}

// ── Line Card avec illustration SVG ───────────────────────────────────────────

class _LineCard extends StatelessWidget {
  final _BusLine line;
  final VoidCallback onTap;

  const _LineCard({required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDCE8F8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Illustration SVG ───────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 130,
                child: _BusIllustration(line: line),
              ),
            ),

            // ── Info bas ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.title,
                              style: const TextStyle(
                                color: Color(0xFF0a1628),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.loop_rounded,
                                    size: 12, color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  line.subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: line.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          line.price,
                          style: TextStyle(
                            color: line.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 13, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        line.time,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: line.color),
                      const SizedBox(width: 4),
                      Text(
                        'Voir détails',
                        style: TextStyle(
                          color: line.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bus Illustration SVG ───────────────────────────────────────────────────────

class _BusIllustration extends StatelessWidget {
  final _BusLine line;

  const _BusIllustration({required this.line});

  @override
  Widget build(BuildContext context) {
    final c = line.color;
    final d = line.darkColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [d, c],
        ),
      ),
      child: Stack(
        children: [
          // Route en pointillés
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _DottedLinePainter(color: c),
              size: const Size(double.infinity, 2),
            ),
          ),

          // Arrêts (cercles)
          ...[0.15, 0.35, 0.55, 0.75].map(
            (x) => Positioned(
              bottom: 22,
              left: MediaQuery.of(context).size.width * x - 16,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),

          // Bus dessiné
          Positioned(
            right: 20,
            top: 10,
            child: CustomPaint(
              painter: _BusPainter(
                bodyColor: Colors.white,
                windowColor: c,
                wheelColor: d,
              ),
              size: const Size(140, 80),
            ),
          ),

          // Badge ligne
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ligne ${line.letter}',
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Badge catégorie
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                line.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Badge prochain bus
          Positioned(
            bottom: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: Color(0xFF1D9E75)),
                  const SizedBox(width: 4),
                  Text(
                    'Prochain : ${line.nextBus}',
                    style: const TextStyle(
                      color: Color(0xFF1D9E75),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bus Painter ────────────────────────────────────────────────────────────────

class _BusPainter extends CustomPainter {
  final Color bodyColor;
  final Color windowColor;
  final Color wheelColor;

  const _BusPainter({
    required this.bodyColor,
    required this.windowColor,
    required this.wheelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Corps du bus
    paint.color = bodyColor.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 10, size.width, size.height - 30),
        const Radius.circular(8),
      ),
      paint,
    );

    // Fenêtres
    paint.color = windowColor.withOpacity(0.8);
    final windows = [
      Rect.fromLTWH(8, 18, 22, 16),
      Rect.fromLTWH(35, 18, 22, 16),
      Rect.fromLTWH(62, 18, 22, 16),
      Rect.fromLTWH(89, 18, 22, 16),
      Rect.fromLTWH(116, 18, 18, 16),
    ];
    for (final w in windows) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(w, const Radius.circular(3)),
        paint,
      );
    }

    // Bande décorative
    paint.color = windowColor.withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, 38, size.width, 4),
      paint,
    );

    // Porte
    paint.color = windowColor.withOpacity(0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 30, 38, 22, 22),
        const Radius.circular(3),
      ),
      paint,
    );

    // Roues
    paint.color = wheelColor;
    canvas.drawCircle(Offset(22, size.height - 12), 12, paint);
    canvas.drawCircle(Offset(size.width - 22, size.height - 12), 12, paint);

    paint.color = bodyColor;
    canvas.drawCircle(Offset(22, size.height - 12), 5, paint);
    canvas.drawCircle(Offset(size.width - 22, size.height - 12), 5, paint);

    // Phare avant
    paint.color = Colors.yellow.withOpacity(0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 8, 20, 8, 10),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Dotted Line Painter ────────────────────────────────────────────────────────

class _DottedLinePainter extends CustomPainter {
  final Color color;
  const _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 8, 0), paint);
      x += 16;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDCE8F8)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? BusLinesScreen.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? BusLinesScreen.blue : const Color(0xFFDCE8F8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : BusLinesScreen.muted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE8F8)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF6B7280)),
          SizedBox(height: 12),
          Text(
            'Aucune ligne trouvée',
            style: TextStyle(
              color: Color(0xFF0a1628),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Essayez une autre recherche.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCE8F8), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: BusLinesScreen.blue,
        unselectedItemColor: BusLinesScreen.muted,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == currentIndex) return;
          Widget page = const HomeScreen();
          if (index == 1) page = const BusLinesScreen();
          if (index == 2) page = const QrPaymentScreen();
          if (index == 3) page = const SubscriptionsScreen();
          if (index == 4) page = const ProfileScreen();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => page,
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus_rounded),
              label: 'Bus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_outlined),
              activeIcon: Icon(Icons.qr_code_rounded),
              label: 'QR'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_rounded),
              activeIcon: Icon(Icons.credit_card_rounded),
              label: 'Abonnements'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
        ],
      ),
    );
  }
}
