import 'package:flutter/material.dart';

class CPCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CPCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // surfaceContainerLowest
        borderRadius: BorderRadius.circular(24), // xl
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A181C21),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
