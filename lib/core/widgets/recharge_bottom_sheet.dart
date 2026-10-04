import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// RECHARGE MOOVLY
// ============================================================
//
// Flux :
//
// 1. Choisir un montant
// 2. Choisir une méthode de paiement
// 3. Si agence -> confirmation
// 4. Simulation de paiement
// 5. Mise à jour réelle du solde Firestore
// 6. Enregistrement du paiement
// 7. Fermeture de la fenêtre
// 8. Message de succès
//
// ============================================================

Future<void> showRechargeSheet(
  BuildContext context, {
  ValueChanged<double>? onBalanceChanged,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    _showErrorMessage(
      context,
      "Aucun utilisateur connecté.",
    );
    return;
  }

  // ------------------------------------------------------------
  // RÉCUPÉRER LE SOLDE ACTUEL
  // ------------------------------------------------------------

  double currentBalance = 0;

  try {
    final firestore = FirebaseFirestore.instance;

    final userRef = firestore.collection('users').doc(user.uid);

    final query = await firestore
        .collection('carte')
        .where(
          'id_user',
          isEqualTo: userRef,
        )
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();

      final solde = data['solde'];

      if (solde is num) {
        currentBalance = solde.toDouble();
      }
    }
  } catch (e) {
    debugPrint(
      "❌ Erreur récupération solde : $e",
    );
  }

  if (!context.mounted) return;

  // ------------------------------------------------------------
  // UNE SEULE BOTTOM SHEET
  // ------------------------------------------------------------

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (sheetContext) {
      return _RechargeSheetContent(
        initialBalance: currentBalance,
        parentContext: context,
        onBalanceChanged: onBalanceChanged,
      );
    },
  );
}

// ============================================================
// WIDGET PRINCIPAL DE LA RECHARGE
// ============================================================

class _RechargeSheetContent extends StatefulWidget {
  final double initialBalance;
  final BuildContext parentContext;
  final ValueChanged<double>? onBalanceChanged;

  const _RechargeSheetContent({
    required this.initialBalance,
    required this.parentContext,
    this.onBalanceChanged,
  });
  @override
  State<_RechargeSheetContent> createState() => _RechargeSheetContentState();
}

class _RechargeSheetContentState extends State<_RechargeSheetContent> {
  // ------------------------------------------------------------
  // ÉTAPES
  //
  // 0 = choix montant
  // 1 = choix paiement
  // 2 = confirmation agence
  // ------------------------------------------------------------

  int step = 0;

  double? selectedAmount;

  bool isLoading = false;

  // ------------------------------------------------------------
  // CHANGER D'ÉTAPE
  // ------------------------------------------------------------

  void _goToPayment(double amount) {
    setState(() {
      selectedAmount = amount;
      step = 1;
    });
  }

  void _goToAgency() {
    if (selectedAmount == null) return;

    setState(() {
      step = 2;
    });
  }

