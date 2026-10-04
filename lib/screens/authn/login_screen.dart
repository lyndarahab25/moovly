import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_login_verification_screen.dart';

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

              if (_isEmailLogin) ...[
                _buildPasswordField(),
                const SizedBox(height: 7),
              ],

              // ==================================================
              // FORGOT PASSWORD
              // ==================================================

              if (_isEmailLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleForgotPassword,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: primaryBlue,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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
            onTap: _loginWithGoogle,
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
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        _showMessage('Impossible de récupérer le compte Google.');
        return;
      }

      // Créer / mettre à jour le profil utilisateur
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber,
        'provider': 'google',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Vérifier si la carte Moovly existe déjà
      final carteQuery = await FirebaseFirestore.instance
          .collection('carte')
          .where(
            'id_user',
            isEqualTo: userRef,
          )
          .limit(1)
          .get();

      // Créer une carte standard pour un nouvel utilisateur
      if (carteQuery.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('carte').add({
          'id_user': userRef,
          'numero': 'MV-${user.uid.substring(0, 8).toUpperCase()}',
          'solde': 0.0,
          'type': 'standard',
          'statut': 'active',
          'date_expiration': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      _showMessage('Connexion Google réussie !');

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Erreur lors de la connexion avec Google.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Erreur Google : $e');
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // ============================================================
    // CONNEXION PAR E-MAIL
    // ============================================================

    if (_isEmailLogin) {
      if (email.isEmpty) {
        _showMessage('Veuillez entrer votre adresse e-mail.');
        return;
      }

      if (password.isEmpty) {
        _showMessage('Veuillez entrer votre mot de passe.');
        return;
      }

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        _showMessage('Connexion réussie !');

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } on FirebaseAuthException catch (e) {
        String message;

        switch (e.code) {
          case 'invalid-credential':
          case 'wrong-password':
          case 'user-not-found':
            message = 'E-mail ou mot de passe incorrect.';
            break;

          case 'invalid-email':
            message = 'Adresse e-mail invalide.';
            break;

          case 'user-disabled':
            message = 'Ce compte a été désactivé.';
            break;

          case 'too-many-requests':
            message = 'Trop de tentatives. Réessayez plus tard.';
            break;

          default:
            message = 'Erreur : ${e.message}';
        }

        if (!mounted) return;
        _showMessage(message);
      } catch (e) {
        if (!mounted) return;
        _showMessage('Une erreur est survenue : $e');
      }

      return;
    }

    // ============================================================
    // CONNEXION PAR NUMÉRO → SMS
    // ============================================================

    if (phone.isEmpty) {
      _showMessage('Veuillez entrer votre numéro de téléphone.');
      return;
    }

    // Conversion 07XXXXXXXX → +2137XXXXXXXX
    if (phone.startsWith('0')) {
      phone = '+213${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      _showMessage(
        'Entrez votre numéro au format +213XXXXXXXXX.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);

            if (!mounted) return;

            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
          } on FirebaseAuthException catch (e) {
            if (mounted) {
              _showMessage(
                e.message ?? 'Impossible de vous connecter.',
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message;

          switch (e.code) {
            case 'invalid-phone-number':
              message = 'Numéro de téléphone invalide.';
              break;

            case 'too-many-requests':
              message = 'Trop de tentatives. Réessayez plus tard.';
              break;

            case 'quota-exceeded':
              message = 'Limite SMS atteinte. Réessayez plus tard.';
              break;

            default:
              message = e.message ?? 'Impossible d’envoyer le SMS.';
          }

          if (mounted) {
            _showMessage(message);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhoneLoginVerificationScreen(
                verificationId: verificationId,
                phone: phone,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showMessage(
          e.message ?? 'Une erreur est survenue.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Une erreur est survenue.');
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Veuillez saisir votre adresse e-mail.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Un lien de réinitialisation a été envoyé à votre adresse e-mail.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Adresse e-mail invalide.';
          break;

        case 'user-not-found':
          message = 'Aucun compte associé à cette adresse e-mail.';
          break;

        case 'too-many-requests':
          message = 'Trop de tentatives. Réessayez plus tard.';
          break;

        default:
          message = 'Impossible d’envoyer l’e-mail de réinitialisation.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Une erreur est survenue. Veuillez réessayer.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: primaryBlue,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: primaryBlue,
                size: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
