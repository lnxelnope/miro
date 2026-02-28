# Step 34: Branding — App Icon, Splash Screen, ชื่อแอป

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1 วัน
> **ความยาก:** ง่าย
> **ต้องทำก่อน:** Step 33 (Production Hardening)

---

## 🎯 เป้าหมาย

1. **ตั้งชื่อแอปใหม่** — เปลี่ยนจาก "Miro Hybrid" เป็น "Miro Cal" (หรือชื่อที่เลือก)
2. **App Icon** — ออกแบบ + ใส่ icon ใหม่ (512x512)
3. **Splash Screen** — หน้าจอเปิดแอปสวยๆ
4. **Theme / Font** — ตรวจ Dark Mode + font ภาษาไทย

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `android/app/src/main/AndroidManifest.xml` | EDIT | เปลี่ยน android:label |
| `pubspec.yaml` | EDIT | เพิ่ม flutter_launcher_icons + flutter_native_splash |
| `lib/main.dart` | EDIT | เปลี่ยน MaterialApp title |
| `lib/features/home/presentation/home_screen.dart` | EDIT | เปลี่ยน AppBar title |
| `assets/icon/app_icon.png` | CREATE | App icon 512x512 |
| `assets/icon/splash_logo.png` | CREATE | Splash logo |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: ตั้งชื่อแอปใหม่

#### 1.1 AndroidManifest.xml

**ไฟล์:** `android/app/src/main/AndroidManifest.xml`

หา `android:label`:

```xml
<!-- ก่อน -->
<application android:label="Miro Hybrid" ...>

<!-- หลัง -->
<application android:label="Miro Cal" ...>
```

#### 1.2 pubspec.yaml

**ไฟล์:** `pubspec.yaml`

```yaml
# ก่อน
name: miro_hybrid

# หลัง
name: miro
```

> **หมายเหตุ:** เปลี่ยน `name` ใน pubspec อาจทำให้ import path เปลี่ยน
> ถ้าเปลี่ยนแล้ว error → เปลี่ยนกลับเป็นเดิมก็ได้ (name นี้ไม่ค่อยสำคัญ)

#### 1.3 MaterialApp title

**ไฟล์:** `lib/main.dart`

```dart
MaterialApp(
  title: 'Miro Cal',  // ← เปลี่ยน
  // ...
)
```

#### 1.4 AppBar title

**ไฟล์:** `lib/features/home/presentation/home_screen.dart`

```dart
AppBar(
  title: const Text('Miro Cal'),  // ← เปลี่ยน
)
```

---

### Step 2: App Icon

#### 2.1 เตรียมรูป Icon

**ขนาด:** 512 x 512 px (PNG, ไม่มีพื้นหลังโปร่งใส)
**ที่เก็บ:** `assets/icon/app_icon.png`

> **แนะนำ:** ใช้ Canva, Figma, หรือ AI (DALL-E, Midjourney) ออกแบบ icon
> **สื่อถึง:** อาหาร + AI + สุขภาพ
> **ตัวอย่าง:** 🍽️ จานอาหาร + ✨ sparkle (AI) หรือ 📊 กราฟ + 🍎

สร้าง folder:
```
assets/
  icon/
    app_icon.png      ← ไฟล์ icon
```

#### 2.2 เพิ่ม flutter_launcher_icons

**ไฟล์:** `pubspec.yaml`

```yaml
dev_dependencies:
  # ... dev dependencies เดิม ...
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"      # พื้นหลัง adaptive icon (Android 8+)
  adaptive_icon_foreground: "assets/icon/app_icon.png"
```

#### 2.3 Generate Icon

รันคำสั่ง:
```bash
flutter pub get
dart run flutter_launcher_icons
```

