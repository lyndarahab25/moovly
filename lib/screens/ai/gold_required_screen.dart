import 'package:flutter/material.dart';
import 'ai_screen.dart';

class GoldRequiredScreen extends StatelessWidget {
  const GoldRequiredScreen({super.key});

  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color darkBlue = Color(0xFF172B68);
  static const Color background = Color(0xFFF7F9FC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: dark,
            size: 21,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Moovly AI",
          style: TextStyle(
            color: dark,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
          child: Column(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1953FF),
                      Color(0xFF693DFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.20),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                "Moovly AI",
                style: TextStyle(
                  color: dark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 8),

              // GOLD BADGE

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5D6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "GOLD",
                  style: TextStyle(
                    color: Color(0xFF9A7410),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Votre assistant intelligent de mobilité",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                "Planifiez vos trajets, trouvez les meilleures lignes "
                "et profitez d'une assistance personnalisée grâce à "
                "Moovly AI.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // GOLD CARD
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF172B68),
                      Color(0xFF263F91),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withOpacity(0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // GOLD decorative circle

                    Positioned(
                      right: -55,
                      top: -70,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: gold.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Text(
                                "GOLD",
                                style: TextStyle(
                                  color: Color(0xFFFFD76A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFD76A),
                              size: 25,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "400 DA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(width: 6),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "/ mois",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 23),

              // ==================================================
              // FEATURES
              // ==================================================

              _feature(
                icon: Icons.auto_awesome_rounded,
                title: "Assistant de mobilité intelligent",
                description:
                    "Discutez avec Moovly AI pour organiser vos déplacements.",
              ),

              _feature(
                icon: Icons.route_rounded,
                title: "Suggestions de trajets personnalisées",
                description:
                    "Trouvez les itinéraires les plus adaptés à vos besoins.",
              ),

              _feature(
                icon: Icons.lightbulb_outline_rounded,
                title: "Optimisation de vos déplacements",
                description:
                    "Obtenez des suggestions intelligentes pour vos trajets.",
              ),

              _feature(
                icon: Icons.block_rounded,
                title: "Sans publicité",
                description:
                    "Profitez d'une expérience Moovly sans interruptions.",
              ),

              const SizedBox(height: 24),

              // ==================================================
              // BUY BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _showPurchaseConfirmation(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFFD76A),
                        size: 21,
                      ),
                      SizedBox(width: 9),
                      Text(
                        "Passer à GOLD",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Peut-être plus tard",
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEATURE
  // ============================================================

  static Widget _feature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: gold,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PURCHASE CONFIRMATION
  // ============================================================

  static void _showPurchaseConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              18,
              24,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 43,
                  height: 5,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7DE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: gold,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Passer à GOLD ?",
                  style: TextStyle(
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "L'abonnement GOLD coûte 400 DA par mois.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 19),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: border,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: primaryBlue,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Le montant sera déduit de votre Wallet.",
                          style: TextStyle(
                            color: dark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      _activateGold(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Confirmer — 400 DA",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GOLD ACTIVATION
  // ============================================================

  static void _activateGold(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF18A563),
        content: Text(
          "Abonnement GOLD activé avec succès !",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AIScreen(),
          ),
        );
      },
    );
  }
}
