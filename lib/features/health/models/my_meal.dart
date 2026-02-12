import 'package:isar/isar.dart';

part 'my_meal.g.dart';

/// เมนูอาหารส่วนตัว
/// ประกอบจาก Ingredients หลายตัว
/// 
/// ตัวอย่าง: "ผัดกระเพราไข่ดาว"
///   totalCalories: 611 (ผลรวมจาก ingredients ทั้งหมด)
///   baseServingDescription: "1 จาน"
@collection
class MyMeal {
  Id id = Isar.autoIncrement;

  /// ชื่อเมนู (ไทย)
  late String name;
  
  /// ชื่อเมนู (อังกฤษ) - nullable
  String? nameEn;

  /// รวม Nutrition ของเมนูนี้ (ผลรวมจาก ingredients ทั้งหมด)
  late double totalCalories;
  late double totalProtein;
  late double totalCarbs;
  late double totalFat;

  /// คำอธิบายปริมาณฐาน เช่น "1 จาน", "1 ชุด"
  late String baseServingDescription;

  /// รูปภาพ (ถ้ามี)
  String? imagePath;

  /// แหล่งที่มา: "gemini" | "manual"
  late String source;

  /// จำนวนครั้งที่ถูกใช้
  int usageCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper: คำนวณ nutrition ตาม multiplier
  // ============================================

  /// คำนวณแคลอรี่สำหรับ multiplier
  /// ตัวอย่าง: totalCalories=611, calcCalories(0.5) → 305.5
  double calcCalories(double multiplier) => totalCalories * multiplier;
  double calcProtein(double multiplier) => totalProtein * multiplier;
  double calcCarbs(double multiplier) => totalCarbs * multiplier;
  double calcFat(double multiplier) => totalFat * multiplier;

  // ============================================
  // Helper: Parse baseServingDescription → size + unit
  // ============================================
  // "16 ลูก" → parsedServingSize=16, parsedServingUnit="ลูก"
  // "1 จาน" → parsedServingSize=1, parsedServingUnit="จาน"
  // "ลูกชิ้น" → parsedServingSize=1, parsedServingUnit="ลูกชิ้น"

  static final _servingRegex = RegExp(r'^([\d.]+)\s*(.*)$');

  /// ปริมาณฐาน (ตัวเลข) จาก baseServingDescription
  @ignore
  double get parsedServingSize {
    final match = _servingRegex.firstMatch(baseServingDescription.trim());
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 1;
    }
    return 1;
  }

  /// หน่วยฐาน (ข้อความ) จาก baseServingDescription
  @ignore
  String get parsedServingUnit {
    final match = _servingRegex.firstMatch(baseServingDescription.trim());
    if (match != null && match.group(2)!.isNotEmpty) {
      return match.group(2)!.trim();
    }
    // ถ้าไม่มีตัวเลขเลย → ทั้ง string คือ unit
    return baseServingDescription.trim().isEmpty ? 'serving' : baseServingDescription.trim();
  }

  /// kcal ต่อ 1 หน่วยฐาน
  @ignore
  double get caloriesPerUnit => parsedServingSize > 0 ? totalCalories / parsedServingSize : totalCalories;
  @ignore
  double get proteinPerUnit  => parsedServingSize > 0 ? totalProtein  / parsedServingSize : totalProtein;
  @ignore
  double get carbsPerUnit    => parsedServingSize > 0 ? totalCarbs    / parsedServingSize : totalCarbs;
  @ignore
  double get fatPerUnit      => parsedServingSize > 0 ? totalFat      / parsedServingSize : totalFat;
}
