import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneLoginVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const PhoneLoginVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<PhoneLoginVerificationScreen> createState() =>
      _PhoneLoginVerificationScreenState();
}

class _PhoneLoginVerificationScreenState
    extends State<PhoneLoginVerificationScreen> {
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

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showMessage('Veuillez entrer le code à 6 chiffres.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Code incorrect. Vérifiez le SMS reçu.';
          break;

        case 'session-expired':
          message = 'Le code a expiré. Veuillez demander un nouveau code.';
          break;

        case 'too-many-requests':
          message = 'Trop de tentatives. Réessayez plus tard.';
          break;

        case 'credential-already-in-use':
          message = 'Ce numéro est déjà associé à un autre compte.';
          break;

        default:
          message = e.message ?? 'Une erreur est survenue.';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Une erreur est survenue.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 25, 30, 30),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: primaryBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Vérification du numéro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Un code de vérification a été envoyé au\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 35),
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
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
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
                            'Vérifier et se connecter',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
