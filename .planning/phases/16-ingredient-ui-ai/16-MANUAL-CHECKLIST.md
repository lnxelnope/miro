# เช็คลิสต์ manual — เฟส 16 (ingredient UI + AI)

ทำครบก่อนปิดเฟส; บันทึกผล pass/fail ตามแถว

1. **วิเคราะห์รูป (หรือแบทช์)** — ยอดรวม macro บน FoodEntry สอดคล้องผลรวมจากวัตถุดิบหลัง flatten (ไม่ double-count ระหว่าง parent/sub)
2. **แก้ sub ใน Edit sheet** — บันทึกแล้ว macro บน entry อัปเดตตาม rollup
3. **เปลี่ยนปริมาณรวม main ที่มี sub** — sub สเกลตามสัดส่วน (Add / Edit)
4. **แชท (chat) บันทึกอาหารจากข้อความ** — เปิดรายละเอียดรายการที่มี `preliminaryIngredientsJson` ได้ ไม่ crash; ข้อมูลวัตถุดิบแสดงหรือโหลดต่อได้
5. **Log จาก My Meal** — บันทึกลง timeline แล้วเปิดรายละเอียดได้; `ingredientsJson` เป็น v2
6. **เปิด entry legacy** (list ดิบเก่าใน DB) — รายละเอียดอาหารแสดงวัตถุดิบได้ ไม่ crash
7. Regression: `flutter test test/core/nutrition/ingredients_codec_test.dart` ผ่าน
