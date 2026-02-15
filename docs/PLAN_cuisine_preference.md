# Feature Plan: Cuisine Preference

> **Goal:** ให้ user ตั้ง Cuisine Preference เพื่อให้ AI ประเมินอาหาร + แนะนำเมนูได้แม่นขึ้นตาม culture ของ user  
> **Scope:** Model, Onboarding, Profile Settings, AI Prompt (Client + Backend)  
> **Breaking Change:** ต้อง regen Isar model (`build_runner`)

---

## 1. Overview

### ปัญหาเดิม
- `UserProfile.locale` มีอยู่ใน model แต่ **ไม่เคยถูก set** ที่ไหน (ทั้ง Onboarding + Settings)
- Prompt ของ AI เคย hardcode ตัวอย่างอาหารไทย → ทำให้ AI bias (แก้แล้วใน commit ก่อนหน้า)
- ไม่มีทางให้ user บอก AI ว่าตัวเองกินอาหารแนวไหนเป็นหลัก

### Solution
เพิ่ม field `cuisinePreference` ใน UserProfile เพื่อ:
- ให้ AI ประเมิน portion size ตาม culture (เช่น ข้าว 1 จานของ ญี่ปุ่น ≠ อเมริกา)
- แนะนำเมนูที่ user หาทานได้จริงในประเทศตัวเอง
- ตอบกลับในภาษาที่ user ต้องการ

---

## 2. Cuisine Options

```dart
// ใช้ Map<String, String> เก็บ key → display name
static const cuisineOptions = [
  {'key': 'international', 'label': 'International / Mixed', 'flag': '🌍'},
  {'key': 'thai',          'label': 'Thai',                  'flag': '🇹🇭'},
  {'key': 'japanese',      'label': 'Japanese',              'flag': '🇯🇵'},
  {'key': 'korean',        'label': 'Korean',                'flag': '🇰🇷'},
  {'key': 'chinese',       'label': 'Chinese',               'flag': '🇨🇳'},
  {'key': 'indian',        'label': 'Indian',                'flag': '🇮🇳'},
  {'key': 'american',      'label': 'American',              'flag': '🇺🇸'},
  {'key': 'mexican',       'label': 'Mexican',               'flag': '🇲🇽'},
  {'key': 'italian',       'label': 'Italian',               'flag': '🇮🇹'},
  {'key': 'mediterranean', 'label': 'Mediterranean',         'flag': '🫒'},
  {'key': 'middle_eastern','label': 'Middle Eastern',        'flag': '🇸🇦'},
  {'key': 'vietnamese',    'label': 'Vietnamese',            'flag': '🇻🇳'},
  {'key': 'indonesian',    'label': 'Indonesian',            'flag': '🇮🇩'},
  {'key': 'filipino',      'label': 'Filipino',              'flag': '🇵🇭'},
  {'key': 'european',      'label': 'European',              'flag': '🇪🇺'},
];
```

**Default:** `'international'` (ไม่ bias ไปทางใด)

---

## 3. Files to Change

### 3.1 Model: `lib/features/profile/models/user_profile.dart`

**Action:** เพิ่ม field ใหม่, ลบ field เก่า

```dart
@collection
class UserProfile {
  // ...existing fields...

  // Settings
  bool isDarkMode = false;
  String? locale;                        // เก็บไว้ backward compat (ไม่ลบ เพราะ Isar migration)
  String cuisinePreference = 'international';  // ← NEW FIELD

  // ...rest of fields...
}
```

**After edit:** Run `dart run build_runner build --delete-conflicting-outputs`

> **Note:** ห้ามลบ `locale` field ออก เพราะ Isar ไม่ support migration — ถ้าลบ field ที่มี data อยู่จะ crash  
> แต่ไม่ต้องใช้มันอีกต่อไป ปล่อยไว้เฉยๆ

---

### 3.2 Context Builder: `lib/core/ai/gemini_chat_service.dart`

**Action:** ส่ง `cuisinePreference` แทน `preferredLanguage`

```dart
static Map<String, dynamic> _buildProfileContext(UserProfile? profile) {
  // ...existing code...

  // ลบ/comment ส่วนเก่า:
  // if (profile.locale != null) {
  //   context['preferredLanguage'] = profile.locale;
  // }

  // เพิ่มใหม่:
  context['cuisinePreference'] = profile.cuisinePreference;

  // ...rest of code...
}
```

---

### 3.3 Onboarding: `lib/features/onboarding/presentation/onboarding_screen.dart`

**Action:** เพิ่ม Cuisine Selection ใน Page 3 (User Info page) ใต้ Activity Level

