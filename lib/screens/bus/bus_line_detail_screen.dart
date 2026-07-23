import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_payment_screen.dart';
import 'bus_lines_screen.dart';
import 'map_screen.dart';

import 'package:provider/provider.dart';

class BusLineDetailScreen extends StatelessWidget {
  final String letter;
  final String title;
  final String route;
  final Color color;
  final String frequency;
  final String firstBus;
  final String lastBus;
  final List<BusStopInfo> stops;

  const BusLineDetailScreen({
    super.key,
    this.letter = "A",
    this.title = "Ligne A",
    this.route = "Gare Centrale → Aéroport",
    this.color = const Color(0xFF0a1628),
    this.frequency = "8 min",
    this.firstBus = "06:00",
    this.lastBus = "22:00",
    this.stops = const [
      BusStopInfo("Gare Centrale", "06:00"),
      BusStopInfo("Place Audin", "06:08"),
      BusStopInfo("Khelifa Boukhalfa", "06:16"),
      BusStopInfo("1er Mai", "06:22"),
      BusStopInfo("Aéroport Houari Boumédiène", "06:30"),
    ],
  });

  static const blue = Color(0xFF075CE6);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          "Détails $title",
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_border_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _StatCard(label: "Fréquence", value: frequency),
                        const SizedBox(width: 10),
                        _StatCard(label: "Premier bus", value: firstBus),
                        const SizedBox(width: 10),
                        _StatCard(label: "Dernier bus", value: lastBus),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Arrêts",
                        style: TextStyle(
                          color: dark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...stops.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final stop = entry.value;

                        return _StopTile(
                          name: stop.name,
                          time: stop.time,
                          first: index == 0,
                          last: index == stops.length - 1,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapScreen(
                                letter: letter,
                                route: route,
                                color: color,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Voir sur la carte",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
    );
  }
}

class BusStopInfo {
  final String name;
  final String time;

  const BusStopInfo(this.name, this.time);
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BusLineDetailScreen.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BusLineDetailScreen.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final String name;
  final String time;
  final bool first;
  final bool last;

  const _StopTile({
    required this.name,
    required this.time,
    this.first = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!first)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: BusLineDetailScreen.blue.withOpacity(.35),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BusLineDetailScreen.blue,
                      width: 3,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: BusLineDetailScreen.blue.withOpacity(.35),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: BusLineDetailScreen.blue,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: BusLineDetailScreen.dark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "Heure de passage : $time",
                            style: const TextStyle(
                              color: BusLineDetailScreen.dark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Prochain bus estimé dans 3 min",
                            style: TextStyle(
                              color: BusLineDetailScreen.muted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text("Compris"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BusLineDetailScreen.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: BusLineDetailScreen.dark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: BusLineDetailScreen.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: BusLineDetailScreen.blue,
      unselectedItemColor: BusLineDetailScreen.muted,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget page = const HomeScreen();

        if (index == 1) page = const BusLinesScreen();
        if (index == 2) page = const QrPaymentScreen();
        if (index == 3) page = const NotificationsScreen();
        if (index == 4) page = const ProfileScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: "Accueil"),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_rounded), label: "Bus"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded), label: "QR"),
        BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded), label: "Abonnements"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: "Profil"),
      ],
    );
  }
}
