# Dark Mode Fix Guide — Pro Mode & Shared Widgets

> **เป้าหมาย**: แก้ปัญหา "ตัวหนังสือขาวบนพื้นขาว" และ contrast ใน Dark Mode ทั้งแอป
>
> **วิธีใช้**: ไล่ทีละไฟล์ ทำตามทุก step จนครบ ✅ ก่อนไปไฟล์ถัดไป
>
> **สถานะ**: ✅ = ทำเสร็จแล้ว | ⬜ = ยังไม่ทำ

---

## 🎨 Color Mapping Cheat Sheet

ใช้ตารางนี้ reference ทุกครั้งที่เจอสีที่ไม่มี dark mode check:

| สีเดิม (Light Only) | เปลี่ยนเป็น |
|---|---|
| `Colors.white` (background) | `isDark ? AppColors.surfaceDark : Colors.white` |
| `Colors.white` (foreground on primary btn) | **ไม่ต้องแก้** — ขาวบนปุ่มสี OK |
| `Colors.black` / `Colors.black87` | `isDark ? AppColors.textPrimaryDark : Colors.black87` |
| `AppColors.surfaceVariant` | `isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant` |
| `AppColors.background` | `isDark ? AppColors.backgroundDark : AppColors.background` |
| `AppColors.textPrimary` | `isDark ? AppColors.textPrimaryDark : AppColors.textPrimary` |
| `AppColors.textSecondary` | `isDark ? AppColors.textSecondaryDark : AppColors.textSecondary` |
| `AppColors.textTertiary` | `isDark ? Colors.white38 : AppColors.textTertiary` |
| `AppColors.divider` | `isDark ? AppColors.dividerDark : AppColors.divider` |
| `dropdownColor: Colors.white` | `dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white` |
| `fillColor: Colors.white` | `fillColor: isDark ? AppColors.surfaceVariantDark : Colors.white` |

---

## 📌 กฎสำคัญ

1. **ทุกไฟล์** ต้องมี `isDark` variable ใน `build()`:
   ```dart
   final isDark = Theme.of(context).brightness == Brightness.dark;
   ```
2. **อย่าแก้** `Colors.white` ที่เป็น `foregroundColor` บน primary button (ขาวบนปุ่มสีน้ำเงิน OK)
3. **อย่าแก้** `Colors.white` ที่อยู่ใน icon/text บน container ที่เป็นสีเข้มอยู่แล้ว (เช่น `AppColors.primary`)
4. **`const` ต้องถอดออก** — ถ้าเปลี่ยนเป็น `isDark ? ... : ...` จะใช้ `const` ไม่ได้
5. ทดสอบทั้ง Light Mode **และ** Dark Mode หลังแก้ทุกไฟล์
6. **ขนาด font มาตรฐาน**: ให้ใช้ scale นี้เท่านั้น:
   - `9` = badge เล็กมาก
   - `10` = caption, sub-label
   - `11` = hint, helper
   - `12` = label, secondary text
   - `13` = body small
   - `14` = body (ค่า default)
   - `16` = subtitle / section header
   - `18` = title
   - `20` = sheet title

---

## ✅ ไฟล์ที่แก้แล้ว

- [x] `lib/features/chat/widgets/message_bubble.dart`
- [x] `lib/features/health/widgets/ingredient_card.dart`
- [x] `lib/features/health/widgets/daily_summary_card.dart`
- [x] `lib/features/home/presentation/basic_mode_tab.dart`
- [x] `lib/features/home/widgets/simple_food_detail_sheet.dart`
- [x] `lib/features/home/widgets/food_sandbox.dart`

---

## ⬜ ไฟล์ 1: `lib/features/health/widgets/food_timeline_card.dart`

### Step 1: เพิ่ม `isDark` ใน `build()`

หาบรรทัดนี้:
```dart
  @override
  Widget build(BuildContext context) {
    return Card(
```

เปลี่ยนเป็น:
```dart
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
```

### Step 2: แก้ 3 จุด (search `AppColors.textSecondary`)

**บรรทัด ~122** (edit icon):
```dart
// เดิม
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

**บรรทัด ~148** (time & meal type text):
```dart
// เดิม
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

**บรรทัด ~224** (macro value text):
```dart
// เดิม
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

> ⚠️ ถ้ามี `const` นำหน้า `TextStyle` → ถอด `const` ออก

---

## ⬜ ไฟล์ 2: `lib/features/chat/presentation/chat_screen.dart`

### Step 1: เพิ่ม `isDark` ในทุก method ที่เกี่ยวข้อง

ไฟล์นี้มีหลาย method แยก ต้องเพิ่ม `isDark` ในแต่ละ method ที่มีปัญหา:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

เพิ่มบรรทัดนี้ที่ต้นทุก method ต่อไปนี้:
- `_buildExampleCard()`
- `_buildInputField()`
- `_buildTypingIndicator()`
- `_showChatHistory()` (ใช้ `sheetCtx` สำหรับ theme)
- `_buildSessionTile()`

### Step 2: `_buildExampleCard()` (~บรรทัด 270)

```dart
// เดิม
color: Colors.white,
// ใหม่
color: isDark ? AppColors.surfaceDark : Colors.white,
```

```dart
// เดิม (~301)
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

