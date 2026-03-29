# Phase 16 — Technical research: Ingredient UI & AI

**Phase:** 16 — ingredient-ui-ai  
**Date:** 2026-03-29  

## RESEARCH COMPLETE

---

## 0. ขึ้นกับ Phase 13

- **`lib/core/nutrition/ingredients_codec.dart`** และ **`ingredients_models.dart`** ต้องมีตามแผน **13-01** ก่อน execute เฟส 16
- API ที่ UI ต้องเรียก (ชื่อจากแผน 13 — ปรับให้ตรง implementation จริงเมื่อ merge):
  - `parseIngredientsJson(String?)`
  - `serializeIngredientsV2(...)` 
  - `flattenAiIngredientRoots` (หรือชื่อเทียบเท่า) สำหรับรายการจาก Gemini
  - ฟังก์ชัน recompute ที่คืนค่า patch macro/micro ระดับ entry (เช่น `recomputeEntryRollup`)

## 1. จุดบันทึก `ingredientsJson` วันนี้

| ไฟล์ | พฤติกรรมปัจจุบัน |
|------|------------------|
| `add_food_bottom_sheet.dart` | `jsonEncode(_ingredients.map(toMap))` → legacy List |
| `edit_food_bottom_sheet.dart` | parse เป็น `List`; save `jsonEncode(toMap)` |
| `food_preview_screen.dart` | `jsonEncode(_analysisResult!.ingredientsDetail)` — ไม่ใช่ v2 |
| `chat_provider.dart` | `jsonEncode(preliminaryIngredients)` จาก hint/detail |
| `log_from_meal_sheet.dart` | `ingredientTreeToJsonMaps` |
| `health_provider.dart` | รับ `ingredientsJson` string จาก caller วิเคราะห์ |

## 2. จุดอ่าน `ingredientsJson`

- `food_detail_bottom_sheet`, `simple_food_detail_sheet`, `meal_section`: สมมติ `List` หลัง `jsonDecode` — ต้องใช้ **parse กลาง** แล้วแปลงเป็นรูปแบบที่ UI วาดได้ (หรือแยก viewer สำหรับ v2)

## 3. Gemini

- **`gemini_service.dart`:** validation + prompts สำหรับ `ingredients_detail` / `sub_ingredients`
- **`gemini_analysis_sheet.dart`:** duplicate `_EditableIngredient`, รวมแคลอรี่จาก root — ต้องสอดคล้อง recompute กลางและล็อก main เมื่อมี sub

## 4. Post-process (ARC2-AI-01)

- หลังได้ document v2 จาก AI: คำนวณผลรวมจาก mains/subs แล้ว **ปรับ** `calories`/`protein`/`carbs`/`fat` บน entry (หรือบนฟอร์มก่อนบันทึก) ให้ตรงภายใน tolerance
- ทำที่ชั้นเดียว (เช่นหลัง flatten ใน service หรือก่อน `updateFoodEntry`) เพื่อไม่ให้ Add/Edit/Gemini คนละสูตร

---

## Validation Architecture

1. **`flutter analyze`** บนไฟล์ที่แตะ
2. **Unit / widget tests** (ถ้ามีจาก Phase 13) + เทสต์ใหม่สำหรับ "บันทึกแล้วได้ `schemaVersion`" จาก path หนึ่งอย่างน้อย
3. **Manual `16-MANUAL-CHECKLIST.md`:** แก้ sub → entry อัปเดต; วิเคราะห์ Gemini แล้วยอดรวมสอดคล้อง; chat บันทึก ingredients

---

*End of research*
