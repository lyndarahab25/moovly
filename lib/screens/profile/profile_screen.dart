import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../authn/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ─────────────────────────────────────────────────────────────
  // DESIGN TOKENS — cohérents avec HomeScreen
  // ─────────────────────────────────────────────────────────────

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color darkBlue = Color(0xFF111A3D);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color lightBlue = Color(0xFFEAF0FF);
  static const Color red = Color(0xFFDC2626);

  Color get surfaceColor => _darkMode ? const Color(0xFF1E293B) : Colors.white;

  Color get primaryTextColor => _darkMode ? Colors.white : textDark;

  Color get secondaryTextColor =>
      _darkMode ? const Color(0xFF94A3B8) : textMuted;

  Color get dynamicBorderColor =>
      _darkMode ? const Color(0xFF334155) : borderColor;

  Color get dynamicLightBlue => _darkMode ? const Color(0xFF263B63) : lightBlue;
  // ─────────────────────────────────────────────────────────────
  // USER DATA
  // ─────────────────────────────────────────────────────────────

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _wilaya = '';

  String _language = 'Français';
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || !mounted) return;

      final data = doc.data();

      if (data == null) return;

      final name = (data['name'] ?? '').toString();
      final nameParts = name.trim().split(' ');

      setState(() {
        _firstName = nameParts.isNotEmpty ? nameParts.first : '';
        _lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _email = (data['email'] ?? user.email ?? '').toString();
        _phone = (data['phone'] ?? '').toString();
        _wilaya = (data['wilaya'] ?? '').toString();
      });
    } catch (e) {
      debugPrint('Erreur chargement profil : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 26),
              _buildProfileCard(),
              const SizedBox(height: 36),
              const SizedBox(height: 16),
              _buildAccountItem(
                icon: Icons.person_outline_rounded,
                title: 'Informations personnelles',
                subtitle: 'Nom, email et téléphone',
                onTap: _showPersonalInfo,
              ),
              const SizedBox(height: 12),
              _buildAccountItem(
                icon: Icons.credit_card_outlined,
                title: 'Mes abonnements',
                subtitle: 'Gérer votre abonnement Moovly',
                onTap: _showSubscriptions,
              ),
              const SizedBox(height: 12),
              _buildAccountItem(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Validateur QR',
                subtitle: 'Valider le trajet',
                onTap: () {
                  Navigator.pushNamed(context, '/validator');
                },
              ),
              const SizedBox(height: 12),
              _buildAccountItem(
                icon: Icons.settings_outlined,
                title: 'Paramètres',
                subtitle: 'Langue, apparence et sécurité',
                onTap: _showSettings,
              ),
              const SizedBox(height: 12),
              _buildAccountItem(
                icon: Icons.help_outline_rounded,
                title: 'Aide & Support',
                subtitle: 'Besoin d’aide avec Moovly ?',
                onTap: _showSupport,
              ),
              const SizedBox(height: 36),
              _buildLogoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // FLÈCHE RETOUR
          Positioned(
            left: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF172033),
                  size: 22,
                ),
              ),
            ),
          ),

          // TITRE CENTRÉ
          const Center(
            child: Text(
              'Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Color(0xFF172033),
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    final fullName = '$_firstName $_lastName';

    return Container(
      width: double.infinity,
      height: 166,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D5BE3),
            Color(0xFF111A3D),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Décoration arrière
            Positioned(
              right: -45,
              top: -45,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            Positioned(
              right: 35,
              bottom: -60,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.035),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Row(
                children: [
                  // Avatar sans photo
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBlue,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.38),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _firstName.isNotEmpty
                            ? _firstName[0].toUpperCase()
                            : 'L',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 39,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Icône profil
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white70,
                      size: 22,
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

  // ─────────────────────────────────────────────────────────────
  // ACCOUNT ITEM
  // ─────────────────────────────────────────────────────────────

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: primaryBlue,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
        ),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: const Color(0xFFDC2626).withOpacity(0.20),
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INFORMATIONS PERSONNELLES
  // ─────────────────────────────────────────────────────────────

  void _showPersonalInfo() {
    final firstNameController = TextEditingController(text: _firstName);
    final lastNameController = TextEditingController(text: _lastName);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Modifiez vos informations de compte.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildTextField(
                      controller: firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 13),
                    _buildTextField(
                      controller: lastNameController,
                      label: 'Nom',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 13),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 13),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (firstNameController.text.trim().isEmpty ||
                              lastNameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty) {
                            return;
                          }

                          setState(() {
                            _firstName = firstNameController.text.trim();
                            _lastName = lastNameController.text.trim();
                            _email = emailController.text.trim();
                            _phone = phoneController.text.trim();
                          });

                          Navigator.pop(sheetContext);

                          _showMessage(
                            'Informations mises à jour',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
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
                          'Enregistrer les modifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showChangePassword();
                        },
                        icon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 19,
                        ),
                        label: const Text(
                          'Modifier le mot de passe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textDark,
                          side: const BorderSide(
                            color: borderColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
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
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TEXT FIELD
  // ─────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: textMuted,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CHANGE PASSWORD
  // ─────────────────────────────────────────────────────────────

  void _showChangePassword() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Sécurité',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Modifiez votre mot de passe.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                _buildTextField(
                  controller: oldController,
                  label: 'Mot de passe actuel',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 13),
                _buildTextField(
                  controller: newController,
                  label: 'Nouveau mot de passe',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 13),
                _buildTextField(
                  controller: confirmController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.check_circle_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (newController.text.isEmpty ||
                          newController.text != confirmController.text) {
                        _showMessage(
                          'Les mots de passe ne correspondent pas.',
                        );
                        return;
                      }

                      Navigator.pop(sheetContext);

                      _showMessage(
                        'Mot de passe modifié avec succès',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Modifier le mot de passe',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
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

  // ─────────────────────────────────────────────────────────────
  // ABONNEMENTS
  // ─────────────────────────────────────────────────────────────

  void _showSubscriptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Mes abonnements',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              _subscriptionOption(
                icon: Icons.credit_card_rounded,
                title: 'Premium',
                subtitle: 'Abonnement standard Moovly',
                color: primaryBlue,
                active: true,
              ),
              const SizedBox(height: 12),
              _subscriptionOption(
                icon: Icons.auto_awesome_rounded,
                title: 'Gold',
                subtitle: 'Moovly AI + suivi en temps réel',
                color: const Color(0xFFD4AF37),
                active: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _subscriptionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? color.withOpacity(0.35) : borderColor,
          width: active ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
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
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Actif',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PARAMÈTRES
  // ─────────────────────────────────────────────────────────────

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Paramètres',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Langue
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: borderColor),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: primaryBlue,
                        ),
                      ),
                      title: const Text(
                        'Langue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      subtitle: Text(
                        _language,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: textMuted,
                      ),
                      onTap: () {
                        _showLanguagePicker(
                          sheetContext,
                          setSheetState,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mode sombre
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: borderColor),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          _darkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: primaryBlue,
                        ),
                      ),
                      title: const Text(
                        'Mode sombre',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      subtitle: Text(
                        _darkMode ? 'Activé' : 'Désactivé',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                      value: _darkMode,
                      activeColor: primaryBlue,
                      onChanged: (value) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(value);

                        setState(() {
                          _darkMode = value;
                        });

                        setSheetState(() {});

                        _showMessage(
                          value ? 'Mode sombre activé' : 'Mode clair activé',
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notifications
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: borderColor),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: primaryBlue,
                        ),
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      subtitle: Text(
                        _notificationsEnabled ? 'Activées' : 'Désactivées',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                      value: _notificationsEnabled,
                      activeColor: primaryBlue,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });

                        setSheetState(() {});

                        _showMessage(
                          value
                              ? 'Notifications activées'
                              : 'Notifications désactivées',
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _settingsSimpleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: primaryBlue,
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
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANGUAGE PICKER
  // ─────────────────────────────────────────────────────────────

  void _showLanguagePicker(
    BuildContext parentContext,
    StateSetter setSheetState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (languageContext) {
        final languages = [
          'Français',
          'العربية',
          'English',
        ];

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choisir la langue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...languages.map(
                (language) {
                  final selected = _language == language;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected
                            ? primaryBlue.withOpacity(0.10)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.language_rounded,
                        color: selected ? primaryBlue : textMuted,
                      ),
                    ),
                    title: Text(
                      language,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: primaryBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _language = language;
                      });

                      setSheetState(() {});

                      Navigator.pop(languageContext);

                      _showMessage(
                        'Langue sélectionnée : $language',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SUPPORT
  // ─────────────────────────────────────────────────────────────

  void _showSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Aide & Support',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Comment pouvons-nous vous aider ?',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _supportItem(
                icon: Icons.help_outline_rounded,
                title: 'Questions fréquentes',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showMessage(
                    'FAQ Moovly bientôt disponible',
                  );
                },
              ),
              const SizedBox(height: 10),
              _supportItem(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Contacter le support',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showMessage(
                    'Support Moovly bientôt disponible',
                  );
                },
              ),
              const SizedBox(height: 10),
              _supportItem(
                icon: Icons.info_outline_rounded,
                title: 'À propos de Moovly',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAbout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _supportItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ABOUT
  // ─────────────────────────────────────────────────────────────

  void _showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Moovly',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Plus vite, plus proche, plus malin.\n\n'
            'Moovly est une solution intelligente pour '
            'simplifier la mobilité urbaine à Bouira.',
            style: TextStyle(
              color: textMuted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter de votre compte Moovly ?',
            style: TextStyle(
              color: textMuted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Fermer la boîte de dialogue
                Navigator.pop(dialogContext);

                try {
                  // 🔥 VRAIE déconnexion Firebase
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  // Retour vers Login en supprimant toutes
                  // les anciennes pages
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;

                  _showMessage(
                    'Impossible de se déconnecter. Veuillez réessayer.',
                  );
                }
              },
              child: const Text(
                'Se déconnecter',
                style: TextStyle(
                  color: red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // ─────────────────────────────────────────────────────────────
  // SNACKBAR
  // ─────────────────────────────────────────────────────────────

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: textDark,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
