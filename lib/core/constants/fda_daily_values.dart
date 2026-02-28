/// FDA Daily Values (2020-2025) based on a 2,000 calorie diet
/// Reference: https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels
class FdaDailyValues {
  // Macronutrients
  static const double calories = 2000;       // kcal
  static const double totalFat = 78;         // g
  static const double protein = 50;          // g
  static const double carbohydrates = 275;   // g

  // Micronutrients
  static const double fiber = 28;            // g (target: reach this)
  static const double sugar = 50;            // g (limit: stay under)
  static const double sodium = 2300;         // mg (limit: stay under)
  static const double cholesterol = 300;     // mg (limit: stay under)
  static const double saturatedFat = 20;     // g (limit: stay under)
  static const double transFat = 0;          // g (limit: avoid completely)
  static const double potassium = 4700;      // mg (target: reach this)

  // ไม่มี FDA DV สำหรับ unsaturated / mono / poly — แสดงเฉพาะค่า

  /// ค่าที่ "ยิ่งน้อยยิ่งดี" (เกินคือแดง)
  static const limitNutrients = {
    'sugar', 'sodium', 'cholesterol', 'saturatedFat', 'transFat',
  };

  /// ค่าที่ "ยิ่งมากยิ่งดี" (ขาดคือแดง)
  static const targetNutrients = {
    'fiber', 'potassium',
  };

  /// ดึง FDA DV ตาม key
  static double? getValue(String key) {
    switch (key) {
      case 'fiber': return fiber;
      case 'sugar': return sugar;
      case 'sodium': return sodium;
      case 'cholesterol': return cholesterol;
      case 'saturatedFat': return saturatedFat;
      case 'transFat': return transFat;
      case 'potassium': return potassium;
      default: return null;
    }
  }

  /// ตรวจสอบว่า nutrient อยู่ในเกณฑ์ดีหรือไม่
  /// true = ดี (เขียว), false = ไม่ดี (แดง)
  static bool isGood(String key, double actualValue) {
    final fdaValue = getValue(key);
    if (fdaValue == null) return true;

    if (limitNutrients.contains(key)) {
      return actualValue <= fdaValue;
    } else if (targetNutrients.contains(key)) {
      return actualValue >= fdaValue;
    }
    return true;
  }
}
