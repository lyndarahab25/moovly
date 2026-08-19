import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // COLORS — IDENTITÉ MOOVLY
  // ============================================================

  static const Color background = Color(0xFFF6F8FD);
  static const Color darkBlue = Color(0xFF0B1F3A);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color mutedBlue = Color(0xFF71809D);

  // ============================================================
  // ANIMATIONS
  // ============================================================

  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _loaderController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // LOGO ANIMATION
    // ------------------------------------------------------------

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    // ------------------------------------------------------------
    // TEXT ANIMATION
    // ------------------------------------------------------------

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ------------------------------------------------------------
    // LOADER
    // ------------------------------------------------------------

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // ------------------------------------------------------------
    // START
    // ------------------------------------------------------------

    _startAnimation();

    // ------------------------------------------------------------
    // GO TO LOGIN
    // ------------------------------------------------------------

    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    });
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    await _contentController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _loaderController.dispose();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==================================================
              // LOGO
              // ==================================================

              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Image.asset(
                    'assets/images/moovly_logo.png',
                    width: 220,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // MOOVLY + SLOGAN
              // ==================================================

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      // ------------------------------------------------
                      // NAME
                      // ------------------------------------------------

                      const Text(
                        'Moovly',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.8,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ------------------------------------------------
                      // SLOGAN
                      // ------------------------------------------------

                      _buildSlogan(),

                      const SizedBox(height: 32),

                      // ------------------------------------------------
                      // LOADING BAR
                      // ------------------------------------------------

                      AnimatedBuilder(
                        animation: _loaderController,
                        builder: (context, child) {
                          final value = 0.75 + (_loaderController.value * 0.25);

                          return Container(
                            width: 52 * value,
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  primaryBlue,
                                  darkBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SLOGAN
  // ============================================================

  Widget _buildSlogan() {
    const normalStyle = TextStyle(
      color: mutedBlue,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );

    const blueStyle = TextStyle(
      color: primaryBlue,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Plus ',
            style: normalStyle,
          ),
          TextSpan(
            text: 'vite',
            style: blueStyle,
          ),
          TextSpan(
            text: ', plus ',
            style: normalStyle,
          ),
          TextSpan(
            text: 'proche',
            style: blueStyle,
          ),
          TextSpan(
            text: ', plus ',
            style: normalStyle,
          ),
          TextSpan(
            text: 'malin',
            style: blueStyle,
          ),
          TextSpan(
            text: '.',
            style: normalStyle,
          ),
        ],
      ),
    );
  }
}
