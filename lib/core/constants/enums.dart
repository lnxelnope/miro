// ============================================
// HEALTH ENUMS (Food only for v1.0)
// ============================================

import 'package:flutter/material.dart';
import '../theme/app_icons.dart';

/// Meal type
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return AppIcons.breakfast;
      case MealType.lunch:
        return AppIcons.lunch;
      case MealType.dinner:
        return AppIcons.dinner;
      case MealType.snack:
        return AppIcons.snack;
    }
  }

  Color get iconColor {
    switch (this) {
      case MealType.breakfast:
        return AppIcons.breakfastColor;
      case MealType.lunch:
        return AppIcons.lunchColor;
      case MealType.dinner:
        return AppIcons.dinnerColor;
      case MealType.snack:
        return AppIcons.snackColor;
    }
  }

  @Deprecated('Use icon getter instead')
  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '☀️';
      case MealType.lunch:
        return '🌤️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍿';
    }
  }
}

// ============================================
// GENERAL ENUMS
// ============================================

/// Search mode for AI food analysis
/// Tells AI whether to analyze as regular food or packaged product
enum FoodSearchMode {
  normal, // อาหารทั่วไป — AI ประมาณค่าจากวัตถุดิบ
  product, // สินค้ามี Nutrition Facts — AI ใช้ข้อมูลฉลากจริง
}

extension FoodSearchModeExtension on FoodSearchMode {
  String get displayName {
    switch (this) {
      case FoodSearchMode.normal:
        return 'Food';
      case FoodSearchMode.product:
        return 'Product';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodSearchMode.normal:
        return Icons.restaurant_menu_rounded;
      case FoodSearchMode.product:
        return AppIcons.package;
    }
  }

  @Deprecated('Use icon getter instead')
  String get emoji {
    switch (this) {
      case FoodSearchMode.normal:
        return '🍳';
      case FoodSearchMode.product:
        return '📦';
    }
  }

  String get description {
    switch (this) {
      case FoodSearchMode.normal:
        return 'Home-cooked or restaurant food';
      case FoodSearchMode.product:
        return 'Packaged with nutrition label';
    }
  }
}

/// Data source
enum DataSource {
  manual, // User entered manually
  aiAnalyzed, // AI analyzed
  database, // From database (My Meal / Ingredient / Thai DB)
  slipScan, // Legacy: Slip scan (kept for Isar backward compatibility)
  healthConnect, // Legacy: Health Connect (kept for Isar backward compatibility)
  googleCalendar, // Legacy: Google Calendar (kept for Isar backward compatibility)
  barcode, // Barcode scan
  galleryScanned, // Auto-scanned from Gallery
}
