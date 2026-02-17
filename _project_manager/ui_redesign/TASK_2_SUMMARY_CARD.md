# TASK 2: Redesign DailySummaryCard

> **ระยะเวลา:** 1 วัน (8 ชั่วโมง)  
> **ความยาก:** ⭐⭐ ปานกลาง  
> **Dependency:** ต้องทำ TASK_1 ก่อน

## 🎯 เป้าหมาย

เปลี่ยน DailySummaryCard จาก gradient amber + linear progress → พื้นขาว + circular progress ring

### Before
```
┌────────────────────────────────┐
│ 📊 Today's Summary             │
│ [gradient amber background]    │
│                                 │
│ 🔥 1200 / 1800 kcal            │
│ ▓▓▓▓▓▓▓▓▓░░░░░░░ 67%           │
│                                 │
│  ⚪ P:80g  ⚪ C:200g  ⚪ F:50g   │
│                                 │
│ [View Details]                  │
└────────────────────────────────┘
```

### After
```
┌────────────────────────────────┐
│ Today's Intake      ╭─────╮   │
│ Subtitle info       │1200 │   │
│                     │/1800│   │
│                     ╰─────╯   │
│                                 │
│ 🔴 P:80g  🟡 C:200g  🔵 F:50g  │
└────────────────────────────────┘
```

## 📁 ไฟล์ที่ต้องแก้

`lib/features/health/widgets/daily_summary_card.dart` (1 ไฟล์เดียว)

---

## ⚠️ กฎสำคัญ - ห้ามแก้

### ✅ ที่แก้ได้
- Container decoration (สี, shadow, radius)
- Layout (Row, Column, Stack)
- Text style, size, color
- Progress indicator แบบ (linear → circular)

### ❌ ห้ามแก้
- `ref.watch(foodEntriesByDateProvider(date))` → ห้ามแก้
- `ref.watch(profileNotifierProvider)` → ห้ามแก้
- การคำนวณ `calories`, `protein`, `carbs`, `fat`, `percent` → ห้ามแก้
- `_isToday()` function → ห้ามแก้
- Navigation ไป `TodaySummaryDashboardScreen` → ห้ามแก้

---

## ขั้นตอนที่ 1: อ่านโค้ดเดิมให้เข้าใจ

### 1.1 เปิดไฟล์
```
lib/features/health/widgets/daily_summary_card.dart
```

### 1.2 ดู structure ปัจจุบัน
- ไฟล์ยาว 257 บรรทัด
- เป็น `ConsumerWidget`
- มี `build()` method (บรรทัด 16-206)
- มี `_buildMacroItem()` helper (บรรทัด 213-256)

---

## ขั้นตอนที่ 2: เปลี่ยน Container decoration

### 2.1 หา Container หลัก (บรรทัดที่ 24-44)

**Before:**
```dart
return Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.health.withOpacity(0.8),
        AppColors.health,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.health.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Column(
    // ...
  ),
);
```

**After:**
```dart
return GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TodaySummaryDashboardScreen(),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),  // เปลี่ยนจาก 16 → 20
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,  // เปลี่ยนจาก gradient → สีขาว/เทา
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),  // เปลี่ยน shadow
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      // ...
    ),
  ),
);
```

---

## ขั้นตอนที่ 3: เปลี่ยน Layout ข้างใน Column

### 3.1 หา Column children (บรรทัดที่ 45-205)

**Before:**
```dart
child: Column(
  children: [
    Text(
      isToday
          ? '📊 Today\'s Summary'
          : '📊 Summary ${DateFormat('d MMM', 'en').format(date)}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    const SizedBox(height: 16),
    
    // Calories + Macros
    profileAsync.when(
      // ...
    ),
  ],
),
```

**After:**
```dart
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // เพิ่มบรรทัดนี้
  children: [
    // ===== ส่วนที่ 1: Title + Circular Progress =====
    profileAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox(),
      data: (profile) => foodsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (_, __) => const Text('Error'),
        data: (entries) {
          final calories = entries.fold<double>(0, (sum, e) => sum + e.calories);
          final protein = entries.fold<double>(0, (sum, e) => sum + e.protein);
          final carbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);
          final fat = entries.fold<double>(0, (sum, e) => sum + e.fat);
          
          final goal = profile.calorieGoal;
          final percent = goal > 0 ? (calories / goal).clamp(0.0, 1.0) : 0.0;
          
          return Column(
            children: [
              // Row 1: Title ซ้าย + Circular Progress ขวา
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== ฝั่งซ้าย: Title + Subtitle =====
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday ? "Today's Intake" : "Daily Intake",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isToday 
                              ? DateFormat('EEEE, d MMM', 'en').format(date)
                              : DateFormat('d MMMM yyyy', 'en').format(date),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ===== ฝั่งขวา: Circular Progress =====
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${calories.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '/ ${goal.toInt()}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Row 2: Macros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroItem(
                    label: 'Protein',
                    value: protein,
                    goal: profile.proteinGoal,
                    color: AppColors.protein,
                  ),
                  _buildMacroItem(
                    label: 'Carbs',
                    value: carbs,
                    goal: profile.carbGoal,
                    color: AppColors.carbs,
                  ),
                  _buildMacroItem(
                    label: 'Fat',
                    value: fat,
                    goal: profile.fatGoal,
                    color: AppColors.fat,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  ],
),
```

