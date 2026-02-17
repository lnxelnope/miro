import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF2D8B75); // Teal-600 (Airbnb style)
  static const Color primaryLight = Color(0xFF5BB5A2); // Teal-400
  static const Color primaryDark = Color(0xFF1F6F5C); // Teal-700

  // Categories
  static const Color finance = Color(0xFF10B981); // Emerald-500
  static const Color health = Color(0xFFF59E0B); // Amber-500
  static const Color tasks = Color(0xFF3B82F6); // Blue-500

  // Status
  static const Color success = Color(0xFF22C55E); // Green-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Neutrals (Light Mode)
  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray-100
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color divider = Color(0xFFE5E7EB); // Gray-200

  // Neutrals (Dark Mode)
  static const Color backgroundDark = Color(0xFF111827); // Gray-900
  static const Color surfaceDark = Color(0xFF1F2937); // Gray-800
  static const Color surfaceVariantDark = Color(0xFF374151); // Gray-700
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray-50
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray-400
  static const Color dividerDark = Color(0xFF374151); // Gray-700

  // Income/Expense
  static const Color income = Color(0xFF22C55E); // Green-500
  static const Color expense = Color(0xFFEF4444); // Red-500

  // Macros
  static const Color protein = Color(0xFFEF4444); // Red-500
  static const Color carbs = Color(0xFFF59E0B); // Amber-500
  static const Color fat = Color(0xFF3B82F6); // Blue-500

  // Tier colors (for gamification)
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFC0C0C0);
  static const Color tierGold = Color(0xFFFFD700);
  static const Color tierDiamond = primary; // Teal

  // Energy level colors
  static const Color energyVeryLow = Color(0xFFEF4444); // Red-500 (< 10)
  static const Color energyLow = Color(0xFFF59E0B); // Amber-500 (< 30)
  static const Color energyMedium = Color(0xFF10B981); // Emerald-500 (< 100)
  static const Color energyHigh = Color(0xFF06B6D4); // Cyan-500 (≥ 100)
}
