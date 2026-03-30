# 17-03 Summary — Create Meal sub photo (ARC2-MEAL-01)

- `create_meal_sheet.dart`: ปุ่ม `Icons.photo_camera_outlined` ข้าง search; bottom sheet `photoSourceTitle` + gallery/camera; `_analyzeSubFromPhoto` → copy รูปไป app documents → `GeminiService.analyzeFoodImage` + map เข้า sub (ชื่อ/ปริมาณ/หน่วย/macro) + `UsageLimiter` / invalidate energy
- `_IngredientRow`: `ingredientImagePath` (+ bbox fields สำหรับอนาคต), `isAnalyzingFromPhoto`; `IngredientThumb` ก่อน Autocomplete ในแถว sub
- `MealIngredientInput` + `_saveMealIngredient` + `ingredientTreeToJsonMaps`: บันทึก/serialize `imagePath`/`arBoundingBox`/ขนาดภาพ ลง JSON v2; `health_provider.parseIngredient` อ่านฟิลด์เดียวกันจาก map
- ไม่ใช้ `ImageAnalysisPreviewScreen` สำหรับ flow นี้ (หลีกเลี่ยงบันทึก diary โดยไม่ตั้งใจ) — วิเคราะห์ตรงผ่าน Gemini แบบเดียวกับจุดอื่นในแอป
