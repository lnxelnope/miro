# Step 28: Quick Repeat & Favorite Quick-Add

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ง่าย-ปานกลาง
> **ต้องทำก่อน:** Step 24 (Ingredient & MyMeal Model) + Step 25 (MyMeal Tab UI)

---

## 🎯 เป้าหมาย

1. **Favorite Quick-Add** - แสดง Top 5 อาหารที่กินบ่อยสุดเป็นปุ่มลัด บนหน้า Timeline ให้กด 1 tap บันทึกได้เลย
2. **Quick Repeat** - ปุ่ม "กินเหมือนเมื่อวาน [มื้อเช้า/เที่ยง/เย็น]" เพื่อ copy entries จากวันก่อน
3. ลดขั้นตอนการบันทึกอาหารให้เหลือน้อยที่สุด

---

## 📐 UI Layout

```
┌──────────────────────────────────────────────────┐
│  Timeline Tab                                     │
│                                                   │
│  ┌──────────────────────────────────────────────┐│
│  │  📊 Daily Summary Card                       ││
│  └──────────────────────────────────────────────┘│
│                                                   │
│  ┌── ⚡ Quick Add ─────────────────────────────┐ │
│  │                                              │ │
│  │  [🍛ผัดกระเพรา] [🥚ไข่] [🍜ก๋วยเตี๋ยว]     │ │
│  │  [☕กาแฟ] [🍌กล้วย]                         │ │
│  │                                              │ │
│  │  [🔄 เหมือนเมื่อวานเช้า] [🔄 เหมือนเที่ยง] │ │
│  │                                              │ │
│  └──────────────────────────────────────────────┘ │
│                                                   │
│  📅 วันนี้                                       │
│  ┌──────────────────────────────────────────────┐│
│  │ 🍽️ ผัดกระเพราไข่ดาว  611 kcal  12:30       ││
│  └──────────────────────────────────────────────┘│
│  ...                                              │
└──────────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/health/widgets/quick_add_section.dart` | CREATE | Widget Quick Add + Repeat |
| `lib/features/health/providers/quick_add_provider.dart` | CREATE | Provider ดึง top foods + yesterday entries |
| `lib/features/health/presentation/health_timeline_tab.dart` | EDIT | เพิ่ม QuickAddSection |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Quick Add Provider

**ไฟล์:** `lib/features/health/providers/quick_add_provider.dart`
**Action:** CREATE

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../models/my_meal.dart';
import '../models/ingredient.dart';

/// ข้อมูลสำหรับ Quick Add
class QuickAddItem {
  final String name;
  final String emoji;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final int? myMealId;
  final int? ingredientId;
  final int usageCount;

  QuickAddItem({
    required this.name,
    required this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    this.myMealId,
    this.ingredientId,
    required this.usageCount,
  });
}

/// ดึง Top 5 อาหารที่กินบ่อยสุด (จาก MyMeal + Ingredient)
final topQuickAddItemsProvider = FutureProvider<List<QuickAddItem>>((ref) async {
  final items = <QuickAddItem>[];

  // 1. ดึง MyMeal ที่ใช้บ่อยสุด
  final topMeals = await DatabaseService.myMeals
      .where()
      .sortByUsageCountDesc()
      .limit(5)
      .findAll();

  for (final meal in topMeals) {
    if (meal.usageCount > 0) {
      items.add(QuickAddItem(
        name: meal.name,
        emoji: '🍽️',
        calories: meal.totalCalories,
        protein: meal.totalProtein,
        carbs: meal.totalCarbs,
        fat: meal.totalFat,
        servingSize: 1,
        servingUnit: meal.baseServingDescription,
        baseCalories: meal.totalCalories,
        baseProtein: meal.totalProtein,
        baseCarbs: meal.totalCarbs,
        baseFat: meal.totalFat,
        myMealId: meal.id,
        usageCount: meal.usageCount,
      ));
    }
  }

  // 2. ดึง Ingredient ที่ใช้บ่อยสุด (เติมจนครบ 5)
  if (items.length < 5) {
    final remaining = 5 - items.length;
    final topIngredients = await DatabaseService.ingredients
        .where()
        .sortByUsageCountDesc()
        .limit(remaining)
        .findAll();

    for (final ing in topIngredients) {
      if (ing.usageCount > 0) {
        items.add(QuickAddItem(
          name: ing.name,
          emoji: '🥬',
          calories: ing.caloriesPerBase,
          protein: ing.proteinPerBase,
          carbs: ing.carbsPerBase,
          fat: ing.fatPerBase,
          servingSize: ing.baseAmount,
          servingUnit: ing.baseUnit,
          baseCalories: ing.caloriesPerBase / ing.baseAmount,
          baseProtein: ing.proteinPerBase / ing.baseAmount,
          baseCarbs: ing.carbsPerBase / ing.baseAmount,
          baseFat: ing.fatPerBase / ing.baseAmount,
          ingredientId: ing.id,
          usageCount: ing.usageCount,
        ));
      }
    }
  }

  // Sort by usage count
  items.sort((a, b) => b.usageCount.compareTo(a.usageCount));

  return items.take(5).toList();
});

