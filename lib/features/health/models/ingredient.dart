import 'package:isar/isar.dart';

part 'ingredient.g.dart';

/// ฐานข้อมูลวัตถุดิบส่วนตัว
/// เรียนรู้จากการใช้งานจริง (Gemini วิเคราะห์ + manual)
///
/// ตัวอย่าง:
///   name: "ไข่", baseAmount: 1, baseUnit: "ฟอง"
///   caloriesPerBase: 90, proteinPerBase: 6, carbsPerBase: 1, fatPerBase: 7
///   → ถ้ากิน 2 ฟอง = 90*2 = 180 kcal
@collection
class Ingredient {
  Id id = Isar.autoIncrement;

  /// ชื่อวัตถุดิบ (ไทย)
  late String name;

  /// ชื่อวัตถุดิบ (อังกฤษ) - nullable
  String? nameEn;

  /// ปริมาณฐาน เช่น 100 (ถ้าหน่วยเป็น g) หรือ 1 (ถ้าหน่วยเป็น ฟอง)
  late double baseAmount;

  /// หน่วยฐาน เช่น "g", "ฟอง", "ถ้วย", "ช้อนโต๊ะ"
  late String baseUnit;

  /// Nutrition ต่อ baseAmount
  late double caloriesPerBase;
  late double proteinPerBase;
  late double carbsPerBase;
  late double fatPerBase;

  /// Micros (optional) ต่อ baseAmount
  double? fiberPerBase;
  double? sugarPerBase;
  double? sodiumPerBase;

  /// แหล่งที่มา: "gemini" | "manual"
  late String source;

  /// จำนวนครั้งที่ถูกใช้ (สำหรับ ranking ตอนค้นหา)
  int usageCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper Methods
  // ============================================

  /// คำนวณ nutrition สำหรับปริมาณที่ระบุ
  /// [amount] ปริมาณที่ต้องการ (ในหน่วย baseUnit)
  ///
  /// ตัวอย่าง: ไข่ (base=1 ฟอง, cal=90)
  ///   calcCalories(2) → 180 kcal (2 ฟอง)
  ///   calcCalories(0.5) → 45 kcal (ครึ่งฟอง)
  ///
  /// ตัวอย่าง: ข้าว (base=100g, cal=130)
  ///   calcCalories(200) → 260 kcal (200g)
  double calcCalories(double amount) => (caloriesPerBase / baseAmount) * amount;
  double calcProtein(double amount) => (proteinPerBase / baseAmount) * amount;
  double calcCarbs(double amount) => (carbsPerBase / baseAmount) * amount;
  double calcFat(double amount) => (fatPerBase / baseAmount) * amount;
}