> ถอด `const` ออกจาก `TextStyle` ด้วย

### Step 3: `_buildInputField()` (~บรรทัด 691-757)

**Container background (~695)**:
```dart
// เดิม
color: Colors.white,
// ใหม่
color: isDark ? AppColors.surfaceDark : Colors.white,
```

**TextField container (~709)**:
```dart
// เดิม
color: AppColors.surfaceVariant,
// ใหม่
color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
```

**Hint style (~718-720)**:
```dart
// เดิม
hintStyle: const TextStyle(
  color: AppColors.textTertiary,
  fontSize: 14,
),
// ใหม่
hintStyle: TextStyle(
  color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
  fontSize: 14,
),
```

**Send button disabled state (~739)**:
```dart
// เดิม
color: _isComposing ? AppColors.primary : AppColors.divider,
// ใหม่
color: _isComposing ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : AppColors.divider),
```

**Send button icon disabled (~750)**:
```dart
// เดิม
color: _isComposing ? Colors.white : AppColors.textTertiary,
// ใหม่
color: _isComposing ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textTertiary),
```

### Step 4: `_buildTypingIndicator()` (~บรรทัด 793)

```dart
// เดิม
color: AppColors.surfaceVariant,
// ใหม่
color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
```

### Step 5: `_showChatHistory()` — Sheet background (~บรรทัด 897)

```dart
// เดิม
color: Colors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxlValue)),
// ใหม่
color: isDark ? AppColors.surfaceDark : Colors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxlValue)),
```

> ⚠️ ที่นี่ `isDark` ต้องใช้ `Theme.of(sheetCtx).brightness == Brightness.dark`

**Handle bar (~908)**:
```dart
// เดิม
color: AppColors.divider,
// ใหม่
color: isDark ? AppColors.dividerDark : AppColors.divider,
```

**Divider (~973)**:
```dart
// เดิม
const Divider(height: 1, color: AppColors.divider),
// ใหม่
Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.divider),
```

### Step 6: `_buildSessionTile()` (~บรรทัด 1038-1137)

เพิ่ม `isDark`:
```dart
Widget _buildSessionTile(BuildContext context, ChatSession session, bool isActive) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ...
```

**Session tile background (~1043)**:
```dart
// เดิม
: AppColors.background,
// ใหม่
: (isDark ? AppColors.backgroundDark : AppColors.background),
```

**Icon container disabled (~1069)**:
```dart
// เดิม
: AppColors.divider,
// ใหม่
: (isDark ? AppColors.dividerDark : AppColors.divider),
```

**Chat icon color (~1074)**:
```dart
// เดิม
color: isActive ? AppColors.primary : AppColors.textSecondary,
// ใหม่
color: isActive ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
```

**Date text (~1120)**:
```dart
// เดิม
fontSize: 12, color: AppColors.textSecondary),
// ใหม่
fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
```

> ถอด `const` ออกจาก `TextStyle`

**Delete icon (~1129)**:
```dart
// เดิม
color: AppColors.textTertiary),
// ใหม่
color: isDark ? Colors.white38 : AppColors.textTertiary),
```

> ถอด `const` ออก

---

## ⬜ ไฟล์ 3: `lib/features/health/widgets/add_food_bottom_sheet.dart`

> ⚠️ ไฟล์นี้ไม่มี `isDark` เลย ต้องเพิ่มตั้งแต่ต้น

### Step 1: เพิ่ม `isDark` ใน `build()` (~บรรทัด 820)

```dart
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;   // ← เพิ่ม
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];
```

### Step 2: แก้ทุกจุดตาม pattern (ใช้ Find & Replace ใน IDE)

ใช้ **Ctrl+H** (Find & Replace) ทีละ pattern ในไฟล์นี้:

#### Pattern A: `AppColors.textSecondary` (ที่ไม่ใช่ `textSecondaryDark`)

**Find**: `color: AppColors.textSecondary`
**Replace**: `color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary`

> ⚠️ **ตรวจทีละจุด** — อย่า Replace All ทันที ต้องเช็คว่า:
> - ไม่ใช่ `AppColors.textSecondaryDark` อยู่แล้ว
> - ถอด `const` ข้างหน้า `TextStyle` ออก

**จุดที่ต้องแก้ (~16 จุด)**: บรรทัด 899, 1082, 1090, 1169, 1238, 1249, 1317, 1439, 1447, 1533, 1574, 1684, 1727, 1734, 1868, 1990, 1997, 2004

