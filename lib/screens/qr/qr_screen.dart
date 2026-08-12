import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  // ============================================================
  // DESIGN TOKENS — cohérents avec HomeScreen
  // ============================================================

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // ============================================================
  // DONNÉES DU QR
  // ============================================================

  String get _qrData {
    final data = {
      'type': 'moovly_transport',
      'passenger_id': 'MV-20481',
      'user': 'Lynda Rahab',
      'status': 'active',
    };

    return jsonEncode(data);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
                        // TITRE
                        _buildHeader(),

                        const SizedBox(height: 35),

                        // QR
                        _buildQr(),

                        const SizedBox(height: 25),

                        _buildPassenger(),
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
          // Données réellement encodées dans le QR
          data: _qrData,

          // Génération automatique de la taille du QR
          version: QrVersions.auto,

          // Taille du QR
          size: 260,

          backgroundColor: Colors.white,

          // Niveau de correction
          errorCorrectionLevel: QrErrorCorrectLevel.M,

          // Carrés des coins
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: textDark,
          ),

          // Modules du QR
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'MV-20481',
        style: TextStyle(
          color: primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
