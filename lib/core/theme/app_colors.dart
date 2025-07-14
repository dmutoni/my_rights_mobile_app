import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE56B1A);
  static const Color primaryDark = Color(0xFFE55A2E);
  static const Color primaryLight = Color(0xFFFF8B65);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F8F8);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textHint = Color(0xFFB0B0B0);

  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFill = Color(0xFFFAFAFA);
  static const Color inputFocused = primary;

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8B65),
    ],
  );
}
