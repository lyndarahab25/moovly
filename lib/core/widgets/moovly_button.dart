import 'package:flutter/material.dart';

class MoovlyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;

  const MoovlyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 180,
  });

  // Même couleurs que le bouton Login
  static const Color royalBlue = Color(0xFF4169E1);
  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color mauveTouch = Color(0xFF9B6BFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            royalBlue,
            primaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: mauveTouch.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
