import 'package:flutter/material.dart';
import 'bus_line_detail_screen.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF172033);
  static const Color mutedText = Color(0xFF718096);
  static const Color border = Color(0xFFE3EAF3);

  // ============================================================
  // SEARCH / FILTER
  // ============================================================

  final TextEditingController _searchController = TextEditingController();

  int _selectedFilter = 0;

  // ============================================================
  // BUS LINES
  // ============================================================

  final List<Map<String, dynamic>> _lines = [
    {
      'name': '3',
      'from': 'Cité 1200 Logts',
      'to': 'Centre-ville',
      'start': 'Cité 1200 Logts',
      'end': 'Centre-ville',
      'crowd': 'Faible affluence',
      'crowdLevel': 0,
      'nextArrival': 'Prochain bus : 3 min',
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
      'nextArrival': 'Prochain bus : 5 min',
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
      'nextArrival': 'Prochain bus : 7 min',
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
      'nextArrival': 'Prochain bus : 4 min',
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
      'nextArrival': 'Prochain bus : 8 min',
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
      'nextArrival': 'Prochain bus : 6 min',
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
      'nextArrival': 'Prochain bus : 9 min',
      'stopsCount': 7,
      'busesCount': 2,
      'favorite': false,
    },
  ];

  // ============================================================
  // FILTERED LINES
  // ============================================================

  List<Map<String, dynamic>> get _filteredLines {
    List<Map<String, dynamic>> result = List.from(_lines);

    if (_selectedFilter == 1) {
      result = result.where((line) => line['crowdLevel'] == 0).toList();
    }

    if (_selectedFilter == 2) {
      result = result.where((line) => line['crowdLevel'] == 1).toList();
    }

    if (_selectedFilter == 3) {
      result = result.where((line) => line['crowdLevel'] == 2).toList();
    }

    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((line) {
        return line['name'].toString().toLowerCase().contains(query) ||
            line['from'].toString().toLowerCase().contains(query) ||
            line['to'].toString().toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // IMPORTANT :
      // Aucun bottomNavigationBar ici.
      // Ta navigation principale existe déjà ailleurs.
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  24,
                ),
                child: Column(
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 10),
                    _buildFilters(),
                    const SizedBox(height: 12),
                    ..._filteredLines.map(
                      _buildLineCard,
                    ),
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
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 10),

          // Retour
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: border,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: darkText,
                size: 21,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Titre parfaitement centré
          const Expanded(
            child: Center(
              child: Text(
                'Lignes de bus',
                style: TextStyle(
                  color: darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          // Même largeur que le bouton gauche
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(
          color: darkText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          hintText: 'Rechercher une ligne',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: mutedText,
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
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final selected = _selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? primaryBlue : border,
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : mutedText,
                  fontSize: 9.5,
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
      height: 68,
      margin: const EdgeInsets.only(
        bottom: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
              horizontal: 8,
              vertical: 7,
            ),
            child: Row(
              children: [
                // --------------------------------------------
                // NUMERO DE LIGNE
                // --------------------------------------------

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    line['name'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                // --------------------------------------------
                // DEPART → ARRIVEE + AFFLUENCE
                // --------------------------------------------

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(
                                0xFF64748B,
                              ),
                              size: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              line['to'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: crowdBackground,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: crowdColor,
                              size: 8,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              line['crowd'].toString(),
                              style: TextStyle(
                                color: crowdColor,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                // --------------------------------------------
                // BUS
                // --------------------------------------------

                Container(
                  width: 49,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF4F7FB,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_bus_filled_rounded,
                    color: darkText,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 2),

                // --------------------------------------------
                // CHEVRON
                // --------------------------------------------

                const Icon(
                  Icons.chevron_right_rounded,
                  color: mutedText,
                  size: 19,
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
        return const Color(0xFFFFF5DF);
      case 2:
        return const Color(0xFFFFEAEA);
      default:
        return const Color(0xFFEAF8F0);
    }
  }
}
