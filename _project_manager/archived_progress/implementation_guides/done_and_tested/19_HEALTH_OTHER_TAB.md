# Step 19: Health Other Tab (น้ำ, ยา, Biometrics)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 16 (Workout)
> **อ้างอิง:** `_project_manager/HEALTH_FEATURE_DESIGN.md`

---

## 🎯 เป้าหมาย

- ติดตามการดื่มน้ำ (แก้ว/ลิตร)
- บันทึกยา/วิตามิน
- บันทึก Biometrics (น้ำหนัก, ความดัน, น้ำตาล)
- แสดงข้อมูลการนอน (ถ้ามี)

---

## สิ่งที่ต้องทำ

1. สร้าง OtherHealthEntry Model
2. สร้าง Medicine Model
3. สร้าง Other Health Provider
4. สร้าง Water Tracking Widget
5. สร้าง Medicine List Widget
6. สร้าง Biometrics Widget
7. สร้าง Other Tab UI
8. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง OtherHealthEntry Model

**สร้างไฟล์:** `lib/features/health/models/other_health_entry.dart`

```dart
import 'package:isar/isar.dart';

part 'other_health_entry.g.dart';

@collection
class OtherHealthEntry {
  Id id = Isar.autoIncrement;

  @enumerated
  late HealthEntryType entryType;

  late DateTime timestamp;

  // ============================================
  // WATER
  // ============================================
  double? waterMl;

  // ============================================
  // SUPPLEMENT/MEDICINE
  // ============================================
  String? medicineName;
  double? dosage;
  String? dosageUnit;  // mg, ml, IU, เม็ด
  bool taken = false;

  // ============================================
  // BIOMETRICS
  // ============================================
  double? weightKg;
  double? bodyFatPercent;
  int? systolicBP;      // ความดันตัวบน
  int? diastolicBP;     // ความดันตัวล่าง
  int? heartRate;
  int? bloodSugar;      // น้ำตาลในเลือด mg/dL

  // ============================================
  // SLEEP
  // ============================================
  int? sleepMinutes;
  int? deepSleepMinutes;
  int? remSleepMinutes;

  // ============================================
  // METADATA
  // ============================================
  String? notes;
  String? source;  // 'manual', 'health_connect'

  late DateTime createdAt;
}

enum HealthEntryType {
  water,
  supplement,
  medicine,
  weight,
  bodyFat,
  bloodPressure,
  heartRate,
  bloodSugar,
  sleep,
}

extension HealthEntryTypeExtension on HealthEntryType {
  String get emoji {
    switch (this) {
      case HealthEntryType.water: return '💧';
      case HealthEntryType.supplement: return '💊';
      case HealthEntryType.medicine: return '💊';
      case HealthEntryType.weight: return '⚖️';
      case HealthEntryType.bodyFat: return '📊';
      case HealthEntryType.bloodPressure: return '🩸';
      case HealthEntryType.heartRate: return '❤️';
      case HealthEntryType.bloodSugar: return '🍬';
      case HealthEntryType.sleep: return '😴';
    }
  }

  String get displayName {
    switch (this) {
      case HealthEntryType.water: return 'น้ำ';
      case HealthEntryType.supplement: return 'วิตามิน';
      case HealthEntryType.medicine: return 'ยา';
      case HealthEntryType.weight: return 'น้ำหนัก';
      case HealthEntryType.bodyFat: return 'ไขมัน';
      case HealthEntryType.bloodPressure: return 'ความดัน';
      case HealthEntryType.heartRate: return 'ชีพจร';
      case HealthEntryType.bloodSugar: return 'น้ำตาล';
      case HealthEntryType.sleep: return 'การนอน';
    }
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Medicine Model

**สร้างไฟล์:** `lib/features/health/models/medicine.dart`

```dart
import 'package:isar/isar.dart';

part 'medicine.g.dart';

/// รายการยา/วิตามินที่ต้องกินประจำ
@collection
class Medicine {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  String emoji = '💊';

  /// โดส
  double? dosage;
  String? dosageUnit;  // mg, ml, IU, เม็ด

