import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // FAVORITES
  // ============================================================

  final Map<String, bool> favorites = {};

  // ============================================================
  // FIRESTORE
  // ============================================================

  final CollectionReference<Map<String, dynamic>> linesCollection =
      FirebaseFirestore.instance.collection('ligne');

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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: linesCollection.snapshots(),
                builder: (context, snapshot) {
                  // ==================================================
                  // LOADING
                  // ==================================================

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    );
                  }

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Erreur de chargement',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ==================================================
                  // NO DATA
                  // ==================================================

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            0,
                          ),
                          child: _buildSearch(),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: _buildFilters(),
                        ),
                        Expanded(
                          child: _buildNoLines(),
                        ),
                      ],
                    );
                  }

                  // ==================================================
                  // FIRESTORE DATA
                  // ==================================================

                  final List<Map<String, dynamic>> lines =
                      snapshot.data!.docs.map((doc) {
                    final Map<String, dynamic> data = doc.data();

                    // ------------------------------------------------
                    // NOM / NUMÉRO
                    // ------------------------------------------------

                    final String name = data['nom']?.toString() ?? doc.id;

                    // ------------------------------------------------
                    // DÉPART
                    // ------------------------------------------------

                    final String from =
                        data['depart']?.toString() ?? 'Départ inconnu';

                    // ------------------------------------------------
                    // ARRIVÉE
                    // ------------------------------------------------

                    final String to =
                        data['destination']?.toString() ?? 'Arrivée inconnue';

                    // ------------------------------------------------
                    // FRÉQUENCE
                    // ------------------------------------------------

                    final String frequency =
                        data['statu']?.toString() ?? 'Faible';

                    final int frequencyLevel = _getFrequencyLevel(frequency);

                    // ------------------------------------------------
                    // FAVORI
                    // ------------------------------------------------

                    favorites.putIfAbsent(
                      doc.id,
                      () => false,
                    );

                    return {
                      'id': doc.id,
                      'name': name,
                      'from': from,
                      'to': to,
                      'distance': data['distance'],
                      'duree': data['duree'],
                      'nb_arrets': data['nb_arrets'],
                      'nb_bus': data['nb_bus'],
                      'status': frequency,
                      'frequency': frequency,
                      'favorite': favorites[doc.id] ?? false,
                      'frequencyText': _getFrequencyText(frequencyLevel),
                      'frequencyLevel': frequencyLevel,
                    };
                  }).toList();

                  // ==================================================
                  // FILTER
                  // ==================================================

                  List<Map<String, dynamic>> filteredLines =
                      List<Map<String, dynamic>>.from(lines);

                  // Fréquence élevée
                  if (selectedFilter == 1) {
                    filteredLines = filteredLines
                        .where(
                          (line) => line['frequencyLevel'] == 2,
                        )
                        .toList();
                  }

                  // Fréquence moyenne
                  else if (selectedFilter == 2) {
                    filteredLines = filteredLines
                        .where(
                          (line) => line['frequencyLevel'] == 1,
                        )
                        .toList();
                  }

                  // Fréquence faible
                  else if (selectedFilter == 3) {
                    filteredLines = filteredLines
                        .where(
                          (line) => line['frequencyLevel'] == 0,
                        )
                        .toList();
                  }

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  final String query =
                      searchController.text.trim().toLowerCase();

                  if (query.isNotEmpty) {
                    filteredLines = filteredLines.where((line) {
                      final String name = line['name'].toString().toLowerCase();

                      final String from = line['from'].toString().toLowerCase();

                      final String to = line['to'].toString().toLowerCase();

                      return name.contains(query) ||
                          from.contains(query) ||
                          to.contains(query);
                    }).toList();
                  }

                  // ==================================================
                  // CONTENT
                  // ==================================================

                  return SingleChildScrollView(
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
                        ...filteredLines.map(
                          _buildLineCard,
                        ),
                        if (filteredLines.isEmpty) _buildEmpty(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FREQUENCY LEVEL
  // ============================================================

  int _getFrequencyLevel(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a');

    if (normalized.contains('eleve') ||
        normalized.contains('high') ||
        normalized.contains('forte')) {
      return 2;
    }

    if (normalized.contains('moyenne') ||
        normalized.contains('moyen') ||
        normalized.contains('medium')) {
      return 1;
    }

    return 0;
  }

  // ============================================================
  // FREQUENCY TEXT
  // ============================================================

  String _getFrequencyText(int level) {
    switch (level) {
      case 2:
        return ' élevée';

      case 1:
        return ' moyenne';

      default:
        return ' faible';
    }
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
    const List<String> filters = [
      'Toutes',
      'Fréquence élevée',
      'Fréquence moyenne',
      'Fréquence faible',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(
            width: 8,
          );
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
              duration: const Duration(
                milliseconds: 180,
              ),
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
                          color: primaryBlue.withOpacity(
                            0.18,
                          ),
                          blurRadius: 10,
                          offset: const Offset(
                            0,
                            4,
                          ),
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
    final int frequencyLevel = line['frequencyLevel'] as int;

    final Color frequencyColor = _frequencyColor(frequencyLevel);

    final Color frequencyBackground = _frequencyBackground(frequencyLevel);

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
                    _formatLineNumber(
                      line['name'].toString(),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
                      // FREQUENCY
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: frequencyBackground,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: frequencyColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              line['frequencyText'].toString(),
                              style: TextStyle(
                                color: frequencyColor,
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
                // ACTIONS
                // ==================================================

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FAVORI
                    GestureDetector(
                      onTap: () {
                        final String id = line['id'].toString();

                        setState(() {
                          favorites[id] = !(favorites[id] ?? false);

                          line['favorite'] = favorites[id];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
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

                    // BUS
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
  // FORMAT LINE NUMBER
  // ============================================================

  String _formatLineNumber(String name) {
    final RegExpMatch? match = RegExp(r'\d+').firstMatch(name);

    if (match != null) {
      return match.group(0)!;
    }

    return name;
  }

  // ============================================================
  // FREQUENCY COLORS
  // ============================================================

  Color _frequencyColor(int level) {
    switch (level) {
      case 2:
        return const Color(0xFF16A34A); // Vert
      case 1:
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFFEF4444); // Rouge
    }
  }

  Color _frequencyBackground(int level) {
    switch (level) {
      case 2:
        return const Color(0xFFEAF8F0);
      case 1:
        return const Color(0xFFFFF4DB);
      default:
        return const Color(0xFFFFE9E9);
    }
  }

  // ============================================================
  // EMPTY SEARCH
  // ============================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
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
  // NO LINES IN FIRESTORE
  // ============================================================

  Widget _buildNoLines() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              color: Color(0xFF94A3B8),
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucune ligne disponible',
              style: TextStyle(
                color: darkText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ajoutez des lignes dans Firestore.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
