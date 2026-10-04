import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';

class WalletScreen extends StatefulWidget {
  final ValueChanged<double>? onBalanceChanged;

  const WalletScreen({
    super.key,
    this.onBalanceChanged,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color darkBlue = Color(0xFF172B68);
  static const Color background = Color(0xFFF7F9FC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF18A563);
  static const Color danger = Color(0xFFE5484D);
  static const Color gold = Color(0xFFD4AF37);

  // ============================================================
  // DATA
  // ============================================================

  double balance = 0.0;

  String selectedPlan = "";
  DateTime? subscriptionExpiration;

  DocumentReference<Map<String, dynamic>>? _cardReference;

  bool _isLoadingBalance = true;
  bool _isProcessing = false;

  List<Map<String, dynamic>> transactions = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _loadActiveSubscription();
    _loadTransactions();
  }

  // ============================================================
// LOAD ACTIVE SUBSCRIPTION FROM FIRESTORE
// ============================================================
  Future<void> _loadActiveSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("Aucun utilisateur connecté.");
        return;
      }

      final userReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final snapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('id_user', isEqualTo: userReference)
          .where('statut', isEqualTo: 'actif')
          .get();

      debugPrint(
        "SUBSCRIPTION : ${snapshot.docs.length} abonnement(s) actif(s) trouvé(s)",
      );

      final now = Timestamp.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        debugPrint("SUBSCRIPTION DATA : $data");

        final dynamic typeValue = data['type'];
        final dynamic expirationValue = data['date_expiration'];

        // Vérifier l'expiration

        if (expirationValue is Timestamp &&
            expirationValue.compareTo(now) <= 0) {
          await doc.reference.update({
            'statut': 'expiré',
          });

          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            final userReference =
                FirebaseFirestore.instance.collection('users').doc(user.uid);

            // Vérifier si la notification existe déjà
            final existingNotification = await FirebaseFirestore.instance
                .collection('notifications')
                .where('id_user', isEqualTo: userReference)
                .where('type', isEqualTo: 'alerte')
                .where('title', isEqualTo: 'Abonnement expiré')
                .where(
                  'message',
                  isEqualTo:
                      'Votre abonnement ${typeValue.toString().toUpperCase()} a expiré.',
                )
                .limit(1)
                .get();

            // Créer la notification seulement si elle n'existe pas
            if (existingNotification.docs.isEmpty) {
              await FirebaseFirestore.instance.collection('notifications').add({
                'id_user': userReference,
                'type': 'alerte',
                'title': 'Abonnement expiré',
                'message':
                    'Votre abonnement ${typeValue.toString().toUpperCase()} a expiré.',
                'date_envoi': Timestamp.now(),
                'lu': false,
              });

              debugPrint('🔔 Notification d expiration créée.');
            } else {
              debugPrint('ℹ️ Notification d expiration déjà existante.');
            }
          }

          debugPrint(
            "Abonnement ${doc.id} marqué comme expiré.",
          );

