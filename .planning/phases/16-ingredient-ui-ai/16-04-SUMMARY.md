# 16-04 Summary — reader paths + MyMeal

## Reader

- `food_detail_bottom_sheet.dart`: ใช้ `parseIngredientsJson` แล้วแปลง `IngredientNode` → `IngredientDetail` สำหรับ UI
- `simple_food_detail_sheet.dart`: ใช้ `parseIngredientsJson` + `ingredientsDocumentToLegacyList` สำหรับ map ที่ใช้สเกล/แก้ไข
- `meal_section.dart`: นับจำนวน root จาก `documentV2.mainIngredients` ผ่าน `parseIngredientsJson`

## MyMeal vs FoodEntry

- **MyMeal** ยังเก็บโครงสร้างผ่าน `saveIngredientsAndMeal` / `MealIngredientInput` แยกจากสตริง `ingredientsJson` บน FoodEntry
- **FoodEntry.ingredientsJson** ใช้รูปแบบ v2 (`schemaVersion` + `mainIngredients`) ในทางเขียนหลักหลังเฟสนี้
- การบันทึกจาก AI / batch ใช้ `ingredientsDocumentToMyMealInputs(flattenAiIngredientRoots(...))` เพื่อให้ MyMeal ได้แถว root + `sub_ingredients` ที่สอดคล้องกับ flatten

## ไฟล์อื่นที่เกี่ยวข้องเฟส 16

- Codec ร่วม entry: `lib/core/nutrition/ingredients_entry_codec.dart` (ย้ายออกจาก `features/` เพื่อให้ `core/utils` ไม่ import features)
- `GeminiAnalysisSheet` ส่ง `ingredientsJsonV2` (string จาก `serializeIngredientsV2(doc)`); `barcode_scanner_screen` ใช้สตริงนี้ก่อน fallback `legacyListToV2`