**ผลลัพธ์:** Icon จะถูกสร้างในทุกขนาดที่ Android ต้องการ:
- `android/app/src/main/res/mipmap-mdpi/` (48x48)
- `android/app/src/main/res/mipmap-hdpi/` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/` (192x192)

---

### Step 3: Splash Screen

#### 3.1 เตรียมรูป Splash

**ขนาด:** แนะนำ 300-500 px (จะถูก center บนจอ)
**ที่เก็บ:** `assets/icon/splash_logo.png`

> **ใช้ logo เดียวกับ icon ก็ได้** หรือออกแบบแยก

#### 3.2 เพิ่ม flutter_native_splash

**ไฟล์:** `pubspec.yaml`

```yaml
dev_dependencies:
  # ... dev dependencies เดิม ...
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#4CAF50"                          # สีพื้นหลัง (เขียว = สุขภาพ)
  image: "assets/icon/splash_logo.png"      # logo ตรงกลาง
  android: true
  android_12:
    color: "#4CAF50"
    image: "assets/icon/splash_logo.png"
```

> **เลือกสี:** ใช้สีหลักของแอป (primary color)
> ดูจาก `lib/core/theme/app_colors.dart`

#### 3.3 Generate Splash

รันคำสั่ง:
```bash
dart run flutter_native_splash:create
```

---

### Step 4: ตรวจ Theme + Dark Mode

#### 4.1 ตรวจ Dark Mode ทุกหน้า

เปิดแอปใน Dark Mode → กดดูทุกหน้า:
- [ ] Timeline → ข้อความอ่านง่าย
- [ ] Diet → form อ่านง่าย
- [ ] My Meal → card อ่านง่าย
- [ ] Profile → อ่านง่าย
- [ ] API Key → อ่านง่าย
- [ ] Chat → bubble สีถูกต้อง
- [ ] Bottom sheets → พื้นหลังไม่ขาว

**ถ้าเจอปัญหา:**
```dart
// ❌ ผิด — hardcode สีขาว
color: Colors.white

// ✅ ถูก — ใช้ theme
color: Theme.of(context).colorScheme.surface
```

#### 4.2 Font ภาษาไทย (Optional)

ถ้าต้องการใช้ Google Fonts:

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.1.0
```

```dart
// lib/core/theme/app_theme.dart
import 'package:google_fonts/google_fonts.dart';

static ThemeData lightTheme() {
  return ThemeData(
    textTheme: GoogleFonts.sarabunTextTheme(), // หรือ kantTextTheme(), promptTextTheme()
    // ... อื่นๆ ...
  );
}
```

> **Font แนะนำสำหรับภาษาไทย:**
> - **Sarabun** — อ่านง่าย ไม่หนัก
> - **Kanit** — ดูทันสมัย
> - **Prompt** — สะอาดตา

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] ชื่อแอปแสดง "Miro Cal" (หรือชื่อที่เลือก) ในหน้าจอ + drawer ของ Android
- [ ] App Icon ใหม่แสดงถูกต้อง (ไม่ใช่ icon Flutter default)
- [ ] Splash Screen แสดง logo + สีพื้นหลังที่เลือก
- [ ] เปิดแอป → เห็น Splash → เข้า Onboarding/Home
- [ ] Dark Mode → ทุกหน้าอ่านง่าย ไม่มี text สีขาวบนพื้นขาว
- [ ] AppBar title แสดงชื่อใหม่
- [ ] ติดตั้งแอปใหม่บนเครื่อง → เห็น icon ใหม่ในหน้าจอ

### ⚠️ สิ่งที่ห้ามลืม

- [ ] เพิ่ม `assets/icon/` ใน `pubspec.yaml` assets section:
```yaml
flutter:
  assets:
    - assets/icon/
```

---

## 🔍 Troubleshooting

### Q: `dart run flutter_launcher_icons` error
**แก้:** ตรวจว่า `flutter_launcher_icons` อยู่ใน `dev_dependencies` + `flutter pub get` แล้ว

### Q: Icon ไม่เปลี่ยน
**แก้:** ลบแอปจากเครื่อง → ติดตั้งใหม่ (icon cache)

### Q: Splash แสดง logo ใหญ่/เล็กเกิน
**แก้:** ปรับขนาดรูป splash_logo.png (แนะนำ 300-400px)

### Q: เปลี่ยนชื่อ pubspec name แล้ว import error หมด
**แก้:** เปลี่ยน `name` กลับเป็นเดิม (ชื่อ pubspec ไม่สำคัญสำหรับ user)

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 35 →

ไปทำ **Step 35: Legal — Privacy Policy + Terms** ได้เลย
