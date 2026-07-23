import 'package:flutter/material.dart';
import '../authn/login_screen.dart';
import 'settings_screen.dart';
import 'personal_info_screen.dart';
import 'payment_history_screen.dart';
import '../home/home_screen.dart';
import '../bus/bus_lines_screen.dart';
import '../qr/qr_payment_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF0a1628);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color background = Color(0xFFF6F8FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/me.jpg'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Lynda Rahab",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("lynda.rahab@email.com",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // --- STATS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCard("128", "TRAJETS", Icons.directions_bus),
                    _statCard("4.8", "NOTE", Icons.star),
                    _statCard("24h", "ACTIVITÉ", Icons.history),
                  ],
                ),
              ),
            ),

            // --- MENU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _menuItem(
                      context,
                      Icons.person_outline,
                      "Informations personnelles",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PersonalInfoScreen()))),
                  _menuItem(context, Icons.credit_card_outlined,
                      "Mes abonnements", () {}),
                  _menuItem(
                      context,
                      Icons.receipt_long_outlined,
                      "Historique des paiements",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentHistoryScreen()))),
                  _menuItem(context, Icons.account_balance_wallet_outlined,
                      "Méthodes de paiement", () {}),
                  _menuItem(context, Icons.notifications_outlined,
                      "Notifications", () {}),
                  _menuItem(
                      context,
                      Icons.settings_outlined,
                      "Paramètres",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()))),
                  _menuItem(
                      context, Icons.help_outline, "Aide et Support", () {}),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Se déconnecter",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 4),
    );
  }

  Widget _statCard(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: accentBlue, size: 28),
        const SizedBox(height: 8),
        Text(val,
            style: const TextStyle(
                color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: ListTile(
        leading: Icon(icon, color: primaryBlue),
        title: Text(title,
            style: const TextStyle(
                color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 14)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
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
      selectedItemColor: ProfileScreen.accentBlue,
      onTap: (index) {
        if (index == currentIndex) return;
        Widget page;
        switch (index) {
          case 0:
            page = const HomeScreen();
            break;
          case 1:
            page = const BusLinesScreen();
            break;
          case 2:
            page = const QrPaymentScreen();
            break;
          case 3:
            page = const SubscriptionsScreen();
            break;
          case 4:
            page = const ProfileScreen();
            break;
          default:
            page = const HomeScreen();
        }
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => page,
                transitionDuration: Duration.zero));
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: "Accueil"),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined), label: "Bus"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "QR"),
        BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined), label: "Abonnement"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}
