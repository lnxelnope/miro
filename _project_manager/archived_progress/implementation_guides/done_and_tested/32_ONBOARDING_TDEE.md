# Step 32: Onboarding + TDEE Calculator

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1-2 วัน
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 31 (Freemium + IAP)

---

## 🎯 เป้าหมาย

1. **Onboarding Screen** — PageView 4 หน้าสำหรับผู้ใช้ใหม่
2. **เก็บข้อมูลพื้นฐาน** — เพศ, อายุ, น้ำหนัก, ส่วนสูง, ระดับกิจกรรม
3. **TDEE Calculator** — คำนวณพลังงานที่ต้องการต่อวัน → แนะนำเป้าหมาย kcal
4. **Onboarding Gate** — เปิดแอปครั้งแรก → ไป Onboarding → เสร็จแล้วเข้า Home

---

## 📐 UI Layout — Onboarding 4 หน้า

```
┌─ Page 1: Welcome ────────────────────────┐
│                                          │
│          🍽️ (ภาพประกอบ)                 │
│                                          │
│          Miro Cal                        │
│   บันทึกอาหารง่ายๆ ด้วย AI              │
│                                          │
│              [ถัดไป →]                    │
│              ● ○ ○ ○                     │
└──────────────────────────────────────────┘

┌─ Page 2: ฟีเจอร์หลัก ───────────────────┐
│                                          │
│  📸 ถ่ายรูป → AI วิเคราะห์อัตโนมัติ      │
│  💬 พิมพ์แชท → บันทึกง่าย               │
│  📊 สรุป kcal / macro ทุกวัน            │
│                                          │
│              [ถัดไป →]                    │
│              ○ ● ○ ○                     │
└──────────────────────────────────────────┘

┌─ Page 3: ข้อมูลพื้นฐาน ─────────────────┐
│                                          │
│  เพศ:    [ชาย ▾]                         │
│  อายุ:   [25] ปี                        │
│  น้ำหนัก: [65.0] kg                     │
│  ส่วนสูง: [170] cm                      │
│  กิจกรรม: [ปานกลาง ▾]                   │
│                                          │
│  ┌─ แนะนำเป้าหมาย ─────────────────────┐│
│  │ TDEE: 2,150 kcal/วัน                ││
│  │ แนะนำ: 1,900 kcal/วัน (ลดน้ำหนัก)  ││
│  └──────────────────────────────────────┘│
│                                          │
│              [ถัดไป →]                    │
│              ○ ○ ● ○                     │
└──────────────────────────────────────────┘

┌─ Page 4: API Key (optional) ─────────────┐
│                                          │
│  🤖 ตั้งค่า Gemini AI                   │
│  เพื่อวิเคราะห์อาหารจากรูปถ่าย           │
│                                          │
│  [ตั้งค่าเลย]                            │
│  [ข้ามไปก่อน → เข้าแอป]                  │
│                                          │
│              ○ ○ ○ ●                     │
└──────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/onboarding/presentation/onboarding_screen.dart` | CREATE | Onboarding UI |
| `lib/core/utils/tdee_calculator.dart` | CREATE | คำนวณ TDEE |
| `lib/features/profile/models/user_profile.dart` | EDIT | เพิ่ม fields ใหม่ |
| `lib/main.dart` | EDIT | เพิ่ม Onboarding Gate |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: เพิ่ม Fields ใน UserProfile

**ไฟล์:** `lib/features/profile/models/user_profile.dart`
**Action:** EDIT

เพิ่ม fields ต่อไปนี้ใน Isar model:

```dart
@collection
class UserProfile {
  Id id = 0;

  // ... fields เดิมที่มีอยู่ ...

  // ===== เพิ่มใหม่ =====
  String? gender;            // 'male' หรือ 'female'
  int? age;
  double? weight;            // kg
  double? height;            // cm
  double? targetWeight;      // kg (optional)
  String? activityLevel;     // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  bool onboardingComplete = false;
  // ===== จบส่วนเพิ่ม =====
}
```

> **สำคัญมาก:** หลังเพิ่ม field ต้องรัน:
> ```bash
> dart run build_runner build --delete-conflicting-outputs
> ```
> เพื่อ regenerate `user_profile.g.dart`

---

### Step 2: สร้าง TDEE Calculator

**ไฟล์:** `lib/core/utils/tdee_calculator.dart`
**Action:** CREATE

