import 'package:miro_hybrid/core/database/model_extensions.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_codec.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_models.dart';

/// Wire format v2 ใช้ `subIngredients`; MyMeal / `saveIngredientsAndMeal` คาดหวัง `sub_ingredients`.
Map<String, dynamic> ingredientNodeToMyMealInputMap(IngredientNode n) {
  final map = <String, dynamic>{
    'name': n.name,
    if (n.nameEn != null) 'name_en': n.nameEn,
    'amount': n.amount,
    'unit': n.unit,
    'calories': n.calories,
    'protein': n.protein,
    'carbs': n.carbs,
    'fat': n.fat,
  };
  if (n.fiber != null) map['fiber'] = n.fiber;
  if (n.sugar != null) map['sugar'] = n.sugar;
  if (n.sodium != null) map['sodium'] = n.sodium;
  if (n.imagePath != null && n.imagePath!.isNotEmpty) {
    map['imagePath'] = n.imagePath;
  }
  if (n.arBoundingBox != null && n.arBoundingBox!.isNotEmpty) {
    map['arBoundingBox'] = n.arBoundingBox;
  }
  if (n.arImageWidth != null) map['arImageWidth'] = n.arImageWidth;
  if (n.arImageHeight != null) map['arImageHeight'] = n.arImageHeight;
  if (n.subIngredients.isNotEmpty) {
    map['sub_ingredients'] =
        n.subIngredients.map(ingredientNodeToMyMealInputMap).toList();
  }
  return map;
}

List<Map<String, dynamic>> ingredientsDocumentToMyMealInputs(
  IngredientsDocumentV2 doc,
) {
  return doc.mainIngredients.map(ingredientNodeToMyMealInputMap).toList();
}

/// รายการ map แบบ legacy (sub_ingredients) สำหรับ UI ที่เคยอ่านจาก list ดิบ
List<Map<String, dynamic>> ingredientsDocumentToLegacyList(
  IngredientsDocumentV2 doc,
) {
  return doc.mainIngredients.map(ingredientNodeToMyMealInputMap).toList();
}

/// แปลงแถวจาก UI (`toMap`) เป็น JSON v2
String? ingredientsEditableMapsToV2Json(List<Map<String, dynamic>> maps) {
  if (maps.isEmpty) return null;
  return serializeIngredientsV2(legacyListToV2(maps));
}

/// ผลจาก AI (รายการ root เป็น Map) → flatten ความลึก + สตริง JSON v2
String? encodeAiRootMapsToV2Json(List<Map<String, dynamic>> roots) {
  if (roots.isEmpty) return null;
  final doc = flattenAiIngredientRoots(roots);
  return serializeIngredientsV2(doc);
}

/// สร้างเอกสารหลัง flatten จากรายการ root ของ AI
IngredientsDocumentV2 documentFromAiRootMaps(List<Map<String, dynamic>> roots) {
  return flattenAiIngredientRoots(roots);
}

/// อัปเดต macro (และ micro ตาม D-08b) บน entry จาก rollup ของเอกสารวัตถุดิบ
void applyIngredientsRollupToFoodEntry(
  FoodEntry entry,
  IngredientsDocumentV2 doc,
) {
  final r = recomputeEntryRollup(
    doc: doc,
    entryFiber: entry.fiber,
    entrySugar: entry.sugar,
    entrySodium: entry.sodium,
  );
  entry.calories = r.calories;
  entry.protein = r.protein;
  entry.carbs = r.carbs;
  entry.fat = r.fat;
  entry.fiber = r.fiber;
  entry.sugar = r.sugar;
  entry.sodium = r.sodium;
  final ss = entry.servingSize;
  if (ss > 0) {
    entry.baseCalories = r.calories / ss;
    entry.baseProtein = r.protein / ss;
    entry.baseCarbs = r.carbs / ss;
    entry.baseFat = r.fat / ss;
  }
}