  /// กี่ครั้งต่อวัน
  int timesPerDay = 1;

  /// เวลาที่ต้องกิน (JSON array of times)
  String? scheduleTimes;  // ["08:00", "20:00"]

  /// กินหลังอาหาร?
  bool afterMeal = false;

  bool isActive = true;

  late DateTime createdAt;
  DateTime? updatedAt;

  // ============================================
  // COMPUTED
  // ============================================

  @ignore
  List<String> get scheduleTimesList {
    if (scheduleTimes == null) return [];
    try {
      // Simple JSON parse
      final str = scheduleTimes!.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      return str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
```

---

## ขั้นตอนที่ 3: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม imports:**

```dart
import '../../features/health/models/other_health_entry.dart';
import '../../features/health/models/medicine.dart';
```

**เพิ่มใน schemas:**

```dart
OtherHealthEntrySchema,
MedicineSchema,
```

**เพิ่ม getters:**

```dart
static IsarCollection<OtherHealthEntry> get otherHealthEntries => _isar!.otherHealthEntrys;
static IsarCollection<Medicine> get medicines => _isar!.medicines;
```

---

## ขั้นตอนที่ 4: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 5: สร้าง Other Health Provider

**สร้างไฟล์:** `lib/features/health/providers/other_health_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/other_health_entry.dart';
import '../models/medicine.dart';

// ============================================
// TODAY'S WATER
// ============================================

final todayWaterProvider = FutureProvider<WaterData>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final entries = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.water)
      .timestampBetween(startOfDay, endOfDay)
      .findAll();

  final totalMl = entries.fold<double>(0, (sum, e) => sum + (e.waterMl ?? 0));

  return WaterData(
    totalMl: totalMl,
    target: 2500, // TODO: ดึงจาก UserProfile
    glasses: (totalMl / 250).round(), // 1 แก้ว = 250ml
  );
});

class WaterData {
  final double totalMl;
  final double target;
  final int glasses;

  WaterData({
    required this.totalMl,
    required this.target,
    required this.glasses,
  });

  double get percent => target > 0 ? (totalMl / target * 100).clamp(0, 100) : 0;
  double get liters => totalMl / 1000;
}

// ============================================
// TODAY'S MEDICINES
// ============================================

final todayMedicinesProvider = FutureProvider<List<MedicineStatus>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // Get all active medicines
  final medicines = await DatabaseService.medicines
      .filter()
      .isActiveEqualTo(true)
      .findAll();

  // Get today's taken entries
  final takenEntries = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.medicine)
      .timestampBetween(startOfDay, endOfDay)
      .takenEqualTo(true)
      .findAll();

  final takenNames = takenEntries.map((e) => e.medicineName).toSet();

  return medicines.map((med) {
    return MedicineStatus(
      medicine: med,
      takenToday: takenNames.contains(med.name),
    );
  }).toList();
});

class MedicineStatus {
  final Medicine medicine;
  final bool takenToday;

  MedicineStatus({
    required this.medicine,
    required this.takenToday,
  });
}

// ============================================
// LATEST BIOMETRICS
// ============================================

final latestBiometricsProvider = FutureProvider<BiometricsData>((ref) async {
  final weight = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.weight)
      .sortByTimestampDesc()
      .findFirst();

  final bp = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.bloodPressure)
      .sortByTimestampDesc()
      .findFirst();

  final sugar = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.bloodSugar)
      .sortByTimestampDesc()
      .findFirst();

  final hr = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.heartRate)
      .sortByTimestampDesc()
      .findFirst();

  return BiometricsData(
    weight: weight?.weightKg,
    weightDate: weight?.timestamp,
    systolic: bp?.systolicBP,
    diastolic: bp?.diastolicBP,
    bpDate: bp?.timestamp,
    bloodSugar: sugar?.bloodSugar,
    sugarDate: sugar?.timestamp,
    heartRate: hr?.heartRate,
    hrDate: hr?.timestamp,
  );
});

