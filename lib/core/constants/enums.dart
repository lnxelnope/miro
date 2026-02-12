// ============================================
// HEALTH ENUMS (Food only for v1.0)
// ============================================

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
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }
  
  String get icon {
    switch (this) {
      case MealType.breakfast: return '☀️';
      case MealType.lunch: return '🌤️';
      case MealType.dinner: return '🌙';
      case MealType.snack: return '🍿';
    }
  }
}

// ============================================
// GENERAL ENUMS
// ============================================

/// Data source
enum DataSource {
  manual,         // User entered manually
  aiAnalyzed,     // AI analyzed
  database,       // From database (My Meal / Ingredient / Thai DB)
  slipScan,       // Legacy: Slip scan (kept for Isar backward compatibility)
  healthConnect,  // Legacy: Health Connect (kept for Isar backward compatibility)
  googleCalendar, // Legacy: Google Calendar (kept for Isar backward compatibility)
  barcode,        // Barcode scan
  galleryScanned, // Auto-scanned from Gallery
}
