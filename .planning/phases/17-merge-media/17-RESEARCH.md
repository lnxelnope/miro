# Phase 17 — Technical research: Merge & media

**Phase:** 17 — merge-media  
**Date:** 2026-03-29  

## RESEARCH COMPLETE

---

## 1. Dependencies

- **Phase 15:** `FoodSandbox` ต้องมี `_buildSelectionBar` พร้อมปุ่มอื่นแล้ว — ปุ่ม **Group** ต่อท้าย/ข้างปุ่มย้ายมื้อ
- **Phase 13 + 16:** `ingredients_codec` + v2 บันทึกจริง — merge ควรส่งออก **`ingredientsJson` v2** (`schemaVersion`, `mainIngredients`) โดยแต่ละ entry ต้นทางสะท้อนเป็น **main อย่างน้อยหนึ่งโหนด** ตาม `17-CONTEXT` D-05

## 2. ลบหลายรายการ (แบบอ้างอิง)

- `basic_mode_tab.dart` → `_deleteSelectedEntries`: ยืนยัน `AlertDialog` (L10n) → loop `notifier.deleteFoodEntry` → `refreshFoodProviders`
- Merge: ยืนยันแบบเดียวกันได้ → สร้าง entry ใหม่ → `addFoodEntry` → ลบรายการเดิมทีละ id → `refreshFoodProviders`

## 3. ข้อมูลรูป / bbox

- `FoodEntry`: `imagePath`, `arBoundingBox`, `arImageWidth`, `arImageHeight` — ใช้สำหรับ thumb ระดับ **entry**; สำหรับ thumb **ต่อ ingredient** ต้องมี **optional `imagePath` (และ bbox ถ้ามี)** บนโหนดใน JSON v2 หรือแมปคู่ขนาน

## 4. Create Meal

- `create_meal_sheet.dart` ~953–966: แถว sub มีแค่ `Icons.search`
- Flow รูปมาตรฐาน: `ImagePickerService` → `ImageAnalysisPreviewScreen` / `GeminiService` — reuse ไม่ fork prompt

## 5. Nested group

- `isGroupOriginal` ใน Drift — ใช้เป็นเงื่อนไข **disable Group** ตาม D-06 (เสริม heuristic `foodName.startsWith('group_')` ถ้าจำเป็น)

---

## Validation Architecture

1. `flutter analyze` บนไฟล์ที่แตะ
2. Manual `17-MANUAL-CHECKLIST.md` (แผน 03)
3. Optional: unit test สำหรับ builder `IngredientsDocumentV2` จากหลาย `FoodEntry` mock

---

*End of research*
