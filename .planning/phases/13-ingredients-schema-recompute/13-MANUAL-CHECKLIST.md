# เฟส 13 — ingredients schema

## Manual checklist

ใช้หลัง **Phase 16** wire UI กับ `ingredientsJson` / codec แล้ว

1. เปิดรายการอาหารที่มี `ingredientsJson` แบบ legacy (list) — แอปต้องไม่ crash และแสดง/แก้ไขได้ตามที่ออกแบบ
2. บันทึกรายการที่มี sub-ingredients — ค่า macro ระดับ entry ต้องสอดคล้องกับผลรวมจาก subs (ตาม recompute)
3. Regression อัตโนมัติ: `flutter test test/core/nutrition/ingredients_codec_test.dart`
