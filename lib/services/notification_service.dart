import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'subscription_expiration';
  static const String _channelName = 'Expiration abonnement';

  static Future<void> initialize() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Création explicite du canal de notification
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description:
          'Notifications concernant l’expiration de votre abonnement Moovly.',
      importance: Importance.high,
    );

    await androidPlugin?.createNotificationChannel(channel);

    // Demande de permission Android
    await androidPlugin?.requestNotificationsPermission();

    debugPrint('✅ NotificationService initialisé.');
  }

  static Future<void> showSubscriptionExpiration({
    required String plan,
    required int daysRemaining,
  }) async {
    if (kIsWeb) return;

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final bool? enabled = await androidPlugin?.areNotificationsEnabled();

    debugPrint('🔔 Notifications Android activées : $enabled');

    if (enabled == false) {
      debugPrint('❌ Les notifications Android sont désactivées.');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription:
          'Notifications concernant l’expiration de votre abonnement Moovly.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final String message = daysRemaining == 1
        ? 'Votre abonnement expire demain.'
        : 'Votre abonnement expire dans $daysRemaining jours.';

    try {
      await _notifications.show(
        1001,
        '⚠️ Abonnement $plan',
        message,
        details,
      );

      debugPrint('✅ Notification Android envoyée.');
    } catch (e) {
      debugPrint('❌ Erreur notification Android : $e');
    }
  }
}
