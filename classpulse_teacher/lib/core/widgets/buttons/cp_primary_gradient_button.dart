import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPPrimaryGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const CPPrimaryGradientButton({Key? key, required this.label, this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF253153), Color(0xFF3C486B)],
          transform: GradientRotation(135 * pi / 180),
        ),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF253153).withOpacity(0.1),
            blurRadius: 16, offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: icon != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (icon != null) Icon(icon, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
