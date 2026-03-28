import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPStatTile extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const CPStatTile({Key? key, required this.icon, required this.number, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF181C21).withOpacity(0.04),
            blurRadius: 24, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF253153), size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: const Color(0xFF253153),
                ),
              ),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.5, color: const Color(0xFF5A5E6E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
