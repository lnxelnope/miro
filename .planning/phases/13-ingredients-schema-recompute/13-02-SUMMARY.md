# 13-02 — Summary

**สถานะ:** เสร็จ

## สิ่งที่ส่งมอบ

- `test/core/nutrition/ingredients_codec_test.dart` — legacy / empty / invalid, v2 round-trip + `schemaVersion`, recompute macro, D-08b (fiber/sugar/sodium preserve), flatten ความลึก ≥3
- `.planning/phases/13-ingredients-schema-recompute/13-MANUAL-CHECKLIST.md` — เช็กหลัง Phase 16

## การตรวจ

- `flutter test test/core/nutrition/ingredients_codec_test.dart` — ผ่านทั้งหมด
- `flutter test` เต็มชุด — **มี failure เดิม** (เช่น `test/widget_test.dart` smoke ไม่ตรงข้อความ) — ไม่เกี่ยวกับไฟล์เทสต์ใหม่ของเฟสนี้
