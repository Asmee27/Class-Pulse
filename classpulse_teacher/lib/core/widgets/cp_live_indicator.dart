import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPLiveIndicator extends StatefulWidget {
  const CPLiveIndicator({Key? key}) : super(key: key);

  @override
  State<CPLiveIndicator> createState() => _CPLiveIndicatorState();
}

class _CPLiveIndicatorState extends State<CPLiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12, height: 12,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA1A1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(1.0 - _ctrl.value), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'LIVE SESSION DASHBOARD',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: const Color(0xFF45464E),
          ),
        ),
      ],
    );
  }
}
