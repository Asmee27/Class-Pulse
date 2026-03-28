import 'package:flutter/material.dart';

class ClassPulseColors {
  static const primary = Color(0xFF253153);
  static const primaryContainer = Color(0xFF3C486B);
  static const surface = Color(0xFFF7F9FF);
  static const surfaceContainerLow = Color(0xFFF1F4FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFE5E8EF);
  static const onSurface = Color(0xFF181C21);
  static const onSurfaceVariant = Color(0xFF45464E);
  static const secondary = Color(0xFF5A5E6E);
  static const outlineVariant = Color(0xFFC6C6CF);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const tertiaryFixed = Color(0xFFD2E6EF);
  static const onTertiaryFixed = Color(0xFF374951);
  static const softOrange = Color(0xFFFFF3E0);
}

class ClassPulseGradients {
  static const primaryGradient = LinearGradient(
    colors: [ClassPulseColors.primary, ClassPulseColors.primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const haloGradient = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [Color(0xFFDAE1FF), ClassPulseColors.surface],
    stops: [0.0, 0.6],
  );
}

class ClassPulseShadows {
  static const ambient = BoxShadow(
    color: Color(0x0A181C21), // 4% opacity on surface
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ClassPulseColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ClassPulseColors.primary,
        primary: ClassPulseColors.primary,
        surface: ClassPulseColors.surface,
        onSurface: ClassPulseColors.onSurface,
        onSurfaceVariant: ClassPulseColors.onSurfaceVariant,
        error: ClassPulseColors.error,
        errorContainer: ClassPulseColors.errorContainer,
      ),
      fontFamily: 'Plus Jakarta Sans',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }
}