---

## ขั้นตอนที่ 4: เปลี่ยน _buildMacroItem()

### 4.1 หา function _buildMacroItem (บรรทัดที่ 213-256)

**Before:**
```dart
Widget _buildMacroItem({
  required String label,
  required double value,
  required double goal,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${value.toInt()}g',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 11,
        ),
      ),
      Text(
        '/${goal.toInt()}g',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 10,
        ),
      ),
    ],
  );
}
```

**After:**
```dart
Widget _buildMacroItem({
  required String label,
  required double value,
  required double goal,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toInt()}g',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          '/ ${goal.toInt()}g',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}
```

---

## ขั้นตอนที่ 5: ลบปุ่ม "View Details" (ถ้ามี)

ปุ่มนี้ย้ายไปอยู่ใน GestureDetector ที่ครอบ Container แล้ว (ขั้นตอนที่ 2) ดังนั้น:

- ถ้าเห็น `TextButton.icon` ที่มี label "View Details" → **ลบออกทั้งหมด**
- ใน Column children ไม่ต้องมี button นี้แล้ว

---

## 📝 Checklist

- [ ] เปลี่ยน Container decoration (ขาว + shadow)
- [ ] เพิ่ม GestureDetector onTap navigation
- [ ] เปลี่ยน layout เป็น Row (title ซ้าย + circular ขวา)
- [ ] เพิ่ม CircularProgressIndicator (ใช้ `percent` เดิม)
- [ ] แสดง calories / goal ข้างใน circular
- [ ] Macros Row ด้านล่าง (ใช้ _buildMacroItem ใหม่)
- [ ] ลบปุ่ม "View Details" (ถ้ามี)
- [ ] Build ผ่าน: `flutter build apk --debug`
- [ ] ทดสอบ: Card พื้นขาว มี shadow
- [ ] ทดสอบ: Circular progress แสดง calories
- [ ] ทดสอบ: Macros แสดงด้านล่าง
- [ ] ทดสอบ: Tap card → navigate ไป Summary Dashboard
- [ ] ทดสอบ: เปลี่ยนวัน → data update
- [ ] ทดสอบ: Dark mode ไม่แตก
- [ ] ทดสอบ: Goal = 0 ไม่ crash

---

## 🧪 Testing Steps

### 1. Build
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 2. Run
```bash
flutter run
```

### 3. Test Card

#### Light Mode
- เปิดแอป → ดู card แรกสุด
- พื้นขาว (ไม่ใช่ amber gradient)
- มี shadow เบาๆ
- Title "Today's Intake" ด้านซ้าย ตัวใหญ่ bold
- Circular progress ด้านขวา → แสดง calorie
- Macros 3 ตัว ด้านล่าง (P/C/F) มีสี มีจุดกลม

#### Navigation
- Tap card → เปิด TodaySummaryDashboardScreen
- Back → กลับมาหน้าเดิม

#### เปลี่ยนวัน
- กด Date selector (📅)
- เลือกวันอื่น
- Card update data ตามวันที่เลือก

#### Dark Mode
- เข้า Profile → Toggle Dark Mode
- Card พื้นเทาเข้ม
- Circular progress ยังเห็นชัด
- Macros ยังอ่านได้

#### Edge Case
- ลบ food entries ทั้งหมด → Card แสดง 0 kcal (ไม่ crash)
- เข้า Profile → ตั้ง Goal = 0 → Card แสดง 0/0 (ไม่ crash, division by zero ป้องกันด้วย `goal > 0 ? ... : 0.0`)

---

## 🚀 Git Commit

```bash
git add lib/features/health/widgets/daily_summary_card.dart
git commit -m "style: redesign DailySummaryCard with circular progress ring

- Change from gradient background to white/card color with shadow
- Replace linear progress bar with circular progress indicator
- Redesign layout: title left + circular progress right
- Redesign macro items with colored background and dot indicator
- Move navigation to card tap (remove View Details button)
- Support both light and dark mode"

git push origin feature/airbnb-redesign
```

---

## ❓ Q&A

**Q: Build error "TodaySummaryDashboardScreen not found"?**  
A: เพิ่ม import ข้างบน:
```dart
import '../presentation/today_summary_dashboard_screen.dart';
```

**Q: Circular progress ไม่แสดง?**  
A: เช็คว่า `percent` คำนวณถูกต้องไหม (ใช้จาก provider เดิม)

**Q: Dark mode พื้นยังเป็นขาว?**  
A: ใช้ `Theme.of(context).cardColor` แทน `Colors.white`

**Q: Macro item ดูไม่สวย?**  
A: ปรับ padding, spacing ตามที่ชอบ (แต่ต้องคล้าย reference)

---

**✅ เสร็จแล้ว?** → ไปทำ `TASK_3_HORIZONTAL_TIMELINE.md` ต่อ (หรือรอ Senior review ก่อน)