  void _goBack() {
    if (step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      step--;
    });
  }

  // ------------------------------------------------------------
  // RECHARGE
  // ------------------------------------------------------------

  Future<void> _confirmRecharge() async {
    if (selectedAmount == null) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final amount = selectedAmount!;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Aucun utilisateur connecté.");
      }

      final firestore = FirebaseFirestore.instance;

      final userRef = firestore.collection('users').doc(user.uid);

      // --------------------------------------------------------
      // TROUVER LA CARTE
      // --------------------------------------------------------

      final query = await firestore
          .collection('carte')
          .where(
            'id_user',
            isEqualTo: userRef,
          )
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Aucune carte Wallet trouvée.");
      }

      final cardRef = query.docs.first.reference;

      debugPrint("==========================================");
      debugPrint("🔵 RECHARGE MOOVLY");
      debugPrint("👤 UID : ${user.uid}");
      debugPrint("💰 Montant : $amount DA");
      debugPrint("🪪 Carte : ${cardRef.id}");

      // --------------------------------------------------------
      // NOUVEAU SOLDE
      // --------------------------------------------------------

      double newBalanceForMessage = widget.initialBalance + amount;

      // --------------------------------------------------------
      // TRANSACTION FIRESTORE
      // --------------------------------------------------------

      await firestore.runTransaction(
        (transaction) async {
          final cardSnapshot = await transaction.get(cardRef);

          if (!cardSnapshot.exists) {
            throw Exception("Carte introuvable.");
          }

          final cardData = cardSnapshot.data() ?? <String, dynamic>{};

          final oldSolde = cardData['solde'];

          double oldBalance = 0;

          if (oldSolde is num) {
            oldBalance = oldSolde.toDouble();
          }

          final newBalance = oldBalance + amount;

          newBalanceForMessage = newBalance;

          debugPrint("💵 Ancien solde : $oldBalance DA");
          debugPrint("💵 Nouveau solde : $newBalance DA");

          // ------------------------------------------------------
          // AUGMENTER LE SOLDE
          // ------------------------------------------------------

          transaction.update(
            cardRef,
            {
              'solde': FieldValue.increment(amount),
            },
          );

          // ------------------------------------------------------
          // ENREGISTRER LE PAIEMENT
          // ------------------------------------------------------

          final paymentRef = firestore.collection('payments').doc();

          transaction.set(
            paymentRef,
            {
              'amount': amount,
              'date_paiement': FieldValue.serverTimestamp(),
              'method': 'agency',
              'status': 'success',
              'userId': 'users/${user.uid}',
              'cardId': cardRef,
            },
          );

          // ------------------------------------------------------
          // ENREGISTRER LA NOTIFICATION
          // ------------------------------------------------------

          final notificationRef = firestore.collection('notifications').doc();

          transaction.set(
            notificationRef,
            {
              'id_user': userRef,
              'userId': 'users/${user.uid}',
              'title': 'Recharge réussie',
              'message': 'Votre compte a été rechargé de '
                  '${amount.toStringAsFixed(0)} DA.',
              'type': 'recharge',
              'lu': false,
              'date_envoi': FieldValue.serverTimestamp(),
            },
          );
        },
      );

      // --------------------------------------------------------
      // TRANSACTION TERMINÉE
      // --------------------------------------------------------

      debugPrint("🟢 TRANSACTION TERMINÉE");
      debugPrint(
        "💰 Nouveau solde : "
        "$newBalanceForMessage DA",
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // ARRÊTER LE CHARGEMENT
      // --------------------------------------------------------

      setState(() {
        isLoading = false;
      });
      widget.onBalanceChanged?.call(newBalanceForMessage);
      // --------------------------------------------------------
      // FERMER LA BOTTOM SHEET
      // --------------------------------------------------------

      Navigator.pop(context);

      // --------------------------------------------------------
      // MESSAGE DE SUCCÈS SUR HOME
      // --------------------------------------------------------

      ScaffoldMessenger.of(
        widget.parentContext,
      ).hideCurrentSnackBar();

      ScaffoldMessenger.of(
        widget.parentContext,
      ).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Recharge de "
                  "${amount.toStringAsFixed(0)} DA réussie !\n"
                  "Nouveau solde : "
                  "${newBalanceForMessage.toStringAsFixed(0)} DA",
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("❌ ERREUR RECHARGE : $e");
      debugPrint("$stackTrace");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showErrorMessage(
        context,
        "Impossible d'effectuer la recharge.",
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9FC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HANDLE
              // ------------------------------------------------

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

              const SizedBox(height: 18),

              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Row(
                children: [
                  if (step > 0)
                    IconButton(
                      onPressed: isLoading ? null : _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Recharger mon compte",
                        style: TextStyle(
                          color: Color(0xFF172033),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // CONTENU SELON L'ÉTAPE
              // ------------------------------------------------

              if (step == 0) _buildAmountStep(),

              if (step == 1) _buildPaymentStep(),

              if (step == 2) _buildAgencyStep(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ÉTAPE 1 : MONTANT
  // ============================================================

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOLDE

        _currentBalanceBox(
          widget.initialBalance,
        ),

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

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            // ----------------------------------------------------------
            // MONTANTS FIXES
            // ----------------------------------------------------------

            if (index < 3) {
              final amounts = [100, 300, 500];
              final amount = amounts[index];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    _goToPayment(
                      amount.toDouble(),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
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
                ),
              );
            }

            // ----------------------------------------------------------
            // AUTRE MONTANT
            // ----------------------------------------------------------

            return Material(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: _openCustomAmountDialog,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF1953FF).withOpacity(0.25),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF1953FF),
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Text(
                        "Autre montant",
                        style: TextStyle(
                          color: Color(0xFF1953FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _openCustomAmountDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Montant personnalisé",
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
            ),
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Ex. 750",
              suffixText: "DA",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(
                  controller.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  return;
                }

                Navigator.pop(dialogContext);

                _goToPayment(amount);
              },
              child: const Text("Continuer"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ÉTAPE 2 : PAIEMENT
  // ============================================================

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MONTANT CHOISI

        _selectedAmountBox(),

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

        // CARTE BANCAIRE

        _paymentMethod(
          icon: Icons.credit_card_rounded,
          title: "Carte bancaire",
          subtitle: "CIB / Visa / Mastercard",
          onTap: () {
            _showComingSoon(
              context,
              "Carte bancaire",
            );
          },
        ),

        // BARIDIMOB

        _paymentMethod(
          icon: Icons.phone_android_rounded,
          title: "BaridiMob",
          subtitle: "Paiement mobile",
          onTap: () {
            _showComingSoon(
              context,
              "BaridiMob",
            );
          },
        ),

        // EDAHABIA

        _paymentMethod(
          icon: Icons.credit_card_rounded,
          title: "Edahabia",
          subtitle: "Paiement via Algérie Poste",
          onTap: () {
            _showComingSoon(
              context,
              "Edahabia",
            );
          },
        ),

        // AGENCE

        _paymentMethod(
          icon: Icons.store_rounded,
          title: "Recharge en agence",
          subtitle: "Paiement en espèces",
          onTap: _goToAgency,
        ),
      ],
    );
  }

  // ============================================================
  // MONTANT CHOISI
  // ============================================================

  Widget _selectedAmountBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFF1953FF),
            size: 30,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Montant sélectionné",
                  style: TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
          Text(
            "${selectedAmount!.toStringAsFixed(0)} DA",
            style: const TextStyle(
              color: Color(0xFF1953FF),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ÉTAPE 3 : AGENCE
  // ============================================================

  Widget _buildAgencyStep() {
    return Column(
      children: [
        // ------------------------------------------------------
        // TITRE
        // ------------------------------------------------------

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

        // ------------------------------------------------------
        // QR
        // ------------------------------------------------------

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

        const SizedBox(height: 6),

        Text(
          "Montant : "
          "${selectedAmount!.toStringAsFixed(0)} DA",
          style: const TextStyle(
            color: Color(0xFF1953FF),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 17),

        // ------------------------------------------------------
        // INFO
        // ------------------------------------------------------

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD4AF37),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  "Donnez le montant en espèces "
                  "à l'agent. Cliquez ensuite sur "
                  "« Simuler la validation » pour "
                  "effectuer la recharge.",
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

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // BOUTON
        // ------------------------------------------------------

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _confirmRecharge,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1953FF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  26,
                ),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Simuler la validation",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SOLDE
// ============================================================

Widget _currentBalanceBox(
  double balance,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.account_balance_wallet_rounded,
          color: Color(0xFF1953FF),
          size: 30,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Solde actuel",
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "${balance.toStringAsFixed(0)} DA",
              style: const TextStyle(
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
// MÉTHODE DE PAIEMENT
// ============================================================

Widget _paymentMethod({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(
      bottom: 9,
    ),
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
                  color: const Color(
                    0xFFEAF0FF,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(
                    0xFF1953FF,
                  ),
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
                        color: Color(
                          0xFF172033,
                        ),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(
                          0xFF718096,
                        ),
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
// MESSAGE ERREUR
// ============================================================

void _showErrorMessage(
  BuildContext context,
  String message,
) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

// ============================================================
// AUTRES MÉTHODES DE PAIEMENT
// ============================================================

void _showComingSoon(
  BuildContext context,
  String method,
) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "$method sera bientôt disponible.",
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