#### Pattern B: `AppColors.textTertiary`

**Find**: `color: AppColors.textTertiary`
**Replace**: `color: isDark ? Colors.white38 : AppColors.textTertiary`

> ถอด `const` ออก

**จุดที่ต้องแก้ (~5 จุด)**: บรรทัด 848, 1559, 1632, 1804, 1898, 1975

#### Pattern C: `Colors.white` (เฉพาะ background container)

**บรรทัด ~1020, 1063, 1105, 1147** (fillColor ใน TextField):
```dart
// เดิม
: Colors.white,
// ใหม่
: (isDark ? AppColors.surfaceVariantDark : Colors.white),
```

**บรรทัด ~1464** (ingredient row container):
```dart
// เดิม
color: Colors.white,
// ใหม่
color: isDark ? AppColors.surfaceDark : Colors.white,
```

> ⚠️ **อย่าแก้** `Colors.white` ที่เป็น `foregroundColor` ใน button

#### Pattern D: `Colors.black` / `Colors.black87` (dropdown text)

**บรรทัด ~936**:
```dart
// เดิม
style: const TextStyle(color: Colors.black),
// ใหม่
style: TextStyle(color: isDark ? AppColors.textPrimaryDark : Colors.black),
```

**บรรทัด ~1651**:
```dart
// เดิม
style: const TextStyle(fontSize: 12, color: Colors.black87),
// ใหม่
style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : Colors.black87),
```

#### Pattern E: `dropdownColor: Colors.white`

**บรรทัด ~937, 1652**:
```dart
// เดิม
dropdownColor: Colors.white,
// ใหม่
dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white,
```

#### Pattern F: `AppColors.background`

**บรรทัด ~1221, 1790**:
```dart
// เดิม
AppColors.background
// ใหม่
isDark ? AppColors.backgroundDark : AppColors.background
```

---

## ⬜ ไฟล์ 4: `lib/features/health/widgets/edit_food_bottom_sheet.dart`

> ⚠️ ไฟล์นี้เหมือนกับ `add_food_bottom_sheet.dart` มาก ไม่มี `isDark` เลย

### Step 1: เพิ่ม `isDark` ใน `build()` (~บรรทัด 777)

```dart
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;   // ← เพิ่ม
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];
```

### Step 2: ทำเหมือน add_food_bottom_sheet.dart ข้างบน — ใช้ pattern เดียวกัน

#### Pattern A: `color: AppColors.textSecondary` → `color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary`

**จุดที่ต้องแก้ (~16 จุด)**: บรรทัด 1082, 1090, 1297, 1305, 1388, 1430, 1540, 1572, 1579, 1698, 1822, 1829, 1836, 1899, 1916

#### Pattern B: `color: AppColors.textTertiary` → `color: isDark ? Colors.white38 : AppColors.textTertiary`

**จุดที่ต้องแก้ (~6 จุด)**: บรรทัด 814, 1415, 1488, 1636, 1730, 1807, 1971

#### Pattern C: `fillColor ... Colors.white`

**บรรทัด ~937, 983, 1022, 1061** (fillColor ใน TextField):
```dart
// เดิม
: Colors.white,
// ใหม่
: (isDark ? AppColors.surfaceVariantDark : Colors.white),
```

**บรรทัด ~1319** (ingredient row):
```dart
// เดิม
color: Colors.white,
// ใหม่
color: isDark ? AppColors.surfaceDark : Colors.white,
```

#### Pattern D: `Colors.black` (dropdown text)

**บรรทัด ~887**:
```dart
// เดิม
style: const TextStyle(color: Colors.black),
// ใหม่
style: TextStyle(color: isDark ? AppColors.textPrimaryDark : Colors.black),
```

**บรรทัด ~1507**:
```dart
// เดิม
style: const TextStyle(fontSize: 12, color: Colors.black87),
// ใหม่
style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : Colors.black87),
```

#### Pattern E: `dropdownColor: Colors.white`

**บรรทัด ~888, 1508**:
```dart
// เดิม
dropdownColor: Colors.white,
// ใหม่
dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white,
```

#### Pattern F: `AppColors.surfaceVariant` / `AppColors.background`

**บรรทัด ~1623** (AppColors.background):
```dart
isDark ? AppColors.backgroundDark : AppColors.background
```

**บรรทัด ~1885, 1941** (AppColors.surfaceVariant):
```dart
isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant
```

---

## ⬜ ไฟล์ 5: `lib/features/health/widgets/meal_section.dart`

> ℹ️ ไฟล์นี้มี `isDark` อยู่แล้วบางจุด (27 จุด) แต่ยังมีจุดที่ขาดอยู่

### ตรวจสอบว่า method ย่อยทุกตัวมี `isDark` หรือยัง

