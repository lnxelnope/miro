// ============================================
// HEALTH ENUMS (Food only for v1.0)
// Enum definitions live in app_database.dart (single source of truth for Drift).
// This file only contains extension methods.
// ============================================

import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../theme/app_icons.dart';

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

// FoodSearchMode enum is defined in app_database.dart

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

// DataSource enum is defined in app_database.dart
