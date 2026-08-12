import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isEmailLogin = true; // Bascule dynamique entre Email et Téléphone

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Palette Premium Moovly : Dominante BLEU avec touches de MAUVE chirurgicales
    const Color primaryBlue = Color(0xFF0F172A); // Bleu nuit sombre
    const Color royalBlue = Color(0xFF1D4ED8); // Bleu royal dominant
    const Color lightBlueBg = Color(
        0xFFF1F5F9); // Fond gris/bleuté ultra doux pour faire ressortir le relief blanc
    const Color cardBgColor = Colors.white;
    const Color mauveTouch =
        Color(0xFF8B5CF6); // Mauve exclusif pour les icônes et accents

    return Scaffold(
      backgroundColor: lightBlueBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 35),

                // Logo triangulaire stylisé d'après votre capture
                FadeInDown(
                  duration: const Duration(milliseconds: 1200),
                  child: Center(
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            blurRadius: 15,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: 18,
                            child: Icon(
                              Icons.navigation_rounded,
                              size: 42,
                              color: royalBlue, // Logo bleu
                            ),
                          ),
                          Positioned(
                            top: 18,
                            right: 18,
                            child: Transform.rotate(
                              angle: 0.5,
                              child: const Icon(
                                Icons.bolt_rounded,
                                size: 28,
                                color: mauveTouch, // Touche mauve subtile
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeInDown(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 150),
                  child: const Column(
                    children: [
                      Text(
                        'Bon retour!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Connectez-vous à votre compte',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Sélecteur d'onglet dynamique : Email ou Téléphone
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 250),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.025),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isEmailLogin = true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isEmailLogin
                                    ? cardBgColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: _isEmailLogin
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'E-mail',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _isEmailLogin
                                      ? royalBlue
                                      : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isEmailLogin = false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isEmailLogin
                                    ? cardBgColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: !_isEmailLogin
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Numéro de téléphone',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: !_isEmailLogin
                                      ? royalBlue
                                      : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // CHAMP SÉPARÉ (Cercle Icône à gauche + Boîte de saisie à droite) comme sur la capture
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 350),
                  child: Row(
                    children: [
                      // Icône circulaire blanche surélevée
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
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
                          _isEmailLogin
                              ? Icons.person_outline_rounded
                              : Icons.phone_android_rounded,
                          color:
                              mauveTouch, // Touche de mauve demandée sur l'icône
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Boîte de saisie style pilule à droite
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
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
                            controller: _isEmailLogin
                                ? _emailController
                                : _phoneController,
                            keyboardType: _isEmailLogin
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: _isEmailLogin
                                  ? 'Adresse email'
                                  : 'Numéro de téléphone',
                              hintStyle: const TextStyle(
                                  color: Colors.black26, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // CHAMP MOT DE PASSE SÉPARÉ
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 450),
                  child: Row(
                    children: [
                      // Icône circulaire blanche
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              blurRadius: 10,
                              offset: const Offset(-3, -3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          color: mauveTouch, // Touche de mauve
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Boîte de saisie à droite
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
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
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: const TextStyle(
                                  color: Colors.black26, fontSize: 13),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black26,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mot de passe oublié?',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bouton centré et réduit de taille comme demandé
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 550),
                  child: Container(
                    height: 50,
                    width: 180, // Largeur réduite style pilule de la capture
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [royalBlue, primaryBlue], // Bleu dominant
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: mauveTouch
                              .withOpacity(0.18), // Ombre mauve subtile
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 600),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.black.withOpacity(0.05),
                              thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'ou continuer avec',
                          style: TextStyle(
                            color: Colors.black26,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.black.withOpacity(0.05),
                              thickness: 1)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Boutons réseaux sociaux (Google et Apple avec vrais logos)
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 650),
                  child: Row(
                    children: [
                      // Google Button
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Google',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: primaryBlue,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Apple Button
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apple_rounded,
                                    color: Colors.black87, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: primaryBlue,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 700),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous n'avez pas encore de compte? ",
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Color(
                                0xFF1D4ED8), // Couleur de lien bleu comme demandé
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Clipper pour un éventuel tracé si nécessaire, sinon laissé vide ou géré.
