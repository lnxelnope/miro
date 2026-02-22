# 🚀 Quick Start Guide - สำหรับ Junior Dev

> เริ่มทำงาน Localization ภายใน 5 นาที

---

## 📋 ขั้นตอนเริ่มต้น (5 นาที)

### 1. อ่านเอกสาร (3 นาที)
```bash
# เปิดไฟล์เหล่านี้อ่านคร่าวๆ
_project_manager/localization_i18n/README.md          # คู่มือหลัก
_project_manager/localization_i18n/PROGRESS.md        # ติดตามงาน
_project_manager/localization_i18n/QUICK_START.md    # ไฟล์นี้
```

### 2. ทดสอบระบบ (2 นาที)
```bash
# 1. Run app
flutter run

# 2. ไปหน้า Profile (tab ล่างขวา)

# 3. กด "Language / ภาษา"

# 4. ลองเปลี่ยนภาษา
#    🇹🇭 ไทย → 🇺🇸 English → 🌐 System Default

# 5. ดูว่าข้อความบางส่วนเปลี่ยนภาษา (Profile Screen ทำเสร็จแล้ว)
```

---

## 🎯 ทำงานจริง (Step-by-Step)

### Step 1: เลือกไฟล์ที่จะทำ

เปิด `PROGRESS.md` → เลือกไฟล์ที่ Status = ⏳ Pending

**แนะนำเริ่มจาก (ไฟล์ที่ยังไม่ได้ทำ):**
- Camera Screen (ง่าย, ~20 strings)
- Referral Screen (medium, ~35 strings)
- Subscription Screen (medium, ~40 strings)

> ⚠️ Phase 1-2 + Chat Screen ทำเสร็จแล้ว ไม่ต้องทำซ้ำ

### Step 2: สร้าง Working Document

สร้างไฟล์ใน folder นี้ เช่น:
```
_project_manager/localization_i18n/work_in_progress/
  ├── home_screen_strings.md
  ├── health_goals_strings.md
  └── my_meal_tab_strings.md
```

**Template ไฟล์:**

```markdown
# [Screen Name] - Localization Work

**File:** `lib/features/.../xxx_screen.dart`  
**Status:** 🔄 In Progress  
**Developer:** [Your Name]  
**Started:** [Date]

---

## Strings Analysis

| Line | Current (Hardcoded) | Key Name | Thai | English | Priority |
|------|---------------------|----------|------|---------|----------|
| 42 | `'Save'` | `save` | บันทึก | Save | High |
| 58 | `'Cancel'` | `cancel` | ยกเลิก | Cancel | High |
| 102 | `'Delete all data?'` | `deleteAllDataTitle` | ลบข้อมูลทั้งหมด? | Delete all data? | High |

---

## ARB Entries

### app_th.arb
```json
{
  "save": "บันทึก",
  "cancel": "ยกเลิก",
  "deleteAllDataTitle": "ลบข้อมูลทั้งหมด?"
}
```

### app_en.arb
```json
{
  "save": "Save",
  "cancel": "Cancel",
  "deleteAllDataTitle": "Delete all data?"
}
```

---

## Code Changes

### Before
```dart
Text('Save')
```

### After
```dart
Text(L10n.of(context)!.save)
```

---

## Testing Checklist

- [ ] Hot reload สำเร็จ
- [ ] ทดสอบภาษาไทย
- [ ] ทดสอบภาษาอังกฤษ
- [ ] ไม่มี error
- [ ] Commit แล้ว
```

### Step 3: วิเคราะห์ไฟล์

```bash
# 1. เปิดไฟล์ที่จะทำ
code lib/features/home/presentation/home_screen.dart

# 2. ค้นหา hardcoded strings
# ใน VS Code กด Ctrl+F แล้วค้น:
#   - Text('
#   - title: '
#   - subtitle: '
#   - 'string

# 3. บันทึกลงในตารางใน Working Document
```

**ตัวอย่างผลลัพธ์:**

```
พบ hardcoded strings:
1. Line 45: 'Home'
2. Line 67: 'Timeline'
3. Line 89: 'Diet'
4. Line 112: 'Chat'
5. Line 134: 'Profile'
```

