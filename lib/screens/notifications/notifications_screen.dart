import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // ============================================================
  // FIREBASE
  // ============================================================

  User? get _currentUser {
    return FirebaseAuth.instance.currentUser;
  }

Stream<QuerySnapshot<Map<String, dynamic>>> get _notificationsStream {
  return FirebaseFirestore.instance
      .collection('notifications')
      .snapshots();
}
  // ============================================================
  // ICON DE LA NOTIFICATION
  // ============================================================

  IconData _getNotificationIcon(dynamic type) {
    switch (type?.toString()) {
      case 'alerte':
      case 'alert':
      case 'retard':
        return Icons.warning_rounded;

      case 'bus':
        return Icons.directions_bus_rounded;

      case 'paiement':
        return Icons.check_circle_rounded;
      case 'recharge':
        return Icons.account_balance_wallet_rounded;

      case 'maintenance':
        return Icons.build_rounded;

      case 'offre':
      case 'promotion':
        return Icons.local_offer_rounded;

      case 'abonnement':
        return Icons.star_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  // ============================================================
  // COULEUR DE LA NOTIFICATION
  // ============================================================

  Color _getNotificationColor(dynamic type) {
    switch (type?.toString()) {
      case 'alerte':
      case 'alert':
      case 'retard':
        return red;

      case 'bus':
        return primaryBlue;

      case 'paiement':
        return green;

      case 'recharge':
      return green;

      case 'maintenance':
        return purple;

      case 'offre':
      case 'promotion':
        return orange;

      case 'abonnement':
        return orange;

      default:
        return primaryBlue;
    }
  }

  // ============================================================
  // CATÉGORIE
  // ============================================================

  String _getNotificationCategory(dynamic type) {
    switch (type?.toString()) {
      case 'alerte':
      case 'alert':
      case 'retard':
      case 'maintenance':
        return 'Alertes';

      case 'bus':
      case 'paiement':
      case 'recharge':
        return 'Infos';

      case 'offre':
      case 'promotion':
      case 'abonnement':
        return 'Offres';

      default:
        return 'Infos';
    }
  }

  // ============================================================
  // DATE
  // ============================================================
 DateTime? _getNotificationDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return null;
}
  String _formatNotificationDate(dynamic value) {
    if (value == null) {
      return '';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    }

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    }

    if (difference.inDays == 1) {
      return 'Hier';
    }

    if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllRead(
    List<MoovlyNotification> notifications,
  ) async {
    HapticFeedback.lightImpact();

    final batch = FirebaseFirestore.instance.batch();

    for (final notification in notifications) {
      if (notification.unread) {
        final reference = FirebaseFirestore.instance
            .collection('notifications')
            .doc(notification.id);

        batch.update(
          reference,
          {
            'lu': true,
          },
        );
      }
    }

    await batch.commit();

    if (!mounted) return;

    _showMessage(
      'Toutes les notifications ont été marquées comme lues.',
      green,
      Icons.done_all_rounded,
    );
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({
      'lu': true,
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteNotification(String id) async {
    HapticFeedback.mediumImpact();

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .delete();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
    Color color,
    IconData icon,
  ) {
    if (!mounted) return;

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
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await deleteNotification(notification.id);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
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
    return Scaffold(
      backgroundColor: bg,

      // Aucun bottomNavigationBar ici.
      // Le navbar appartient au HomeScreen.
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Erreur lors du chargement des notifications.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

           final docs = snapshot.data?.docs ?? [];

final user = _currentUser;

if (user == null) {
  return const _EmptyNotifications();
}

// ======================================================
// FILTRER LES NOTIFICATIONS DE L'UTILISATEUR
// ======================================================

final userPath = 'users/${user.uid}';

final userDocs = docs.where((doc) {
  final data = doc.data();

  // ------------------------------------------------------
  // FORMAT 1 : id_user = DocumentReference
  // ------------------------------------------------------

  final idUser = data['id_user'];

  if (idUser is DocumentReference) {
    if (idUser.path == userPath) {
      return true;
    }
  }

  // ------------------------------------------------------
  // FORMAT 2 : userId = "users/UID"
  // ------------------------------------------------------

  final userId = data['userId'];

  if (userId?.toString() == userPath) {
    return true;
  }

  // ------------------------------------------------------
  // FORMAT 3 : userId = UID directement
  // ------------------------------------------------------

  if (userId?.toString() == user.uid) {
    return true;
  }

  return false;
}).toList();

// ======================================================
// CONVERSION FIRESTORE → MODEL
// ======================================================

final allNotifications = userDocs.map((doc) {
  final data = doc.data();

  return MoovlyNotification(
    id: doc.id,

    icon: _getNotificationIcon(
      data['type'],
    ),

    title: (data['title'] ?? '')
            .toString()
            .trim()
            .isEmpty
        ? 'Notification'
        : data['title'].toString(),

    subtitle: (data['message'] ?? '').toString(),

    time: _formatNotificationDate(
      data['date_envoi'],
    ),

    color: _getNotificationColor(
      data['type'],
    ),

    category: _getNotificationCategory(
      data['type'],
    ),

    unread: data['lu'] != true,

    date: _getNotificationDate(
      data['date_envoi'],
    ),
  );
}).toList();

            // ======================================================
            // TRI PAR DATE
            // ======================================================

            allNotifications.sort((a, b) {
  final dateA = a.date;
  final dateB = b.date;

  if (dateA == null && dateB == null) {
    return 0;
  }

  if (dateA == null) {
    return 1;
  }

  if (dateB == null) {
    return -1;
  }

  return dateB.compareTo(dateA);
});

            // ======================================================
            // FILTRE
            // ======================================================

            final filtered = selectedTab == 'Toutes'
                ? allNotifications
                : allNotifications
                    .where(
                      (notification) => notification.category == selectedTab,
                    )
                    .toList();

            // ======================================================
            // NOTIFICATIONS NON LUES
            // ======================================================

            final unreadCount = allNotifications
                .where(
                  (notification) => notification.unread,
                )
                .length;

            return Column(
              children: [
                _buildHeader(
                  unreadCount,
                  allNotifications,
                ),
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
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: Dismissible(
                                key: ValueKey(
                                  notification.id,
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  deleteNotification(
                                    notification.id,
                                  );
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                    right: 22,
                                  ),
                                  decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
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
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    int unreadCount,
    List<MoovlyNotification> notifications,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        8,
      ),
      child: Row(
        children: [
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
                      : '$unreadCount notification'
                          '${unreadCount > 1 ? 's' : ''} '
                          'non lue'
                          '${unreadCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => markAllRead(notifications),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
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
  final DateTime? date;

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
    required this.date,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
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
                          color: notification.color.withOpacity(
                            0.09,
                          ),
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
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
              'Vous êtes à jour !\n'
              'Nous vous préviendrons en cas de nouveauté.',
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
