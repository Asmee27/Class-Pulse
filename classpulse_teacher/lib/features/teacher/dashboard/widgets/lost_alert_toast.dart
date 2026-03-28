import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared/shared.dart';

class LostAlertToast extends StatelessWidget {
  final bool visible;
  final double lostPercent;
  final VoidCallback onDismiss;

  const LostAlertToast({
    Key? key,
    required this.visible,
    required this.lostPercent,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [ClassPulseShadows.ambient],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: ClassPulseColors.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⚠️ ${lostPercent.toStringAsFixed(0)}%+ students are lost — consider pausing',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ClassPulseColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: ClassPulseColors.onSurfaceVariant),
                onPressed: onDismiss,
              ),
            ],
          ),
        ).animate().slideY(begin: -1.0, end: 0.0, curve: Curves.easeOut).fadeIn(),
      ),
    );
  }
}