### Step 4: เพิ่ม Strings ใน ARB Files

```bash
# 1. เปิด app_th.arb
code lib/l10n/app_th.arb

# 2. เลื่อนไปท้ายไฟล์ (ก่อน } ปิดสุดท้าย)

# 3. เพิ่ม strings (อย่าลืม comma!)
```

**Template สำหรับ app_th.arb:**

```json
{
  "@@locale": "th",
  
  ... existing strings ...,

  "home": "หน้าหลัก",
  "timeline": "Timeline",
  "diet": "Diet",
  "chat": "แชท",
  "profile": "โปรไฟล์"
}
```

> **⚠️ ห้ามใช้ key ที่ขึ้นต้นด้วย `_`** (เช่น `"_comment_xxx"`) จะทำให้ `flutter gen-l10n` error!  
> ใช้ **บรรทัดว่าง** แยกกลุ่มแทน

**จากนั้นทำซ้ำใน app_en.arb:**

```json
{
  "@@locale": "en",
  
  ... existing strings ...,

  "home": "Home",
  "timeline": "Timeline",
  "diet": "Diet",
  "chat": "Chat",
  "profile": "Profile"
}
```

### Step 5: Generate Code

```bash
# Terminal
flutter gen-l10n

# ถ้าสำเร็จจะเห็น:
# Generating localizations
# Done

# ถ้ามี error → ตรวจสอบ JSON syntax
```

### Step 6: แก้โค้ด

```bash
# 1. เปิดไฟล์อีกครั้ง
code lib/features/home/presentation/home_screen.dart

# 2. เพิ่ม import (ถ้ายังไม่มี)
import 'package:miro_hybrid/l10n/app_localizations.dart';

# 3. แก้ hardcoded → L10n
```

**ตัวอย่างการแก้:**

```dart
// ❌ ก่อน
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: 'Home',
)

// ✅ หลัง
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: L10n.of(context)!.home,
)
```

**⚠️ สำคัญ: ลบ `const` ออก**

```dart
// ❌ จะ error
const Text(L10n.of(context)!.home)

// ✅ ถูกต้อง
Text(L10n.of(context)!.home)
```

### Step 7: ทดสอบ

```bash
# 1. Hot Reload
r

# 2. ถ้ามี error → อ่าน error message แก้ให้ถูก

# 3. ถ้าไม่มี error → เปลี่ยนภาษา
#    Profile → Language → เลือก ไทย / English

# 4. กลับมาดูหน้าที่แก้ ตรวจสอบว่าข้อความเปลี่ยนตามภาษา
```

### Step 8: Commit

```bash
git add .
git commit -m "feat(i18n): add localization for Home Screen

- Added 5 strings (home, timeline, diet, chat, profile)
- Updated home_screen.dart to use L10n
- Tested Thai and English translations"
```

### Step 9: Update Progress

```bash
# 1. เปิด PROGRESS.md
code _project_manager/localization_i18n/PROGRESS.md

# 2. เปลี่ยน Status จาก ⏳ Pending → ✅ Done

# 3. ใส่ชื่อ Developer, Date, Tested ✅

# 4. Commit
git add _project_manager/localization_i18n/PROGRESS.md
git commit -m "docs: update localization progress - Home Screen done"
```

---

## 🎓 ตัวอย่างจริง: Home Screen (5-10 นาที)

### 1. วิเคราะห์

เปิด `lib/features/home/presentation/home_screen.dart`:

```dart
// พบ hardcoded strings:
bottomNavigationBar: BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.timeline),
      label: 'Timeline',  // ← นี่
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant),
      label: 'Diet',  // ← นี่
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',  // ← นี่
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',  // ← นี่
    ),
  ],
)
```

### 2. เพิ่มใน app_th.arb

```json
{
  "@@locale": "th",
  
  ...,
  
  "timeline": "Timeline",
  "diet": "Diet",
  "chat": "แชท",
  "profile": "โปรไฟล์"
}
```

### 3. เพิ่มใน app_en.arb

```json
{
  "@@locale": "en",
  
  ...,
  
  "timeline": "Timeline",
  "diet": "Diet",
  "chat": "Chat",
  "profile": "Profile"
}
```

### 4. Generate

