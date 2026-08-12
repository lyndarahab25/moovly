import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ============================================================
  // MOOVLY DESIGN TOKENS
  // ============================================================

  static const Color bg = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mutedText = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const Color red = Color(0xFFE24B4A);
  static const Color green = Color(0xFF16A34A);
  static const Color orange = Color(0xFFFF8A00);
  static const Color purple = Color(0xFF6D4DE6);

  String selectedTab = 'Toutes';

  final List<MoovlyNotification> notifications = [
    MoovlyNotification(
      id: '1',
      icon: Icons.warning_rounded,
      title: 'Retard sur la ligne A',
      subtitle: 'Retard de 10 min sur la ligne A à 08:20.',
      time: 'Maintenant',
      color: red,
      category: 'Alertes',
      unread: true,
    ),
    MoovlyNotification(
      id: '2',
      icon: Icons.directions_bus_rounded,
      title: 'Plus de bus disponibles',
      subtitle: 'Plus de bus sont disponibles sur la ligne 12.',
      time: 'Il y a 1h',
      color: primaryBlue,
      category: 'Infos',
      unread: true,
    ),
    MoovlyNotification(
      id: '3',
      icon: Icons.check_circle_rounded,
      title: 'Paiement réussi',
      subtitle: 'Votre paiement de 50 DA a été effectué avec succès.',
      time: 'Il y a 2h',
      color: green,
      category: 'Infos',
      unread: false,
    ),
    MoovlyNotification(
      id: '4',
      icon: Icons.build_rounded,
      title: 'Maintenance prévue',
      subtitle: 'Maintenance prévue sur la ligne C de 00:00 à 04:00.',
      time: 'Hier',
      color: purple,
      category: 'Alertes',
      unread: false,
    ),
    MoovlyNotification(
      id: '5',
      icon: Icons.local_offer_rounded,
      title: 'Offre spéciale Premium',
      subtitle: 'Profitez d’une réduction sur votre prochain abonnement.',
      time: 'Hier',
      color: orange,
      category: 'Offres',
      unread: false,
    ),
    MoovlyNotification(
      id: '6',
      icon: Icons.directions_bus_rounded,
      title: 'Bus en approche',
      subtitle: 'Votre bus ligne B arrive dans 3 min à l’arrêt Université.',
      time: 'Il y a 3h',
      color: primaryBlue,
      category: 'Alertes',
      unread: false,
    ),
    MoovlyNotification(
      id: '7',
      icon: Icons.star_rounded,
      title: 'Abonnement renouvelé',
      subtitle: 'Votre abonnement Premium est valable jusqu’au 31/08.',
      time: 'Il y a 2j',
      color: orange,
      category: 'Offres',
      unread: false,
    ),
  ];

  // ============================================================
  // FILTER
  // ============================================================

  List<MoovlyNotification> get filteredNotifications {
    if (selectedTab == 'Toutes') {
      return notifications;
    }

    return notifications
        .where((notification) => notification.category == selectedTab)
        .toList();
  }

  int get unreadCount {
    return notifications.where((notification) => notification.unread).length;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void markAllRead() {
    HapticFeedback.lightImpact();

    setState(() {
      for (final notification in notifications) {
        notification.unread = false;
      }
    });

    _showMessage(
      'Toutes les notifications ont été marquées comme lues.',
      green,
      Icons.done_all_rounded,
    );
  }

  void markAsRead(String id) {
    setState(() {
      final notification =
          notifications.firstWhere((notification) => notification.id == id);

      notification.unread = false;
    });
  }

  void deleteNotification(String id) {
    HapticFeedback.mediumImpact();

    setState(() {
      notifications.removeWhere(
        (notification) => notification.id == id,
      );
    });
  }

  void _showMessage(
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION DETAIL
  // ============================================================

  void showNotificationDetail(
    BuildContext context,
    MoovlyNotification notification,
  ) {
    markAsRead(notification.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  notification.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  notification.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 15),

                // Time + category
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoPill(
                      icon: Icons.access_time_rounded,
                      text: notification.time,
                    ),
                    const SizedBox(width: 8),
                    _InfoPill(
                      icon: Icons.label_outline_rounded,
                      text: notification.category,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          deleteNotification(notification.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: red,
                          side: BorderSide(
                            color: red.withOpacity(0.25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.check_rounded,
                          size: 18,
                        ),
                        label: const Text('Fermer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredNotifications;

    return Scaffold(
      backgroundColor: bg,

      // IMPORTANT :
      // Aucun bottomNavigationBar ici.
      // Le navbar appartient au HomeScreen.
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyNotifications()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        30,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final notification = filtered[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(notification.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              deleteNotification(notification.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 22),
                              decoration: BoxDecoration(
                                color: red,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            child: _NotificationCard(
                              notification: notification,
                              onTap: () {
                                showNotificationDetail(
                                  context,
                                  notification,
                                );
                              },
                            ),
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          // Back
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: darkText,
                size: 21,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount == 0
                      ? 'Vous êtes à jour'
                      : '$unreadCount notification${unreadCount > 1 ? 's' : ''} non lue${unreadCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tout lire
          if (unreadCount > 0)
            GestureDetector(
              onTap: markAllRead,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      color: primaryBlue,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Tout lire',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    const tabs = [
      'Toutes',
      'Alertes',
      'Infos',
      'Offres',
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final active = selectedTab == tab;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = tab;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: active ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? primaryBlue : borderColor,
                ),
                boxShadow: active
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
                tab,
                style: TextStyle(
                  color: active ? Colors.white : mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class MoovlyNotification {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String category;

  bool unread;

  MoovlyNotification({
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

// ============================================================
// NOTIFICATION CARD
// ============================================================

class _NotificationCard extends StatelessWidget {
  final MoovlyNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool unread = notification.unread;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unread
                ? notification.color.withOpacity(0.22)
                : _NotificationsScreenState.borderColor,
            width: unread ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                unread ? 0.045 : 0.025,
              ),
              blurRadius: unread ? 14 : 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 22,
                  ),
                ),
                if (unread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: _NotificationsScreenState.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _NotificationsScreenState.darkText,
                            fontSize: 13.5,
                            fontWeight:
                                unread ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: _NotificationsScreenState.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread
                          ? _NotificationsScreenState.darkText
                          : _NotificationsScreenState.mutedText,
                      fontSize: 11.5,
                      height: 1.45,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: notification.color.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.category,
                          style: TextStyle(
                            color: notification.color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _NotificationsScreenState.mutedText,
                        size: 18,
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

// ============================================================
// INFO PILL
// ============================================================

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _NotificationsScreenState.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _NotificationsScreenState.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: _NotificationsScreenState.mutedText,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: _NotificationsScreenState.mutedText,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _NotificationsScreenState.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _NotificationsScreenState.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucune notification',
              style: TextStyle(
                color: _NotificationsScreenState.darkText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vous êtes à jour !\nNous vous préviendrons en cas de nouveauté.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _NotificationsScreenState.mutedText,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
