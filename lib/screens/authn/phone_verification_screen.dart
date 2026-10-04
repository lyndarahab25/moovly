import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String name;
  final String wilaya;

  const PhoneVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.name,
    required this.wilaya,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepBlue = Color(0xFF172554);
  static const Color background = Color(0xFFF4F7FC);
  static const Color dark = Color(0xFF172033);
  static const Color muted = Color(0xFF71809D);

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ============================================================
  // VÉRIFICATION DU CODE SMS
  // ============================================================

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showMessage(
        'Veuillez entrer le code à 6 chiffres reçu par SMS.',
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // CRÉER LE CREDENTIAL FIREBASE
      // ----------------------------------------------------------

      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      // ----------------------------------------------------------
      // CONNECTER L'UTILISATEUR
      // ----------------------------------------------------------

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Impossible de récupérer le compte utilisateur.',
        );
      }

      final firestore = FirebaseFirestore.instance;

      final userRef = firestore.collection('users').doc(user.uid);

      // ----------------------------------------------------------
      // CRÉER LE DOCUMENT USER
      // ----------------------------------------------------------

      await userRef.set({
        'uid': user.uid,
        'name': widget.name,
        'email': null,
        'phone': widget.phone,
        'wilaya': widget.wilaya,
        'provider': 'phone',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ----------------------------------------------------------
      // CRÉER LA CARTE MOOVLY
      // ----------------------------------------------------------

      final carteQuery = await firestore
          .collection('carte')
          .where(
            'id_user',
            isEqualTo: userRef,
          )
          .limit(1)
          .get();

      if (carteQuery.docs.isEmpty) {
        await firestore.collection('carte').add({
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

      _showMessage(
        'Compte créé avec succès !',
      );

      // ----------------------------------------------------------
      // ALLER À L'ACCUEIL
      // ----------------------------------------------------------

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Code de vérification incorrect.';
          break;

        case 'session-expired':
          message = 'Le code a expiré. Veuillez recommencer l’inscription.';
          break;

        case 'invalid-verification-id':
          message = 'Session de vérification invalide. Veuillez recommencer.';
          break;

        case 'credential-already-in-use':
          message = 'Ce numéro est déjà associé à un compte.';
          break;

        default:
          message = 'Erreur de vérification : ${e.message ?? e.code}';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Impossible de vérifier le numéro. Réessayez.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
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
        leading: IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: dark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            30,
            20,
            30,
            30,
          ),
          child: Column(
            children: [
              // --------------------------------------------------
              // ICÔNE
              // --------------------------------------------------

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  color: primaryBlue,
                  size: 38,
                ),
              ),

              const SizedBox(height: 25),

              // --------------------------------------------------
              // TITRE
              // --------------------------------------------------

              const Text(
                'Vérifier votre numéro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Nous avons envoyé un code de vérification '
                'par SMS à votre numéro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.phone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 35),

              // --------------------------------------------------
              // CODE
              // --------------------------------------------------

              Container(
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
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(
                      color: Color(0xFFA5B0C4),
                      fontSize: 22,
                      letterSpacing: 8,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 17,
                    ),
                  ),
                  onSubmitted: (_) => _verifyCode(),
                ),
              ),

              const SizedBox(height: 25),

              // --------------------------------------------------
              // BOUTON
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 58,
                child: Container(
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
                    onPressed: _isLoading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Vérifier et continuer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --------------------------------------------------
              // INFO
              // --------------------------------------------------

              const Text(
                'Le code peut prendre quelques secondes à arriver.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
