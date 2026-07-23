import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF18A563);
  static const purple = Color(0xFF6D4DE6);
  static const orange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: dark,
        centerTitle: true,
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: const [
            _SectionTitle("Préférences"),
            _SettingSwitchTile(
              icon: Icons.notifications_active_rounded,
              title: "Notifications push",
              subtitle: "Recevoir les alertes et informations",
              color: blue,
              value: true,
            ),
            _SettingSwitchTile(
              icon: Icons.location_on_rounded,
              title: "Localisation en temps réel",
              subtitle: "Autoriser le suivi des bus proches",
              color: green,
              value: true,
            ),
            _SettingSwitchTile(
              icon: Icons.dark_mode_rounded,
              title: "Mode sombre",
              subtitle: "Changer l'apparence de l'application",
              color: purple,
              value: false,
            ),
            SizedBox(height: 20),
            _SectionTitle("Application"),
            _SettingActionTile(
              icon: Icons.language_rounded,
              title: "Langue",
              subtitle: "Français",
              color: blue,
            ),
            _SettingActionTile(
              icon: Icons.security_rounded,
              title: "Sécurité",
              subtitle: "Mot de passe et confidentialité",
              color: orange,
            ),
            _SettingActionTile(
              icon: Icons.info_outline_rounded,
              title: "À propos",
              subtitle: "Version 1.0.0",
              color: muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: SettingsScreen.dark,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;

  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: SettingsScreen.blue,
        onChanged: (_) {},
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        secondary: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: SettingsScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: SettingsScreen.muted),
          ),
        ),
      ),
    );
  }
}

class _SettingActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SettingActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: SettingsScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: SettingsScreen.muted),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: SettingsScreen.muted,
        ),
        onTap: () {},
      ),
    );
  }
}
