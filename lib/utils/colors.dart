import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - TEAL & TURQUOISE from Logo
  static const Color primary = Color(0xFF4DB8AC); // Teal dari logo
  static const Color secondary = Color(0xFF75D4CC); // Turquoise terang
  static const Color accent = Color(0xFF91E0D9); // Turquoise lebih terang

  // Background Colors - Clean & Minimal
  static const Color background = Color(0xFFF2F2F7);
  static const Color cardBackground = Colors.white;
  static const Color surfaceLight = Color(0xFFE8F7F5); // Light teal tint

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFC7C7CC);
  static const Color textWhite = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF4DB8AC); // Teal untuk success
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF4DB8AC);

  // Divider & Border
  static const Color divider = Color(0xFFE5E5EA);
  static const Color border = Color(0xFFD1D1D6);

  // Rating & Special
  static const Color star = Color(0xFFFFCC00);
  static const Color discount = Color(0xFF4DB8AC);

  // Gradient Colors - Teal to Turquoise
  static const Color gradientStart = Color(0xFF4DB8AC); // Teal
  static const Color gradientMid = Color(0xFF75D4CC); // Turquoise medium
  static const Color gradientEnd = Color(0xFF91E0D9); // Turquoise terang

  // Shadow
  static const Color shadow = Color(0x0F000000);
  static const Color shadowColor = Color(0x0F000000);

  // Transparent overlays
  static Color primaryLight = primary.withValues(alpha: 0.1);
  static Color secondaryLight = secondary.withValues(alpha: 0.1);
  static Color accentLight = accent.withValues(alpha: 0.1);
  static Color blackOverlay = Colors.black.withValues(alpha: 0.3);
  static Color whiteOverlay = Colors.white.withValues(alpha: 0.97);

  // Gradient - Teal to Turquoise smooth transition
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientMid, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  
  // Subtle gradient for cards
  static LinearGradient get cardGradient => const LinearGradient(
        colors: [Colors.white, Color(0xFFF0FFFE)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
