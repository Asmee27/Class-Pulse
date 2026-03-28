import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPSideNav extends StatefulWidget {
  final int activeIndex;
  const CPSideNav({Key? key, required this.activeIndex}) : super(key: key);

  @override
  State<CPSideNav> createState() => _CPSideNavState();
}

class _CPSideNavState extends State<CPSideNav> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: _isExpanded ? 320 : 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF181C21).withOpacity(0.04),
              blurRadius: 48,
              offset: const Offset(4, 0),
            )
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF253153),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.insights, color: Colors.white, size: 20),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'ClassPulse',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: const Color(0xFF253153),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Nav Items
            _DesktopNavItem(idx: 0, activeIndex: widget.activeIndex, isExpanded: _isExpanded, icon: Icons.calendar_today, label: 'Sessions'),
            _DesktopNavItem(idx: 1, activeIndex: widget.activeIndex, isExpanded: _isExpanded, icon: Icons.dashboard_rounded, label: 'Dashboard'),
            _DesktopNavItem(idx: 2, activeIndex: widget.activeIndex, isExpanded: _isExpanded, icon: Icons.question_answer_rounded, label: 'Questions'),
            _DesktopNavItem(idx: 3, activeIndex: widget.activeIndex, isExpanded: _isExpanded, icon: Icons.person_rounded, label: 'Profile'),
            const Spacer(),
            // Avatar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE5E8EF),
                    child: Icon(Icons.person, color: Color(0xFF5A5E6E)),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. Aris', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF253153))),
                          Text('Professor', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF5A5E6E))),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final int idx;
  final int activeIndex;
  final bool isExpanded;
  final IconData icon;
  final String label;

  const _DesktopNavItem({required this.idx, required this.activeIndex, required this.isExpanded, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isActive = idx == activeIndex;
    final color = isActive ? Colors.white : const Color(0xFF5A5E6E);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF253153) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
