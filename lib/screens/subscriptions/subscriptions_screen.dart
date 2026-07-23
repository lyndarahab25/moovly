import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bus/bus_lines_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_payment_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  static const blue = Color(0xFF0a1628);
  static const sky = Color(0xFF0a1628);
  static const bg = Color(0xFFF0F6FF);
  static const dark = Color(0xFF0a1628);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF1D9E75);
  static const orange = Color(0xFFFF8A00);
  static const purple = Color(0xFF6D4DE6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Abonnements',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PremiumCard(),
              const SizedBox(height: 24),
              const Text(
                'Mes abonnements',
                style: TextStyle(
                  color: dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _SubscriptionTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Premium Mensuel',
                price: '120,50 DA',
                status: 'Actif',
                dates: '01/07/2026 - 31/07/2026',
                color: sky,
                premium: true,
                onTap: () => _showDetailSheet(
                  context,
                  title: 'Premium Mensuel',
                  price: '120,50 DA',
                  status: 'Actif',
                  dates: '01/07/2026 - 31/07/2026',
                  color: sky,
                  icon: Icons.workspace_premium_rounded,
                  features: [
                    'Trajets illimités sur toutes les lignes',
                    'Priorité à bord',
                    'Offres exclusives partenaires',
                    'Support client prioritaire',
                    'QR Code dédié',
                  ],
                ),
              ),
              _SubscriptionTile(
                icon: Icons.directions_bus_rounded,
                title: 'Standard Mensuel',
                price: '80,00 DA',
                status: 'Expiré',
                dates: '01/06/2026 - 30/06/2026',
                color: muted,
                onTap: () => _showDetailSheet(
                  context,
                  title: 'Standard Mensuel',
                  price: '80,00 DA',
                  status: 'Expiré',
                  dates: '01/06/2026 - 30/06/2026',
                  color: muted,
                  icon: Icons.directions_bus_rounded,
                  features: [
                    'Accès aux lignes urbaines',
                    '30 trajets par mois',
                    'Valable 30 jours',
                  ],
                ),
              ),
              _SubscriptionTile(
                icon: Icons.school_rounded,
                title: 'Étudiant Mensuel',
                price: '60,00 DA',
                status: 'Expiré',
                dates: '01/05/2026 - 31/05/2026',
                color: orange,
                onTap: () => _showDetailSheet(
                  context,
                  title: 'Étudiant Mensuel',
                  price: '60,00 DA',
                  status: 'Expiré',
                  dates: '01/05/2026 - 31/05/2026',
                  color: orange,
                  icon: Icons.school_rounded,
                  features: [
                    'Tarif réduit pour étudiants',
                    'Justificatif requis',
                    '20 trajets par mois',
                    'Valable 30 jours',
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showAcheterSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Acheter un abonnement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sky,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Offres disponibles',
                style: TextStyle(
                  color: dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'Mensuel Standard',
                price: '80,00 DA',
                description: 'Accès aux lignes urbaines pendant 30 jours',
                icon: Icons.directions_bus_rounded,
                color: sky,
                features: [
                  'Accès aux lignes urbaines',
                  '30 trajets par mois',
                  'Valable 30 jours',
                ],
                onTap: () => _showAcheterSheet(context, plan: 'Standard'),
              ),
              _PlanCard(
                title: 'Mensuel Étudiant',
                price: '60,00 DA',
                description: 'Tarif réduit pour étudiants avec justificatif',
                icon: Icons.school_rounded,
                color: orange,
                features: [
                  'Tarif réduit pour étudiants',
                  'Justificatif requis',
                  '20 trajets par mois',
                  'Valable 30 jours',
                ],
                onTap: () => _showAcheterSheet(context, plan: 'Étudiant'),
              ),
              _PlanCard(
                title: 'Premium Mensuel',
                price: '120,50 DA',
                description: 'Trajets illimités, priorité et offres exclusives',
                icon: Icons.workspace_premium_rounded,
                color: purple,
                features: [
                  'Trajets illimités',
                  'Priorité à bord',
                  'Offres exclusives partenaires',
                  'Support prioritaire',
                  'QR Code dédié',
                ],
                onTap: () => _showAcheterSheet(context, plan: 'Premium'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }

  // ── Detail Sheet ───────────────────────────────────────────────────────────
  void _showDetailSheet(
    BuildContext context, {
    required String title,
    required String price,
    required String status,
    required String dates,
    required Color color,
    required IconData icon,
    required List<String> features,
  }) {
    final isActive = status == 'Actif';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F6FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8F8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [blue, color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        Text(price,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE1F5EE)
                          : const Color(0xFFDCE8F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF1D9E75) : muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCE8F8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Color(0xFF2196F3), size: 18),
                          const SizedBox(width: 10),
                          Text(dates,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0a1628))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Inclus dans cet abonnement',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF0a1628))),
                    const SizedBox(height: 10),
                    ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Color(0xFF1D9E75), size: 14),
                              ),
                              const SizedBox(width: 10),
                              Text(f,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF0a1628))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    if (isActive)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const QrPaymentScreen()),
                            );
                          },
                          icon: const Icon(Icons.qr_code_rounded),
                          label: const Text('Voir mon QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0a1628),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    if (!isActive) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAcheterSheet(context);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Renouveler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Acheter Sheet ──────────────────────────────────────────────────────────
  void _showAcheterSheet(BuildContext context, {String plan = 'Standard'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AcheterSheet(selectedPlan: plan),
    );
  }
}

