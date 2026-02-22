# 🌐 Centralized Strings & Localization Guide

> **คู่มือปฏิบัติการสำหรับ Junior Developer**  
> สามารถทำตามขั้นตอนได้เลยโดยไม่ต้องถามเพิ่มเติม

---

## 📋 สารบัญ

1. [ภาพรวมระบบ](#ภาพรวมระบบ)
2. [โครงสร้างไฟล์](#โครงสร้างไฟล์)
3. [ขั้นตอนการทำงาน](#ขั้นตอนการทำงาน)
4. [คู่มือสำหรับแต่ละหน้า](#คู่มือสำหรับแต่ละหน้า)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 เป้าหมาย

แปลงโค้ดทั้งหมดจาก **hardcoded strings** เป็น **centralized strings** เพื่อ:
- ✅ จัดการข้อความจากที่เดียว
- ✅ รองรับหลายภาษา (ไทย, อังกฤษ, และอื่นๆ)
- ✅ แก้ไขข้อความได้ง่ายโดยไม่ต้องค้นโค้ด
- ✅ Type-safe (มี autocomplete ใน IDE)

---

## 📦 ภาพรวมระบบ

### ระบบที่มีอยู่แล้ว

```
lib/l10n/
├── app_th.arb           # ไฟล์ภาษาไทย (template)
├── app_en.arb           # ไฟล์ภาษาอังกฤษ
├── app_localizations.dart       # Auto-generated
├── app_localizations_th.dart    # Auto-generated
└── app_localizations_en.dart    # Auto-generated
```

### Workflow

```
1. เพิ่ม/แก้ strings ใน .arb files
              ↓
2. Flutter auto-generate code (Hot Reload)
              ↓
3. ใช้ L10n.of(context)!.keyName ในโค้ด
              ↓
4. แอปแสดงภาษาตาม locale ของผู้ใช้
```

---

## 📂 โครงสร้างไฟล์

### 1. `l10n.yaml` (Config file)

```yaml
arb-dir: lib/l10n
template-arb-file: app_th.arb
output-localization-file: app_localizations.dart
output-class: L10n
```

### 2. `app_th.arb` (ภาษาไทย - Template)

```json
{
  "@@locale": "th",
  
  "save": "บันทึก",
  "cancel": "ยกเลิก",
  "welcomeMessage": "สวัสดี {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

### 3. `app_en.arb` (ภาษาอังกฤษ)

```json
{
  "@@locale": "en",
  
  "save": "Save",
  "cancel": "Cancel",
  "welcomeMessage": "Hello {name}!"
}
```

### 4. การใช้งานในโค้ด

```dart
import 'package:miro_hybrid/l10n/app_localizations.dart';

// ❌ แบบเก่า (hardcoded)
Text('Save')

// ✅ แบบใหม่ (centralized)
Text(L10n.of(context)!.save)

// ✅ แบบมี placeholder
Text(L10n.of(context)!.welcomeMessage('John'))
```

---

## 🚀 ขั้นตอนการทำงาน

### Phase 1: วิเคราะห์หน้า (Analysis)

1. เปิดไฟล์ที่จะทำ (เช่น `profile_screen.dart`)
2. ค้นหาข้อความทั้งหมดที่ต้อง centralize:
   - `Text('...')`
   - `'string literal'`
   - `subtitle: '...'`
   - Error messages, labels, hints

3. สร้างลิสต์ strings ที่พบ พร้อมตั้งชื่อ key

**ตัวอย่าง:**

| ข้อความที่เจอ | Key Name | ภาษาไทย | ภาษาอังกฤษ |
|-------------|----------|---------|-----------|
| `'Profile & Settings'` | `profileSettings` | `โปรไฟล์และการตั้งค่า` | `Profile & Settings` |
| `'Daily Goals'` | `dailyGoals` | `เป้าหมายรายวัน` | `Daily Goals` |
| `'Version'` | `version` | `เวอร์ชัน` | `Version` |

### Phase 2: เพิ่ม Strings ใน .arb Files

#### Step 1: เพิ่มใน `app_th.arb`

```json
{
  "@@locale": "th",
  
  "profileSettings": "โปรไฟล์และการตั้งค่า",
  "dailyGoals": "เป้าหมายรายวัน",
  "version": "เวอร์ชัน",
  "backupData": "สำรองข้อมูล",
  "restoreData": "กู้คืนข้อมูล",
  
  "clearAllDataConfirm": "ข้อมูลทั้งหมดจะถูกลบ\nลบแล้วกู้คืนไม่ได้!",
  
  "energyRemaining": "พลังงานเหลือ {energy} หน่วย",
  "@energyRemaining": {
    "placeholders": {
      "energy": {
        "type": "int"
      }
    }
  }
}
```

#### Step 2: เพิ่มใน `app_en.arb` (แปลเป็นอังกฤษ)

```json
{
  "@@locale": "en",
  
  "profileSettings": "Profile & Settings",
  "dailyGoals": "Daily Goals",
  "version": "Version",
  "backupData": "Backup Data",
  "restoreData": "Restore Data",
  
  "clearAllDataConfirm": "All data will be deleted.\nThis cannot be undone!",
  
  "energyRemaining": "{energy} energy remaining"
}
```

**⚠️ สำคัญ:**
- ชื่อ key ต้องเหมือนกันทั้งสองไฟล์
- Placeholders `@keyName` ใส่แค่ใน template (app_th.arb)

### Phase 3: Auto-generate Code

เมื่อบันทึก `.arb` แล้ว:

1. **Hot Reload (r)** - Flutter จะ generate code อัตโนมัติ
2. ถ้าไม่ได้ ให้รัน:
   ```bash
   flutter gen-l10n
   ```

### Phase 4: แก้ไขโค้ด

#### ตัวอย่างที่ 1: Text Widget

```dart
// ❌ ก่อน
AppBar(
  title: const Text('Profile & Settings'),
)

// ✅ หลัง
AppBar(
  title: Text(L10n.of(context)!.profileSettings),
)
```

#### ตัวอย่างที่ 2: String Properties

```dart
// ❌ ก่อน
_buildModernSettingCard(
  context: context,
  title: 'Daily Goals',
  subtitle: '2000 kcal • P 150g',
)

// ✅ หลัง
_buildModernSettingCard(
  context: context,
  title: L10n.of(context)!.dailyGoals,
  subtitle: '2000 kcal • P 150g', // นี่อาจไม่ต้องแปล (เป็นตัวเลข)
)
```

#### ตัวอย่างที่ 3: Dialog Messages

```dart
// ❌ ก่อน
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Clear all data?'),
    content: const Text('All data will be deleted.\nThis cannot be undone!'),
  ),
)

// ✅ หลัง
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(L10n.of(context)!.clearAllDataTitle),
    content: Text(L10n.of(context)!.clearAllDataConfirm),
  ),
)
```

#### ตัวอย่างที่ 4: SnackBar Messages

```dart
// ❌ ก่อน
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Saved successfully')),
)

