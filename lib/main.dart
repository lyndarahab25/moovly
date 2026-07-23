import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/authn/login_screen.dart';
import 'screens/authn/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MoovlyApp());
}

class MoovlyApp extends StatelessWidget {
  const MoovlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData premiumTheme = ThemeData(
      useMaterial3: true,
      primaryColor: const Color(0xFF1D4ED8),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1D4ED8),
          foregroundColor: Colors.white,
          minimumSize: const Size(180, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1D4ED8),
        primary: const Color(0xFF1D4ED8),
        secondary: const Color(0xFF8B5CF6),
      ),
    );

    return MaterialApp(
      title: 'Moovly',
      debugShowCheckedModeBanner: false,
      theme: premiumTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
