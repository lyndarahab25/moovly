import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const bg = Color(0xFFF6F8FD);
  static const dark = Color(0xFF101426);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF18A563);
  static const red = Color(0xFFE53935);
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
          "Historique des paiements",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: blue,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Solde actuel",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "120,50 DA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.add_circle_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Transactions récentes",
                    style: TextStyle(
                      color: dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Filtrer",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _DateLabel("Aujourd'hui"),
            const _PaymentTile(
              icon: Icons.directions_bus_rounded,
              title: "Trajet Ligne A",
              subtitle: "Gare Centrale → Place Audin",
              date: "08:15",
              amount: "-50 DA",
              color: red,
            ),
            const _PaymentTile(
              icon: Icons.account_balance_wallet_rounded,
              title: "Recharge portefeuille",
              subtitle: "Carte bancaire •••• 2458",
              date: "07:45",
              amount: "+500 DA",
              color: green,
            ),
            const _DateLabel("Hier"),
            const _PaymentTile(
              icon: Icons.directions_bus_rounded,
              title: "Trajet Ligne B",
              subtitle: "Université → Centre-ville",
              date: "17:40",
              amount: "-50 DA",
              color: red,
            ),
            const _PaymentTile(
              icon: Icons.workspace_premium_rounded,
              title: "Abonnement Mensuel EC",
              subtitle: "Renouvellement automatique",
              date: "09:00",
              amount: "-500 DA",
              color: orange,
            ),
            const _DateLabel("12/07/2026"),
            const _PaymentTile(
              icon: Icons.directions_bus_rounded,
              title: "Trajet Ligne C",
              subtitle: "Port → Gare Routière",
              date: "18:20",
              amount: "-50 DA",
              color: red,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String text;

  const _DateLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(
        text,
        style: const TextStyle(
          color: PaymentHistoryScreen.muted,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final Color color;

  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith("+");

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
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
            color: PaymentHistoryScreen.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: PaymentHistoryScreen.muted,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: isPositive
                    ? PaymentHistoryScreen.green
                    : PaymentHistoryScreen.red,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                color: PaymentHistoryScreen.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
