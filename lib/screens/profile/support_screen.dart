import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF18A563);
  static const orange = Color(0xFFFF8A00);
  static const purple = Color(0xFF6D4DE6);

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
          "Aide et support",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [blue, Color(0xFF0047B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: blue,
                      size: 34,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Besoin d’aide ?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Notre équipe est disponible pour vous accompagner.",
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "Contact rapide",
              style: TextStyle(
                color: dark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _SupportTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: "Chat en direct",
              subtitle: "Discutez avec un conseiller Moovly",
              color: blue,
            ),
            const _SupportTile(
              icon: Icons.email_outlined,
              title: "Envoyer un email",
              subtitle: "support@moovly.app",
              color: green,
            ),
            const _SupportTile(
              icon: Icons.phone_outlined,
              title: "Appeler le support",
              subtitle: "+213 555 000 111",
              color: orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "Questions fréquentes",
              style: TextStyle(
                color: dark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _FaqTile(
              question: "Comment renouveler mon abonnement ?",
              answer:
                  "Allez dans Mes abonnements puis choisissez Acheter un abonnement.",
            ),
            const _FaqTile(
              question: "Comment utiliser le QR paiement ?",
              answer:
                  "Ouvrez Paiement QR et présentez le code au lecteur dans le bus.",
            ),
            const _FaqTile(
              question: "Comment suivre un bus en temps réel ?",
              answer:
                  "Ouvrez Lignes de bus puis sélectionnez une ligne pour voir la carte.",
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SupportTile({
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
            color: SupportScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: SupportScreen.muted),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: SupportScreen.muted,
        ),
        onTap: () {},
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: SupportScreen.blue,
        collapsedIconColor: SupportScreen.muted,
        title: Text(
          question,
          style: const TextStyle(
            color: SupportScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                color: SupportScreen.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