class BiometricsData {
  final double? weight;
  final DateTime? weightDate;
  final int? systolic;
  final int? diastolic;
  final DateTime? bpDate;
  final int? bloodSugar;
  final DateTime? sugarDate;
  final int? heartRate;
  final DateTime? hrDate;

  BiometricsData({
    this.weight,
    this.weightDate,
    this.systolic,
    this.diastolic,
    this.bpDate,
    this.bloodSugar,
    this.sugarDate,
    this.heartRate,
    this.hrDate,
  });

  String get bpString => systolic != null && diastolic != null 
      ? '$systolic/$diastolic' 
      : '-';
}

// ============================================
// NOTIFIER
// ============================================

class OtherHealthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  OtherHealthNotifier(this.ref) : super(const AsyncValue.data(null));

  /// บันทึกน้ำ
  Future<void> logWater(double ml) async {
    final entry = OtherHealthEntry()
      ..entryType = HealthEntryType.water
      ..waterMl = ml
      ..timestamp = DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.otherHealthEntries.put(entry);
    });

    ref.invalidate(todayWaterProvider);
  }

  /// บันทึกกินยา
  Future<void> logMedicine(String name, {double? dosage, String? unit}) async {
    final entry = OtherHealthEntry()
      ..entryType = HealthEntryType.medicine
      ..medicineName = name
      ..dosage = dosage
      ..dosageUnit = unit
      ..taken = true
      ..timestamp = DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.otherHealthEntries.put(entry);
    });

    ref.invalidate(todayMedicinesProvider);
  }

  /// บันทึกน้ำหนัก
  Future<void> logWeight(double kg) async {
    final entry = OtherHealthEntry()
      ..entryType = HealthEntryType.weight
      ..weightKg = kg
      ..timestamp = DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.otherHealthEntries.put(entry);
    });

    ref.invalidate(latestBiometricsProvider);
  }

  /// บันทึกความดัน
  Future<void> logBloodPressure(int systolic, int diastolic) async {
    final entry = OtherHealthEntry()
      ..entryType = HealthEntryType.bloodPressure
      ..systolicBP = systolic
      ..diastolicBP = diastolic
      ..timestamp = DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.otherHealthEntries.put(entry);
    });

    ref.invalidate(latestBiometricsProvider);
  }

  /// บันทึกน้ำตาล
  Future<void> logBloodSugar(int value) async {
    final entry = OtherHealthEntry()
      ..entryType = HealthEntryType.bloodSugar
      ..bloodSugar = value
      ..timestamp = DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.otherHealthEntries.put(entry);
    });

    ref.invalidate(latestBiometricsProvider);
  }

  /// เพิ่มยาใหม่
  Future<Medicine> addMedicine({
    required String name,
    double? dosage,
    String? dosageUnit,
    int timesPerDay = 1,
    List<String>? times,
  }) async {
    final medicine = Medicine()
      ..name = name
      ..dosage = dosage
      ..dosageUnit = dosageUnit
      ..timesPerDay = timesPerDay
      ..scheduleTimes = times != null ? '["${times.join('","')}"]' : null
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.medicines.put(medicine);
    });

    ref.invalidate(todayMedicinesProvider);
    return medicine;
  }

  /// ลบยา
  Future<void> deleteMedicine(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.medicines.delete(id);
    });

    ref.invalidate(todayMedicinesProvider);
  }
}

final otherHealthNotifierProvider =
    StateNotifierProvider<OtherHealthNotifier, AsyncValue<void>>((ref) {
  return OtherHealthNotifier(ref);
});
```

---

## ขั้นตอนที่ 6: สร้าง Other Tab UI

**สร้างไฟล์:** `lib/features/health/presentation/health_other_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/other_health_provider.dart';

class HealthOtherTab extends ConsumerWidget {
  const HealthOtherTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Water Section
        SliverToBoxAdapter(
          child: _buildWaterSection(context, ref),
        ),

        // Medicine Section
        SliverToBoxAdapter(
          child: _buildMedicineSection(context, ref),
        ),

