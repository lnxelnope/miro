# 🎯 คู่มือสร้าง In-App Purchase ใน Play Console

## ⚠️ สำคัญ: Play Console มี 2 ช่องที่แตกต่างกัน!

Play Console จะมี **2 หน้า** และแต่ละหน้ามี **รหัสคนละอัน**:

---

## 📝 หน้าที่ 1: สร้าง Product (Create Product)

### ช่อง "Product ID" (รหัสการซื้อ)

**กรอกแบบนี้:**
```
miro_pro
```

✅ **ใช้ underscore (`_`) ได้**  
✅ นี่คือ **Product ID จริงๆ** ที่ต้องตรงกับ code

### ช่องอื่นๆ:

**Name (ชื่อ):**
```
MIRO Pro
```

**Description (คำอธิบาย):**
```
Unlock unlimited AI food analysis - no daily limits
```

### กด "Next" หรือ "ถัดไป"

---

## 💰 หน้าที่ 2: ตั้งราคา (Set Price)

### ช่อง "รหัสตัวเลือกการซื้อ" (SKU)

**อาจบังคับให้กรอก และอาจบังคับให้ใช้ dash!**

**ถ้าบังคับให้กรอก ให้กรอก:**
```
miro-pro
```

⚠️ **หมายเหตุ:** ช่องนี้เป็น **SKU ไม่ใช่ Product ID** - ในบาง version ของ Play Console มันอาจ auto-fill หรือไม่ให้แก้ไข

### ตั้งราคา:

เลือกประเทศและราคา:
- **Thailand:** ฿99
- **United States:** $2.99
- หรือใช้ template pricing

### เปลี่ยน Status:

เปลี่ยนจาก **Inactive** → **Active** ✅

### กด "Save" หรือ "บันทึก"

---

## 🎯 สิ่งสำคัญที่สุด

### ในโค้ดเราใช้ Product ID (หน้าแรก):
```dart
static const String proProductId = 'miro_pro';  // ✅ underscore
```

### ไม่ใช่ SKU (หน้าสอง):
```dart
❌ 'miro-pro'  // นี่คือ SKU ไม่ใช่ Product ID
```

---

## ✅ Checklist

- [x] แก้ไข code เป็น `miro_pro` (underscore)
- [ ] สร้าง product ใน Play Console
  - [ ] หน้า 1: Product ID = `miro_pro` (underscore)
  - [ ] หน้า 2: SKU = `miro-pro` (dash - ถ้าบังคับ)
  - [ ] ตั้งราคา ฿99
  - [ ] เปลี่ยน Status = Active
- [ ] Build version 1.0.2+8
- [ ] Upload ไป Internal Testing
- [ ] รอ 1-2 ชั่วโมง
- [ ] ทดสอบ

---

## 🔧 สรุปแบบสั้น

1. **หน้าแรก** → Product ID: `miro_pro` (underscore ✅)
2. **หน้าสอง** → SKU: `miro-pro` (dash - ถ้าบังคับให้กรอก)
3. **Code ใช้** → `miro_pro` (ตรงกับหน้าแรก)

---

## 📞 ถ้ายังสับสน

Google Play Console มีหลาย version และ UI อาจแตกต่างกันไป

**กฎทอง:** ใช้ Product ID ที่กรอกใน**หน้าแรก** ไปใส่ใน code

ในกรณีของคุณคือ: `miro_pro` (underscore)

---

Build version ใหม่แล้วทดสอบดูนะครับ! 🚀