/// ดึง entries ของเมื่อวาน แยกตามมื้อ
final yesterdayEntriesProvider = FutureProvider<Map<MealType, List<FoodEntry>>>((ref) async {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final entries = await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .findAll();

  final grouped = <MealType, List<FoodEntry>>{};
  for (final entry in entries) {
    grouped.putIfAbsent(entry.mealType, () => []).add(entry);
  }

  return grouped;
});

/// ข้อมูล repeat meal
class RepeatMealInfo {
  final MealType mealType;
  final List<FoodEntry> entries;
  final double totalCalories;

  RepeatMealInfo({
    required this.mealType,
    required this.entries,
    required this.totalCalories,
  });
}

/// ดึง repeat options (มื้อที่เมื่อวานมี entries)
final repeatOptionsProvider = FutureProvider<List<RepeatMealInfo>>((ref) async {
  final grouped = await ref.watch(yesterdayEntriesProvider.future);

  return grouped.entries.map((e) {
    final totalCal = e.value.fold<double>(0, (sum, entry) => sum + entry.calories);
    return RepeatMealInfo(
      mealType: e.key,
      entries: e.value,
      totalCalories: totalCal,
    );
  }).toList()
    ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));
});
```

---

### Step 2: สร้าง Quick Add Section Widget

**ไฟล์:** `lib/features/health/widgets/quick_add_section.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../providers/quick_add_provider.dart';
import '../providers/health_provider.dart';
import '../models/food_entry.dart';

/// Section แสดง Quick Add buttons + Repeat Yesterday
/// แสดงบน Timeline Tab ก่อนรายการอาหาร
class QuickAddSection extends ConsumerWidget {
  final DateTime selectedDate;