// ✅ หลัง
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(L10n.of(context)!.savedSuccess)),
)
```

#### ตัวอย่างที่ 5: Strings with Placeholders

```dart
// ❌ ก่อน
Text('Energy remaining: $energy units')

// ✅ หลัง
Text(L10n.of(context)!.energyRemaining(energy))
```

### Phase 5: ทดสอบ

1. Hot Reload (r)
2. เปลี่ยนภาษาในแอป (Profile → Language)
3. ตรวจสอบว่าข้อความเปลี่ยนภาษาถูกต้อง
4. ตรวจสอบว่าไม่มี error

---

## 📱 คู่มือสำหรับแต่ละหน้า

### 1. Profile Screen

**ไฟล์:** `lib/features/profile/presentation/profile_screen.dart`

**Strings ที่ต้องเพิ่ม:**

```json
{
  "profileSettings": "โปรไฟล์และการตั้งค่า",
  "healthGoals": "เป้าหมายสุขภาพ",
  "dailyGoals": "เป้าหมายรายวัน",
  "chatAiMode": "โหมด Chat AI",
  "cuisinePreference": "ความชอบอาหาร",
  "photoScan": "สแกนรูปภาพ",
  "language": "ภาษา",
  "account": "บัญชี",
  "miroId": "MiRO ID",
  "inviteFriends": "เชิญเพื่อน",
  "inviteFriendsSubtitle": "แชร์โค้ดและรับรางวัล",
  "energyPass": "Energy Pass",
  "energyPassSubtitle": "AI ไม่จำกัด + รางวัล 2 เท่า",
  "dataSection": "ข้อมูล",
  "backupData": "สำรองข้อมูล",
  "backupDataSubtitle": "Energy + ประวัติอาหาร → บันทึกเป็นไฟล์",
  "restoreFromBackup": "กู้คืนจาก Backup",
  "restoreFromBackupSubtitle": "นำเข้าข้อมูลจากไฟล์ backup",
  "analyticsDataCollection": "เก็บข้อมูลการใช้งาน",
  "analyticsEnabled": "เปิดอยู่ - ช่วยปรับปรุงประสบการณ์",
  "analyticsDisabled": "ปิดอยู่ - ไม่เก็บข้อมูล",
  "clearAllData": "ล้างข้อมูลทั้งหมด",
  "about": "เกี่ยวกับ",
  "version": "เวอร์ชัน",
  "privacyPolicy": "นโยบายความเป็นส่วนตัว",
  "termsOfService": "เงื่อนไขการใช้งาน",
  "healthDisclaimer": "ข้อจำกัดความรับผิด",
  "healthDisclaimerSubtitle": "ข้อมูลกฎหมายสำคัญ",
  "showTutorialAgain": "แสดง Tutorial อีกครั้ง",
  "showTutorialAgainSubtitle": "ดูทัวร์ฟีเจอร์",
  "foodAnalysisTutorial": "Tutorial วิเคราะห์อาหาร",
  "foodAnalysisTutorialSubtitle": "เรียนรู้การใช้งานฟีเจอร์",
  
  "clearAllDataTitle": "ล้างข้อมูลทั้งหมด?",
  "clearAllDataConfirm": "ข้อมูลทั้งหมดจะถูกลบ:\n• บันทึกอาหาร\n• เมนูของฉัน\n• วัตถุดิบ\n• เป้าหมาย\n• ข้อมูลส่วนตัว\n\nลบแล้วกู้คืนไม่ได้!",
  "allDataCleared": "ล้างข้อมูลทั้งหมดสำเร็จ",
  
  "backupCreated": "สร้าง Backup สำเร็จ!",
  "backupFailed": "Backup ล้มเหลว",
  "restoreFailed": "กู้คืนล้มเหลว",
  "restoreComplete": "กู้คืนสำเร็จ!",
  
  "languageChangeSuccess": "เปลี่ยนภาษาเป็น {language} แล้ว",
  "@languageChangeSuccess": {
    "placeholders": {
      "language": {
        "type": "String"
      }
    }
  },
  
  "miroIdCopied": "คัดลอก MiRO ID แล้ว!",
  "analyticsEnabledMessage": "เปิดการเก็บข้อมูล - ขอบคุณที่ช่วยปรับปรุงแอป",
  "analyticsDisabledMessage": "ปิดการเก็บข้อมูล - ไม่เก็บข้อมูลการใช้งาน"
}
```

**วิธีแก้ไข:**

1. เพิ่ม import:
```dart
import 'package:miro_hybrid/l10n/app_localizations.dart';
```

2. แก้ AppBar:
```dart
AppBar(
  title: Text(L10n.of(context)!.profileSettings),
)
```

3. แก้ Section titles:
```dart
// ก่อน
_buildModernSectionTitle('🎯 Health Goals')