```dart
/// คำนวณ TDEE (Total Daily Energy Expenditure)
/// ใช้สูตร Mifflin-St Jeor — สูตรที่แม่นยำที่สุดในปัจจุบัน
class TdeeCalculator {
  /// คำนวณ BMR (Basal Metabolic Rate)
  ///
  /// สูตร Mifflin-St Jeor:
  /// - ชาย:  BMR = 10 × น้ำหนัก(kg) + 6.25 × ส่วนสูง(cm) - 5 × อายุ + 5
  /// - หญิง: BMR = 10 × น้ำหนัก(kg) + 6.25 × ส่วนสูง(cm) - 5 × อายุ - 161
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' หรือ 'female'
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == 'male' ? base + 5 : base - 161;
  }

  /// ตัวคูณกิจกรรม
  static double activityMultiplier(String level) {
    switch (level) {
      case 'sedentary':    return 1.2;    // นั่งทั้งวัน
      case 'light':        return 1.375;  // ออกกำลังกายเบาๆ 1-3 วัน/สัปดาห์
      case 'moderate':     return 1.55;   // ออกกำลังกาย 3-5 วัน/สัปดาห์
      case 'active':       return 1.725;  // ออกกำลังกายหนัก 6-7 วัน/สัปดาห์
      case 'very_active':  return 1.9;    // ออกกำลังกายหนักมาก + งานที่ต้องใช้แรง
      default:             return 1.55;   // default: ปานกลาง
    }
  }

  /// คำนวณ TDEE
  static double calculateTDEE({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    return bmr * activityMultiplier(activityLevel);
  }

  /// แนะนำเป้าหมาย kcal ตามเป้าหมาย
  static Map<String, int> suggestGoals({
    required double tdee,
  }) {
    return {
      'maintain': tdee.round(),              // รักษาน้ำหนัก
      'mild_loss': (tdee - 250).round(),     // ลดช้า (-0.25 kg/สัปดาห์)
      'loss': (tdee - 500).round(),          // ลด (-0.5 kg/สัปดาห์)
      'mild_gain': (tdee + 250).round(),     // เพิ่มช้า
      'gain': (tdee + 500).round(),          // เพิ่ม (+0.5 kg/สัปดาห์)
    };
  }

  /// แนะนำ Macro % (default)
  static Map<String, int> defaultMacroPercent() {
    return {
      'protein': 30,  // 30% protein
      'carbs': 40,    // 40% carbs
      'fat': 30,      // 30% fat
    };
  }

  /// ชื่อกิจกรรมภาษาไทย (สำหรับ dropdown)
  static List<Map<String, String>> activityLevels = [
    {'key': 'sedentary',   'th': 'นั่งทั้งวัน (ไม่ออกกำลังกาย)',     'en': 'Sedentary'},
    {'key': 'light',       'th': 'ออกกำลังกายเบา (1-3 วัน/สัปดาห์)', 'en': 'Lightly Active'},
    {'key': 'moderate',    'th': 'ออกกำลังกายปานกลาง (3-5 วัน)',     'en': 'Moderately Active'},
    {'key': 'active',      'th': 'ออกกำลังกายหนัก (6-7 วัน)',        'en': 'Very Active'},
    {'key': 'very_active', 'th': 'หนักมาก + งานใช้แรง',             'en': 'Extra Active'},
  ];
}
```

---

### Step 3: สร้าง Onboarding Screen

