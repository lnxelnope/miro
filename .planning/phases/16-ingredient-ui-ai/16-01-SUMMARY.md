# 16-01 Summary — Add/Edit + codec

## สถานะ

รายการตรวจใน repo (execute-phase 16):

- `ingredients_codec.dart` มี `parseIngredientsJson` / `serializeIngredientsV2`
- `add_food_bottom_sheet.dart`: โหลดผ่าน `parseIngredientsJson`, บันทึกผ่าน `serializeIngredientsV2` + recompute; ไม่มี `jsonEncode(_ingredients.map`); มี `readOnly: true` สำหรับ macro เมื่อล็อกตาม flow
- `edit_food_bottom_sheet.dart`: `parseIngredientsJson` ตอนโหลด, `serializeIngredientsV2` ตอนบันทึก; ไม่มี `jsonDecode(entry.ingredientsJson` แบบสมมติ List ตรงๆ

## Fixture / manual

บันทึกใหม่ที่มีโครงสร้างวัตถุดิบจาก codec ควรได้ `ingredientsJson` ที่มี `schemaVersion` (ยืนยันด้วย UAT ใน `16-MANUAL-CHECKLIST.md`)
