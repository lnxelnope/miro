# เฟส 14 — App shell & Energy

## Manual checklist

1. **ModeToggle** — บน AppBar หน้าหลักไม่มีปุ่มสลับ Pro/Basic
2. **My Meal** — แตะไอคอนเมนู (ร้านอาหาร) บน AppBar → เปิดหน้าเมนูของฉัน → กดกลับออกได้
3. **QuestBar** — หน้าหลักแบบ basic ไม่แสดง QuestBar
4. **Energy Store** — ไม่มีการ์ด/ปุ่มรับ free energy แบบ legacy; **free pass** (freepass) ยังทดสอบ flow ได้
5. **แชท** — ช่องพิมพ์แชทด้านล่างของหน้าหลัก basic ไม่ปรากฏให้เห็น

Regression: `flutter test` และ `flutter test test/core/nutrition/ingredients_codec_test.dart`