**สร้าง folder:** `lib/features/onboarding/presentation/`
**ไฟล์:** `lib/features/onboarding/presentation/onboarding_screen.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/tdee_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/presentation/api_key_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/database/database_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 3: ข้อมูลพื้นฐาน
  String _gender = 'male';
  final _ageController = TextEditingController(text: '25');
  final _weightController = TextEditingController(text: '65');
  final _heightController = TextEditingController(text: '170');
  String _activityLevel = 'moderate';

  double? _tdee;
  Map<String, int>? _suggestions;

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _buildDot(i)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1Welcome(),
                  _buildPage2Features(),
                  _buildPage3UserInfo(),
                  _buildPage4ApiKey(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ Page Indicator ============

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ============ Page 1: Welcome ============

  Widget _buildPage1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon หรือ ภาพประกอบ
          Icon(Icons.restaurant_menu, size: 100, color: AppColors.primary),
          const SizedBox(height: 32),
          const Text(
            'Miro Cal',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'บันทึกอาหารง่ายๆ ด้วย AI',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  // ============ Page 2: Features ============

  Widget _buildPage2Features() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureRow(Icons.camera_alt, 'ถ่ายรูปอาหาร', 'AI วิเคราะห์ kcal อัตโนมัติ'),
          const SizedBox(height: 24),
          _buildFeatureRow(Icons.chat_bubble, 'พิมพ์แชท', 'บอกว่า "กินข้าวผัด" → บันทึกให้เลย'),
          const SizedBox(height: 24),
          _buildFeatureRow(Icons.bar_chart, 'สรุปทุกวัน', 'ดู kcal, โปรตีน, คาร์บ, ไขมัน'),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ============ Page 3: User Info + TDEE ============

  Widget _buildPage3UserInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ข้อมูลพื้นฐาน',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('เพื่อคำนวณเป้าหมายแคลอรี่ที่เหมาะกับคุณ',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          // เพศ
          const Text('เพศ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('ชาย'), icon: Icon(Icons.male)),
              ButtonSegment(value: 'female', label: Text('หญิง'), icon: Icon(Icons.female)),
            ],
            selected: {_gender},
            onSelectionChanged: (v) {
              setState(() => _gender = v.first);
              _recalculate();
            },
          ),
          const SizedBox(height: 16),

          // อายุ + น้ำหนัก + ส่วนสูง (Row)
          Row(
            children: [
              Expanded(child: _buildNumberField('อายุ', _ageController, 'ปี')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('น้ำหนัก', _weightController, 'kg')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('ส่วนสูง', _heightController, 'cm')),
            ],
          ),
          const SizedBox(height: 16),

          // ระดับกิจกรรม
          const Text('ระดับกิจกรรม', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: TdeeCalculator.activityLevels.map((level) {
              return DropdownMenuItem(
                value: level['key'],
                child: Text(level['th']!, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _activityLevel = v);
                _recalculate();
              }
            },
          ),
          const SizedBox(height: 24),

          // แสดงผล TDEE
          if (_tdee != null) _buildTdeeResult(),

          const SizedBox(height: 24),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: suffix,
            isDense: true,
          ),
          onChanged: (_) => _recalculate(),
        ),
      ],
    );
  }

  Widget _buildTdeeResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('แนะนำเป้าหมาย',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text('TDEE ของคุณ: ${_tdee!.round()} kcal/วัน',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          if (_suggestions != null) ...[
            Text('• รักษาน้ำหนัก: ${_suggestions!["maintain"]} kcal',
                style: const TextStyle(fontSize: 13)),
            Text('• ลดน้ำหนัก: ${_suggestions!["loss"]} kcal',
                style: const TextStyle(fontSize: 13)),
            Text('• เพิ่มน้ำหนัก: ${_suggestions!["gain"]} kcal',
                style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  void _recalculate() {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (age != null && weight != null && height != null &&
        age > 0 && weight > 0 && height > 0) {
      final tdee = TdeeCalculator.calculateTDEE(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
        activityLevel: _activityLevel,
      );
      setState(() {
        _tdee = tdee;
        _suggestions = TdeeCalculator.suggestGoals(tdee: tdee);
      });
    }
  }

  // ============ Page 4: API Key ============

  Widget _buildPage4ApiKey() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('ตั้งค่า Gemini AI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'ถ่ายรูปอาหาร → AI วิเคราะห์ให้อัตโนมัติ\nสร้าง API Key ฟรี ใช้เวลาแค่ 5 นาที',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('ตั้งค่าเลย'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _completeOnboarding,
              child: const Text('ข้ามไปก่อน → เข้าแอป'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ไม่มี API Key ก็บันทึกอาหารด้วยมือได้',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ============ Navigation ============

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          if (_currentPage < 3) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          // Page 3 → recalculate TDEE ก่อนไปต่อ
          if (_currentPage == 2) {
            _recalculate();
          }
        },
        child: const Text('ถัดไป'),
      ),
    );
  }

  // ============ Complete Onboarding ============

  Future<void> _completeOnboarding() async {
    // บันทึกข้อมูลลง UserProfile
    final isar = DatabaseService.isar;  // ← ปรับตาม code จริง
    final profile = await isar.userProfiles.get(0) ?? UserProfile();

    profile.gender = _gender;
    profile.age = int.tryParse(_ageController.text);
    profile.weight = double.tryParse(_weightController.text);
    profile.height = double.tryParse(_heightController.text);
    profile.activityLevel = _activityLevel;
    profile.onboardingComplete = true;

    // บันทึกเป้าหมาย kcal (ใช้ค่า "ลดน้ำหนัก" เป็น default)
    if (_suggestions != null) {
      // ถ้ามี field goalCalories ใน profile → บันทึก
      // profile.goalCalories = _suggestions!['loss']?.toDouble();
    }

    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
    });

    // Navigate ไป HomeScreen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,  // ลบ stack ทั้งหมด
      );
    }
  }
}
```

