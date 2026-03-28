import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPBottomNav extends StatelessWidget {
  final int activeIndex;
  
  const CPBottomNav({Key? key, required this.activeIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 24,
            color: const Color(0xFF181C21).withOpacity(0.04),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              top: 12, left: 16, right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(idx: 0, activeIndex: activeIndex, icon: Icons.calendar_today, label: 'Sessions'),
                _NavItem(idx: 1, activeIndex: activeIndex, icon: Icons.dashboard_rounded, label: 'Dashboard'),
                _NavItem(idx: 2, activeIndex: activeIndex, icon: Icons.question_answer_rounded, label: 'Questions'),
                _NavItem(idx: 3, activeIndex: activeIndex, icon: Icons.person_rounded, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int idx;
  final int activeIndex;
  final IconData icon;
  final String label;

  const _NavItem({required this.idx, required this.activeIndex, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isActive = idx == activeIndex;
    final color = isActive ? Colors.white : const Color(0xFF5A5E6E);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF253153) : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