        // Biometrics Section
        SliverToBoxAdapter(
          child: _buildBiometricsSection(context, ref),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildWaterSection(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: waterAsync.when(
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
          data: (water) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'น้ำวันนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${water.liters.toStringAsFixed(1)} / ${(water.target / 1000).toStringAsFixed(1)} ลิตร',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: water.percent / 100,
                backgroundColor: Colors.blue.shade100,
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                minHeight: 12,
              ),
              const SizedBox(height: 8),
              Text(
                '${water.percent.toStringAsFixed(0)}% • ${water.glasses} แก้ว',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton(context, ref, 250, '1 แก้ว'),
                  _buildWaterButton(context, ref, 500, '2 แก้ว'),
                  _buildWaterButton(context, ref, 1000, '1 ลิตร'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterButton(BuildContext context, WidgetRef ref, double ml, String label) {
    return OutlinedButton(
      onPressed: () async {
        await ref.read(otherHealthNotifierProvider.notifier).logWater(ml);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่ม $label แล้ว 💧')),
          );
        }
      },
      child: Text('+$label'),
    );
  }

  Widget _buildMedicineSection(BuildContext context, WidgetRef ref) {
    final medAsync = ref.watch(todayMedicinesProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💊', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Text(
                  'ยา/วิตามิน วันนี้',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('เพิ่ม'),
                  onPressed: () => _showAddMedicineDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            medAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (meds) {
                if (meds.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'ยังไม่มีรายการยา\nกด + เพื่อเพิ่มยาที่ต้องกินประจำ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Column(
                  children: meds.map((status) => _buildMedicineItem(context, ref, status)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(BuildContext context, WidgetRef ref, MedicineStatus status) {
    final med = status.medicine;
    
    return ListTile(
      leading: Checkbox(
        value: status.takenToday,
        onChanged: status.takenToday
            ? null
            : (value) async {
                if (value == true) {
                  await ref.read(otherHealthNotifierProvider.notifier).logMedicine(
                        med.name,
                        dosage: med.dosage,
                        unit: med.dosageUnit,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('กิน ${med.name} แล้ว ✅')),
                    );
                  }
                }
              },
      ),
      title: Text(
        med.name,
        style: TextStyle(
          decoration: status.takenToday ? TextDecoration.lineThrough : null,
          color: status.takenToday ? AppColors.textSecondary : null,
        ),
      ),
      subtitle: med.dosage != null
          ? Text('${med.dosage} ${med.dosageUnit ?? 'mg'}')
          : null,
      trailing: status.takenToday
          ? const Icon(Icons.check_circle, color: Colors.green)
          : Text(
              med.scheduleTimesList.isNotEmpty 
                  ? med.scheduleTimesList.first 
                  : '',
              style: TextStyle(color: AppColors.textSecondary),
            ),
    );
  }

  Widget _buildBiometricsSection(BuildContext context, WidgetRef ref) {
    final bioAsync = ref.watch(latestBiometricsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Biometrics ล่าสุด',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            bioAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (bio) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBioCard(
                          context, ref,
                          '⚖️',
                          'น้ำหนัก',
                          bio.weight != null ? '${bio.weight} kg' : '-',
                          bio.weightDate,
                          () => _showWeightDialog(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBioCard(
                          context, ref,
                          '🩸',
                          'ความดัน',
                          bio.bpString,
                          bio.bpDate,
                          () => _showBPDialog(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBioCard(
                          context, ref,
                          '❤️',
                          'ชีพจร',
                          bio.heartRate != null ? '${bio.heartRate} bpm' : '-',
                          bio.hrDate,
                          () => _showHRDialog(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBioCard(
                          context, ref,
                          '🍬',
                          'น้ำตาล',
                          bio.bloodSugar != null ? '${bio.bloodSugar} mg/dL' : '-',
                          bio.sugarDate,
                          () => _showSugarDialog(context, ref),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard(
    BuildContext context,
    WidgetRef ref,
    String emoji,
    String label,
    String value,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (date != null)
              Text(
                DateFormat('d MMM', 'th').format(date),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // DIALOGS
  // ============================================

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    String dosageUnit = 'mg';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💊 เพิ่มยา/วิตามิน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อยา',
                hintText: 'เช่น วิตามิน C',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: dosageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'โดส',
                      hintText: '1000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: dosageUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ['mg', 'ml', 'IU', 'เม็ด'].map((u) {
                      return DropdownMenuItem(value: u, child: Text(u));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) dosageUnit = v;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              
              await ref.read(otherHealthNotifierProvider.notifier).addMedicine(
                    name: nameController.text,
                    dosage: double.tryParse(dosageController.text),
                    dosageUnit: dosageUnit,
                  );
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚖️ บันทึกน้ำหนัก'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'น้ำหนัก (kg)',
            hintText: '70.5',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null) return;
              
              await ref.read(otherHealthNotifierProvider.notifier).logWeight(value);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showBPDialog(BuildContext context, WidgetRef ref) {
    final sysController = TextEditingController();
    final diaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🩸 บันทึกความดัน'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: sysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ตัวบน',
                  hintText: '120',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('/'),
            ),
            Expanded(
              child: TextField(
                controller: diaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ตัวล่าง',
                  hintText: '80',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final sys = int.tryParse(sysController.text);
              final dia = int.tryParse(diaController.text);
              if (sys == null || dia == null) return;
              
              await ref.read(otherHealthNotifierProvider.notifier).logBloodPressure(sys, dia);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showHRDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❤️ บันทึกชีพจร'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ชีพจร (bpm)',
            hintText: '72',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value == null) return;
              
              // TODO: Add logHeartRate method
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showSugarDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍬 บันทึกน้ำตาล'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'น้ำตาล (mg/dL)',
            hintText: '100',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value == null) return;
              
              await ref.read(otherHealthNotifierProvider.notifier).logBloodSugar(value);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 7: อัปเดต Health Page

**แก้ไขไฟล์:** `lib/features/health/presentation/health_page.dart`

**เพิ่ม import และ tab:**

```dart
import 'health_other_tab.dart';

// แก้ไข TabBar ให้มี Other tab
TabBar(
  controller: _tabController,
  tabs: const [
    Tab(text: 'Timeline'),
    Tab(text: 'Diet'),
    Tab(text: 'Workout'),
    Tab(text: 'Other'),    // เพิ่ม
  ],
),

// TabBarView
TabBarView(
  controller: _tabController,
  children: const [
    HealthTimelineTab(),
    HealthDietTab(),
    HealthWorkoutTab(),
    HealthOtherTab(),      // เพิ่ม
  ],
),
```

**อย่าลืมแก้ `TabController` length เป็น 4:**

```dart
_tabController = TabController(length: 4, vsync: this);
```

---

## ขั้นตอนที่ 8: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Health → Other tab**
2. **เพิ่มน้ำ** - กดปุ่ม +1 แก้ว, +2 แก้ว
3. **เพิ่มยา** - กด + เพิ่มยาใหม่
4. **กินยา** - กด checkbox
5. **บันทึก Biometrics** - กดที่ card แล้วใส่ค่า

---

## ✅ Checklist

- [ ] สร้าง `other_health_entry.dart` model แล้ว
- [ ] สร้าง `medicine.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `other_health_provider.dart` แล้ว
- [ ] สร้าง `health_other_tab.dart` แล้ว
- [ ] อัปเดต `health_page.dart` แล้ว (4 tabs)
- [ ] ทดสอบบันทึกน้ำได้
- [ ] ทดสอบเพิ่ม/กินยาได้
- [ ] ทดสอบบันทึก Biometrics ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/health/
├── models/
│   ├── other_health_entry.dart    ← NEW
│   ├── other_health_entry.g.dart  ← GENERATED
│   ├── medicine.dart              ← NEW
│   └── medicine.g.dart            ← GENERATED
├── providers/
│   └── other_health_provider.dart ← NEW
└── presentation/
    ├── health_page.dart           ← UPDATED (4 tabs)
    └── health_other_tab.dart      ← NEW
```

---

## ขั้นตอนถัดไป

ไป **Step 20: Health Lab Results** เพื่อสร้างระบบบันทึกผลตรวจสุขภาพ
