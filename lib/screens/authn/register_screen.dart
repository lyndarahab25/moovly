import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'phone_verification_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool _isEmailRegister = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedWilaya;

  // ============================================================
  // WILAYAS
  // ============================================================

  final List<String> _wilayas = [
    '01 — Adrar',
    '02 — Chlef',
    '03 — Laghouat',
    '04 — Oum El Bouaghi',
    '05 — Batna',
    '06 — Béjaïa',
    '07 — Biskra',
    '08 — Béchar',
    '09 — Blida',
    '10 — Bouira',
    '11 — Tamanrasset',
    '12 — Tébessa',
    '13 — Tlemcen',
    '14 — Tiaret',
    '15 — Tizi Ouzou',
    '16 — Alger',
    '17 — Djelfa',
    '18 — Jijel',
    '19 — Sétif',
    '20 — Saïda',
    '21 — Skikda',
    '22 — Sidi Bel Abbès',
    '23 — Annaba',
    '24 — Guelma',
    '25 — Constantine',
    '26 — Médéa',
    '27 — Mostaganem',
    '28 — M’Sila',
    '29 — Mascara',
    '30 — Ouargla',
    '31 — Oran',
    '32 — El Bayadh',
    '33 — Illizi',
    '34 — Bordj Bou Arréridj',
    '35 — Boumerdès',
    '36 — El Tarf',
    '37 — Tindouf',
    '38 — Tissemsilt',
    '39 — El Oued',
    '40 — Khenchela',
    '41 — Souk Ahras',
    '42 — Tipaza',
    '43 — Mila',
    '44 — Aïn Defla',
    '45 — Naâma',
    '46 — Aïn Témouchent',
    '47 — Ghardaïa',
    '48 — Relizane',
    '49 — Timimoun',
    '50 — Bordj Badji Mokhtar',
    '51 — Ouled Djellal',
    '52 — Béni Abbès',
    '53 — In Salah',
    '54 — In Guezzam',
    '55 — Touggourt',
    '56 — Djanet',
    '57 — El M’Ghair',
    '58 — El Meniaâ',
    '59 — Aflou',
    '60 — Barika',
    '61 — El Kantara',
    '62 — Bir El Ater',
    '63 — El Aricha',
    '64 — Ksar Chellala',
    '65 — Aïn Oussera',
    '66 — Messaad',
    '67 — Ksar El Boukhari',
    '68 — Bou Saâda',
    '69 — El Bayadh Sidi Cheikh',
  ];

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepBlue = Color(0xFF172554);

  static const Color background = Color(0xFFF4F7FC);
  static const Color dark = Color(0xFF172033);
  static const Color muted = Color(0xFF71809D);
  static const Color fieldHint = Color(0xFFA5B0C4);

  static const Color borderColor = Color(0xFFE1E5EE);

  Future<void> _registerWithPhone({
    required String name,
    required String phone,
    required String wilaya,
  }) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(
              credential,
            );

            final user = userCredential.user;

            if (user == null) return;

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'uid': user.uid,
              'name': name,
              'email': null,
              'phone': phone,
              'wilaya': wilaya,
              'createdAt': FieldValue.serverTimestamp(),
            });

            await FirebaseFirestore.instance.collection('carte').add({
              'id_user':
                  FirebaseFirestore.instance.collection('users').doc(user.uid),
              'numero': 'MV-${user.uid.substring(0, 8).toUpperCase()}',
              'solde': 0.0,
              'statut': 'active',
              'date_expiration': null,
            });

            if (!mounted) return;

            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
          } catch (e) {
            if (mounted) {
              _showMessage('Erreur lors de la création du compte.');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message;

          switch (e.code) {
            case 'invalid-phone-number':
              message = 'Le numéro de téléphone est invalide.';
              break;

            case 'too-many-requests':
              message = 'Trop de tentatives. Réessayez plus tard.';
              break;

            case 'quota-exceeded':
              message = 'La limite de SMS a été atteinte.';
              break;

            default:
              message = 'Impossible d’envoyer le SMS : ${e.message ?? e.code}';
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
              builder: (_) => PhoneVerificationScreen(
                verificationId: verificationId,
                phone: phone,
                name: name,
                wilaya: wilaya,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Erreur : $e');
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                'Créer un compte',
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
                'Rejoignez Moovly et simplifiez vos trajets au quotidien',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // EMAIL / PHONE
              // ==================================================

              _buildRegisterTypeSelector(),

              const SizedBox(height: 22),

              // ==================================================
              // NAME
              // ==================================================

              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline_rounded,
                hint: 'Nom complet',
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // EMAIL / PHONE
              // ==================================================

              _buildTextField(
                controller:
                    _isEmailRegister ? _emailController : _phoneController,
                icon: _isEmailRegister
                    ? Icons.mail_outline_rounded
                    : Icons.phone_android_outlined,
                hint:
                    _isEmailRegister ? 'Adresse e-mail' : 'Numéro de téléphone',
                keyboardType: _isEmailRegister
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // WILAYA
              // ==================================================

              _buildWilayaField(),

              const SizedBox(height: 12),

              // ==================================================
              // PASSWORD
              // ==================================================

              if (_isEmailRegister) ...[
                // ==================================================
                // PASSWORD
                // ==================================================

                _buildPasswordField(
                  controller: _passwordController,
                  hint: 'Créer un mot de passe',
                  obscure: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: 'Confirmer le mot de passe',
                  obscure: _obscureConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 22),
              ] else ...[
                const SizedBox(height: 10),
              ],

              // ==================================================
              // REGISTER BUTTON
              // ==================================================

              _buildRegisterButton(),

              const SizedBox(height: 40),

              // ==================================================
              // DIVIDER
              // ==================================================

              _buildDivider(),

              const SizedBox(height: 20),

              // ==================================================
              // SOCIAL
              // ==================================================

              _buildSocialButtons(),

              const SizedBox(height: 35),

              // ==================================================
              // LOGIN LINK
              // ==================================================

              _buildLoginLink(),

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

  Widget _buildRegisterTypeSelector() {
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
                  _isEmailRegister = true;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isEmailRegister ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: _isEmailRegister
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
                    color: _isEmailRegister ? primaryBlue : muted,
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
                  _isEmailRegister = false;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isEmailRegister ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: !_isEmailRegister
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
                    color: !_isEmailRegister ? primaryBlue : muted,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
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
              controller: controller,
              obscureText: obscure,
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
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      obscure
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
  // WILAYA
  // ============================================================

  Widget _buildWilayaField() {
    return GestureDetector(
      onTap: _showWilayaPicker,
      child: Row(
        children: [
          _buildIconCircle(Icons.map_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedWilaya ?? 'Sélectionnez votre Wilaya',
                      style: TextStyle(
                        color: _selectedWilaya == null ? fieldHint : dark,
                        fontSize: 14,
                        fontWeight: _selectedWilaya == null
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: muted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WILAYA PICKER
  // ============================================================

  void _showWilayaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.72,
          decoration: const BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Choisir votre Wilaya',
                  style: TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    itemCount: _wilayas.length,
                    itemBuilder: (context, index) {
                      final wilaya = _wilayas[index];
                      final selected = wilaya == _selectedWilaya;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? primaryBlue : borderColor,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedWilaya = wilaya;
                            });
                            Navigator.pop(sheetContext);
                          },
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: selected ? primaryBlue : muted,
                          ),
                          title: Text(
                            wilaya,
                            style: TextStyle(
                              color: selected ? primaryBlue : dark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryBlue,
                                )
                              : null,
                        ),
                      );
                    },
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
  // REGISTER BUTTON
  // ============================================================

  Widget _buildRegisterButton() {
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
        onPressed: _handleRegister,
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
          "S'inscrire",
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
            onTap: _registerWithGoogle,
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
  // LOGIN LINK
  // ============================================================

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            'Vous avez déjà un compte ? ',
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
                '/login',
              );
            },
            child: const Text(
              'Se connecter',
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
  // REGISTER ACTION
  // ============================================================
  Future<void> _registerWithGoogle() async {
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
        _showMessage('Impossible de créer le compte avec Google.');
        return;
      }

      // ==========================================================
      // USERS
      // ==========================================================

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber,
        'wilaya': _selectedWilaya,
        'provider': 'google',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ==========================================================
      // CARTE MOOVLY
      // ==========================================================

      final carteQuery = await FirebaseFirestore.instance
          .collection('carte')
          .where('id_user', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (carteQuery.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('carte').add({
          'id_user': user.uid,
          'numero': 'MV-${user.uid.substring(0, 8).toUpperCase()}',
          'solde': 0.0,
          'type': 'standard',
          'statut': 'active',
          'date_expiration': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }

      _showMessage(
        'Connexion Google impossible : ${e.description ?? e.code}',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Erreur lors de l’inscription avec Google.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Impossible de créer le compte avec Google.',
      );
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    // ============================================================
    // VALIDATION COMMUNE
    // ============================================================

    if (name.isEmpty) {
      _showMessage('Veuillez entrer votre nom complet.');
      return;
    }

    if (_selectedWilaya == null) {
      _showMessage('Veuillez sélectionner votre Wilaya.');
      return;
    }

    // ============================================================
    // INSCRIPTION PAR TÉLÉPHONE
    // ============================================================

    if (!_isEmailRegister) {
      if (phone.isEmpty) {
        _showMessage('Veuillez entrer votre numéro de téléphone.');
        return;
      }

      // Exemple pour l'Algérie :
      // 0555000001 → +213555000001
      String formattedPhone = phone.replaceAll(' ', '');

      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+213${formattedPhone.substring(1)}';
      }

      if (!formattedPhone.startsWith('+')) {
        _showMessage(
          'Veuillez entrer un numéro valide, par exemple +213555000001.',
        );
        return;
      }

      await _registerWithPhone(
        name: name,
        phone: formattedPhone,
        wilaya: _selectedWilaya!,
      );

      return;
    }

    // ============================================================
    // INSCRIPTION PAR E-MAIL
    // ============================================================

    if (email.isEmpty) {
      _showMessage('Veuillez entrer votre adresse e-mail.');
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showMessage('Veuillez créer un mot de passe.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Les mots de passe ne correspondent pas.');
      return;
    }

    // ============================================================
    // FIREBASE EMAIL
    // ============================================================

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        _showMessage('Impossible de créer le compte.');
        return;
      }

      // ==========================================================
// USERS
// ==========================================================

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': null,
        'wilaya': _selectedWilaya,
        'createdAt': FieldValue.serverTimestamp(),
      });

// ==========================================================
// CARTE MOOVLY
// ==========================================================

      await FirebaseFirestore.instance.collection('carte').add({
        'id_user': FirebaseFirestore.instance.collection('users').doc(user.uid),
        'numero': 'MV-${user.uid.substring(0, 8).toUpperCase()}',
        'solde': 0.0,
        'type': 'standard',
        'statut': 'active',
        'date_expiration': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage('Compte créé avec succès !');

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Cette adresse e-mail est déjà utilisée.';
          break;

        case 'invalid-email':
          message = 'Adresse e-mail invalide.';
          break;

        case 'weak-password':
          message = 'Le mot de passe est trop faible.';
          break;

        case 'operation-not-allowed':
          message = 'L’inscription par e-mail n’est pas activée.';
          break;

        default:
          message = 'Une erreur est survenue : ${e.message ?? e.code}';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Erreur : $e');
      }
    }
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
