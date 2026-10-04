import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  // ============================================================
  // DESIGN TOKENS
  // ============================================================

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color danger = Color(0xFFE5484D);

  // ============================================================
  // UTILISATEUR FIREBASE
  // ============================================================

  User? get _currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  // ============================================================
  // DONNÉES DU QR
  // ============================================================

  String get _qrData {
    final user = _currentUser;

    if (user == null) {
      return '';
    }

    final data = {
      'type': 'moovly_transport',
      'userId': user.uid,
    };

    return jsonEncode(data);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      backgroundColor: bgLight,

      // IMPORTANT :
      // Aucun bottomNavigationBar ici.
      // Le navbar de HomeScreen reste utilisé.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        _buildHeader(),

                        const SizedBox(height: 35),

                        // ==================================================
                        // QR
                        // ==================================================

                        if (user != null) _buildQr() else _buildNoUser(),

                        const SizedBox(height: 25),

                        // ==================================================
                        // INFORMATIONS PASSAGER
                        // ==================================================

                        if (user != null) _buildPassenger(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mon QR',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textDark,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Présentez votre QR pour valider votre trajet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VRAI QR CODE
  // ============================================================

  Widget _buildQr() {
    return Container(
      width: 300,
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: QrImageView(
          // Données réelles de l'utilisateur Firebase
          data: _qrData,

          version: QrVersions.auto,

          size: 260,

          backgroundColor: Colors.white,

          errorCorrectionLevel: QrErrorCorrectLevel.M,

          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: textDark,
          ),

          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: textDark,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATIONS PASSAGER
  // ============================================================

  Widget _buildPassenger() {
    final user = _currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'ID : ${user.uid}',
        style: const TextStyle(
          color: primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // AUCUN UTILISATEUR
  // ============================================================

  Widget _buildNoUser() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_rounded,
                color: danger,
                size: 45,
              ),
              SizedBox(height: 15),
              Text(
                'Utilisateur non connecté',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Connectez-vous pour afficher votre QR.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textMuted,
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
