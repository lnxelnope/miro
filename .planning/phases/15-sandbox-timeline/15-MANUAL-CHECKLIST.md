# เฟส 15 — Sandbox timeline

## Manual checklist

1. **กลุ่มมื้อ** — บน Basic home รายการในวันเดียวกันแยกเป็นหัวข้อมื้อ (เช้า / กลางวัน / เย็น / ว่าง) เมื่อมีข้อมูลหลายมื้อ; มื้อว่างไม่แสดงหัวข้อ
2. **วันในอนาคต / พรุ่งนี้** — จาก `DailySummaryCard` และ `DateNavigationBar` เลื่อนไปวันถัดไปได้จนถึงขีดวางแผน (horizon เดียวกับ date picker)
3. **ย้ายมื้อจาก sandbox** — เลือกหลายรายการ → เปลี่ยนมื้อ → `mealType` อัปเดต โดยไม่เปลี่ยนเวลาในวัน

Regression: `flutter test test/core/nutrition/ingredients_codec_test.dart`