// หลัง (ถ้าต้องการแปล)
_buildModernSectionTitle('🎯 ${L10n.of(context)!.healthGoals}')

// หรือสร้าง method ใหม่
String _getSectionTitle(String emoji, String key) {
  switch (key) {
    case 'healthGoals':
      return '$emoji ${L10n.of(context)!.healthGoals}';
    case 'chatAiMode':
      return '$emoji ${L10n.of(context)!.chatAiMode}';
    // ...
    default:
      return emoji;
  }
}
```

### 2. Home Screen

**ไฟล์:** `lib/features/home/presentation/home_screen.dart`

**Strings ที่ต้องเพิ่ม:**

```json
{
  "home": "หน้าหลัก",
  "timeline": "Timeline",
  "diet": "Diet",
  "chat": "Chat",
  "profile": "โปรไฟล์"
}
```

### 3. Health Screens

**ไฟล์:** `lib/features/health/presentation/*.dart`

**Strings หลักๆ:**

```json
{
  "myMeals": "เมนูของฉัน",
  "createMeal": "สร้างเมนู",
  "editMeal": "แก้ไขเมนู",
  "deleteMeal": "ลบเมนู",
  "deleteMealConfirm": "ยืนยันการลบเมนู?",
  "mealDeleted": "ลบเมนูแล้ว",
  "ingredients": "วัตถุดิบ",
  "addIngredient": "เพิ่มวัตถุดิบ",
  "editIngredient": "แก้ไขวัตถุดิบ",
  "deleteIngredient": "ลบวัตถุดิบ",
  "noIngredientsYet": "ยังไม่มีวัตถุดิบ",
  "searchFood": "ค้นหาอาหาร",
  "searchFoodHint": "พิมพ์ชื่ออาหาร เช่น ข้าวผัด",
  "noResultsFound": "ไม่พบผลลัพธ์"
}
```

### 4. Chat Screen

**ไฟล์:** `lib/features/chat/presentation/chat_screen.dart`

**Strings:**

```json
{
  "chatWithMiro": "แชทกับ Miro",
  "chatHint": "สั่ง Miro เช่น \"บันทึกข้าวผัด\"...",
  "sendMessage": "ส่งข้อความ",
  "chatFoodSaved": "บันทึกอาหารแล้ว!",
  "chatError": "เกิดข้อผิดพลาด กรุณาลองใหม่"
}
```

---

## 💡 Best Practices

### 1. การตั้งชื่อ Key

**✅ ดี:**
- `profileSettings`
- `dailyGoals`
- `clearAllDataConfirm`
- `energyRemaining`

**❌ ไม่ดี:**
- `text1`
- `msg_a`
- `profile_screen_title`
- `String1`

**กฎการตั้งชื่อ:**
- ใช้ camelCase
- ชื่อสื่อความหมาย
- ไม่ใช้ตัวเลขลำดับ
- ไม่ใช้ชื่อไฟล์เป็น prefix

### 2. การจัดกลุ่ม Strings

จัดกลุ่มตามหมวดหมู่ โดยใช้ **comment แบบว่างเปล่า** เพื่อแยกกลุ่ม:

```json
{
  "@@locale": "th",
  
  "save": "บันทึก",
  "cancel": "ยกเลิก",
  "delete": "ลบ",
  "edit": "แก้ไข",
  "close": "ปิด",

  "mealBreakfast": "เช้า",
  "mealLunch": "กลางวัน",
  "mealDinner": "เย็น",

  "profileSettings": "โปรไฟล์และการตั้งค่า",
  "healthGoals": "เป้าหมายสุขภาพ"
}
```

> **⚠️ ห้ามใช้ key ที่ขึ้นต้นด้วย `_`** เช่น `"_comment_xxx"` — จะทำให้ `flutter gen-l10n` error!  
> ใช้ **บรรทัดว่าง** แยกกลุ่มแทน

### 3. Placeholders

**String เดียว:**
```json
{
  "welcomeMessage": "สวัสดี {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**หลาย Placeholders:**
```json
{
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  "@chatFoodSavedDetail": {
    "placeholders": {
      "name": {"type": "String"},
      "serving": {"type": "String"},
      "unit": {"type": "String"},
      "cal": {"type": "String"}
    }
  }
}
```

**ใช้ในโค้ด:**
```dart
// Single placeholder
L10n.of(context)!.welcomeMessage('John')

// Multiple placeholders
L10n.of(context)!.chatFoodSavedDetail(
  name: 'ข้าวผัด',
  serving: '1',
  unit: 'จาน',
  cal: '350',
)
```

### 4. Multiline Strings

```json
{
  "clearAllDataConfirm": "ข้อมูลทั้งหมดจะถูกลบ:\n• บันทึกอาหาร\n• เมนูของฉัน\n• วัตถุดิบ\n\nลบแล้วกู้คืนไม่ได้!"
}
```

### 5. เมื่อไหร่ควรแปล เมื่อไหร่ไม่ควรแปล

**✅ ควรแปล:**
- UI labels (ปุ่ม, หัวข้อ) ที่ user เห็นบนหน้าจอ
- Error messages ที่แสดงให้ user
- Dialog messages (title, content, buttons)
- Hints, placeholders ใน TextFields
- Navigation labels (tab, bottom nav)

**❌ ไม่ต้องแปล:**
- ชื่อ API (JSON keys)
- ชื่อตัวแปรในโค้ด
- `debugPrint()` / `AppLogger` messages
- Technical error codes
- Brand names (MiRO, Gemini)
- **AI prompts ที่ส่งให้ Gemini** (Gemini เข้าใจหลายภาษาอยู่แล้ว)
- **Strings ใน Provider/Service** ที่เป็น debug log

**🤔 พิจารณา:**
- ตัวเลข + หน่วย (เช่น "350 kcal")
  - ถ้าต้องการเปลี่ยนรูปแบบตามภาษา → แปล
  - ถ้าเหมือนกันทุกภาษา → ไม่ต้องแปล
- Emoji (🎯, 🍽️, 📸)
  - ถ้าใช้เป็น visual only → ไม่ต้องแปล
  - ถ้าเป็นส่วนหนึ่งของข้อความ → แปล

**⚠️ Provider/Service ที่มี hardcoded strings:**
- ถ้า string แสดงให้ user เห็น (เช่น chat message) → ควรแปลแต่ซับซ้อน (ดู Troubleshooting ปัญหา 6)
- ถ้าเป็น debug log / AI prompt → **ข้ามได้เลย**
- แนะนำ: **ทำ Widget ก่อน, Provider/Service ทำทีหลังหรือข้ามไป**

---

## 🔧 Troubleshooting

### ปัญหา 1: แก้ .arb แล้ว Hot Reload ไม่อัพเดท

**วิธีแก้:**
```bash
# Stop app (Ctrl+C)
flutter clean
flutter pub get
flutter run
```

### ปัญหา 2: Error `L10n.of(context) returned null`

**สาเหตุ:**
- ใช้ `context` ที่ไม่มี `MaterialApp` ครอบ
- ลืม import `L10n`

**วิธีแก้:**
```dart
// ตรวจสอบว่า main.dart มี localizationsDelegates
MaterialApp(
  localizationsDelegates: const [
    L10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('th'),
  ],
)
```

### ปัญหา 3: Error `The getter 'xxx' isn't defined for the type 'L10n'`

**สาเหตุ:**
- ยังไม่ได้ generate code
- Key name ผิด
- Typo

**วิธีแก้:**
```bash
flutter gen-l10n
flutter pub get
```

### ปัญหา 4: แก้ .arb แล้วมี JSON syntax error

**ตรวจสอบ:**
- ลืม comma (,)
- Quote ผิด (`"` vs `'`)
- Bracket ไม่ match (`{`, `}`)

**วิธีตรวจสอบ:**
```bash
# ใช้ JSON validator online
# หรือใช้ VS Code JSON formatter
```

### ปัญหา 5: Placeholder ไม่ทำงาน

**ตรวจสอบ:**
- ประกาศ `@keyName` metadata ครบ
- `type` ถูกต้อง (`String`, `int`, `double`)
- Key name ใน placeholder ตรง

**ตัวอย่างถูกต้อง:**
```json
{
  "welcomeMessage": "สวัสดี {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

### ปัญหา 6: Context ไม่มีให้ใช้ใน Provider

**เกิดอะไรขึ้น:**
```dart
class MyProvider extends StateNotifier {
  void method() {
    L10n.of(context)!.text  // ❌ Error: context ไม่มี!
  }
}
```

**สาเหตุ:**
- Provider ไม่ใช่ Widget → ไม่มี `BuildContext`
- `L10n.of(context)` ต้องการ context จาก Widget tree

**วิธีแก้:**
ดูเอกสารละเอียดที่ `TROUBLESHOOTING_CONTEXT_ISSUE.md`

**วิธีแก้แบบสั้น:**
1. แปลใน Widget (มี context)
2. ส่ง String เข้า Provider

```dart
// Widget
void _doSomething() {
  final text = L10n.of(context)!.message;  // ✅ แปลที่นี่
  ref.read(provider).process(text);         // ส่ง String
}

// Provider
void process(String text) {  // รับ String
  // ใช้ text ได้เลย
}
```

---

## ✅ Checklist สำหรับแต่ละไฟล์

เมื่อทำเสร็จแต่ละไฟล์ ให้ตรวจสอบ:

- [ ] เพิ่ม strings ครบใน `app_th.arb`
- [ ] เพิ่มการแปลครบใน `app_en.arb`
- [ ] Key names เหมือนกันทั้งสองไฟล์
- [ ] Placeholders มี metadata ครบ
- [ ] รัน `flutter gen-l10n` สำเร็จ
- [ ] แก้โค้ดจาก hardcoded → `L10n.of(context)!.xxx`
- [ ] ลบ `const` ออกจาก Widget ที่ใช้ `L10n` (เพราะไม่ const แล้ว)
- [ ] Hot Reload สำเร็จ ไม่มี error
- [ ] ทดสอบเปลี่ยนภาษา ภาษาไทย/อังกฤษ ถูกต้อง
- [ ] Commit code

---

## 📊 Progress Tracking

ดูตารางเต็มที่ `PROGRESS.md` — สถานะล่าสุด:

| Screen | File | Status |
|--------|------|--------|
| Profile | profile_screen.dart | ✅ Done |
| Home | home_screen.dart | ✅ Done |
| Health Goals | health_goals_screen.dart | ✅ Done |
| Onboarding | onboarding_screen.dart | ✅ Done |
| Health Screens (7 ไฟล์) | health_*.dart, *.dart | ✅ Done |
| Chat Screen | chat_screen.dart | ✅ Done |
| Camera Screen | camera_screen.dart | ⏳ Pending |
| Subscription/Referral | subscription_screen.dart, ... | ⏳ Pending |
| Legal Screens | privacy_policy_screen.dart, ... | ⏳ Pending |

> **รวม:** 12/24 ไฟล์เสร็จ (50%) — ดูรายละเอียดที่ `PROGRESS.md`

---

## 📚 อ้างอิง

### เอกสารเพิ่มเติม

- [Flutter Localization Official Guide](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)

### ไฟล์ตัวอย่าง

- `lib/l10n/app_th.arb` - ดู strings ที่มีอยู่แล้ว
- `lib/features/profile/presentation/profile_screen.dart` - ดูตัวอย่างการใช้ Language Selector

### Commands ที่ใช้บ่อย

```bash
# Generate localization code
flutter gen-l10n

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Hot reload
r

# Hot restart
R
```

---

## 🎓 สรุป Workflow สำหรับ Junior

1. **เลือกหน้าที่จะทำ** (เริ่มจากง่ายก่อน เช่น Profile)
2. **วิเคราะห์ + สร้างตาราง** strings ที่ต้องแปล
3. **เพิ่มใน app_th.arb** (ภาษาไทย)
4. **เพิ่มใน app_en.arb** (ภาษาอังกฤษ)
5. **รัน `flutter gen-l10n`**
6. **แก้โค้ด** เปลี่ยนจาก hardcoded → `L10n.of(context)!.xxx`
7. **Hot Reload + ทดสอบ**
8. **เปลี่ยนภาษา** ตรวจสอบทั้ง 2 ภาษา
9. **Commit** พร้อม message ชัดเจน
10. **Update checklist** + ทำหน้าถัดไป

---

**สร้างโดย:** AI Assistant  
**วันที่:** 19 ก.พ. 2026  
**สำหรับ:** Miro Hybrid Project - Localization Phase
