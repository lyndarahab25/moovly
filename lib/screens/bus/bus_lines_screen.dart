import 'package:flutter/material.dart';
import 'bus_line_detail_screen.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  // ============================================================
  // MOOVLY THEME
  // ============================================================

  static const Color background = Color(0xFFF7F9FC);
  static const Color primaryBlue = Color(0xFF0057FF);
  static const Color darkText = Color(0xFF172033);
  static const Color mutedText = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);

  // ============================================================
  // SEARCH + FILTER
  // ============================================================

  final TextEditingController searchController = TextEditingController();

  int selectedFilter = 0;

  // ============================================================
  // BUS LINES
  // ============================================================

  final List<Map<String, dynamic>> lines = [
    {
      'name': '3',
      'from': 'Cité 1200 Logts',
      'to': 'Centre-ville',
      'start': 'Cité 1200 Logts',
      'end': 'Centre-ville',
      'crowd': 'Faible affluence',
      'crowdLevel': 0,
      'nextArrival': 'Prochain : 3 min',
      'next': '3 min',
      'stopsCount': 8,
      'busesCount': 3,
      'favorite': false,
    },
    {
      'name': '10',
      'from': 'Gare Routière',
      'to': 'Centre-ville',
      'start': 'Gare Routière',
      'end': 'Centre-ville',
      'crowd': 'Faible affluence',
      'crowdLevel': 0,
      'nextArrival': 'Prochain : 5 min',
      'next': '5 min',
      'stopsCount': 10,
      'busesCount': 4,
      'favorite': false,
    },
    {
      'name': '18',
      'from': 'Aïn Bessem',
      'to': 'Université',
      'start': 'Aïn Bessem',
      'end': 'Université',
      'crowd': 'Moyenne affluence',
      'crowdLevel': 1,
      'nextArrival': 'Prochain : 7 min',
      'next': '7 min',
      'stopsCount': 12,
      'busesCount': 3,
      'favorite': false,
    },
    {
      'name': '21',
      'from': "M'Chedallah",
      'to': 'Gare Ferroviaire',
      'start': "M'Chedallah",
      'end': 'Gare Ferroviaire',
      'crowd': 'Élevée affluence',
      'crowdLevel': 2,
      'nextArrival': 'Prochain : 4 min',
      'next': '4 min',
      'stopsCount': 9,
      'busesCount': 5,
      'favorite': false,
    },
    {
      'name': '22',
      'from': 'Bitam',
      'to': 'Centre-ville',
      'start': 'Bitam',
      'end': 'Centre-ville',
      'crowd': 'Faible affluence',
      'crowdLevel': 0,
      'nextArrival': 'Prochain : 8 min',
      'next': '8 min',
      'stopsCount': 11,
      'busesCount': 3,
      'favorite': false,
    },
    {
      'name': '23',
      'from': 'Haïzer',
      'to': 'Université',
      'start': 'Haïzer',
      'end': 'Université',
      'crowd': 'Moyenne affluence',
      'crowdLevel': 1,
      'nextArrival': 'Prochain : 6 min',
      'next': '6 min',
      'stopsCount': 10,
      'busesCount': 4,
      'favorite': false,
    },
    {
      'name': '24',
      'from': 'Boukram',
      'to': 'Gare Routière',
      'start': 'Boukram',
      'end': 'Gare Routière',
      'crowd': 'Faible affluence',
      'crowdLevel': 0,
      'nextArrival': 'Prochain : 9 min',
      'next': '9 min',
      'stopsCount': 7,
      'busesCount': 2,
      'favorite': false,
    },
  ];

  // ============================================================
  // FILTERED LINES
  // ============================================================

  List<Map<String, dynamic>> get filteredLines {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(lines);

    if (selectedFilter == 1) {
      result = result.where((line) => line['crowdLevel'] == 0).toList();
    } else if (selectedFilter == 2) {
      result = result.where((line) => line['crowdLevel'] == 1).toList();
    } else if (selectedFilter == 3) {
      result = result.where((line) => line['crowdLevel'] == 2).toList();
    }

    final query = searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((line) {
        final name = line['name'].toString().toLowerCase();
        final from = line['from'].toString().toLowerCase();
        final to = line['to'].toString().toLowerCase();

        return name.contains(query) ||
            from.contains(query) ||
            to.contains(query);
      }).toList();
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  110,
                ),
                child: Column(
                  children: [
                    _buildSearch(),

                    const SizedBox(height: 14),

                    _buildFilters(),

                    const SizedBox(height: 16),

                    // IMPORTANT :
                    // Pas de "Lignes disponibles"
                    // Pas de "7 lignes"
                    ...filteredLines.map(_buildLineCard),

                    if (filteredLines.isEmpty) _buildEmpty(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        4,
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _buildBackButton(),

            const Expanded(
              child: Center(
                child: Text(
                  'Lignes de bus',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),

            // Pour garder le titre parfaitement centré.
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _buildBackButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: darkText,
          size: 22,
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.018),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: darkText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8A99AE),
            size: 23,
          ),
          hintText: 'Rechercher une ligne',
          hintStyle: const TextStyle(
            color: Color(0xFF9AA7BA),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: mutedText,
                    size: 19,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    const filters = [
      'Toutes',
      'Faible affluence',
      'Moyenne',
      'Élevée',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final bool selected = selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? primaryBlue : border,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF718096),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUS LINE CARD
  // ============================================================

  Widget _buildLineCard(
    Map<String, dynamic> line,
  ) {
    final int crowdLevel = line['crowdLevel'] as int;

    final Color crowdColor = _crowdColor(crowdLevel);

    final Color crowdBackground = _crowdBackground(crowdLevel);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: primaryBlue.withOpacity(0.04),
          highlightColor: primaryBlue.withOpacity(0.02),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BusLineDetailScreen(
                  line: line,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                // ==================================================
                // LINE NUMBER
                // ==================================================

                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(13),
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
                    line['name'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ==================================================
                // ROUTE
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              line['from'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 12.8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF7B8BA1),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              line['to'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 12.8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // ==================================================
                      // CROWD BADGE
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
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
                              size: 11,
                              color: crowdColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              line['crowd'].toString(),
                              style: TextStyle(
                                color: crowdColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

// ==================================================
// ACTIONS : FAVORI + BUS + CHEVRON
// ==================================================

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ❤️ FAVORI
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          line['favorite'] = !(line['favorite'] ?? false);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: line['favorite'] == true
                              ? const Color(0xFFFFF1F2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          line['favorite'] == true
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: line['favorite'] == true
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF718096),
                          size: 19,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // 🚌 BUS
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.directions_bus_filled_rounded,
                        color: darkText,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 3),

// ==================================================
// CHEVRON
// ==================================================

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF718096),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CROWD COLORS
  // ============================================================

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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: Color(0xFF94A3B8),
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'Aucune ligne trouvée',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Essayez une autre recherche.',
            style: TextStyle(
              color: mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          12,
        ),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              selected: false,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _navItem(
              icon: Icons.directions_bus_rounded,
              label: 'Bus',
              selected: true,
              onTap: () {},
            ),

            // ==================================================
            // QR CENTER BUTTON
            // ==================================================

            GestureDetector(
              onTap: () {},
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),

            _navItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Wallet',
              selected: false,
              onTap: () {},
            ),

            _navItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAV ITEM
  // ============================================================

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7EEFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: selected ? primaryBlue : const Color(0xFF64748B),
          size: 23,
        ),
      ),
    );
  }
}
