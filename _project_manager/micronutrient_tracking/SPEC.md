# Micronutrient Tracking, Health Sync & Summary Redesign

> **สำหรับ:** Junior Developer  
> **Stack:** Flutter, Riverpod, Isar, fl_chart, health package  
> **อ้างอิง:** รูป Google Health "Add a meal" ที่รองรับ micronutrient

---

## สารบัญ

1. [Part 1: เพิ่ม Micronutrient Fields](#part-1)
2. [Part 2: อัปเดต AI Prompt ให้ดึง Micronutrient](#part-2)
3. [Part 3: Sync Micronutrient ไป Google Health / HealthKit](#part-3)
4. [Part 4: สร้าง FDA Daily Values Constants](#part-4)
5. [Part 5: Redesign Summary Screen](#part-5)

---

<a id="part-1"></a>
## Part 1: เพิ่ม Micronutrient Fields ใน Model

### 1.1 เพิ่ม field ใน FoodEntry

**ไฟล์:** `lib/features/health/models/food_entry.dart`

**บรรทัดที่ 46-51** — ตอนนี้มี:
```dart
// Micros (optional)
double? fiber;
double? sugar;
double? sodium;
double? cholesterol;
double? saturatedFat;
```

**เปลี่ยนเป็น:**
```dart
// Micros (optional)
double? fiber;
double? sugar;
double? sodium;
double? cholesterol;
double? saturatedFat;
double? transFat;
double? unsaturatedFat;
double? monounsaturatedFat;
double? polyunsaturatedFat;
double? potassium;
```

**หลังจากแก้แล้ว:** รัน `dart run build_runner build --delete-conflicting-outputs`

---

### 1.2 เพิ่ม field ใน NutritionData

**ไฟล์:** `lib/core/ai/gemini_service.dart`

**บรรทัดที่ 2410-2440** — class `NutritionData`

**เปลี่ยนทั้ง class เป็น:**
```dart
class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? cholesterol;
  final double? saturatedFat;
  final double? transFat;
  final double? unsaturatedFat;
  final double? monounsaturatedFat;
  final double? polyunsaturatedFat;
  final double? potassium;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.unsaturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.potassium,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
      saturatedFat: json['saturatedFat']?.toDouble(),
      transFat: json['transFat']?.toDouble(),
      unsaturatedFat: json['unsaturatedFat']?.toDouble(),
      monounsaturatedFat: json['monounsaturatedFat']?.toDouble(),
      polyunsaturatedFat: json['polyunsaturatedFat']?.toDouble(),
      potassium: json['potassium']?.toDouble(),
    );
  }
}
```

---

### 1.3 อัปเดต applyResultToEntry

**ไฟล์:** `lib/core/utils/batch_analysis_helper.dart`

**บรรทัดที่ 117-119** — ตอนนี้มี:
```dart
entry.fiber = result.nutrition.fiber;
entry.sugar = result.nutrition.sugar;
entry.sodium = result.nutrition.sodium;
```

**เปลี่ยนเป็น:**
```dart
entry.fiber = result.nutrition.fiber;
entry.sugar = result.nutrition.sugar;
entry.sodium = result.nutrition.sodium;
entry.cholesterol = result.nutrition.cholesterol;
entry.saturatedFat = result.nutrition.saturatedFat;
entry.transFat = result.nutrition.transFat;
entry.unsaturatedFat = result.nutrition.unsaturatedFat;
entry.monounsaturatedFat = result.nutrition.monounsaturatedFat;
entry.polyunsaturatedFat = result.nutrition.polyunsaturatedFat;
entry.potassium = result.nutrition.potassium;
```

---

### 1.4 อัปเดต updateFromGeminiConfirmed

**ไฟล์:** `lib/features/health/providers/health_provider.dart`

**บรรทัดที่ 253-274** — method `updateFromGeminiConfirmed`

เพิ่ม parameter ใหม่ต่อจาก `double? sodium`:
```dart
double? cholesterol,
double? saturatedFat,
double? transFat,
double? unsaturatedFat,
double? monounsaturatedFat,
double? polyunsaturatedFat,
double? potassium,
```

เพิ่ม assignment ต่อจาก `entry.sodium = sodium;` (บรรทัด 295):
```dart
entry.cholesterol = cholesterol;
entry.saturatedFat = saturatedFat;
entry.transFat = transFat;
entry.unsaturatedFat = unsaturatedFat;
entry.monounsaturatedFat = monounsaturatedFat;
entry.polyunsaturatedFat = polyunsaturatedFat;
entry.potassium = potassium;
```

---

<a id="part-2"></a>
## Part 2: อัปเดต AI Prompt ให้ดึง Micronutrient

**ไฟล์:** `lib/core/ai/gemini_service.dart`

มี **7 จุด** ที่ต้องแก้ JSON ตัวอย่าง `"nutrition"` ทุกจุดต้องเปลี่ยนเหมือนกันหมด

### JSON เดิม (ที่ปรากฏใน 7 จุด):
```json
"nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200
}
```

### JSON ใหม่ (ใช้แทนทุกจุด):
```json
"nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200,
    "cholesterol": 0,
    "saturatedFat": 3,
    "transFat": 0,
    "unsaturatedFat": 3,
    "monounsaturatedFat": 2,
    "polyunsaturatedFat": 1,
    "potassium": 150
}
```

### ตำแหน่งทั้ง 7 จุด (หาจาก `"nutrition": {`):

| # | Method | บรรทัดโดยประมาณ |
|---|--------|------|
| 1 | `analyzeBarcodedProduct` | 911-918 |
| 2 | `analyzeNutritionLabel` | 1010-1017 |
| 3 | `_getImageAnalysisPrompt` | 1380-1387 |
| 4 | `_getProductImageAnalysisPrompt` | 1592-1599 |
| 5 | `_getTextAnalysisPrompt` | 1877-1884 |
| 6 | `_getProductTextAnalysisPrompt` | 2012-2019 |
| 7 | `_getBatchTextAnalysisPrompt` | 2132-2139 |

**วิธีทำ:** ค้นหา `"fiber":` ในไฟล์ จะเจอ 7 จุดพอดี แต่ละจุดจะมี `"sodium":` เป็นตัวสุดท้าย ให้เพิ่ม `,` หลัง sodium แล้วเพิ่ม 7 field ใหม่

**สำคัญ:** ค่าตัวเลขใน JSON ใหม่สามารถเปลี่ยนได้ตามตัวอย่างอาหาร สิ่งสำคัญคือ key name ต้องตรง

### เพิ่มคำอธิบายใน prompt text

ค้นหา text ที่มี `fiber, sugar, sodium` ใน prompt descriptions (ไม่ใช่ JSON) และเพิ่ม micronutrient ใหม่:

- บรรทัดประมาณ 1776 มี text:
  ```
  You MUST calculate ALL nutrition values (calories, protein, carbs, fat, fiber, sugar, sodium) for this EXACT amount.
  ```
  **เปลี่ยนเป็น:**
  ```
  You MUST calculate ALL nutrition values (calories, protein, carbs, fat, fiber, sugar, sodium, cholesterol, saturatedFat, transFat, unsaturatedFat, monounsaturatedFat, polyunsaturatedFat, potassium) for this EXACT amount.
  ```

- ค้นหาข้อความคล้ายๆ กันในทุก prompt method แล้วเพิ่ม field ใหม่ด้วย

---

<a id="part-3"></a>
## Part 3: Sync Micronutrient ไป Google Health / HealthKit

### 3.1 อัปเดต writeFoodEntry

**ไฟล์:** `lib/core/services/health_sync_service.dart`

**บรรทัดที่ 143-182** — method `writeFoodEntry`

**เปลี่ยนทั้ง method เป็น:**
```dart
static Future<String?> writeFoodEntry({
  required String name,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
  required DateTime timestamp,
  app_enums.MealType? mealType,
  double? fiber,
  double? sugar,
  double? sodium,
  double? cholesterol,
  double? saturatedFat,
  double? transFat,
  double? unsaturatedFat,
  double? monounsaturatedFat,
  double? polyunsaturatedFat,
  double? potassium,
}) async {
  try {
    _ensureConfigured();

    final startTime = timestamp;
    final endTime = timestamp.add(const Duration(minutes: 1));

    final success = await _health.writeMeal(
      startTime: startTime,
      endTime: endTime,
      caloriesConsumed: calories,
      protein: protein,
      carbohydrates: carbs,
      fatTotal: fat,
      name: name,
      mealType: _mapMealType(mealType),
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      cholesterol: cholesterol,
      fatSaturated: saturatedFat,
      fatTransMonoenoic: transFat,
      fatUnsaturated: unsaturatedFat,
      fatMonounsaturated: monounsaturatedFat,
      fatPolyunsaturated: polyunsaturatedFat,
      potassium: potassium,
    );

    if (!success) {
      AppLogger.warn('writeMeal returned false for "$name"');
      return null;
    }

    final syncKey = '${startTime.millisecondsSinceEpoch}';
    AppLogger.info(
        'Wrote food to Health: "$name" $calories kcal (key=$syncKey)');
    return syncKey;
  } catch (e) {
    AppLogger.error('Failed to write food entry to Health', e);
    return null;
  }
}
```

### 3.2 อัปเดต updateFoodEntry

**บรรทัดที่ 213-236** — method `updateFoodEntry`

**เปลี่ยนทั้ง method เป็น:**
```dart
static Future<String?> updateFoodEntry({
  required String? oldHealthSyncKey,
  required String name,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
  required DateTime timestamp,
  app_enums.MealType? mealType,
  double? fiber,
  double? sugar,
  double? sodium,
  double? cholesterol,
  double? saturatedFat,
  double? transFat,
  double? unsaturatedFat,
  double? monounsaturatedFat,
  double? polyunsaturatedFat,
  double? potassium,
}) async {
  if (oldHealthSyncKey != null && oldHealthSyncKey.isNotEmpty) {
    await deleteFoodEntry(healthSyncKey: oldHealthSyncKey);
  }

  return writeFoodEntry(
    name: name,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    timestamp: timestamp,
    mealType: mealType,
    fiber: fiber,
    sugar: sugar,
    sodium: sodium,
    cholesterol: cholesterol,
    saturatedFat: saturatedFat,
    transFat: transFat,
    unsaturatedFat: unsaturatedFat,
    monounsaturatedFat: monounsaturatedFat,
    polyunsaturatedFat: polyunsaturatedFat,
    potassium: potassium,
  );
}
```

### 3.3 อัปเดต _syncEntryToHealth

**ไฟล์:** `lib/features/health/providers/health_provider.dart`

**บรรทัดที่ 195-218** — method `_syncEntryToHealth`

**เปลี่ยนทั้ง method เป็น:**
```dart
Future<void> _syncEntryToHealth(FoodEntry entry, {String? oldSyncKey}) async {
  try {
    final syncKey = await HealthSyncService.updateFoodEntry(
      oldHealthSyncKey: oldSyncKey,
      name: entry.foodName,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      timestamp: entry.timestamp,
      mealType: entry.mealType,
      fiber: entry.fiber,
      sugar: entry.sugar,
      sodium: entry.sodium,
      cholesterol: entry.cholesterol,
      saturatedFat: entry.saturatedFat,
      transFat: entry.transFat,
      unsaturatedFat: entry.unsaturatedFat,
      monounsaturatedFat: entry.monounsaturatedFat,
      polyunsaturatedFat: entry.polyunsaturatedFat,
      potassium: entry.potassium,
    );

    if (syncKey != null) {
      entry.healthConnectId = syncKey;
      entry.syncedAt = DateTime.now();
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });
    }
  } catch (e) {
    AppLogger.warn('Health sync failed for "${entry.foodName}"', e);
  }
}
```

---

<a id="part-4"></a>
## Part 4: สร้าง FDA Daily Values Constants

**สร้างไฟล์ใหม่:** `lib/core/constants/fda_daily_values.dart`

```dart
/// FDA Daily Values (2020-2025) based on a 2,000 calorie diet
/// Reference: https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels
class FdaDailyValues {
  // Macronutrients
  static const double calories = 2000;       // kcal
  static const double totalFat = 78;         // g
  static const double protein = 50;          // g
  static const double carbohydrates = 275;   // g

  // Micronutrients
  static const double fiber = 28;            // g (target: reach this)
  static const double sugar = 50;            // g (limit: stay under)
  static const double sodium = 2300;         // mg (limit: stay under)
  static const double cholesterol = 300;     // mg (limit: stay under)
  static const double saturatedFat = 20;     // g (limit: stay under)
  static const double transFat = 0;          // g (limit: avoid completely)
  static const double potassium = 4700;      // mg (target: reach this)

  // ไม่มี FDA DV สำหรับ unsaturated / mono / poly — แสดงเฉพาะค่า

  /// ค่าที่ "ยิ่งน้อยยิ่งดี" (เกินคือแดง)
  static const limitNutrients = {
    'sugar', 'sodium', 'cholesterol', 'saturatedFat', 'transFat',
  };

  /// ค่าที่ "ยิ่งมากยิ่งดี" (ขาดคือแดง)
  static const targetNutrients = {
    'fiber', 'potassium',
  };

  /// ดึง FDA DV ตาม key
  static double? getValue(String key) {
    switch (key) {
      case 'fiber': return fiber;
      case 'sugar': return sugar;
      case 'sodium': return sodium;
      case 'cholesterol': return cholesterol;
      case 'saturatedFat': return saturatedFat;
      case 'transFat': return transFat;
      case 'potassium': return potassium;
      default: return null;
    }
  }

  /// ตรวจสอบว่า nutrient อยู่ในเกณฑ์ดีหรือไม่
  /// true = ดี (เขียว), false = ไม่ดี (แดง)
  static bool isGood(String key, double actualValue) {
    final fdaValue = getValue(key);
    if (fdaValue == null) return true;

    if (limitNutrients.contains(key)) {
      return actualValue <= fdaValue;
    } else if (targetNutrients.contains(key)) {
      return actualValue >= fdaValue;
    }
    return true;
  }
}
```

---

<a id="part-5"></a>
## Part 5: Redesign Summary Screen

### 5.1 อัปเดต MicronutrientStatistics model

**ไฟล์:** `lib/features/health/models/micronutrient_stats.dart`

**เปลี่ยนทั้งไฟล์เป็น:**
```dart
/// Statistics for a single micronutrient over time
class MicronutrientStats {
  final String name;
  final String key;
  final String unit;
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final double yearlyAverage;
  final double? fdaDailyValue;
  final List<DailyValue> dailyValues;

  const MicronutrientStats({
    required this.name,
    required this.key,
    required this.unit,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.yearlyAverage,
    this.fdaDailyValue,
    required this.dailyValues,
  });

  double get percentOfFda =>
      fdaDailyValue != null && fdaDailyValue! > 0
          ? (dailyAverage / fdaDailyValue!) * 100
          : 0;
}

/// A single day's micronutrient value
class DailyValue {
  final DateTime date;
  final double value;

  const DailyValue({
    required this.date,
    required this.value,
  });
}

/// All micronutrient statistics
class MicronutrientStatistics {
  final MicronutrientStats? fiber;
  final MicronutrientStats? sugar;
  final MicronutrientStats? sodium;
  final MicronutrientStats? cholesterol;
  final MicronutrientStats? saturatedFat;
  final MicronutrientStats? transFat;
  final MicronutrientStats? unsaturatedFat;
  final MicronutrientStats? monounsaturatedFat;
  final MicronutrientStats? polyunsaturatedFat;
  final MicronutrientStats? potassium;

  const MicronutrientStatistics({
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.unsaturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.potassium,
  });

  bool get hasAnyData =>
      fiber != null ||
      sugar != null ||
      sodium != null ||
      cholesterol != null ||
      saturatedFat != null ||
      transFat != null ||
      potassium != null;

  List<MicronutrientStats> get allStats => [
        if (fiber != null) fiber!,
        if (sugar != null) sugar!,
        if (sodium != null) sodium!,
        if (cholesterol != null) cholesterol!,
        if (saturatedFat != null) saturatedFat!,
        if (transFat != null) transFat!,
        if (unsaturatedFat != null) unsaturatedFat!,
        if (monounsaturatedFat != null) monounsaturatedFat!,
        if (polyunsaturatedFat != null) polyunsaturatedFat!,
        if (potassium != null) potassium!,
      ];
}
```

---

### 5.2 อัปเดต micronutrient_stats_provider

**ไฟล์:** `lib/features/health/providers/micronutrient_stats_provider.dart`

**เปลี่ยนทั้งไฟล์เป็น:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/fda_daily_values.dart';
import '../models/micronutrient_stats.dart';
import '../models/food_entry.dart';

/// Provider for micronutrient statistics
final micronutrientStatsProvider =
    FutureProvider.autoDispose<MicronutrientStatistics>((ref) async {
  final last30Days = await _getFoodEntriesForPeriod(30);
  final last7Days = await _getFoodEntriesForPeriod(7);
  final last365Days = await _getFoodEntriesForPeriod(365);

  return MicronutrientStatistics(
    fiber: _calculateStats(
      name: 'Fiber', key: 'fiber', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.fiber ?? 0,
      fdaDv: FdaDailyValues.fiber,
    ),
    sugar: _calculateStats(
      name: 'Sugar', key: 'sugar', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.sugar ?? 0,
      fdaDv: FdaDailyValues.sugar,
    ),
    sodium: _calculateStats(
      name: 'Sodium', key: 'sodium', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.sodium ?? 0,
      fdaDv: FdaDailyValues.sodium,
    ),
    cholesterol: _calculateStats(
      name: 'Cholesterol', key: 'cholesterol', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.cholesterol ?? 0,
      fdaDv: FdaDailyValues.cholesterol,
    ),
    saturatedFat: _calculateStats(
      name: 'Saturated Fat', key: 'saturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.saturatedFat ?? 0,
      fdaDv: FdaDailyValues.saturatedFat,
    ),
    transFat: _calculateStats(
      name: 'Trans Fat', key: 'transFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.transFat ?? 0,
      fdaDv: FdaDailyValues.transFat,
    ),
    unsaturatedFat: _calculateStats(
      name: 'Unsaturated Fat', key: 'unsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.unsaturatedFat ?? 0,
    ),
    monounsaturatedFat: _calculateStats(
      name: 'Mono Fat', key: 'monounsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.monounsaturatedFat ?? 0,
    ),
    polyunsaturatedFat: _calculateStats(
      name: 'Poly Fat', key: 'polyunsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.polyunsaturatedFat ?? 0,
    ),
    potassium: _calculateStats(
      name: 'Potassium', key: 'potassium', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.potassium ?? 0,
      fdaDv: FdaDailyValues.potassium,
    ),
  );
});

Future<List<FoodEntry>> _getFoodEntriesForPeriod(int days) async {
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: days));
  return await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startDate, now)
      .isDeletedEqualTo(false)
      .sortByTimestampDesc()
      .findAll();
}

MicronutrientStats? _calculateStats({
  required String name,
  required String key,
  required String unit,
  required List<FoodEntry> entries,
  required List<FoodEntry> dailyEntries,
  required List<FoodEntry> weeklyEntries,
  required double Function(FoodEntry) extractor,
  double? fdaDv,
}) {
  if (entries.isEmpty) return null;

  final dailyValueMap = <DateTime, double>{};
  for (final entry in dailyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year, entry.timestamp.month, entry.timestamp.day,
    );
    dailyValueMap[dateOnly] = (dailyValueMap[dateOnly] ?? 0) + extractor(entry);
  }

  final dailyValues = dailyValueMap.entries
      .map((e) => DailyValue(date: e.key, value: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final totalValue = entries.fold<double>(0, (sum, e) => sum + extractor(e));
  final daysWithData = dailyValueMap.length;
  final dailyAverage = daysWithData > 0 ? totalValue / daysWithData : 0.0;

  final weeklyValueMap = <DateTime, double>{};
  for (final entry in weeklyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year, entry.timestamp.month, entry.timestamp.day,
    );
    weeklyValueMap[dateOnly] = (weeklyValueMap[dateOnly] ?? 0) + extractor(entry);
  }
  final weeklyAverage = weeklyValueMap.isNotEmpty
      ? weeklyValueMap.values.reduce((a, b) => a + b) / weeklyValueMap.length
      : 0.0;

  final monthlyValueMap = <String, double>{};
  for (final entry in entries) {
    final monthKey = '${entry.timestamp.year}-${entry.timestamp.month}';
    monthlyValueMap[monthKey] = (monthlyValueMap[monthKey] ?? 0) + extractor(entry);
  }
  final monthlyAverage = monthlyValueMap.isNotEmpty
      ? monthlyValueMap.values.reduce((a, b) => a + b) / monthlyValueMap.length
      : 0.0;

  return MicronutrientStats(
    name: name,
    key: key,
    unit: unit,
    dailyAverage: dailyAverage,
    weeklyAverage: weeklyAverage,
    monthlyAverage: monthlyAverage,
    yearlyAverage: dailyAverage,
    fdaDailyValue: fdaDv,
    dailyValues: dailyValues,
  );
}
```

---

### 5.3 Redesign Summary Screen

**ไฟล์:** `lib/features/health/presentation/today_summary_dashboard_screen.dart`

**เปลี่ยนทั้งไฟล์** — ด้านล่างคือ scaffold ของ UI ใหม่ ให้สร้างตาม layout นี้:

```
┌─────────────────────────────────────────────────────────────┐
│  Nutrition Summary                                     [x]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ◀  Today, Feb 27, 2026  ▶     [Day|Week|Month|Year|All]   │
│                                                             │
│  ─── Macro Distribution ───                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                                                      │   │
│  │      🍩 Donut Chart (P 30% | C 45% | F 25%)        │   │
│  │      Center: total kcal eaten / goal                 │   │
│  │                                                      │   │
│  │   P ████████░░░░ 72g / 120g                          │   │
│  │   C ████████████░ 245g / 250g                        │   │
│  │   F ██████░░░░░░ 45g / 65g                           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ─── Calorie Trend ───                                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │   📈 Line Chart (fl_chart)                           │   │
│  │   - Blue line: actual calories per day               │   │
│  │   - Dashed red line: goal (horizontal)               │   │
│  │   - X axis: dates                                    │   │
│  │   - Y axis: kcal                                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ─── Micronutrient Tracker ───                              │
│  ┌────────────┐  ┌────────────┐                             │
│  │ 🌾 Fiber   │  │ 🍬 Sugar   │                             │
│  │ 18g / 28g  │  │ 35g / 50g  │                             │
│  │ ██████░░░░ │  │ ████████░░ │                             │
│  │ 64% ⚠️     │  │ 70% ✅     │                             │
│  └────────────┘  └────────────┘                             │
│  ┌────────────┐  ┌────────────┐                             │
│  │ 🧂 Sodium  │  │ 💛 Chol.   │                             │
│  │ 1800/2300  │  │ 180/300    │                             │
│  │ ████████░░ │  │ ██████░░░░ │                             │
│  │ 78% ✅     │  │ 60% ✅     │                             │
│  └────────────┘  └────────────┘                             │
│  ┌────────────┐  ┌────────────┐                             │
│  │ 🫒 Sat.Fat │  │ 🚫 Trans   │                             │
│  │ 12g / 20g  │  │ 0.5g / 0g  │                             │
│  │ ██████░░░░ │  │ ██████████ │                             │
│  │ 60% ✅     │  │ ❌ OVER    │                             │
│  └────────────┘  └────────────┘                             │
│  ┌────────────┐                                             │
│  │ 🥬 Potass. │                                             │
│  │ 2100/4700  │                                             │
│  │ █████░░░░░ │                                             │
│  │ 45% ⚠️     │                                             │
│  └────────────┘                                             │
│                                                             │
│  ─── Fat Breakdown ───                                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Saturated   ████████░░░  12g                        │   │
│  │  Mono        ██████░░░░░  8g                         │   │
│  │  Poly        ████░░░░░░░  5g                         │   │
│  │  Trans       █░░░░░░░░░░  0.5g                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Design Requirements:

1. **Dark mode support** — ใช้ `Theme.of(context).brightness == Brightness.dark` ทุกที่
2. **ใช้ AppColors, AppSpacing, AppRadius** จาก `core/theme/`
3. **Period selector** — SegmentedButton หรือ ToggleButtons สำหรับ Day / Week / Month / Year / All
4. **Donut chart** — ใช้ `fl_chart` `PieChart` สำหรับ macro distribution
5. **Line chart** — ใช้ `fl_chart` `LineChart` สำหรับ calorie trend
6. **Micronutrient grid** — ใช้ `GridView.count(crossAxisCount: 2)` แต่ละ card มี:
   - Icon + ชื่อ nutrient
   - ค่าจริง / FDA DV
   - LinearProgressIndicator (สี)
   - % ของ FDA + status icon
7. **Color logic:**
   - **limitNutrients** (sugar, sodium, cholesterol, saturatedFat, transFat):
     - เขียว ✅: actual <= FDA DV
     - แดง ❌: actual > FDA DV
   - **targetNutrients** (fiber, potassium):
     - เขียว ✅: actual >= FDA DV
     - ส้ม ⚠️: actual < 80% ของ FDA DV
     - แดง ❌: actual < 50% ของ FDA DV
8. **Date navigation** — ใช้ pattern เดียวกับ `DailySummaryCard` (ลูกศรซ้าย/ขวา + tap เปิด DatePicker)
9. **Period เปลี่ยน** — เมื่อเลือก Week/Month/Year/All ให้แสดงค่าเฉลี่ยต่อวัน แทนค่ารวม

### Icon mapping สำหรับ micronutrient:

```dart
const micronutrientIcons = {
  'fiber': Icons.grass_rounded,
  'sugar': Icons.cake_rounded,
  'sodium': Icons.water_drop_rounded,
  'cholesterol': Icons.favorite_rounded,
  'saturatedFat': Icons.opacity_rounded,
  'transFat': Icons.block_rounded,
  'unsaturatedFat': Icons.local_dining_rounded,
  'monounsaturatedFat': Icons.local_dining_rounded,
  'polyunsaturatedFat': Icons.local_dining_rounded,
  'potassium': Icons.eco_rounded,
};
```

### Provider ที่ต้องใช้:

```dart
// ใช้ provider เดิม:
ref.watch(foodEntriesByDateProvider(date))   // สำหรับ Day mode
ref.watch(micronutrientStatsProvider)         // สำหรับ Week/Month/Year/All

// Profile สำหรับ macro goals:
ref.watch(profileNotifierProvider)
```

---

## Checklist

| # | Task | ไฟล์ | Status |
|---|------|------|--------|
| 1 | เพิ่ม field ใน FoodEntry | `food_entry.dart` | ☐ |
| 2 | รัน build_runner | terminal | ☐ |
| 3 | เพิ่ม field ใน NutritionData | `gemini_service.dart` | ☐ |
| 4 | อัปเดต 7 JSON prompts | `gemini_service.dart` | ☐ |
| 5 | อัปเดต prompt descriptions | `gemini_service.dart` | ☐ |
| 6 | อัปเดต applyResultToEntry | `batch_analysis_helper.dart` | ☐ |
| 7 | อัปเดต updateFromGeminiConfirmed | `health_provider.dart` | ☐ |
| 8 | อัปเดต writeFoodEntry | `health_sync_service.dart` | ☐ |
| 9 | อัปเดต updateFoodEntry | `health_sync_service.dart` | ☐ |
| 10 | อัปเดต _syncEntryToHealth | `health_provider.dart` | ☐ |
| 11 | สร้าง FDA constants | `fda_daily_values.dart` | ☐ |
| 12 | อัปเดต MicronutrientStats model | `micronutrient_stats.dart` | ☐ |
| 13 | อัปเดต micronutrient provider | `micronutrient_stats_provider.dart` | ☐ |
| 14 | Redesign summary screen | `today_summary_dashboard_screen.dart` | ☐ |
| 15 | Redesign micronutrient charts | `micronutrient_charts_section.dart` | ☐ |
| 16 | ทดสอบ AI analysis ได้ micro ครบ | manual test | ☐ |
| 17 | ทดสอบ Health sync ส่ง micro | manual test | ☐ |
| 18 | ทดสอบ Summary screen ทุก period | manual test | ☐ |

---

## หมายเหตุ

- **ห้ามเปลี่ยนชื่อ field** ที่กำหนดไว้ (เช่น `saturatedFat`, `transFat`) — ต้องตรงกับ JSON key ที่ AI ส่งกลับ
- **ห้ามลบ field เดิม** ที่มีอยู่ — เพิ่มเท่านั้น
- **ทุก widget ต้อง support dark mode**
- **ใช้ AppColors, AppSpacing, AppRadius** จาก `lib/core/theme/` เท่านั้น ห้าม hardcode สี
- **ห้ามเพิ่ม package ใหม่** — ใช้ `fl_chart` ที่มีอยู่แล้ว
