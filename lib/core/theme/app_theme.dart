import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color primaryDark = Color(0xFF0A0A0F);
  static const Color secondaryDark = Color(0xFF1A1A2F);

  // Gold palette
  static const Color goldLight = Color(0xFFF9E076);
  static const Color goldMain = Color(0xFFC6A43F);
  static const Color goldDark = Color(0xFF8B6B1E);

  // Purple palette
  static const Color purpleLight = Color(0xFF9D7BFF);
  static const Color purpleMain = Color(0xFF6B4EFF);
  static const Color purpleDark = Color(0xFF4A2FD6);

  static const Color surfaceGlass = Color(0x1AFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2F), Color(0xFF252542)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9E076), Color(0xFFC6A43F), Color(0xFF8B6B1E)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D7BFF), Color(0xFF6B4EFF), Color(0xFF4A2FD6)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF), Color(0x05FFFFFF)],
  );

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: goldMain.withValues(alpha: 0.1),
      blurRadius: 30,
      offset: const Offset(0, -5),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: goldMain.withValues(alpha: 0.3),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];
}