```bash
flutter gen-l10n
```

### 5. แก้โค้ด

```dart
import 'package:miro_hybrid/l10n/app_localizations.dart';

// เอา const ออก!
bottomNavigationBar: BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: const Icon(Icons.timeline),
      label: L10n.of(context)!.timeline,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.restaurant),
      label: L10n.of(context)!.diet,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.chat),
      label: L10n.of(context)!.chat,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.person),
      label: L10n.of(context)!.profile,
    ),
  ],
)
```

### 6. ทดสอบ

```bash
# Hot Reload
r

# เปลี่ยนภาษา
Profile → Language → ไทย

# ดู Bottom Nav
# "Chat" → "แชท" ✅
# "Profile" → "โปรไฟล์" ✅
```

---

## 💡 Tips สำหรับทำงานเร็วขึ้น

### 1. ใช้ Multi-cursor ใน VS Code

```
1. เลือกข้อความที่ต้องการแก้
2. กด Ctrl+D (Windows) / Cmd+D (Mac) หลายๆ ครั้ง
3. พิมพ์แก้ทีเดียวหลายบรรทัด
```

### 2. ใช้ Find & Replace

```
Find:    Text('([^']+)')
Replace: Text(L10n.of(context)!.$1)

แต่ระวัง! ต้องสร้าง key ใน .arb ก่อน
```

### 3. ทำทีละส่วน

อย่าพยายามทำทั้งไฟล์ในครั้งเดียว:
- ทำทีละ 5-10 strings
- Generate + Test
- ถ้าผ่านค่อยทำต่อ

### 4. Copy Pattern จากไฟล์ที่ทำแล้ว

```bash
# ดู Profile Screen (ทำเสร็จแล้ว)
code lib/features/profile/presentation/profile_screen.dart

# Copy pattern การใช้ L10n
# แล้วนำมาดัดแปลงใช้
```

---

## 🚨 ข้อผิดพลาดที่พบบ่อย

### 1. ลืมเอา `const` ออก
```dart
❌ const Text(L10n.of(context)!.home)
✅ Text(L10n.of(context)!.home)
```

### 2. ลืม comma ใน JSON
```json
❌ "home": "Home"
   "chat": "Chat"

✅ "home": "Home",
   "chat": "Chat"
```

### 3. Key name ไม่ตรงกัน
```json
// app_th.arb
"homePage": "หน้าหลัก"

// app_en.arb
"home": "Home"  ← ผิด! ต้องเป็น "homePage"
```

### 4. Placeholder ผิด
```json
❌ "welcome": "Hello {username}!"  // ใช้ {username}
   L10n.of(context)!.welcome(name: userName)  // แต่ใส่ name

✅ "welcome": "Hello {name}!"  // ใช้ {name}
   L10n.of(context)!.welcome(userName)  // ใส่ name ตรง
```

---

## 🎯 เป้าหมายแรก (วันที่ 1)

> **หมายเหตุ:** Phase 1-2 และ Chat Screen ทำเสร็จแล้ว  
> Junior ให้เริ่มจากไฟล์ที่ยังไม่ได้ทำ (ดู PROGRESS.md)

- [ ] อ่านคู่มือให้จบ (30 นาที)
- [ ] เลือกไฟล์จาก `PROGRESS.md` ที่ Status = ⏳ Pending
- [ ] ทำ 1-2 ไฟล์ให้เสร็จ (1-2 ชั่วโมง)
- [ ] Commit ทั้งหมด
- [ ] Update PROGRESS.md

**แนะนำเริ่มจาก:**
- Camera Screen (ง่าย, ~20 strings, เป็น Widget ตรงไปตรงมา)
- Referral Screen (medium, ~35 strings)

**รวมเวลา:** ~2-3 ชั่วโมง

---

## 📞 ติดต่อ / ถามคำถาม

ถ้าติดปัญหา:
1. อ่าน **Troubleshooting** ใน README.md
2. ดู examples ใน Profile Screen
3. ลอง Google error message
4. ถามใน team chat พร้อมแนบ error screenshot

---

**สร้างโดย:** AI Assistant  
**สำหรับ:** Miro Hybrid - Localization Phase  
**Last Updated:** 19 ก.พ. 2026
