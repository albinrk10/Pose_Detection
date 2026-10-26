import 'package:flutter/material.dart';

class AppTheme {
  // Dark Sports Color Palette
  static const Color background = Color(0xFF0F1419);
  static const Color surface = Color(0xFF1B222A);
  static const Color surfaceHighlight = Color(0xFF26303B);

  static const Color primaryNeon = Color(0xFF00E676); // Emerald Green
  static const Color secondaryCyan = Color(0xFF00E5FF); // Bright Cyan
  static const Color accentOrange = Color(0xFFFF9100); // Warning/Instruction
  static const Color errorRed = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryCyan,
        surface: surface,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: textSecondary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: textMuted,
        ),
      ),
    );
  }
}
