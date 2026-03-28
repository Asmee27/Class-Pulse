import 'package:flutter/material.dart';

class CPButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isSecondary;

  const CPButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          gradient: isPrimary ? const LinearGradient(
            colors: [Color(0xFF253153), Color(0xFF3C486B)],
          ) : null,
          color: !isPrimary ? const Color(0xFFE5E8EF) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF181C21),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
