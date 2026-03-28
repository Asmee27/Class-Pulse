import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared/shared.dart';

class SignalRing extends StatelessWidget {
  final int count;
  final double percentage;
  final Color arcColor;
  final String label;
  final bool isPulsing;

  const SignalRing({
    Key? key,
    required this.count,
    required this.percentage,
    required this.arcColor,
    required this.label,
    this.isPulsing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = CPCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percentage.clamp(0.0, 1.0),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: ClassPulseColors.surfaceContainerHigh,
            progressColor: arcColor,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 300,
            center: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ClassPulseColors.onSurface,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ClassPulseColors.secondary,
            ),
          ),
        ],
      ),
    );

    if (isPulsing) {
      content = content.animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: const Duration(seconds: 1));
    }

    return content;
  }
}
