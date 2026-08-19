import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool _isEmailLogin = true;
  bool _obscurePassword = true;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepBlue = Color(0xFF172554);

  static const Color background = Color(0xFFF4F7FC);
  static const Color dark = Color(0xFF172033);
  static const Color muted = Color(0xFF71809D);
  static const Color fieldHint = Color(0xFFA5B0C4);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(31, 28, 31, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'Bon retour !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Connectez-vous à votre compte Moovly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // EMAIL / PHONE SELECTOR
              // ==================================================

              _buildLoginTypeSelector(),

              const SizedBox(height: 27),

              // ==================================================
              // EMAIL / PHONE
              // ==================================================

              _buildTextField(
                controller: _isEmailLogin ? _emailController : _phoneController,
                icon: Icons.person_outline_rounded,
                hint: _isEmailLogin ? 'Adresse e-mail' : 'Numéro de téléphone',
                keyboardType: _isEmailLogin
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // PASSWORD
              // ==================================================

              _buildPasswordField(),

              const SizedBox(height: 7),

              // ==================================================
              // FORGOT PASSWORD
              // ==================================================

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // LOGIN BUTTON
              // ==================================================

              _buildLoginButton(),

              const SizedBox(height: 56),

              // ==================================================
              // DIVIDER
              // ==================================================

              _buildDivider(),

              const SizedBox(height: 20),

              // ==================================================
              // SOCIAL BUTTONS
              // ==================================================

              _buildSocialButtons(),

              const SizedBox(height: 35),

              // ==================================================
              // REGISTER LINK
              // ==================================================

              _buildRegisterLink(),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL / PHONE SELECTOR
  // ============================================================

  Widget _buildLoginTypeSelector() {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F8),
        borderRadius: BorderRadius.circular(31),
        border: Border.all(
          color: const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEmailLogin = true;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isEmailLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: _isEmailLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'E-mail',
                  style: TextStyle(
                    color: _isEmailLogin ? primaryBlue : muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEmailLogin = false;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isEmailLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: !_isEmailLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    color: !_isEmailLogin ? primaryBlue : muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Row(
      children: [
        _buildIconCircle(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(31),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(-3, -3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: dark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: fieldHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 21,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField() {
    return Row(
      children: [
        _buildIconCircle(Icons.lock_outline_rounded),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(31),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(-3, -3),
                ),
              ],
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: dark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Mot de passe',
                hintStyle: const TextStyle(
                  color: fieldHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: muted,
                      size: 21,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 21,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ICON CIRCLE
  // ============================================================

  Widget _buildIconCircle(IconData icon) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: primaryBlue,
        size: 23,
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryBlue,
            deepBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
        ),
        child: const Text(
          'Se connecter',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE0E5EE),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'ou continuer avec',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE0E5EE),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL BUTTONS
  // ============================================================

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _socialButton(
            icon: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            label: 'Google',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _socialButton(
            icon: const Icon(
              Icons.apple_rounded,
              color: Colors.black,
              size: 22,
            ),
            label: 'Apple',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: dark,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REGISTER LINK
  // ============================================================

  Widget _buildRegisterLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            "Vous n'avez pas encore de compte ? ",
            style: TextStyle(
              color: muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/register',
              );
            },
            child: const Text(
              "S'inscrire",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _handleLogin() {
    final identifier = _isEmailLogin
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    final password = _passwordController.text;

    if (identifier.isEmpty) {
      _showMessage(
        _isEmailLogin
            ? 'Veuillez entrer votre adresse e-mail.'
            : 'Veuillez entrer votre numéro de téléphone.',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage('Veuillez entrer votre mot de passe.');
      return;
    }

    // Firebase sera branché après.
    Navigator.pushReplacementNamed(
      context,
      '/home',
    );
  }

  void _handleForgotPassword() {
    _showMessage(
        'La récupération du mot de passe sera disponible prochainement.');
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
