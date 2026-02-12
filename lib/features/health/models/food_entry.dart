import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'food_entry.g.dart';

@collection
class FoodEntry {
  Id id = Isar.autoIncrement;

  // ข้อมูลพื้นฐาน
  late String foodName;
  String? foodNameEn;
  late DateTime timestamp;
  String? imagePath;

  // มื้ออาหาร
  @enumerated
  late MealType mealType;

  // Serving Size - ปริมาณที่กิน
  late double servingSize; // เช่น 1.0, 0.5, 2.0
  late String servingUnit; // e.g. "serving", "piece", "g", "lbs"
  double? servingGrams;    // ปริมาณเป็นกรัม (ถ้าทราบ)

  // ============================================
  // Nutrition ที่คำนวณแล้ว (= base * servingSize)
  // ============================================
  late double calories;
  late double protein;
  late double carbs;
  late double fat;

  // ============================================
  // BASE Nutrition (ต่อ 1 หน่วย servingUnit)
  // ใช้สำหรับ recalculate เมื่อ servingSize เปลี่ยน
  // ตัวอย่าง: ถ้า 1 จาน = 520 kcal
  //   baseCalories = 520
  //   servingSize = 1 → calories = 520
  //   servingSize = 0.5 → calories = 260
  // ============================================
  double baseCalories = 0;
  double baseProtein = 0;
  double baseCarbs = 0;
  double baseFat = 0;

  // Micros (optional)
  double? fiber;
  double? sugar;
  double? sodium;
  double? cholesterol;
  double? saturatedFat;

  // Metadata
  @enumerated
  late DataSource source;
  double? aiConfidence;
  bool isVerified = false;
  String? notes;

  // ============================================
  // Links สำหรับ Phase 2 (My Meal / Ingredient)
  // ยังไม่ใช้ตอนนี้ แต่เตรียมไว้ก่อน
  // ============================================
  int? myMealId;          // link ไป MyMeal (ถ้ามา from My Meal)
  int? ingredientId;      // link ไป Ingredient (ถ้าเป็นวัตถุดิบเดี่ยว)
  String? groupId;        // group หลายรายการจากเมนูเดียวกัน
  String? ingredientsJson; // snapshot ของ ingredients ที่ใช้จริง

  // Sync
  String? healthConnectId;
  DateTime? syncedAt;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper Methods
  // ============================================

  /// คำนวณ nutrition จาก base * servingSize
  void recalculateFromBase() {
    if (baseCalories > 0) {
      calories = baseCalories * servingSize;
      protein = baseProtein * servingSize;
      carbs = baseCarbs * servingSize;
      fat = baseFat * servingSize;
    }
  }

  /// ตั้ง base values จาก nutrition ปัจจุบัน (สำหรับ serving = 1)
  /// เรียกหลังจาก Gemini วิเคราะห์เสร็จ หรือ manual entry
  void setBaseFromCurrentNutrition() {
    if (servingSize > 0) {
      baseCalories = calories / servingSize;
      baseProtein = protein / servingSize;
      baseCarbs = carbs / servingSize;
      baseFat = fat / servingSize;
    } else {
      baseCalories = calories;
      baseProtein = protein;
      baseCarbs = carbs;
      baseFat = fat;
    }
  }

  /// ตรวจสอบว่ามี base values หรือยัง
  bool get hasBaseValues => baseCalories > 0 || baseProtein > 0 || baseCarbs > 0 || baseFat > 0;

  /// ตรวจสอบว่ามีค่าโภชนาการหรือยัง (ยังไม่ได้วิเคราะห์ = ค่า 0 ทั้งหมด)
  bool get hasNutritionData => calories > 0 || protein > 0 || carbs > 0 || fat > 0;
}