> **หมายเหตุ:** ปรับ import paths และ database access ตาม code จริงในโปรเจค
> เช่น `DatabaseService.isar` อาจเป็น `IsarService.instance` แทน

---

### Step 4: เพิ่ม Onboarding Gate ใน main.dart

**ไฟล์:** `lib/main.dart`
**Action:** EDIT

#### 4.1 เพิ่ม function ตรวจ onboarding

```dart
import 'features/onboarding/presentation/onboarding_screen.dart';

/// ตรวจว่า onboarding เสร็จแล้วหรือยัง
Future<bool> _checkOnboardingComplete() async {
  final isar = DatabaseService.isar;  // ← ปรับตาม code จริง
  final profile = await isar.userProfiles.get(0);
  return profile?.onboardingComplete ?? false;
}
```

#### 4.2 เปลี่ยน home ของ MaterialApp

**ก่อน:**
```dart
home: const HomeScreen(),
```

**หลัง:**
```dart
home: FutureBuilder<bool>(
  future: _checkOnboardingComplete(),
  builder: (context, snapshot) {
    // กำลังโหลด
    if (snapshot.connectionState != ConnectionState.done) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // เคยทำ onboarding แล้ว → ไป Home
    if (snapshot.data == true) {
      return const HomeScreen();
    }
    // ยังไม่เคย → ไป Onboarding
    return const OnboardingScreen();
  },
),
```

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] `dart run build_runner build --delete-conflicting-outputs` รันสำเร็จ (หลังเพิ่ม fields)
- [ ] เปิดแอปครั้งแรก → เห็น Onboarding (ไม่ใช่ Home)
- [ ] Page 1 → เห็น Welcome + ปุ่มถัดไป
- [ ] Page 2 → เห็น 3 ฟีเจอร์
- [ ] Page 3 → กรอกข้อมูล → เห็นผล TDEE คำนวณ
- [ ] Page 3 → เปลี่ยนเพศ/น้ำหนัก → TDEE เปลี่ยนตาม
- [ ] Page 4 → กด "ตั้งค่าเลย" → ไปหน้า API Key
- [ ] Page 4 → กด "ข้ามไปก่อน" → เข้า Home
- [ ] เปิดแอปอีกครั้ง → ไป Home ทันที (ไม่แสดง Onboarding ซ้ำ)
- [ ] ข้อมูลที่กรอก (เพศ, อายุ, น้ำหนัก, ส่วนสูง) ถูกบันทึกใน UserProfile

### TDEE Calculator ทดสอบ:
- [ ] ชาย 25 ปี 70kg 175cm ปานกลาง → TDEE ≈ 2,550 kcal
- [ ] หญิง 30 ปี 55kg 160cm เบา → TDEE ≈ 1,700 kcal
- [ ] เปลี่ยนกิจกรรมจาก "นั่งทั้งวัน" → "หนักมาก" → TDEE เพิ่มขึ้นอย่างชัดเจน

---

## 🔍 Troubleshooting

### Q: Error "type 'Null' is not a subtype of type 'UserProfile'"
**สาเหตุ:** ยังไม่มี UserProfile ใน DB (เปิดครั้งแรก)
**แก้:** ใช้ `?? UserProfile()` เมื่อ get จาก Isar

### Q: build_runner error
**สาเหตุ:** field type ไม่ถูกต้องสำหรับ Isar
**แก้:** ตรวจว่า fields ที่เพิ่มเป็น type ที่ Isar รองรับ (String?, int?, double?, bool)

### Q: Onboarding แสดงซ้ำทุกครั้ง
**สาเหตุ:** `onboardingComplete` ไม่ถูก save
**แก้:** ตรวจว่า `_completeOnboarding()` เรียก `isar.writeTxn` จริง

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 33 →

ไปทำ **Step 33: Production Hardening** ได้เลย
