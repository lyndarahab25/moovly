import 'package:flutter/material.dart';
import 'map_screen.dart'; // Assure-toi que le nom du fichier correspond

class BusLineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> line;

  const BusLineDetailScreen({
    super.key,
    required this.line,
  });

  @override
  State<BusLineDetailScreen> createState() => _BusLineDetailScreenState();
}

class _BusLineDetailScreenState extends State<BusLineDetailScreen> {
  // ============================================================
  // MOOVLY THEME
  // ============================================================
  static const Color background = Color(0xFFF7F9FC);
  static const Color primaryBlue = Color(0xFF0057FF);
  static const Color darkText = Color(0xFF172033);
  static const Color mutedText = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.line['favorite'] ?? false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String lineName = widget.line['name']?.toString() ?? '';
    final String from = widget.line['from']?.toString() ?? '';
    final String to = widget.line['to']?.toString() ?? '';
    final String crowd = widget.line['crowd']?.toString() ?? 'Faible affluence';
    final int crowdLevel = widget.line['crowdLevel'] ?? 0;

    final Color crowdColor = _crowdColor(crowdLevel);
    final Color crowdBackground = _crowdBackground(crowdLevel);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    _buildBackButton(),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Détails de la ligne',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                    ),
                    _buildFavoriteButton(),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // TOP INFO CARD (Line Badge + Route + Crowd)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Line Number Badge
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.18),
                                  blurRadius: 9,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lineName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        from,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 15,
                                        color: Color(0xFF7B8BA1),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        to,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: crowdBackground,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_alt_rounded,
                                        size: 12,
                                        color: crowdColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        crowd,
                                        style: TextStyle(
                                          color: crowdColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // STATS CARDS (Sans prix, 3 éléments centrés)
                    // ==========================================
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Fréquence',
                          value: '7-10 min',
                          icon: Icons.timer_outlined,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          title: 'Premier départ',
                          value: '06:30',
                          icon: Icons.wb_sunny_outlined,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          title: 'Dernier départ',
                          value: '22:30',
                          icon: Icons.nights_stay_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // SECTION TITRE ITINÉRAIRE
                    // ==========================================
                    const Text(
                      'Itinéraire de la ligne',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // CONTENEUR DE LA LISTE DES ARRÊTS
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 320,
                        child: _buildItineraryList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // BUTTON SUIVI EN TEMPS REEL (BOTTOM)
      // ============================================================
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: background,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0057FF),
                  Color(0xFF2855D9),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapScreen(line: widget.line),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              icon: const Icon(
                Icons.map_outlined,
                size: 20,
              ),
              label: const Text(
                'Voir sur la carte',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WIDGETS HELPERS
  // ============================================================

  Widget _buildBackButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back_rounded, color: darkText, size: 22),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            isFavorite = !isFavorite;
            widget.line['favorite'] = isFavorite;
          });
        },
        padding: EdgeInsets.zero,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.red : darkText,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: darkText,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryList() {
    final stops = [
      {'name': 'Aïn Bessem', 'time': '06:30'},
      {'name': 'Cité 1200 Logts', 'time': '06:36'},
      {'name': 'Gare Routière', 'time': '06:42'},
      {'name': 'Cité Administrative', 'time': '06:48'},
      {'name': 'Place de la Liberté', 'time': '06:54'},
      {'name': 'Université', 'time': '07:00'},
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (index != stops.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: primaryBlue.withOpacity(0.3),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  stops[index]['name']!,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                stops[index]['time']!,
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _crowdColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF16A34A);
    }
  }

  Color _crowdBackground(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFFF4DB);
      case 2:
        return const Color(0xFFFFE9E9);
      default:
        return const Color(0xFFEAF8F0);
    }
  }
}
