# TASK 1: เปลี่ยน Theme และ Color System

> **ระยะเวลา:** 4 ชั่วโมง  
> **ความยาก:** ⭐ ง่าย  
> **Dependency:** ไม่มี (ทำก่อนได้เลย)

## 🎯 เป้าหมาย

เปลี่ยนสีของแอปจาก Indigo เป็น Teal/Green และปรับ theme ให้เป็น Airbnb style

### Before → After
| สิ่งที่เปลี่ยน | ก่อน | หลัง |
|---------------|------|------|
| สี Primary | Indigo `#6366F1` | Teal `#2D8B75` |
| Card | Border + flat | Shadow + rounded 16px |
| AppBar title | ตรงกลาง | ชิดซ้าย |

## 📁 ไฟล์ที่ต้องแก้ (2 ไฟล์เท่านั้น)

1. `lib/core/theme/app_colors.dart`
2. `lib/core/theme/app_theme.dart`

---

## ขั้นตอนที่ 1: แก้ไฟล์ app_colors.dart

### 1.1 เปิดไฟล์
```
lib/core/theme/app_colors.dart
```

### 1.2 หา 3 บรรทัดนี้ (บรรทัดที่ 5-7)
```dart
static const Color primary = Color(0xFF6366F1);      // Indigo-500
static const Color primaryLight = Color(0xFFA5B4FC); // Indigo-300
static const Color primaryDark = Color(0xFF4F46E5);  // Indigo-600
```

### 1.3 เปลี่ยนเป็น
```dart
static const Color primary = Color(0xFF2D8B75);      // Teal-600 (Airbnb style)
static const Color primaryLight = Color(0xFF5BB5A2); // Teal-400
static const Color primaryDark = Color(0xFF1F6F5C);  // Teal-700
```

### 1.4 เซฟไฟล์

**✅ Done ไฟล์แรก!** ไฟล์นี้มีแค่ 45 บรรทัด แก้ 3 บรรทัดพอ

---

## ขั้นตอนที่ 2: แก้ไฟล์ app_theme.dart (Light Theme)

### 2.1 เปิดไฟล์
```
lib/core/theme/app_theme.dart
```

### 2.2 หาส่วน AppBar Theme (บรรทัดที่ 18-23)

**Before:**
```dart
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.surface,
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  centerTitle: true,
),
```

**After:**
```dart
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.background,  // เปลี่ยนจาก surface → background
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  centerTitle: false,  // เปลี่ยนจาก true → false (ชิดซ้าย)
  titleTextStyle: TextStyle(  // เพิ่ม 4 บรรทัดนี้
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  ),
),
```

### 2.3 หาส่วน Card Theme (บรรทัดที่ 30-36)

**Before:**
```dart
cardTheme: CardThemeData(
  color: AppColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: const BorderSide(color: AppColors.divider),
  ),
),
```

**After:**
```dart
cardTheme: CardThemeData(
  color: AppColors.surface,
  elevation: 1,  // เปลี่ยนจาก 0 → 1
  shadowColor: Colors.black.withOpacity(0.08),  // เพิ่มบรรทัดนี้
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),  // เปลี่ยนจาก 12 → 16
    // ลบ side: const BorderSide(...) ออกทั้งบรรทัด
  ),
),
```

### 2.4 หาส่วน TextTheme → headlineLarge (บรรทัดที่ 47-51)

**Before:**
```dart
headlineLarge: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: AppColors.textPrimary,
),
```

**After:**
```dart
headlineLarge: TextStyle(
  fontSize: 28,  // เปลี่ยนจาก 24 → 28
  fontWeight: FontWeight.w800,  // เปลี่ยนจาก bold → w800
  color: AppColors.textPrimary,
),
```

---

## ขั้นตอนที่ 3: แก้ไฟล์ app_theme.dart (Dark Theme)

### 3.1 หาส่วน Dark Theme (เริ่มบรรทัดที่ 82)

คุณจะเห็น `static ThemeData darkTheme = ThemeData(` ให้ทำแบบเดียวกับ Light Theme แต่ใน Dark Theme นี้

### 3.2 แก้ AppBar Theme ใน Dark (บรรทัดที่ 96-101)

**Before:**
```dart
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.surfaceDark,
  foregroundColor: AppColors.textPrimaryDark,
  elevation: 0,
  centerTitle: true,
),
```