Onboarding มี 4 pages (PageView):
- Page 0: Welcome
- Page 1: Features
- **Page 2: User Info** ← เพิ่ม Cuisine Selection ที่นี่
- Page 3: Energy System

#### เพิ่ม State Variable
```dart
String _selectedCuisine = 'international';
```

#### เพิ่ม UI Widget (ใต้ Activity Level dropdown)
```dart
const SizedBox(height: 16),
const Text(
  'Your typical cuisine',
  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
),
const SizedBox(height: 8),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: CuisineOptions.options.map((option) {
    final isSelected = _selectedCuisine == option['key'];
    return ChoiceChip(
      avatar: Text(option['flag']!, style: const TextStyle(fontSize: 16)),
      label: Text(option['label']!),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedCuisine = option['key']!);
      },
    );
  }).toList(),
),
```

#### บันทึกตอน Complete Onboarding
ใน `_completeOnboarding()` method (~line 446):
```dart
profile.cuisinePreference = _selectedCuisine;
```

---

### 3.4 Profile Settings: `lib/features/profile/presentation/profile_screen.dart`

**Action:** เพิ่ม Cuisine Preference card ในหน้า Settings

#### เพิ่มไว้ใต้ "Chat AI Mode" section (~line 64):
```dart
const SizedBox(height: 16),

// Cuisine Preference
_buildSectionTitle('🍽️ Cuisine Preference'),
_buildSettingCard(
  context: context,
  title: 'Preferred Cuisine',
  subtitle: _getCuisineLabel(profile.cuisinePreference),
  leading: Text(
    _getCuisineFlag(profile.cuisinePreference),
    style: const TextStyle(fontSize: 20),
  ),
  onTap: () => _showCuisineDialog(context, profile),
),
```

#### เพิ่ม Dialog Method:
```dart
Future<void> _showCuisineDialog(BuildContext context, UserProfile profile) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Select Your Cuisine'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CuisineOptions.options.map((option) {
              final isSelected = profile.cuisinePreference == option['key'];
              return ChoiceChip(
                avatar: Text(option['flag']!, style: const TextStyle(fontSize: 16)),
                label: Text(option['label']!),
                selected: isSelected,
                onSelected: (selected) async {
                  if (selected) {
                    profile.cuisinePreference = option['key']!;
                    await ref.read(profileNotifierProvider.notifier)
                        .updateProfile(profile);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
```

---

### 3.5 Cuisine Options Constant: `lib/core/constants/cuisine_options.dart` (NEW FILE)

**Action:** สร้างไฟล์ใหม่สำหรับ cuisine options ที่ใช้ร่วมกัน

```dart
/// Cuisine preference options — shared between Onboarding and Profile Settings
class CuisineOptions {
  CuisineOptions._();

  static const List<Map<String, String>> options = [
    {'key': 'international', 'label': 'International / Mixed', 'flag': '🌍'},
    {'key': 'thai',          'label': 'Thai',                  'flag': '🇹🇭'},
    {'key': 'japanese',      'label': 'Japanese',              'flag': '🇯🇵'},
    {'key': 'korean',        'label': 'Korean',                'flag': '🇰🇷'},
    {'key': 'chinese',       'label': 'Chinese',               'flag': '🇨🇳'},
    {'key': 'indian',        'label': 'Indian',                'flag': '🇮🇳'},
    {'key': 'american',      'label': 'American',              'flag': '🇺🇸'},
    {'key': 'mexican',       'label': 'Mexican',               'flag': '🇲🇽'},
    {'key': 'italian',       'label': 'Italian',               'flag': '🇮🇹'},
    {'key': 'mediterranean', 'label': 'Mediterranean',         'flag': '🫒'},
    {'key': 'middle_eastern','label': 'Middle Eastern',        'flag': '🇸🇦'},
    {'key': 'vietnamese',    'label': 'Vietnamese',            'flag': '🇻🇳'},
    {'key': 'indonesian',    'label': 'Indonesian',            'flag': '🇮🇩'},
    {'key': 'filipino',      'label': 'Filipino',              'flag': '🇵🇭'},
    {'key': 'european',      'label': 'European',              'flag': '🇪🇺'},
  ];

  /// Get display label for a cuisine key
  static String getLabel(String key) {
    return options.firstWhere(
      (o) => o['key'] == key,
      orElse: () => options.first,
    )['label']!;
  }

  /// Get flag emoji for a cuisine key
  static String getFlag(String key) {
    return options.firstWhere(
      (o) => o['key'] == key,
      orElse: () => options.first,
    )['flag']!;
  }
}
```

---

### 3.6 Backend Prompt: `functions/src/analyzeFood.ts`

**Action:** ปรับ prompt ทั้ง `buildMenuSuggestionPrompt` และ `buildChatPrompt` ให้ใช้ `cuisinePreference`