          continue;
        }

        // Vérifier l'abonnement valide
        if (typeValue is String &&
            typeValue.isNotEmpty &&
            expirationValue is Timestamp &&
            expirationValue.compareTo(now) > 0) {
          final String type = typeValue;
          final Timestamp expiration = expirationValue;

          if (!mounted) return;

          setState(() {
            selectedPlan = type.toUpperCase();
            subscriptionExpiration = expiration.toDate();
          });

          await _checkSubscriptionExpiration(
            expiration.toDate(),
          );

          debugPrint(
            "SUBSCRIPTION TYPE : ${type.toUpperCase()}",
          );

          debugPrint(
            "SUBSCRIPTION EXPIRATION : ${expiration.toDate()}",
          );

          return;
        }
      }

      // Aucun abonnement valide
      if (!mounted) return;

      setState(() {
        selectedPlan = "";
        subscriptionExpiration = null;
      });

      debugPrint("Aucun abonnement valide trouvé.");
    } catch (e) {
      debugPrint("Erreur chargement abonnement : $e");
    }
  }

  Future<void> _checkSubscriptionExpiration(DateTime expiration) async {
    final now = DateTime.now();
    final difference = expiration.difference(now);

    if (difference.inSeconds > 0 && difference.inDays <= 3) {
      final daysRemaining = difference.inDays;

      final String message = daysRemaining == 1
          ? 'Votre abonnement $selectedPlan expire demain.'
          : 'Votre abonnement $selectedPlan expire dans $daysRemaining jours.';

      debugPrint(
        "⚠️ Abonnement $selectedPlan expire dans $daysRemaining jour(s).",
      );

      // ============================================================
      // 1. NOTIFICATION ANDROID
      // ============================================================

      await NotificationService.showSubscriptionExpiration(
        plan: selectedPlan,
        daysRemaining: daysRemaining,
      );

      // ============================================================
      // 2. NOTIFICATION DANS L'APPLICATION
      // ============================================================

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final userReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.collection('notifications').add({
        'id_user': userReference,
        'type': 'alerte',
        'title': 'Expiration de votre abonnement',
        'message': message,
        'date_envoi': Timestamp.now(),
        'lu': false,
      });

      debugPrint(
        '🔔 Notification d expiration ajoutée dans Firestore.',
      );
    }
  }

  // ============================================================
  // LOAD WALLET FROM FIRESTORE
  // ============================================================

  Future<void> _loadWalletData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("Aucun utilisateur Firebase connecté.");

        if (mounted) {
          setState(() {
            _isLoadingBalance = false;
          });
        }

        return;
      }

      debugPrint("Wallet - utilisateur : ${user.uid}");

      final userReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final snapshot = await FirebaseFirestore.instance
          .collection('carte')
          .where('id_user', isEqualTo: userReference)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("Aucune carte trouvée pour cet utilisateur.");

        if (mounted) {
          setState(() {
            balance = 0.0;
            _isLoadingBalance = false;
          });

          widget.onBalanceChanged?.call(0.0);
        }

        return;
      }

      final cardDocument = snapshot.docs.first;

      _cardReference = cardDocument.reference;

      final data = cardDocument.data();

      final dynamic firestoreBalance = data['solde'];

      double loadedBalance = 0.0;

      if (firestoreBalance is num) {
        loadedBalance = firestoreBalance.toDouble();
      } else if (firestoreBalance is String) {
        loadedBalance = double.tryParse(firestoreBalance) ?? 0.0;
      }

      if (!mounted) return;

      setState(() {
        balance = loadedBalance;
        _isLoadingBalance = false;
      });

      widget.onBalanceChanged?.call(loadedBalance);

      debugPrint(
        "Solde Wallet récupéré depuis Firestore : $loadedBalance DA",
      );
    } catch (e) {
      debugPrint("Erreur chargement Wallet : $e");

      if (!mounted) return;

      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  // ============================================================
  // GET CARD REFERENCE
  // ============================================================

  Future<DocumentReference<Map<String, dynamic>>?> _getCardReference() async {
    if (_cardReference != null) {
      return _cardReference;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final userReference =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await FirebaseFirestore.instance
        .collection('carte')
        .where('id_user', isEqualTo: userReference)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    _cardReference = snapshot.docs.first.reference;

    return _cardReference;
  }

  // ============================================================
  // UPDATE BALANCE IN FIRESTORE
  // ============================================================

  Future<bool> _updateFirestoreBalance(double newBalance) async {
    try {
      final cardReference = await _getCardReference();

      if (cardReference == null) {
        debugPrint("Impossible de trouver la carte utilisateur.");
        return false;
      }

      await cardReference.update({
        'solde': newBalance,
      });

      if (!mounted) return false;

      setState(() {
        balance = newBalance;
      });

      widget.onBalanceChanged?.call(newBalance);

      return true;
    } catch (e) {
      debugPrint("Erreur mise à jour solde Firestore : $e");
      return false;
    }
  }
  // ============================================================
// LOAD TRANSACTIONS FROM FIRESTORE
// ============================================================

  Future<void> _loadTransactions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("Transactions : aucun utilisateur connecté.");
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // ----------------------------------------------------------
      // 1. Récupérer les paiements du Wallet
      // ----------------------------------------------------------

      final userReference = firestore.collection('users').doc(user.uid);

      final paymentsSnapshot = await firestore
          .collection('payments')
          .where('userId', isEqualTo: userReference)
          .get();

      final List<Map<String, dynamic>> loadedTransactions = [];

      for (final doc in paymentsSnapshot.docs) {
        final data = doc.data();

        final status = data['status'];

        // On affiche uniquement les paiements réussis
        if (status != 'success') continue;

        final amount = data['amount'];
        final date = data['date_paiement'];
        final method = data['method'];

        double transactionAmount = 0;

        if (amount is num) {
          transactionAmount = amount.toDouble();
        }

        DateTime? transactionDate;

        if (date is Timestamp) {
          transactionDate = date.toDate();
        }

        String title = "Recharge Wallet";
        IconData icon = Icons.account_balance_wallet_rounded;
        bool positive = true;

        if (method == 'agency') {
          title = "Recharge en agence";
          icon = Icons.store_rounded;
        } else if (method == 'card') {
          title = "Recharge par carte";
          icon = Icons.credit_card_rounded;
        } else if (method == 'baridimob') {
          title = "Recharge BaridiMob";
          icon = Icons.phone_android_rounded;
        } else if (method == 'edahabia') {
          title = "Recharge Edahabia";
          icon = Icons.credit_card_rounded;
        } else if (method == 'qr') {
          title = "Paiement QR";
          icon = Icons.qr_code_rounded;
          positive = false;
        }

        loadedTransactions.add({
          "title": title,
          "date": transactionDate,
          "amount": transactionAmount,
          "icon": icon,
          "positive": positive,
        });
      }

      // ----------------------------------------------------------
      // 2. Récupérer les abonnements
      // ----------------------------------------------------------

      final subscriptionsSnapshot = await firestore
          .collection('subscriptions')
          .where('id_user', isEqualTo: userReference)
          .get();

      for (final doc in subscriptionsSnapshot.docs) {
        final data = doc.data();

        final amount = data['prix'];
        final date = data['date_debut'];
        final type = data['type'];

        double transactionAmount = 0;

        if (amount is num) {
          transactionAmount = amount.toDouble();
        }

        DateTime? transactionDate;

        if (date is Timestamp) {
          transactionDate = date.toDate();
        }

        String plan = "Abonnement";

        if (type is String && type.isNotEmpty) {
          plan = "Abonnement ${type.toUpperCase()}";
        }

        loadedTransactions.add({
          "title": plan,
          "date": transactionDate,
          "amount": transactionAmount,
          "icon": Icons.workspace_premium_rounded,
          "positive": false,
        });
      }

      // ----------------------------------------------------------
      // 3. Trier du plus récent au plus ancien
      // ----------------------------------------------------------

      loadedTransactions.sort((a, b) {
        final dateA = a["date"] as DateTime?;
        final dateB = b["date"] as DateTime?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      // ----------------------------------------------------------
      // 4. Convertir la date pour l'affichage
      // ----------------------------------------------------------

      for (final transaction in loadedTransactions) {
        final date = transaction["date"] as DateTime?;

        if (date == null) {
          transaction["date"] = "Date inconnue";
          continue;
        }

        transaction["date"] = "${date.day.toString().padLeft(2, '0')}/"
            "${date.month.toString().padLeft(2, '0')}/"
            "${date.year} à "
            "${date.hour.toString().padLeft(2, '0')}:"
            "${date.minute.toString().padLeft(2, '0')}";
      }

      if (!mounted) return;

      setState(() {
        transactions
          ..clear()
          ..addAll(loadedTransactions);
      });

      debugPrint(
        "TRANSACTIONS : ${loadedTransactions.length} transaction(s) chargée(s)",
      );
    } catch (e) {
      debugPrint("Erreur chargement transactions : $e");
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: dark,
              size: 22,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Mon Wallet",
          style: TextStyle(
            color: dark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _showTransactionHistory,
                icon: const Icon(
                  Icons.receipt_long_rounded,
                  color: dark,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletCard(),
              const SizedBox(height: 30),
              _buildSubscriptionSection(),
              const SizedBox(height: 30),
              _buildTransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSubscriptionDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$day/$month/$year";
  }
  // ============================================================
  // WALLET CARD
  // ============================================================

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2855D9),
            Color(0xFF111A3D),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1953FF).withOpacity(0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // =====================================================
            // FORME DÉCORATIVE 1
            // =====================================================

            Positioned(
              right: -55,
              top: -65,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5CFF).withOpacity(0.22),
                ),
              ),
            ),

            // =====================================================
            // FORME DÉCORATIVE 2
            // =====================================================

            Positioned(
              right: -20,
              bottom: -85,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // =====================================================
            // FORME DÉCORATIVE 3
            // =====================================================

            Positioned(
              left: -70,
              bottom: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5CFF).withOpacity(0.12),
                ),
              ),
            ),

            // =====================================================
            // CONTENU
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // TOP : WALLET
                  // PAS DE QR ICI
                  // =================================================

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Wallet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // =================================================
                  // SOLDE
                  // =================================================

                  Text(
                    "Solde disponible",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  _isLoadingBalance
                      ? const SizedBox(
                          height: 38,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          "${balance.toStringAsFixed(0)} DZD",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),

                  const SizedBox(height: 6),

                  // =================================================
                  // ABONNEMENT
                  // =================================================

                  if (selectedPlan.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selectedPlan.toLowerCase() == 'gold'
                                ? gold
                                : Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            selectedPlan,
                            style: TextStyle(
                              color: selectedPlan.toLowerCase() == 'gold'
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            subscriptionExpiration != null
                                ? "Expire le ${subscriptionExpiration!.day.toString().padLeft(2, '0')}/"
                                    "${subscriptionExpiration!.month.toString().padLeft(2, '0')}/"
                                    "${subscriptionExpiration!.year}"
                                : "Abonnement actif",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // =================================================
                  // RECHARGER
                  // =================================================

                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 43,
                      child: ElevatedButton.icon(
                        onPressed: _openRechargeSheet,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 17,
                        ),
                        label: const Text(
                          "Recharger",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.96),
                          foregroundColor: const Color(0xFF2855D9),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUBSCRIPTIONS
  // ============================================================

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Abonnements",
          style: TextStyle(
            color: dark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        _subscriptionCard(
          title: "PREMIUM",
          price: "200 DA / mois",
          description: "Une expérience sans publicité",
          features: const [
            "Sans publicité",
            "Notifications avancées",
          ],
          color: primaryBlue,
          isSelected: selectedPlan == "PREMIUM",
          onTap: () {
            _choosePlan("PREMIUM", 200);
          },
        ),
        const SizedBox(height: 12),
        _subscriptionCard(
          title: "GOLD",
          price: "400 DA / mois",
          description: "L'expérience Moovly complète",
          features: const [
            "Tout le contenu PREMIUM",
            "Moovly AI 🤖",
            "Suggestions intelligentes",
            "Fonctionnalités avancées",
          ],
          color: gold,
          isSelected: selectedPlan == "GOLD",
          onTap: () {
            _choosePlan("GOLD", 400);
          },
        ),
      ],
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: isSelected ? color : border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // PLAN
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  // ABONNEMENT ACTUEL
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: color,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                "ABONNEMENT ACTUEL",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),

                  const SizedBox(width: 8),

                  // PRIX
                  Text(
                    price,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              // DESCRIPTION
              Text(
                description,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 13),

              // FEATURES
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: dark,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
  // CHOOSE PLAN
  // ============================================================

  void _choosePlan(String plan, double price) {
    if (_isProcessing) return;

    if (selectedPlan == plan) {
      _showGreenMessage(
        "Vous utilisez déjà l'abonnement $plan.",
      );
      return;
    }

    if (balance < price) {
      _showInsufficientBalance(plan, price);
      return;
    }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  "Passer à $plan ?",
                  style: const TextStyle(
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$price DA seront retirés de votre Wallet.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Solde actuel",
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${balance.toStringAsFixed(2)} DA",
                              style: const TextStyle(
                                color: dark,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _activatePlan(plan, price);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Confirmer — $price DA",
                      style: const TextStyle(
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

  Future<void> _activatePlan(
    String plan,
    double price,
  ) async {
    if (_isProcessing) return;

    // ============================================================
    // UTILISATEUR CONNECTÉ
    // ============================================================

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showErrorMessage(
        "Aucun utilisateur connecté.",
      );
      return;
    }

    // ============================================================
    // VÉRIFICATION DU SOLDE
    // ============================================================

    if (balance < price) {
      _showInsufficientBalance(plan, price);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // ==========================================================
      // RÉFÉRENCE UTILISATEUR
      // ==========================================================

      final userReference = firestore.collection('users').doc(user.uid);

      // ==========================================================
      // RÉFÉRENCE CARTE
      // ==========================================================

      final cardReference = await _getCardReference();

      if (cardReference == null) {
        throw Exception("Carte utilisateur introuvable.");
      }

      // ==========================================================
      // DATES
      // ==========================================================

      final dateDebut = DateTime.now();

      final dateExpiration = DateTime(
        dateDebut.year,
        dateDebut.month + 1,
        dateDebut.day,
        dateDebut.hour,
        dateDebut.minute,
        dateDebut.second,
      );

      // ==========================================================
      // 1️⃣ CHERCHER L'ANCIEN ABONNEMENT ACTIF
      // ==========================================================

      final activeSubscriptions = await firestore
          .collection('subscriptions')
          .where(
            'id_user',
            isEqualTo: userReference,
          )
          .where(
            'statut',
            isEqualTo: 'actif',
          )
          .get();

      // ==========================================================
      // 2️⃣ DÉSACTIVER L'ANCIEN ABONNEMENT
      // ==========================================================

      for (final doc in activeSubscriptions.docs) {
        await doc.reference.update({
          'statut': 'remplacé',
        });
      }

      // ==========================================================
      // 3️⃣ CALCULER LE NOUVEAU SOLDE
      // ==========================================================

      final newBalance = balance - price;

      // ==========================================================
      // 4️⃣ METTRE À JOUR LE SOLDE DE LA CARTE
      // ==========================================================

      await cardReference.update({
        'solde': newBalance,
      });

      // ==========================================================
      // 5️⃣ CRÉER LE NOUVEL ABONNEMENT
      // ==========================================================

      final subscriptionData = {
        'id_user': userReference,
        'type': plan.trim().toLowerCase(),
        'prix': price,
        'statut': 'actif',
        'date_debut': Timestamp.fromDate(dateDebut),
        'date_expiration': Timestamp.fromDate(dateExpiration),
      };

      debugPrint("Création abonnement : $subscriptionData");

      await firestore.collection('subscriptions').add(subscriptionData);
      // ==========================================================
// NOTIFICATION : ACHAT D'ABONNEMENT
// ==========================================================

      await firestore.collection('notifications').add({
        'id_user': userReference,
        'userId': 'users/${user.uid}',
        'title': 'Abonnement activé',
        'message':
            'Votre abonnement ${plan.toUpperCase()} a été activé avec succès.',
        'type': 'subscription',
        'lu': false,
        'date_envoi': FieldValue.serverTimestamp(),
      });
      // ==========================================================
      // 6️⃣ METTRE À JOUR L'INTERFACE
      // ==========================================================

      if (!mounted) return;

      setState(() {
        balance = newBalance;

        // IMPORTANT :
        // PREMIUM → GOLD
        // GOLD → PREMIUM
        selectedPlan = plan;

        transactions.insert(
          0,
          {
            "title": "Abonnement $plan",
            "date": "Aujourd'hui, maintenant",
            "amount": -price,
            "icon": Icons.workspace_premium_rounded,
            "positive": false,
          },
        );

        _isProcessing = false;
      });

      // Synchronisation avec HomeScreen
      widget.onBalanceChanged?.call(newBalance);

      // ==========================================================
      // MESSAGE
      // ==========================================================

      _showGreenMessage(
        "Abonnement $plan activé avec succès !",
      );
    } catch (e) {
      debugPrint(
        "❌ Erreur activation abonnement : $e",
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showErrorMessage(
        "Impossible d'activer l'abonnement.",
      );
    }
  }

  // ============================================================
  // INSUFFICIENT BALANCE
  // ============================================================

  void _showInsufficientBalance(
    String plan,
    double price,
  ) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: danger,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Solde insuffisant",
                  style: TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Votre solde est de ${balance.toStringAsFixed(2)} DA.\n"
                  "L'abonnement $plan coûte ${price.toStringAsFixed(0)} DA.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0057FF),
                          Color(0xFF2855D9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openRechargeSheet();
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        "Recharger mon Wallet",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
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
  // RECHARGE SHEET
  // ============================================================

  void _openRechargeSheet() {
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
                  const Center(
                    child: Text(
                      "Recharger mon compte",
                      style: TextStyle(
                        color: dark,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _currentBalanceBox(),
                  const SizedBox(height: 22),
                  const Text(
                    "Choisir un montant",
                    style: TextStyle(
                      color: dark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 11),
                  _amountGrid(),
                  const SizedBox(height: 22),
                  const Text(
                    "Méthode de paiement",
                    style: TextStyle(
                      color: dark,
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
                      _showComingSoon("Carte bancaire");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.phone_android_rounded,
                    title: "BaridiMob",
                    subtitle: "Paiement mobile",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon("BaridiMob");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.credit_card_rounded,
                    title: "Edahabia",
                    subtitle: "Paiement via Algérie Poste",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon("Edahabia");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.store_rounded,
                    title: "Recharge en agence",
                    subtitle: "Paiement en espèces",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAgencyRecharge();
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
  // CURRENT BALANCE
  // ============================================================

  Widget _currentBalanceBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Solde actuel",
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${balance.toStringAsFixed(2)} DA",
                  style: const TextStyle(
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
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
  // AMOUNTS
  // ============================================================

  Widget _amountGrid() {
    final amounts = [100, 300, 500];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amounts.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        // Montants fixes
        if (index < amounts.length) {
          final amount = amounts[index];

          return InkWell(
            onTap: () {
              Navigator.pop(context);
              _selectPaymentAmount(amount.toDouble());
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Text(
                "$amount DA",
                style: const TextStyle(
                  color: dark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }

        // Montant personnalisé
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            _openCustomAmountDialog();
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryBlue.withOpacity(0.25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: primaryBlue,
                  size: 18,
                ),
                SizedBox(width: 7),
                Text(
                  "Autre montant",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                _selectPaymentAmount(amount);
              },
              child: const Text("Continuer"),
            ),
          ],
        );
      },
    );
  }
  // ============================================================
  // PAYMENT METHOD
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
                    color: primaryBlue,
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
                          color: dark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECT AMOUNT
  // ============================================================

  void _selectPaymentAmount(double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Montant de recharge",
                    style: TextStyle(
                      color: dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${amount.toStringAsFixed(0)} DA",
                    style: const TextStyle(
                      color: primaryBlue,
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
                      _showComingSoon("Carte bancaire");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.phone_android_rounded,
                    title: "BaridiMob",
                    subtitle: "Paiement mobile",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon("BaridiMob");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.credit_card_rounded,
                    title: "Edahabia",
                    subtitle: "Paiement via Algérie Poste",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon("Edahabia");
                    },
                  ),
                  _paymentMethod(
                    icon: Icons.store_rounded,
                    title: "Recharge en agence",
                    subtitle: "Espèces + validation par agent",
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAgencyRecharge(amount: amount);
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
  // AGENCY RECHARGE
  // ============================================================

  void _openAgencyRecharge({
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
          child: SingleChildScrollView(
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
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Présentez votre identifiant Wallet à l'agent",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
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
                    color: dark,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "MOOV-WALLET",
                  style: TextStyle(
                    color: dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Montant : ${amount.toStringAsFixed(0)} DA",
                  style: const TextStyle(
                    color: primaryBlue,
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
                        color: gold,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          "Donnez le montant en espèces à l'agent. "
                          "La recharge sera validée après confirmation.",
                          style: TextStyle(
                            color: dark,
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
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _simulateAgencyValidation(amount);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text(
                      "Simuler la validation",
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
  // SIMULATE RECHARGE
  // ============================================================

  Future<void> _simulateAgencyValidation(double amount) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final newBalance = balance + amount;

    final successUpdate = await _updateFirestoreBalance(newBalance);

    if (!mounted) return;

    if (!successUpdate) {
      setState(() {
        _isProcessing = false;
      });

      _showErrorMessage(
        "Impossible de mettre à jour votre Wallet.",
      );

      return;
    }

// ============================================================
// ENREGISTRER LA TRANSACTION DANS PAYMENTS
// ============================================================

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Utilisateur non connecté.");
      }

      final userReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final cardReference = await _getCardReference();

      if (cardReference == null) {
        throw Exception("Carte utilisateur introuvable.");
      }

      await FirebaseFirestore.instance.collection('payments').add({
        'amount': amount.toInt(),
        'cardId': cardReference,
        'date_paiement': Timestamp.now(),
        'method': 'agency',
        'status': 'success',
        'userId': userReference,
      });

      debugPrint("✅ Paiement enregistré dans payments.");
      await FirebaseFirestore.instance.collection('notifications').add({
        'id_user': userReference,
        'userId': 'users/${user.uid}',
        'title': 'Recharge réussie',
        'message':
            'Votre compte a été rechargé de ${amount.toStringAsFixed(0)} DA.',
        'type': 'recharge',
        'lu': false,
        'date_envoi': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Erreur enregistrement paiement : $e");

      setState(() {
        _isProcessing = false;
      });

      _showErrorMessage(
        "Recharge effectuée, mais la transaction n'a pas pu être enregistrée.",
      );

      return;
    }

    setState(() {
      transactions.insert(
        0,
        {
          "title": "Recharge en agence",
          "date": "Aujourd'hui, maintenant",
          "amount": amount,
          "icon": Icons.store_rounded,
          "positive": true,
        },
      );

      _isProcessing = false;
    });

    _showGreenMessage(
      "Recharge de ${amount.toStringAsFixed(0)} DA réussie !",
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Dernières transactions",
              style: TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            GestureDetector(
              onTap: _showTransactionHistory,
              child: const Text(
                "Voir tout",
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (transactions.isEmpty)
          _emptyTransactions()
        else
          ...transactions
              .take(4)
              .map((transaction) => _transactionTile(transaction)),
      ],
    );
  }

  Widget _transactionTile(
    Map<String, dynamic> transaction,
  ) {
    final bool positive = transaction["positive"] as bool;
    final double amount = transaction["amount"] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
                  positive ? const Color(0xFFE7F8EF) : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction["icon"] as IconData,
              color: positive ? success : danger,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction["title"] as String,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction["date"] as String,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${positive ? "+" : ""}${amount.toStringAsFixed(2)} DA",
            style: TextStyle(
              color: positive ? success : danger,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: muted,
            size: 35,
          ),
          SizedBox(height: 8),
          Text(
            "Aucune transaction",
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  void _showTransactionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Historique des transactions",
                    style: TextStyle(
                      color: dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return _transactionTile(
                          transactions[index],
                        );
                      },
                    ),
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
  // MESSAGES
  // ============================================================

  void _showGreenMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: danger,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryBlue,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          "$method sera connecté au système de paiement dans la version finale.",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
