import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moovly/screens/subscriptions/subscriptions_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../bus/bus_lines_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen>
    with TickerProviderStateMixin {
  static const blue = Color(0xFF0a1628);
  static const sky = Color(0xFF0a1628);
  static const bg = Color(0xFFF0F6FF);
  static const dark = Color(0xFF0a1628);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF1D9E75);
  static const greenLight = Color(0xFFE1F5EE);

  late Timer _timer;
  int _secondsLeft = 30 * 60;
  final String _qrData =
      'MOOVLY:ABN-EC-2026-00123:L02:${DateTime.now().millisecondsSinceEpoch}';
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scanAnim;

  // Historique complet des paiements
  final List<Map<String, dynamic>> _allPayments = [
    {
      'title': 'Ligne A → Gare Centrale',
      'date': '12/07/2026 — 08:15',
      'amount': '-50 DA',
      'success': true
    },
    {
      'title': 'Ligne B → Université',
      'date': '11/07/2026 — 17:40',
      'amount': '-50 DA',
      'success': true
    },
    {
      'title': 'Ligne L05 → Centre',
      'date': '10/07/2026 — 13:22',
      'amount': '-75 DA',
      'success': false
    },
    {
      'title': 'Ligne L02 → Hôpital',
      'date': '09/07/2026 — 09:10',
      'amount': '-50 DA',
      'success': true
    },
    {
      'title': 'Ligne L01 → Aéroport',
      'date': '08/07/2026 — 07:55',
      'amount': '-100 DA',
      'success': true
    },
    {
      'title': 'Ligne L04 → Théâtre',
      'date': '07/07/2026 — 16:30',
      'amount': '-50 DA',
      'success': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  String get _timeFormatted {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsLeft > 10 * 60) return green;
    if (_secondsLeft > 5 * 60) return Colors.orange;
    return Colors.red;
  }

  // ── Bouton Télécharger ────────────────────────────────────────────────────
  Future<void> _telecharger() async {
    HapticFeedback.mediumImpact();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/moovly_ticket_L02.txt');
      await file.writeAsString(
        'MOOVLY — TICKET\n'
        '================\n'
        'ID: ABN-EC-2026-00123\n'
        'Ligne: L02 — Gare → Hôpital\n'
        'Prix: 50,00 DA\n'
        'Expire le: 31/07/2026\n'
        'Statut: ACTIF\n'
        '================\n'
        'Généré par Moovly App',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Ticket téléchargé avec succès !'),
              ],
            ),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Bouton Partager ───────────────────────────────────────────────────────
  void _copierID() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(const ClipboardData(text: 'ABN-EC-2026-00123'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('ID copié dans le presse-papier !'),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ── Bouton Recharger ──────────────────────────────────────────────────────
  void _recharger() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RechargeSheet(),
    );
  }

  // ── Bouton Voir tout ──────────────────────────────────────────────────────
  void _voirTout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoriqueSheet(payments: _allPayments),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildQrCard(),
                  const SizedBox(height: 16),
                  _buildBalanceCard(),
                  const SizedBox(height: 20),
                  _buildPaymentHistory(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 2),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: blue,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0a1628), Color(0xFF185FA5)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: sky,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.directions_bus,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('Moovly',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('QR Paiement',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const Text('Scannez pour valider votre trajet',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: sky.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF0a1628), Color(0xFF185FA5)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Ticket valide — Ligne L02',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: greenLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('ACTIF',
                      style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: sky.withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: sky.withOpacity(0.1), blurRadius: 16)
                          ],
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0a1628),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0a1628),
                          ),
                        ),
                      ),
                      Positioned(top: 8, left: 8, child: _Corner()),
                      Positioned(top: 8, right: 8, child: _Corner(flipX: true)),
                      Positioned(
                          bottom: 8, left: 8, child: _Corner(flipY: true)),
                      Positioned(
                          bottom: 8,
                          right: 8,
                          child: _Corner(flipX: true, flipY: true)),
                      AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (_, __) => Positioned(
                          top: 16 + _scanAnim.value * 168,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: sky.withOpacity(0.7),
                              boxShadow: [
                                BoxShadow(
                                    color: sky.withOpacity(0.5), blurRadius: 4)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _timerColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: _timerColor, size: 16),
                      const SizedBox(width: 6),
                      Text('Expire dans $_timeFormatted',
                          style: TextStyle(
                              color: _timerColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoBox(
                          label: 'ID Abonnement',
                          value: 'ABN-EC-2026-00123',
                          icon: Icons.tag_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoBox(
                          label: 'Expire le',
                          value: '31/07/2026',
                          icon: Icons.calendar_today_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoBox(
                          label: 'Ligne',
                          value: 'L02 — Gare → Hôpital',
                          icon: Icons.directions_bus_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoBox(
                          label: 'Prix',
                          value: '50,00 DA',
                          icon: Icons.payments_outlined,
                          valueColor: sky),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Boutons Télécharger / Partager ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _telecharger,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Télécharger'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: blue,
                          side: BorderSide(color: blue.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copierID,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copier ID'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0a1628), Color(0xFF185FA5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: blue.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solde disponible',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text('120,50 DA',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // ── Bouton Recharger ────────────────────────────────────────────
          GestureDetector(
            onTap: _recharger,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: sky, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Recharger',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Derniers paiements',
                style: TextStyle(
                    color: dark, fontSize: 17, fontWeight: FontWeight.w700)),
            // ── Bouton Voir tout ────────────────────────────────────────
            TextButton(
              onPressed: _voirTout,
              child: Text('Voir tout',
                  style: TextStyle(color: sky, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Affiche seulement les 3 premiers
        ..._allPayments.take(3).map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PaymentTile(
                title: p['title'],
                date: p['date'],
                amount: p['amount'],
                success: p['success'],
              ),
            )),
      ],
    );
  }
}

// ── Recharge Bottom Sheet ──────────────────────────────────────────────────────

class _RechargeSheet extends StatefulWidget {
  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  static const sky = Color(0xFF2196F3);
  static const blue = Color(0xFF0a1628);
  double _selectedAmount = 500;
  int _selectedMethod = 0;

  static const _amounts = [100.0, 300.0, 500.0, 1000.0, 2000.0];
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
  Widget build(BuildContext context) {
    return Container(
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
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Recharger mon compte',
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
                  // Solde actuel
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Solde actuel',
                                  style: TextStyle(
                                      color: Color(0xFF185FA5), fontSize: 11)),
                              SizedBox(height: 4),
                              Text('120,50 DA',
                                  style: TextStyle(
                                      color: Color(0xFF0a1628),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Icon(Icons.account_balance_wallet,
                            color: Color(0xFF185FA5), size: 28),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choisir un montant',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                    children: [
                      ..._amounts.map((a) => GestureDetector(
                            onTap: () => setState(() => _selectedAmount = a),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color:
                                    _selectedAmount == a ? blue : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _selectedAmount == a
                                        ? blue
                                        : const Color(0xFFDCE8F8)),
                              ),
                              child: Center(
                                child: Text('${a.toInt()} DA',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedAmount == a
                                            ? Colors.white
                                            : blue)),
                              ),
                            ),
                          )),
                      GestureDetector(
                        onTap: () => _showCustomAmount(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFDCE8F8))),
                          child: const Center(
                              child: Text('Autre',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0a1628)))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                                    ? sky
                                    : const Color(0xFFDCE8F8),
                                width: _selectedMethod == i ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE6F1FB),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(m['icon'] as IconData,
                                    color: sky, size: 18),
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
                                Icon(Icons.check_circle, color: sky, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                    '${_selectedAmount.toInt()} DA ajoutés avec succès !'),
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
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Confirmer — ${_selectedAmount.toInt()} DA',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
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

  void _showCustomAmount(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Montant personnalisé'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(suffixText: 'DA', hintText: 'Ex: 750'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) setState(() => _selectedAmount = v);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ── Historique Bottom Sheet ────────────────────────────────────────────────────

class _HistoriqueSheet extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  const _HistoriqueSheet({required this.payments});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Historique des paiements',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0a1628))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _PaymentTile(
                title: payments[i]['title'],
                date: payments[i]['date'],
                amount: payments[i]['amount'],
                success: payments[i]['success'],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Corner Widget ──────────────────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final bool flipX;
  final bool flipY;
  const _Corner({this.flipX = false, this.flipY = false});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
      child: SizedBox(
          width: 20, height: 20, child: CustomPaint(painter: _CornerPainter())),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Info Box ───────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? valueColor;
  const _InfoBox(
      {required this.label,
      required this.value,
      required this.icon,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDCE8F8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: const Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(label,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? const Color(0xFF0a1628)),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Payment Tile ───────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final String title, date, amount;
  final bool success;
  const _PaymentTile(
      {required this.title,
      required this.date,
      required this.amount,
      required this.success});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE8F8)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color:
                    success ? const Color(0xFFE1F5EE) : const Color(0xFFFAECE7),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(success ? Icons.check_rounded : Icons.close_rounded,
                color:
                    success ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A),
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF0a1628))),
                const SizedBox(height: 2),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF0a1628))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: success
                        ? const Color(0xFFE1F5EE)
                        : const Color(0xFFFAECE7),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(success ? 'Réussi' : 'Échoué',
                    style: TextStyle(
                        color: success
                            ? const Color(0xFF1D9E75)
                            : const Color(0xFFE24B4A),
                        fontWeight: FontWeight.w700,
                        fontSize: 10)),
              ),
            ],
          ),
        ],
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
          border:
              Border(top: BorderSide(color: Color(0xFFDCE8F8), width: 0.5))),
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
