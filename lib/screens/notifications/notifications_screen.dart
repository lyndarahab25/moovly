import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bus/bus_lines_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_payment_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const blue = Color(0xFF0a1628);
  static const sky = Color(0xFF2196F3);
  static const bg = Color(0xFFF0F6FF);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF1D9E75);
  static const orange = Color(0xFFFF8A00);
  static const purple = Color(0xFF6D4DE6);
  static const red = Color(0xFFE24B4A);

  String _selectedTab = 'Toutes';

  final List<_Notif> _notifications = [
    _Notif(
      id: '1',
      icon: Icons.warning_rounded,
      title: 'Retard sur la ligne A',
      subtitle: 'Retard de 10 min sur la ligne A à 08:20',
      time: 'Maintenant',
      color: red,
      category: 'Alertes',
      unread: true,
    ),
    _Notif(
      id: '2',
      icon: Icons.directions_bus_rounded,
      title: 'Nouveau : Plus de bus',
      subtitle: 'Plus de bus disponibles sur la ligne 12 à 07:30',
      time: 'Il y a 1h',
      color: sky,
      category: 'Infos',
      unread: true,
    ),
    _Notif(
      id: '3',
      icon: Icons.check_circle_rounded,
      title: 'Paiement réussi',
      subtitle: 'Votre paiement de 50 DA a été effectué avec succès',
      time: 'Il y a 2h',
      color: green,
      category: 'Infos',
      unread: false,
    ),
    _Notif(
      id: '4',
      icon: Icons.build_rounded,
      title: 'Maintenance prévue',
      subtitle: 'Maintenance le 15/07 de 00:00 à 04:00 sur la ligne C',
      time: 'Hier',
      color: purple,
      category: 'Alertes',
      unread: false,
    ),
    _Notif(
      id: '5',
      icon: Icons.local_offer_rounded,
      title: 'Offre spéciale Premium',
      subtitle: 'Profitez d\'une réduction sur votre prochain abonnement',
      time: 'Hier',
      color: orange,
      category: 'Offres',
      unread: false,
    ),
    _Notif(
      id: '6',
      icon: Icons.directions_bus_rounded,
      title: 'Bus en approche',
      subtitle: 'Votre bus ligne B arrive dans 3 min à l\'arrêt Université',
      time: 'Il y a 3h',
      color: sky,
      category: 'Alertes',
      unread: false,
    ),
    _Notif(
      id: '7',
      icon: Icons.star_rounded,
      title: 'Abonnement renouvelé',
      subtitle: 'Votre abonnement Premium a été renouvelé jusqu\'au 31/08',
      time: 'Il y a 2j',
      color: orange,
      category: 'Offres',
      unread: false,
    ),
  ];

  List<_Notif> get _filtered {
    if (_selectedTab == 'Toutes') return _notifications;
    return _notifications.where((n) => n.category == _selectedTab).toList();
  }

  int get _unreadCount => _notifications.where((n) => n.unread).length;

  void _markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        n.unread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Toutes les notifications marquées comme lues'),
          ],
        ),
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteNotif(String id) {
    HapticFeedback.mediumImpact();
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.unread = false;
    });
  }

  void _showNotifDetail(BuildContext context, _Notif notif) {
    _markRead(notif.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F6FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8F8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: notif.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(notif.icon, color: notif.color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              notif.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0a1628),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              notif.subtitle,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCE8F8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: muted),
                  const SizedBox(width: 4),
                  Text(
                    notif.time,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _deleteNotif(notif.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: red,
                      side: BorderSide(color: red.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sky,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar simple ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: blue,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (_unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (_unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all_rounded,
                      color: Colors.white70, size: 18),
                  label: const Text(
                    'Tout lire',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: blue,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: ['Toutes', 'Alertes', 'Infos', 'Offres']
                      .map((tab) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _TabBtn(
                              label: tab,
                              active: _selectedTab == tab,
                              onTap: () => setState(() => _selectedTab = tab),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),

          // ── Liste ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(child: _EmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final notif = filtered[i];
                        return Dismissible(
                          key: Key(notif.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteNotif(notif.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _NotifCard(
                              notif: notif,
                              onTap: () => _showNotifDetail(context, notif),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 3),
    );
  }
}

// ── Models ─────────────────────────────────────────────────────────────────────

class _Notif {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String category;
  bool unread;

  _Notif({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.category,
    required this.unread,
  });
}

// ── Tab Button ─────────────────────────────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF0a1628) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Notification Card ──────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.unread ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.unread
                ? notif.color.withOpacity(0.2)
                : const Color(0xFFDCE8F8),
            width: notif.unread ? 1.5 : 1,
          ),
          boxShadow: notif.unread
              ? [
                  BoxShadow(
                    color: notif.color.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: notif.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(notif.icon, color: notif.color, size: 22),
                ),
                if (notif.unread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE24B4A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.unread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF0a1628),
                          ),
                        ),
                      ),
                      Text(
                        notif.time,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.subtitle,
                    style: TextStyle(
                      color: notif.unread
                          ? const Color(0xFF0a1628)
                          : const Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: notif.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notif.category,
                          style: TextStyle(
                            color: notif.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '← Glisser pour supprimer',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
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

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Color(0xFF6B7280)),
          SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0a1628),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Vous êtes à jour !',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
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
        selectedItemColor: const Color(0xFF0a1628),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == currentIndex) return;
          Widget page = const HomeScreen();
          if (index == 1) page = const BusLinesScreen();
          if (index == 2) page = const QrPaymentScreen();
          if (index == 3) page = const NotificationsScreen();
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
