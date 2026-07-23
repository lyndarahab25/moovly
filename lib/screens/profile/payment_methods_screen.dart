import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF18A563);
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
          "Méthodes de paiement",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              height: 178,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [blue, Color(0xFF0047B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -32,
                    child: Icon(
                      Icons.credit_card_rounded,
                      size: 132,
                      color: Colors.white.withOpacity(.14),
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Carte principale",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "••••  ••••  ••••  2458",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Lynda Kouassi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            "08/28",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "Mes moyens de paiement",
              style: TextStyle(
                color: dark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _PaymentMethodTile(
              icon: Icons.credit_card_rounded,
              title: "Carte bancaire",
              subtitle: "Visa •••• 2458",
              color: blue,
              active: true,
            ),
            const _PaymentMethodTile(
              icon: Icons.account_balance_wallet_rounded,
              title: "Portefeuille Moovly",
              subtitle: "Solde : 120,50 DA",
              color: green,
            ),
            const _PaymentMethodTile(
              icon: Icons.payments_rounded,
              title: "Paiement en espèces",
              subtitle: "Disponible aux points partenaires",
              color: orange,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text("Ajouter une méthode"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool active;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: active
            ? const BorderSide(color: PaymentMethodsScreen.blue, width: 1.3)
            : BorderSide.none,
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
            color: PaymentMethodsScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: PaymentMethodsScreen.muted),
          ),
        ),
        trailing: active
            ? const Icon(
                Icons.check_circle_rounded,
                color: PaymentMethodsScreen.blue,
              )
            : const Icon(
                Icons.chevron_right_rounded,
                color: PaymentMethodsScreen.muted,
              ),
      ),
    );
  }
}
