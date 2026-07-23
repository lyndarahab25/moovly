import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../bus/bus_lines_screen.dart';
import '../bus/map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../qr/qr_payment_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

enum _MockUserPlan { ticketSimple, weekly, monthly, premium, gold }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF1D4ED8);
  static const background = Color(0xFFF8FAFC);
  static const success = Color(0xFF18A563);
  static const textDark = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _MockUserPlan _currentPlan = _MockUserPlan.gold;

  bool get _isGold => _currentPlan == _MockUserPlan.gold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeScreen.background,
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                _buildCurrentPlanCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Services rapides'),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.13,
                  children: [
                    _ServiceCard(
                      icon: Icons.directions_bus_rounded,
                      title: 'Bus',
                      iconColor: HomeScreen.primary,
                      bgColor: const Color(0xFFEFF6FF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BusLinesScreen()),
                      ),
                    ),
                    _ServiceCard(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Abonnement',
                      iconColor: HomeScreen.secondary,
                      bgColor: const Color(0xFFEFF2FF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                      ),
                    ),
                    _ServiceCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Paiement QR',
                      iconColor: HomeScreen.success,
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrPaymentScreen()),
                      ),
                    ),
                    _ServiceCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Profil',
                      iconColor: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF5F3FF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Notifications récentes'),
                const SizedBox(height: 10),
                _buildNotificationsSection(),
                const SizedBox(height: 20),
                _buildNearbyBusesSection(),
                const SizedBox(height: 18),
                _buildAiSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Lynda 👋',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: HomeScreen.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Votre accès actuel est affiché ci-dessous.',
                style: TextStyle(color: HomeScreen.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_outlined, color: HomeScreen.textDark, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: HomeScreen.textDark),
    );
  }

  Widget _buildCurrentPlanCard() {
    switch (_currentPlan) {
      case _MockUserPlan.ticketSimple:
        return _buildTicketCard();
      case _MockUserPlan.weekly:
        return _buildSubscriptionCard(
          title: 'Abonnement Hebdomadaire',
          subtitle: 'Accès standard sur 7 jours',
          status: 'Valide 7 jours',
          highlight: 'Valide jusqu\'au 29/07/2026',
          accentColor: HomeScreen.primary,
          showQr: true,
          qrValue: 'MOOVLY|TICKET|WEEKLY',
        );
      case _MockUserPlan.monthly:
        return _buildSubscriptionCard(
          title: 'Abonnement Mensuel',
          subtitle: 'Trajets illimités',
          status: 'Actif',
          highlight: 'Expire le 31/08/2026',
          accentColor: HomeScreen.secondary,
          showQr: true,
          qrValue: 'MOOVLY|TICKET|MONTHLY',
        );
      case _MockUserPlan.premium:
        return _buildPremiumCard();
      case _MockUserPlan.gold:
        return _buildGoldCard();
    }
  }

  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.confirmation_num_rounded, color: HomeScreen.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ticket Simple', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
                    SizedBox(height: 4),
                    Text('Accès unique pour un trajet', style: TextStyle(color: HomeScreen.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoPill(title: 'Validité', value: 'Aujourd\'hui', color: const Color(0xFFEFF6FF)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(title: 'QR', value: 'Prêt', color: const Color(0xFFECFDF5)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: QrImageView(
              data: 'MOOVLY|TICKET|SIMPLE',
              version: QrVersions.auto,
              size: 160,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String subtitle,
    required String status,
    required String highlight,
    required Color accentColor,
    required bool showQr,
    required String qrValue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, HomeScreen.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.credit_card_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _InfoPill(title: 'Statut', value: status, color: Colors.white.withOpacity(0.18))),
              const SizedBox(width: 10),
              Expanded(child: _InfoPill(title: 'Échéance', value: highlight, color: Colors.white.withOpacity(0.14))),
            ],
          ),
          if (showQr) ...[
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: QrImageView(
                    data: qrValue,
                    version: QrVersions.auto,
                    size: 110,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: HomeScreen.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moovly Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
                    SizedBox(height: 4),
                    Text('Votre abonnement Premium est actif', style: TextStyle(color: HomeScreen.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Avantages Premium', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
          const SizedBox(height: 8),
          _BenefitRow(icon: Icons.verified_rounded, label: 'Publicités supprimées'),
          _BenefitRow(icon: Icons.priority_high_rounded, label: 'Accès prioritaire aux services'),
          _BenefitRow(icon: Icons.support_agent_rounded, label: 'Support premium'),
        ],
      ),
    );
  }

  Widget _buildGoldCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), HomeScreen.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moovly Gold', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Accès complet à la mobilité intelligente', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('Badge Gold', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          _BenefitRow(icon: Icons.map_rounded, label: 'Bus à proximité débloqués', isDark: true),
          _BenefitRow(icon: Icons.smart_toy_rounded, label: 'Moovly AI débloqué', isDark: true),
          _BenefitRow(icon: Icons.route_rounded, label: 'Suivi GPS en temps réel', isDark: true),
        ],
      ),
    );
  }

  Widget _buildNearbyBusesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 10)),
        ],
      ),
      child: _isGold
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Bus à proximité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('Gold', style: TextStyle(color: HomeScreen.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 170,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen())),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(36.3749, 3.9020),
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
                          MarkerLayer(
                            markers: [
                              Marker(point: LatLng(36.3754, 3.9025), width: 36, height: 36, child: _MiniBusMarker(color: HomeScreen.primary)),
                              Marker(point: LatLng(36.3744, 3.9032), width: 36, height: 36, child: _MiniBusMarker(color: HomeScreen.success)),
                              Marker(point: LatLng(36.3748, 3.9008), width: 36, height: 36, child: _MiniBusMarker(color: const Color(0xFFF59E0B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.lock_outline_rounded, color: HomeScreen.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Bus à proximité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
                          SizedBox(height: 4),
                          Text('Disponible uniquement pour les utilisateurs Gold.', style: TextStyle(color: HomeScreen.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Passez à Gold pour activer la carte GPS temps réel et le suivi des bus.', style: TextStyle(color: HomeScreen.textDark, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: const Text('Passer à Gold'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAiSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isGold ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 10)),
        ],
      ),
      child: _isGold
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Moovly AI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Suggestions de trajet et recommandations instantanées.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Tag('Suggestion de trajet'),
                    _Tag('Temps d\'arrivée 14 min'),
                    _Tag('Recommandation rapide'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Itinéraire conseillé : ligne 7 vers la Gare Centrale • 2 changements minimum', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: HomeScreen.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Moovly AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomeScreen.textDark)),
                          SizedBox(height: 4),
                          Text('Fonctionnalité réservée aux abonnés Gold.', style: TextStyle(color: HomeScreen.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: const Text('Passer à Gold'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _NotificationTile(
            icon: Icons.route_rounded,
            title: 'Trajet recommandé',
            subtitle: 'Le meilleur itinéraire pour 18:30 vient d’être calculé.',
            color: HomeScreen.primary,
          ),
          _NotificationTile(
            icon: Icons.announcement_rounded,
            title: 'Mise à jour du réseau',
            subtitle: 'Les lignes 5 et 8 circulent plus vite aujourd’hui.',
            color: HomeScreen.success,
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoPill({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _BenefitRow({required this.icon, required this.label, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : HomeScreen.primary, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: isDark ? Colors.white : HomeScreen.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _NotificationTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: HomeScreen.textDark, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: HomeScreen.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(color: HomeScreen.primary, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height * 0.58), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint..strokeWidth = 3);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), paint..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BusDot extends StatelessWidget {
  final Color color;
  const _BusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.25), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.directions_bus, color: Colors.white, size: 14),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ServiceCard({required this.icon, required this.title, required this.iconColor, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconColor.withOpacity(0.14)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [iconColor.withOpacity(0.95), iconColor.withOpacity(0.75)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: iconColor.withOpacity(0.18), blurRadius: 10),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: HomeScreen.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: HomeScreen.primary,
          unselectedItemColor: HomeScreen.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: (i) {
            if (i == currentIndex) return;
            Widget page = const HomeScreen();
            if (i == 1) page = const BusLinesScreen();
            if (i == 2) page = const QrPaymentScreen();
            if (i == 3) page = const SubscriptionsScreen();
            if (i == 4) page = const ProfileScreen();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => page,
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_bus_outlined), activeIcon: Icon(Icons.directions_bus_rounded), label: 'Bus'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_outlined), activeIcon: Icon(Icons.qr_code_rounded), label: 'QR'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), activeIcon: Icon(Icons.credit_card_rounded), label: 'Abonnements'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _MiniBusMarker extends StatelessWidget {
  final Color color;
  const _MiniBusMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 6)],
      ),
      child: const Center(child: Icon(Icons.directions_bus, color: Colors.white, size: 16)),
    );
  }
}