  const QuickAddSection({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickItemsAsync = ref.watch(topQuickAddItemsProvider);
    final repeatAsync = ref.watch(repeatOptionsProvider);

    // ถ้าไม่มี data เลย ไม่ต้องแสดง section นี้
    final hasQuickItems = quickItemsAsync.valueOrNull?.isNotEmpty ?? false;
    final hasRepeat = repeatAsync.valueOrNull?.isNotEmpty ?? false;

    if (!hasQuickItems && !hasRepeat) return const SizedBox();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.bolt, size: 16, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                'Quick Add',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Add Chips (Favorite foods)
          quickItemsAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (items) {
              if (items.isEmpty) return const SizedBox();
              return Wrap(
                spacing: 8,
                runSpacing: 6,
                children: items.map((item) => _buildQuickChip(
                  context, ref, item,
                )).toList(),
              );
            },
          ),

          // Repeat Yesterday
          repeatAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (options) {
              if (options.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: options.map((opt) => _buildRepeatChip(
                    context, ref, opt,
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Chip สำหรับ quick add (1 tap = บันทึกทันที)
  Widget _buildQuickChip(BuildContext context, WidgetRef ref, QuickAddItem item) {
    return ActionChip(
      avatar: Text(item.emoji, style: const TextStyle(fontSize: 14)),
      label: Text(
        '${item.name} (${item.calories.toInt()})',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppColors.health.withOpacity(0.08),
      side: BorderSide(color: AppColors.health.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _quickAdd(context, ref, item),
    );
  }

  /// Chip สำหรับ repeat yesterday
  Widget _buildRepeatChip(BuildContext context, WidgetRef ref, RepeatMealInfo option) {
    return ActionChip(
      avatar: const Text('🔄', style: TextStyle(fontSize: 14)),
      label: Text(
        'เหมือนเมื่อวาน${option.mealType.displayName} (${option.totalCalories.toInt()} kcal)',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue.withOpacity(0.08),
      side: BorderSide(color: Colors.blue.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _repeatMeal(context, ref, option),
    );
  }

  /// Quick Add: บันทึกทันที 1 tap
  Future<void> _quickAdd(BuildContext context, WidgetRef ref, QuickAddItem item) async {
    final mealType = _guessMealType();

    final entry = FoodEntry()
      ..foodName = item.name
      ..mealType = mealType
      ..timestamp = DateTime.now()
      ..servingSize = item.servingSize
      ..servingUnit = item.servingUnit
      ..calories = item.calories
      ..protein = item.protein
      ..carbs = item.carbs
      ..fat = item.fat
      ..baseCalories = item.baseCalories
      ..baseProtein = item.baseProtein
      ..baseCarbs = item.baseCarbs
      ..baseFat = item.baseFat
      ..myMealId = item.myMealId
      ..ingredientId = item.ingredientId
      ..source = DataSource.manual
      ..isVerified = true;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);
    refreshFoodProviders(ref, selectedDate);

    // เพิ่ม usage count
    if (item.myMealId != null) {
      await ref.read(myMealNotifierProvider.notifier).incrementMealUsage(item.myMealId!);
    }

    ref.invalidate(topQuickAddItemsProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ บันทึก "${item.name}" ${item.calories.toInt()} kcal'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'แก้ไข',
          textColor: Colors.white,
          onPressed: () {
            // TODO: เปิด edit sheet
          },
        ),
      ),
    );
  }

  /// Repeat: copy entries ทั้งมื้อจากเมื่อวาน
  Future<void> _repeatMeal(BuildContext context, WidgetRef ref, RepeatMealInfo option) async {
    // ยืนยันก่อน
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔄 กินเหมือนเมื่อวาน${option.mealType.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คัดลอก ${option.entries.length} รายการ (${option.totalCalories.toInt()} kcal)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...option.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '  • ${e.foodName} (${e.calories.toInt()} kcal)',
                style: const TextStyle(fontSize: 13),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.health,
              foregroundColor: Colors.white,
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final now = DateTime.now();

    for (final original in option.entries) {
      final copy = FoodEntry()
        ..foodName = original.foodName
        ..foodNameEn = original.foodNameEn
        ..mealType = original.mealType
        ..timestamp = now
        ..imagePath = original.imagePath
        ..servingSize = original.servingSize
        ..servingUnit = original.servingUnit
        ..servingGrams = original.servingGrams
        ..calories = original.calories
        ..protein = original.protein
        ..carbs = original.carbs
        ..fat = original.fat
        ..baseCalories = original.baseCalories
        ..baseProtein = original.baseProtein
        ..baseCarbs = original.baseCarbs
        ..baseFat = original.baseFat
        ..fiber = original.fiber
        ..sugar = original.sugar
        ..sodium = original.sodium
        ..myMealId = original.myMealId
        ..ingredientId = original.ingredientId
        ..source = original.source
        ..isVerified = original.isVerified
        ..notes = 'คัดลอกจากเมื่อวาน';

      await notifier.addFoodEntry(copy);
    }

    refreshFoodProviders(ref, selectedDate);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔄 คัดลอก ${option.entries.length} รายการจากเมื่อวาน${option.mealType.displayName} '
          '(${option.totalCalories.toInt()} kcal)',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
```

**⚠️ import ที่จำเป็น:**

```dart
import '../providers/my_meal_provider.dart';
```

ถ้า `myMealNotifierProvider` อยู่ใน `my_meal_provider.dart` (จาก Step 24)

---

### Step 3: เพิ่ม QuickAddSection ใน Health Timeline Tab

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

**เพิ่ม import:**

```dart
import '../widgets/quick_add_section.dart';
```

**หาตำแหน่งใน `build()` method ระหว่าง Date Selector กับ Timeline list**

หาบรรทัดนี้:
```dart
          SliverToBoxAdapter(child: _buildDateSelector()),
```

เพิ่มข้างล่าง:
```dart
          // Quick Add Section (Favorite + Repeat Yesterday)
          SliverToBoxAdapter(
            child: QuickAddSection(selectedDate: _selectedDate),
          ),
```

**ผลลัพธ์:**

```dart
          SliverToBoxAdapter(child: _buildDateSelector()),
          
          // Quick Add Section (Favorite + Repeat Yesterday)
          SliverToBoxAdapter(
            child: QuickAddSection(selectedDate: _selectedDate),
          ),

          timelineAsync.when(
            // ... existing code ...
          ),
```

---

## ✅ Definition of Done

- [ ] Quick Add chips แสดง Top 5 อาหารที่กินบ่อยสุด
- [ ] กดปุ่ม Quick Add → บันทึก FoodEntry ทันที (1 tap)
- [ ] SnackBar แสดงผลลัพธ์ + ปุ่ม "แก้ไข"
- [ ] Repeat Yesterday chips แสดงมื้อที่เมื่อวานมี entries
- [ ] กด Repeat → แสดง dialog ยืนยัน → คัดลอก entries ทั้งมื้อ
- [ ] ถ้ายังไม่มี data (ผู้ใช้ใหม่) → ไม่แสดง section นี้
- [ ] Usage count เพิ่มเมื่อ quick add
- [ ] Quick Add section อยู่ระหว่าง Date Selector กับ Timeline

---

## 📁 ไฟล์ที่สร้าง/แก้ไข

```
lib/features/health/
├── providers/
│   └── quick_add_provider.dart          ← NEW
├── widgets/
│   └── quick_add_section.dart           ← NEW
└── presentation/
    └── health_timeline_tab.dart          ← EDIT (เพิ่ม QuickAddSection)
```

---

## 🔄 Summary: ลำดับการทำงานทั้ง 6 Steps (รวมใหม่)

```
Step 23 ──► Step 24 ──► Step 25 ──► Step 26 ──► Step 27 ──► Step 28
ลบ GlobalDB  Models     My Meal    Chat Smart  Barcode     Quick Add
Fix kcal     Ingredient  Tab UI    Food Log    Scanner     Repeat
Gemini Sheet MyMeal     CRUD       Modifier    Nutri Label Favorite
             Auto-save  Log Meal   Auto-save

  ↑ ต้องทำก่อน ↑ ↑ ต้องทำก่อน ↑ ↑ ต้องทำก่อน ↑
                                
  Step 27 ต้องทำหลัง 24 (ใช้ Ingredient model)
  Step 28 ต้องทำหลัง 24+25 (ใช้ MyMeal + Ingredient)
```