ถ้า method ย่อยไม่รับ `isDark` เป็น parameter → เพิ่ม:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### จุดที่ต้องเช็ค

ค้นหาทุกจุดใน `meal_section.dart` ที่มี `AppColors.textSecondary`, `AppColors.textTertiary`, `Colors.white` (เป็น background) แล้วดูว่ามี `isDark` ครอบหรือยัง

**ดูตัวอย่างจุดที่ทำถูกแล้ว** (ไม่ต้องแก้):
```dart
color: isDark ? Colors.white38 : AppColors.textSecondary,  // ✅ OK
```

**จุดที่ยังขาด** — ค้นหา pattern เหล่านี้แล้วแก้:

1. `const TextStyle(... color: AppColors.textSecondary)` — ถอด `const`, ใส่ `isDark`
2. `const TextStyle(... color: AppColors.textTertiary)` — ถอด `const`, ใส่ `isDark`
3. `const Icon(... color: AppColors.textSecondary)` — ถอด `const`, ใส่ `isDark`

---

## ⬜ ไฟล์ 6: `lib/features/health/widgets/food_detail_bottom_sheet.dart`

> ℹ️ ไฟล์นี้มี `isDark` ครอบเกือบทุกจุดแล้ว แต่มีหลุดบางจุด

### จุดที่ต้องเช็ค

**บรรทัด ~354** (kcal text):
```dart
// เดิม
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

**บรรทัด ~580** (macro label):
```dart
// เดิม
color: AppColors.textSecondary,
// ใหม่
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
```

> ถอด `const` ออกถ้ามี

---

## 🔤 ไฟล์ 7: ปรับขนาด Font ให้สม่ำเสมอ

### ตาราง font size มาตรฐาน

| ประเภท | ขนาด |
|---|---|
| Badge เล็กมาก (AI, active) | `9` |
| Caption, sub-label, usage count | `10` |
| Hint, helper text, ingredient detail | `11` |
| Label, secondary text, date | `12` |
| Body small | `13` |
| Body text (default) | `14` |
| Subtitle, food name in card | `14` |
| Section header, button text | `16` |
| Sheet/Dialog title | `18` |
| Screen title | `20` |

### จุดที่ font size ผิดจาก scale:

| ไฟล์ | บรรทัด | เดิม | แก้เป็น |
|---|---|---|---|
| `ingredient_card.dart` | ~98 | `fontSize: 15` | `fontSize: 14` |
| `meal_section.dart` | header | `fontSize: 17` | `fontSize: 16` |
| `message_bubble.dart` | ~63 | `fontSize: 15` | `fontSize: 14` |
| `chat_screen.dart` | ~932 | `fontSize: 20` | `fontSize: 18` |
| `add_food_bottom_sheet.dart` | calories input | `fontSize: 22` | `fontSize: 20` |
| `edit_food_bottom_sheet.dart` | calories input | `fontSize: 22` | `fontSize: 20` |

> ⚠️ ขนาด font เฉพาะที่ใช้สำหรับ display (เช่น kcal ตัวใหญ่ใน detail sheet) ไม่ต้องแก้ — ปล่อยไว้ได้

---

## ✅ Checklist หลังแก้

- [ ] เปิด Dark Mode → ทุกหน้าอ่านได้ชัดเจน
- [ ] ตัวหนังสือไม่หายบนพื้นขาว/ดำ
- [ ] Dropdown ไม่มีพื้นขาวตอน dark mode
- [ ] TextField fill color ไม่ขาวเกินไป
- [ ] Ingredient card/row ไม่มีพื้นขาวตอน dark mode
- [ ] Chat bubble (assistant) ไม่มีพื้นขาว
- [ ] Chat input ไม่มีพื้นขาว
- [ ] Chat history sheet ไม่มีพื้นขาว
- [ ] Session tiles ไม่มีพื้นขาว
- [ ] เปิด Light Mode → ทุกอย่างยังสวยเหมือนเดิม
- [ ] `flutter analyze` ไม่มี error ใหม่
- [ ] ขนาด font ดูสม่ำเสมอ ไม่เดี๋ยวเล็กเดี๋ยวใหญ่

---

## 📝 หมายเหตุ

- **ทุกครั้งที่ถอด `const`** ต้องเช็คว่า parent widget ที่มี `const` ข้างหน้าก็ต้องถอดด้วย
- **import** ถ้าไฟล์ยังไม่มี `import '../../../core/theme/app_colors.dart';` ต้องเพิ่ม
- ทุกไฟล์ต้องรัน `flutter analyze` หลังแก้เพื่อจับ error
- ถ้าไม่แน่ใจจุดไหน ให้ดู `daily_summary_card.dart` หรือ `food_sandbox.dart` เป็นตัวอย่าง reference — ไฟล์เหล่านี้ทำ dark mode ถูกแล้ว