#### buildMenuSuggestionPrompt (~line 279):
```typescript
// เพิ่มใน contextInfo builder:
if (userContext.cuisinePreference) {
  contextInfo += `\n- Cuisine Preference: ${userContext.cuisinePreference}`;
}

// เปลี่ยน rule ข้อ 3:
// เดิม: "Match the user's local cuisine based on their past meals..."
// ใหม่:
`3. Match the user's cuisine preference (${userContext?.cuisinePreference || 'international'}) — suggest dishes from this cuisine`
```

#### buildChatPrompt (~line 349):
```typescript
// เพิ่มใน contextInfo builder:
if (userContext.cuisinePreference) {
  contextInfo += `\n- Cuisine Preference: ${userContext.cuisinePreference}`;
}

// เพิ่มใน prompt section:
`When estimating nutrition, consider typical portion sizes for ${userContext?.cuisinePreference || 'international'} cuisine.`
```

---

### 3.7 Client Prompt (Image/Text): `lib/core/ai/gemini_service.dart`

**Action:** ไม่ต้องเปลี่ยน — prompt ของ image/text analysis ไม่ได้รับ userContext  
(ส่งแค่ prompt + image ไป backend โดยตรง)

แต่ถ้าอนาคตต้องการให้ image analysis ก็ใช้ cuisine preference ด้วย สามารถเพิ่มเป็น optional parameter:

```dart
// Future improvement (optional):
static Future<FoodAnalysisResult?> analyzeFood(
  File imageFile, {
  String? foodName,
  double? quantity,
  String? unit,
  String? cuisineHint,  // ← เพิ่มได้ในอนาคต
  EnergyService? energyService,
}) async {
  // ...
  if (cuisineHint != null) {
    prompt += '\n\nThe user typically eats $cuisineHint cuisine. '
        'Consider typical portion sizes and ingredients from this cuisine.';
  }
}
```

---

## 4. Implementation Order

```
Step 1: สร้าง cuisine_options.dart (constants)
Step 2: เพิ่ม field ใน user_profile.dart
Step 3: Run build_runner (regen .g.dart)
Step 4: แก้ gemini_chat_service.dart (context builder)
Step 5: เพิ่ม UI ใน profile_screen.dart (Settings)
Step 6: เพิ่ม UI ใน onboarding_screen.dart
Step 7: แก้ prompt ใน analyzeFood.ts (Backend)
Step 8: Test ทั้ง flow
```

---

## 5. Testing Checklist

- [ ] Onboarding: เลือก cuisine → บันทึกลง DB ถูกต้อง
- [ ] Onboarding: ไม่เลือก → default = 'international'
- [ ] Profile Settings: แสดง cuisine ปัจจุบันถูกต้อง
- [ ] Profile Settings: เปลี่ยน cuisine → บันทึกลง DB + update UI ทันที
- [ ] Chat: ส่ง message → backend ได้รับ `cuisinePreference` ใน `userContext`
- [ ] Menu Suggestion: ส่ง request → backend ได้รับ `cuisinePreference`
- [ ] Menu Suggestion: ถ้า cuisine = 'thai' → แนะนำอาหารไทย
- [ ] Menu Suggestion: ถ้า cuisine = 'japanese' → แนะนำอาหารญี่ปุ่น
- [ ] Menu Suggestion: ถ้า cuisine = 'international' → แนะนำอาหารหลากหลาย
- [ ] Existing user (ไม่มี field เดิม): app ไม่ crash, ใช้ default 'international'
- [ ] Image analysis: ยังทำงานปกติ (ไม่ได้ใช้ cuisinePreference)

---

## 6. Migration Notes

- **Isar:** ไม่ต้อง migrate — Isar handle schema change อัตโนมัติ (เพิ่ม field ได้เลย)
- **Existing users:** `cuisinePreference` จะเป็น default `'international'` (เพราะ Dart default value)
- **Backend:** ต้อง deploy `analyzeFood.ts` ใหม่หลังแก้ prompt
- **`locale` field:** เก็บไว้ ไม่ลบ — ไม่ได้ใช้แล้วแต่ลบแล้ว Isar จะมีปัญหากับ data เก่า

---

## 7. Future Enhancements

- **Multi-cuisine:** ให้เลือกได้มากกว่า 1 (เช่น user กิน Thai + Japanese สลับกัน)
- **Auto-detect:** วิเคราะห์จาก food log ว่า user กินอาหารแนวไหนบ่อยสุด → แนะนำ cuisine
- **Language preference:** แยก language (ภาษาที่ AI ตอบ) กับ cuisine (อาหารที่แนะนำ) ออกจากกัน