// ── Acheter Sheet Widget ───────────────────────────────────────────────────────

class _AcheterSheet extends StatefulWidget {
  final String selectedPlan;
  const _AcheterSheet({required this.selectedPlan});

  @override
  State<_AcheterSheet> createState() => _AcheterSheetState();
}

class _AcheterSheetState extends State<_AcheterSheet> {
  late String _selectedPlan;
  int _selectedMethod = 0;

  static const _plans = [
    {
      'title': 'Standard',
      'price': '80,00 DA',
      'icon': Icons.directions_bus_rounded,
      'color': Color(0xFF2196F3)
    },
    {
      'title': 'Étudiant',
      'price': '60,00 DA',
      'icon': Icons.school_rounded,
      'color': Color(0xFFFF8A00)
    },
    {
      'title': 'Premium',
      'price': '120,50 DA',
      'icon': Icons.workspace_premium_rounded,
      'color': Color(0xFF6D4DE6)
    },
  ];

  static const _methods = [
    {'label': 'Carte bancaire', 'sub': 'Visa / CIB', 'icon': Icons.credit_card},
    {
      'label': 'BaridiMob',
      'sub': 'Paiement mobile',
      'icon': Icons.phone_android
    },
    {'label': 'Chez le contrôleur', 'sub': 'En espèces', 'icon': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.selectedPlan;
  }

  String get _selectedPrice {
    final plan = _plans.firstWhere(
      (p) => p['title'] == _selectedPlan,
      orElse: () => _plans[0],
    );
    return plan['price'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F6FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE8F8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Acheter un abonnement',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0a1628))),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Choix du plan
                  const Text('Choisir un plan',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  ..._plans.map((p) {
                    final isSelected = _selectedPlan == p['title'];
                    final color = p['color'] as Color;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _selectedPlan = p['title'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? color : const Color(0xFFDCE8F8),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(p['icon'] as IconData,
                                    color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${p['title']} Mensuel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isSelected
                                        ? color
                                        : const Color(0xFF0a1628),
                                  ),
                                ),
                              ),
                              Text(
                                p['price'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isSelected
                                      ? color
                                      : const Color(0xFF0a1628),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? color
                                    : const Color(0xFFDCE8F8),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Méthode de paiement
                  const Text('Méthode de paiement',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  ..._methods.asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedMethod == i
                                ? const Color(0xFFE6F1FB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedMethod == i
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFFDCE8F8),
                              width: _selectedMethod == i ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F1FB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(m['icon'] as IconData,
                                    color: const Color(0xFF2196F3), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m['label'] as String,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Color(0xFF0a1628))),
                                    Text(m['sub'] as String,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                              if (_selectedMethod == i)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF2196F3), size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Récap
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCE8F8)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Plan sélectionné',
                                style: TextStyle(
                                    color: Color(0xFF6B7280), fontSize: 12)),
                            Text('$_selectedPlan Mensuel',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF0a1628))),
                          ],
                        ),
                        const Divider(height: 16, color: Color(0xFFDCE8F8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total à payer',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0a1628))),
                            Text(_selectedPrice,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF2196F3))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton confirmer
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Abonnement $_selectedPlan acheté !'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1D9E75),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0a1628),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      child: Text('Confirmer — $_selectedPrice'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Card ───────────────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0a1628), Color(0xFF185FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0a1628).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -20,
            child: Icon(
              Icons.directions_bus_filled_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      size: 14, color: Color(0xFF0a1628)),
                  SizedBox(width: 4),
                  Text('Meilleur',
                      style: TextStyle(
                          color: Color(0xFF0a1628),
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Premium Mensuel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text('120,50 DA',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Row(
                children: [
                  _WhiteInfo(label: 'Début', value: '01/07/2026'),
                  _WhiteInfo(label: 'Fin', value: '31/07/2026'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrPaymentScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0a1628),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Voir mon abonnement',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── White Info ─────────────────────────────────────────────────────────────────

class _WhiteInfo extends StatelessWidget {
  final String label;
  final String value;
  const _WhiteInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Subscription Tile ──────────────────────────────────────────────────────────

class _SubscriptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final String status;
  final String dates;
  final Color color;
  final bool premium;
  final VoidCallback onTap;

  const _SubscriptionTile({
    required this.icon,
    required this.title,
    required this.price,
    required this.status,
    required this.dates,
    required this.color,
    required this.onTap,
    this.premium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Actif';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE8F8)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0a1628))),
                  const SizedBox(height: 2),
                  Text('$price  •  $dates',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE1F5EE)
                    : const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF1D9E75)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan Card ──────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE8F8)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0a1628))),
                  const SizedBox(height: 2),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: color)),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Color(0xFF6B7280)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCE8F8), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0a1628),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == currentIndex) return;
          Widget page = const HomeScreen();
          if (index == 1) page = const BusLinesScreen();
          if (index == 2) page = const QrPaymentScreen();
          if (index == 3) page = const SubscriptionsScreen();
          if (index == 4) page = const ProfileScreen();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => page,
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus_rounded),
              label: 'Bus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_outlined),
              activeIcon: Icon(Icons.qr_code_rounded),
              label: 'QR'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_rounded),
              activeIcon: Icon(Icons.credit_card_rounded),
              label: 'Abonnements'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
        ],
      ),
    );
  }
}