**After:**
```dart
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.backgroundDark,  // เปลี่ยนจาก surfaceDark → backgroundDark
  foregroundColor: AppColors.textPrimaryDark,
  elevation: 0,
  centerTitle: false,  // เปลี่ยนจาก true → false
  titleTextStyle: TextStyle(  // เพิ่ม 4 บรรทัดนี้
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimaryDark,
  ),
),
```

### 3.3 แก้ Card Theme ใน Dark (บรรทัดที่ 108-114)

**Before:**
```dart
cardTheme: CardThemeData(
  color: AppColors.surfaceDark,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: const BorderSide(color: AppColors.dividerDark),
  ),
),
```

**After:**
```dart
cardTheme: CardThemeData(
  color: AppColors.surfaceDark,
  elevation: 1,  // เปลี่ยนจาก 0 → 1
  shadowColor: Colors.black.withOpacity(0.2),  // เพิ่มบรรทัดนี้ (0.2 เพราะ dark mode)
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),  // เปลี่ยนจาก 12 → 16
    // ลบ side: const BorderSide(...) ออกทั้งบรรทัด
  ),
),
```

### 3.4 เซฟไฟล์

**✅ Done ไฟล์ที่สอง!**

---

## 📝 Checklist

- [ ] เปลี่ยน primary colors ใน `app_colors.dart` (3 บรรทัด)
- [ ] แก้ AppBar theme ใน Light (centerTitle: false, background, titleTextStyle)
- [ ] แก้ Card theme ใน Light (elevation: 1, shadowColor, borderRadius: 16, ลบ side)
- [ ] แก้ headlineLarge ใน Light (fontSize: 28, w800)
- [ ] แก้ AppBar theme ใน Dark เหมือน Light
- [ ] แก้ Card theme ใน Dark เหมือน Light
- [ ] Build ผ่าน: `flutter build apk --debug`
- [ ] ทดสอบ: เปิดแอป ดูสีเปลี่ยนทั้งแอป
- [ ] ทดสอบ: Card มี shadow เล็กน้อย (มุมมน)
- [ ] ทดสอบ: AppBar title ชิดซ้าย ไม่ได้ตรงกลาง
- [ ] ทดสอบ: สลับ Dark mode ไม่แตก

---

## 🧪 Testing Steps

### 1. Build แอป
```bash
cd c:\aiprogram\miro
flutter clean
flutter pub get
flutter build apk --debug
```

**คาดหวัง:** Build สำเร็จ ไม่มี error

### 2. Run แอป
```bash
flutter run
```

### 3. Test ด้วยตา

#### Light Mode
- เปิดแอป → สีหลักเปลี่ยนจาก Indigo เป็น Teal (เขียวอมฟ้า)
- ดู Card → มี shadow เบาๆ (ไม่มีขอบ), มุมมน
- ดู AppBar → title ชิดซ้าย (ไม่ใช่ตรงกลาง)

#### Dark Mode
- เข้า Profile → Toggle Dark Mode
- ดู Card → มี shadow (สีเข้มกว่า light)
- ดู AppBar → title ชิดซ้าย
- สีต้องไม่แตก (ไม่มีสีขาวแทรกที่ไม่ควร)

### 4. กด Scroll ดู Card
- Home screen → scroll ดู card
- Card ทั้งหมดมี shadow เล็กน้อย
- มุม card มน (16px)

---

## 🚀 Git Commit

เมื่อทดสอบผ่านหมดแล้ว commit:

```bash
git add lib/core/theme/
git commit -m "style: update color palette and theme to Airbnb-inspired design

- Change primary color from Indigo to Teal
- Update AppBar: left-aligned title, larger font
- Update Card: shadow instead of border, rounded 16px
- Update both light and dark themes"

git push origin feature/airbnb-redesign
```

---

## ❓ Q&A

**Q: ถ้า build error แล้วมี import error?**  
A: เพิ่ม import ข้างบน:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
```

**Q: ถ้าไม่แน่ใจว่าแก้ถูกไหม?**  
A: ดูที่ icon/button ต่างๆ → ถ้าเปลี่ยนจาก Indigo เป็น Teal = ถูก

**Q: ต้องแก้ไฟล์อื่นอีกไหม?**  
A: ไม่ต้อง Task นี้แก้แค่ 2 ไฟล์

---

**✅ เสร็จแล้ว?** → ไปทำ `TASK_2_SUMMARY_CARD.md` ต่อ
