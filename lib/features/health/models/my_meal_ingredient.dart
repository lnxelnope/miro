import 'package:isar/isar.dart';

part 'my_meal_ingredient.g.dart';

/// วัตถุดิบในเมนู (Junction Table)
/// เชื่อม MyMeal กับ Ingredient พร้อมปริมาณ
/// 
/// ตัวอย่าง: ผัดกระเพราไข่ดาว (myMealId=1)
///   ingredientId=1 (ข้าว),   amount=200, unit="g"  → cal=260
///   ingredientId=2 (หมูสับ), amount=80,  unit="g"  → cal=170
///   ingredientId=3 (ไข่),    amount=1,   unit="ฟอง" → cal=90
@collection
class MyMealIngredient {
  Id id = Isar.autoIncrement;

  /// ID ของเมนูที่อยู่ใน
  late int myMealId;

  /// ID ของวัตถุดิบ
  late int ingredientId;

  /// ชื่อวัตถุดิบ (เก็บซ้ำเพื่อ display ไม่ต้อง join)
  late String ingredientName;

  /// ปริมาณที่ใช้ในเมนูนี้
  late double amount;
  
  /// หน่วย
  late String unit;

  /// Nutrition ที่คำนวณแล้ว (= ingredient.calc * amount)
  late double calories;
  late double protein;
  late double carbs;
  late double fat;

  /// ลำดับ (สำหรับ display)
  int sortOrder = 0;
}
