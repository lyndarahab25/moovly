import 'package:flutter/material.dart';

void showRechargeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Titre
                const Center(
                  child: Text(
                    "Recharger mon compte",
                    style: TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Solde
                _currentBalanceBox(),

                const SizedBox(height: 22),

                const Text(
                  "Choisir un montant",
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 11),

                _amountGrid(context),

                const SizedBox(height: 22),

                const Text(
                  "Méthode de paiement",
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 11),

                _paymentMethod(
                  icon: Icons.credit_card_rounded,
                  title: "Carte bancaire",
                  subtitle: "CIB / Visa / Mastercard",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "Carte bancaire");
                  },
                ),

                _paymentMethod(
                  icon: Icons.phone_android_rounded,
                  title: "BaridiMob",
                  subtitle: "Paiement mobile",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "BaridiMob");
                  },
                ),

                _paymentMethod(
                  icon: Icons.credit_card_rounded,
                  title: "Edahabia",
                  subtitle: "Paiement via Algérie Poste",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "Edahabia");
                  },
                ),

                _paymentMethod(
                  icon: Icons.store_rounded,
                  title: "Recharge en agence",
                  subtitle: "Paiement en espèces",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openAgencyRecharge(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ============================================================
// SOLDE
// ============================================================

Widget _currentBalanceBox() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.account_balance_wallet_rounded,
          color: Color(0xFF1953FF),
          size: 30,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Solde actuel",
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 11,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "0.00 DA",
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ============================================================
// MONTANTS
// ============================================================

Widget _amountGrid(BuildContext context) {
  final amounts = [100, 300, 500, 1000, 2000, 5000];

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: amounts.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 2.5,
    ),
    itemBuilder: (context, index) {
      final amount = amounts[index];

      return InkWell(
        onTap: () {
          Navigator.pop(context);
          _selectPaymentAmount(context, amount.toDouble());
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            "$amount DA",
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    },
  );
}

// ============================================================
// MÉTHODE DE PAIEMENT
// ============================================================

Widget _paymentMethod({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1953FF),
                  size: 22,
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
                        color: Color(0xFF172033),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF718096),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// CHOIX DU MONTANT
// ============================================================

void _selectPaymentAmount(
  BuildContext context,
  double amount,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Montant de recharge",
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${amount.toStringAsFixed(0)} DA",
                  style: const TextStyle(
                    color: Color(0xFF1953FF),
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _paymentMethod(
                  icon: Icons.credit_card_rounded,
                  title: "Carte bancaire",
                  subtitle: "CIB / Visa / Mastercard",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "Carte bancaire");
                  },
                ),
                _paymentMethod(
                  icon: Icons.phone_android_rounded,
                  title: "BaridiMob",
                  subtitle: "Paiement mobile",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "BaridiMob");
                  },
                ),
                _paymentMethod(
                  icon: Icons.credit_card_rounded,
                  title: "Edahabia",
                  subtitle: "Paiement via Algérie Poste",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon(context, "Edahabia");
                  },
                ),
                _paymentMethod(
                  icon: Icons.store_rounded,
                  title: "Recharge en agence",
                  subtitle: "Espèces + validation par agent",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openAgencyRecharge(
                      context,
                      amount: amount,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ============================================================
// RECHARGE EN AGENCE
// ============================================================

void _openAgencyRecharge(
  BuildContext context, {
  double amount = 500,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Recharge en agence",
                style: TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Présentez votre identifiant Wallet à l'agent",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 145,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "MOOV-WALLET",
                style: TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Montant : ${amount.toStringAsFixed(0)} DA",
                style: const TextStyle(
                  color: Color(0xFF1953FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD4AF37),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        "Donnez le montant en espèces à l'agent. "
                        "La recharge sera validée après confirmation.",
                        style: TextStyle(
                          color: Color(0xFF172033),
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showSuccessMessage(
                      context,
                      amount,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1953FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Simuler la validation",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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
// MESSAGES
// ============================================================

void _showComingSoon(
  BuildContext context,
  String method,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("$method sera bientôt disponible."),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showSuccessMessage(
  BuildContext context,
  double amount,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Recharge de ${amount.toStringAsFixed(0)} DA réussie !",
      ),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
