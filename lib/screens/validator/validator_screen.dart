import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ValidatorScreen extends StatefulWidget {
  const ValidatorScreen({super.key});

  @override
  State<ValidatorScreen> createState() => _ValidatorScreenState();
}

class _ValidatorScreenState extends State<ValidatorScreen> {
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color success = Color(0xFF18A563);
  static const Color danger = Color(0xFFE5484D);

  static const double ticketPrice = 25.0;

  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  bool _scanFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // =========================
          // CAMÉRA
          // =========================
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                if (_isProcessing || _scanFinished) return;

                final barcodes = capture.barcodes;

                if (barcodes.isEmpty) return;

                final rawValue = barcodes.first.rawValue;

                if (rawValue == null || rawValue.isEmpty) return;

                _handleQrCode(rawValue);
              },
            ),
          ),

          // =========================
          // BOUTON RETOUR
          // =========================
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =========================
          // CADRE DE SCAN
          // =========================
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _ScannerFramePainter(
                  color: primaryBlue,
                  strokeWidth: 4,
                  cornerLength: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCAN QR
  // ============================================================

  Future<void> _handleQrCode(String rawValue) async {
    if (_isProcessing || _scanFinished) return;

    setState(() {
      _isProcessing = true;
      _scanFinished = true;
    });

    await _scannerController.stop();

    debugPrint('QR SCANNÉ : $rawValue');

    await _processQrCode(rawValue);
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  Future<void> _processQrCode(String rawValue) async {
    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('QR invalide.');
      }

      final qrType = decoded['type'];
      final userId = decoded['userId'];

      if (qrType != 'moovly_transport') {
        throw Exception("Ce QR n'est pas un QR Moovly.");
      }

      if (userId == null || userId.toString().trim().isEmpty) {
        throw Exception('Identifiant utilisateur absent.');
      }

      final String userIdString = userId.toString().trim();

      debugPrint('USER ID DU QR : $userIdString');

      final firestore = FirebaseFirestore.instance;

      // ----------------------------------------------------------
      // UTILISATEUR
      // ----------------------------------------------------------

      final userReference = firestore.collection('users').doc(userIdString);

      final userSnapshot = await userReference.get();

      if (!userSnapshot.exists) {
        throw Exception('Utilisateur introuvable.');
      }

      // ----------------------------------------------------------
      // CARTE
      // ----------------------------------------------------------

      final cardSnapshot = await firestore
          .collection('carte')
          .where(
            'id_user',
            isEqualTo: userReference,
          )
          .limit(1)
          .get();

      if (cardSnapshot.docs.isEmpty) {
        throw Exception('Carte du passager introuvable.');
      }

      final cardDocument = cardSnapshot.docs.first;
      final cardReference = cardDocument.reference;
      final cardData = cardDocument.data();

      // ----------------------------------------------------------
      // SOLDE
      // ----------------------------------------------------------

      final dynamic soldeValue = cardData['solde'];

      double solde = 0.0;

      if (soldeValue is num) {
        solde = soldeValue.toDouble();
      } else if (soldeValue is String) {
        solde = double.tryParse(soldeValue) ?? 0.0;
      }

      debugPrint('SOLDE DU PASSAGER : $solde DA');

      // ----------------------------------------------------------
      // SOLDE INSUFFISANT
      // ----------------------------------------------------------

      if (solde < ticketPrice) {
        await _saveQrScan(
          userReference: userReference,
          cardReference: cardReference,
          amount: ticketPrice,
          status: 'failed',
        );

        await _showScanResult(
          success: false,
          title: 'Trajet refusé',
          message: 'Solde insuffisant.\n\n'
              'Solde actuel : ${solde.toStringAsFixed(0)} DA\n'
              'Prix du trajet : ${ticketPrice.toStringAsFixed(0)} DA',
        );

        return;
      }

      // ----------------------------------------------------------
      // DÉBIT
      // ----------------------------------------------------------

      final double newBalance = solde - ticketPrice;

      await cardReference.update({
        'solde': newBalance,
      });
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': userReference,
        'amount': ticketPrice,
        'status': 'success',
        'method': 'qr',
        'date_paiement': FieldValue.serverTimestamp(),
      });
      debugPrint('NOUVEAU SOLDE : $newBalance DA');

      // ----------------------------------------------------------
      // HISTORIQUE SCAN
      // ----------------------------------------------------------

      await _saveQrScan(
        userReference: userReference,
        cardReference: cardReference,
        amount: ticketPrice,
        status: 'success',
      );

      // ----------------------------------------------------------
      // SUCCÈS
      // ----------------------------------------------------------

      await _showScanResult(
        success: true,
        title: 'Trajet validé',
        message: 'Le trajet a été validé avec succès.\n\n'
            'Montant débité : 25 DA\n'
            'Nouveau solde : ${newBalance.toStringAsFixed(0)} DA',
      );
    } catch (e) {
      debugPrint('ERREUR VALIDATION QR : $e');

      await _showScanResult(
        success: false,
        title: 'Scan échoué',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ============================================================
  // ENREGISTRER LE SCAN
  // ============================================================

  Future<void> _saveQrScan({
    required DocumentReference<Map<String, dynamic>> userReference,
    required DocumentReference<Map<String, dynamic>> cardReference,
    required double amount,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('qr_scans').add({
        'userId': userReference,
        'cardId': cardReference,
        'amount': amount,
        'status': status,
        'date_scan': FieldValue.serverTimestamp(),
      });

      debugPrint('QR SCAN ENREGISTRÉ : $status');
    } catch (e) {
      debugPrint('Erreur enregistrement qr_scans : $e');
    }
  }

  // ============================================================
  // RÉSULTAT
  // ============================================================

  Future<void> _showScanResult({
    required bool success,
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              25,
              24,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: success
                        ? const Color(0xFFE7F8EF)
                        : const Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success ? Icons.check_rounded : Icons.close_rounded,
                    color: success ? _ValidatorScreenState.success : danger,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 18),

                // Titre
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _resetScanner();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? primaryBlue : danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Scanner un autre QR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
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

  // ============================================================
  // RECOMMENCER
  // ============================================================

  void _resetScanner() {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _scanFinished = false;
    });

    _scannerController.start();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

// ================================================================
// CADRE DU SCANNER
// ================================================================

class _ScannerFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  _ScannerFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // Coin supérieur gauche
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerLength),
      paint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(w, 0),
      Offset(w - cornerLength, 0),
      paint,
    );

    canvas.drawLine(
      Offset(w, 0),
      Offset(w, cornerLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(0, h),
      Offset(cornerLength, h),
      paint,
    );

    canvas.drawLine(
      Offset(0, h),
      Offset(0, h - cornerLength),
      paint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(w, h),
      Offset(w - cornerLength, h),
      paint,
    );

    canvas.drawLine(
      Offset(w, h),
      Offset(w, h - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength;
  }
}
