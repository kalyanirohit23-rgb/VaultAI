import 'package:flutter/material.dart';

/// VaultAI App Colors
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryDark = Color(0xFF0E7490);

  // Accent
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentGold = Color(0xFFF59E0B);

  // Success, Warning, Error, Info
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals - Light
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  static const Color black = Color(0xFF000000);

  // Background - Light Theme
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background - Dark Theme
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glass effect colors
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'passport': Color(0xFF4F46E5),
    'aadhaar': Color(0xFFEF4444),
    'pan': Color(0xFFF59E0B),
    'driving_licence': Color(0xFF10B981),
    'vehicle_rc': Color(0xFF06B6D4),
    'insurance': Color(0xFF8B5CF6),
    'bank_statement': Color(0xFF059669),
    'medical': Color(0xFFEC4899),
    'education': Color(0xFF0EA5E9),
    'property': Color(0xFF78716C),
    'employment': Color(0xFF6366F1),
    'bills': Color(0xFFF97316),
    'receipts': Color(0xFF84CC16),
    'warranties': Color(0xFF14B8A6),
    'travel': Color(0xFF3B82F6),
    'tax': Color(0xFFF59E0B),
    'investments': Color(0xFF22C55E),
    'other': Color(0xFF6B7280),
  };
}
