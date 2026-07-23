import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF18A563);

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
          "Informations personnelles",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Modifier",
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Color(0xFFEAF4FF),
                          child: Icon(
                            Icons.person_rounded,
                            color: blue,
                            size: 60,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: blue,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Lynda Rahab",
                      style: TextStyle(
                        color: dark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Compte vérifié",
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Détails du compte",
              style: TextStyle(
                color: dark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _InfoTile(
              icon: Icons.person_outline_rounded,
              label: "Nom complet",
              value: "Lynda Rahab",
            ),
            const _InfoTile(
              icon: Icons.email_outlined,
              label: "Email",
              value: "lynda.rahab@gmail.com",
            ),
            const _InfoTile(
              icon: Icons.phone_outlined,
              label: "Téléphone",
              value: "+213 555 123 456",
            ),
            const _InfoTile(
              icon: Icons.location_on_outlined,
              label: "Adresse",
              value: "Alger, Algérie",
            ),
            const _InfoTile(
              icon: Icons.calendar_month_outlined,
              label: "Membre depuis",
              value: "Janvier 2026",
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: PersonalInfoScreen.blue.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: PersonalInfoScreen.blue,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: PersonalInfoScreen.muted,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              color: PersonalInfoScreen.dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
