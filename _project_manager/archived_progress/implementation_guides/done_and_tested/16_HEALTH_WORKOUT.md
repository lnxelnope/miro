# Step 16: Health Workout Tracking

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ปานกลาง-ยาก
> **ต้องทำก่อน:** Step 15 (Habits)

---

## 🎯 เป้าหมาย

- สร้างและจัดการโปรแกรม Workout
- บันทึก Workout Session
- แสดงสถิติการออกกำลังกาย
- ติดตามความก้าวหน้า

---

## สิ่งที่ต้องทำ

1. ตรวจสอบ Models ที่มีอยู่
2. สร้าง Workout Provider
3. สร้าง Workout Tab UI
4. สร้าง Workout Session Screen
5. สร้าง Workout Program Detail
6. เชื่อมต่อกับ Chat AI
7. ทดสอบ

---

## ขั้นตอนที่ 1: ตรวจสอบ Models ที่มีอยู่

**ไฟล์ที่ควรมีแล้ว (จาก Step 01):**

- `lib/features/health/models/workout_program.dart`
- `lib/features/health/models/workout_entry.dart`

**ถ้ายังไม่มี ให้สร้างตามนี้:**

### workout_program.dart

**สร้างไฟล์:** `lib/features/health/models/workout_program.dart`

```dart
import 'package:isar/isar.dart';

part 'workout_program.g.dart';

@collection
class WorkoutProgram {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  String emoji = '💪';

  @enumerated
  WorkoutType type = WorkoutType.strength;

  @enumerated
  WorkoutLevel level = WorkoutLevel.intermediate;

  /// จำนวนวันต่อสัปดาห์
  int daysPerWeek = 3;

  /// ระยะเวลาโดยเฉลี่ย (นาที)
  int durationMinutes = 45;

  /// รายการ Exercises (เก็บเป็น JSON string)
  String? exercisesJson;

  bool isActive = false;
  bool isArchived = false;

  late DateTime createdAt;
  DateTime? updatedAt;

  // Computed
  @ignore
  int totalSessions = 0;

  @ignore
  int thisWeekSessions = 0;
}

enum WorkoutType {
  strength,   // ยกน้ำหนัก
  cardio,     // คาร์ดิโอ
  hiit,       // HIIT
  yoga,       // โยคะ
  flexibility, // ยืดเหยียด
  sports,     // กีฬา
  mixed,      // ผสม
}

extension WorkoutTypeExtension on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.strength: return 'ยกน้ำหนัก';
      case WorkoutType.cardio: return 'คาร์ดิโอ';
      case WorkoutType.hiit: return 'HIIT';
      case WorkoutType.yoga: return 'โยคะ';
      case WorkoutType.flexibility: return 'ยืดเหยียด';
      case WorkoutType.sports: return 'กีฬา';
      case WorkoutType.mixed: return 'ผสม';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutType.strength: return '🏋️';
      case WorkoutType.cardio: return '🏃';
      case WorkoutType.hiit: return '⚡';
      case WorkoutType.yoga: return '🧘';
      case WorkoutType.flexibility: return '🤸';
      case WorkoutType.sports: return '⚽';
      case WorkoutType.mixed: return '💪';
    }
  }
}

enum WorkoutLevel {
  beginner,
  intermediate,
  advanced,
}

extension WorkoutLevelExtension on WorkoutLevel {
  String get displayName {
    switch (this) {
      case WorkoutLevel.beginner: return 'เริ่มต้น';
      case WorkoutLevel.intermediate: return 'ปานกลาง';
      case WorkoutLevel.advanced: return 'ยาก';
    }
  }
}
```

### workout_entry.dart

**สร้าง/ตรวจสอบไฟล์:** `lib/features/health/models/workout_entry.dart`

```dart
import 'package:isar/isar.dart';

part 'workout_entry.g.dart';

@collection
class WorkoutEntry {
  Id id = Isar.autoIncrement;

  /// อ้างอิง WorkoutProgram (optional)
  int? programId;

  late String name;
  String? notes;

  @enumerated
  WorkoutType workoutType = WorkoutType.strength;

  /// ระยะเวลา (นาที)
  int durationMinutes = 0;

  /// แคลอรี่ที่เผาผลาญ (ประมาณ)
  int caloriesBurned = 0;

  /// รายละเอียด exercises (JSON)
  String? exercisesJson;

  /// ความเข้มข้น 1-10
  int intensity = 5;

  /// ความรู้สึกหลังออกกำลัง
  @enumerated
  WorkoutFeeling feeling = WorkoutFeeling.good;

  late DateTime date;
  DateTime? startTime;
  DateTime? endTime;

  late DateTime createdAt;
}

enum WorkoutFeeling {
  exhausted,  // หมดแรง
  tired,      // เหนื่อย
  good,       // ดี
  energized,  // มีพลัง
  amazing,    // ยอดเยี่ยม
}

extension WorkoutFeelingExtension on WorkoutFeeling {
  String get emoji {
    switch (this) {
      case WorkoutFeeling.exhausted: return '😵';
      case WorkoutFeeling.tired: return '😓';
      case WorkoutFeeling.good: return '😊';
      case WorkoutFeeling.energized: return '💪';
      case WorkoutFeeling.amazing: return '🔥';
    }
  }

  String get displayName {
    switch (this) {
      case WorkoutFeeling.exhausted: return 'หมดแรง';
      case WorkoutFeeling.tired: return 'เหนื่อย';
      case WorkoutFeeling.good: return 'ดี';
      case WorkoutFeeling.energized: return 'มีพลัง';
      case WorkoutFeeling.amazing: return 'ยอดเยี่ยม';
    }
  }
}

// Re-export WorkoutType from workout_program.dart
export 'workout_program.dart' show WorkoutType, WorkoutTypeExtension;
```

---

## ขั้นตอนที่ 2: อัปเดต Database Service (ถ้าจำเป็น)

**ตรวจสอบว่า `database_service.dart` มี schemas และ getters แล้ว:**

```dart
// ใน schemas list
WorkoutProgramSchema,
WorkoutEntrySchema,

// Getters
static IsarCollection<WorkoutProgram> get workoutPrograms => _isar!.workoutPrograms;
static IsarCollection<WorkoutEntry> get workoutEntries => _isar!.workoutEntries;
```

---

## ขั้นตอนที่ 3: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 4: สร้าง Workout Provider

**สร้างไฟล์:** `lib/features/health/providers/workout_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/workout_program.dart';
import '../models/workout_entry.dart';

// ============================================
// WORKOUT PROGRAMS PROVIDERS
// ============================================

/// Provider สำหรับ WorkoutPrograms ทั้งหมด
final workoutProgramsProvider = FutureProvider<List<WorkoutProgram>>((ref) async {
  final programs = await DatabaseService.workoutPrograms
      .filter()
      .isArchivedEqualTo(false)
      .sortByIsActiveDesc()
      .thenByCreatedAtDesc()
      .findAll();

  // Load session counts
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  for (final program in programs) {
    final sessions = await DatabaseService.workoutEntries
        .filter()
        .programIdEqualTo(program.id)
        .findAll();

    program.totalSessions = sessions.length;
    program.thisWeekSessions = sessions
        .where((s) => s.date.isAfter(weekStart))
        .length;
  }

  return programs;
});

/// Provider สำหรับ Active Program
final activeProgramProvider = FutureProvider<WorkoutProgram?>((ref) async {
  return await DatabaseService.workoutPrograms
      .filter()
      .isActiveEqualTo(true)
      .isArchivedEqualTo(false)
      .findFirst();
});

// ============================================
// WORKOUT ENTRIES PROVIDERS
// ============================================

/// Provider สำหรับ Workout Entries วันนี้
final todayWorkoutsProvider = FutureProvider<List<WorkoutEntry>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return await DatabaseService.workoutEntries
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .sortByDateDesc()
      .findAll();
});

/// Provider สำหรับ Workout Entries สัปดาห์นี้
final weekWorkoutsProvider = FutureProvider<List<WorkoutEntry>>((ref) async {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  return await DatabaseService.workoutEntries
      .filter()
      .dateGreaterThan(weekStart)
      .sortByDateDesc()
      .findAll();
});

/// Provider สำหรับ Workout Stats
final workoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final monthStart = DateTime(now.year, now.month, 1);

  final allEntries = await DatabaseService.workoutEntries.where().findAll();
  final weekEntries = allEntries.where((e) => e.date.isAfter(weekStart)).toList();
  final monthEntries = allEntries.where((e) => e.date.isAfter(monthStart)).toList();

  return WorkoutStats(
    totalWorkouts: allEntries.length,
    thisWeek: weekEntries.length,
    thisMonth: monthEntries.length,
    totalMinutes: allEntries.fold(0, (sum, e) => sum + e.durationMinutes),
    totalCalories: allEntries.fold(0, (sum, e) => sum + e.caloriesBurned),
    weekMinutes: weekEntries.fold(0, (sum, e) => sum + e.durationMinutes),
    weekCalories: weekEntries.fold(0, (sum, e) => sum + e.caloriesBurned),
  );
});

class WorkoutStats {
  final int totalWorkouts;
  final int thisWeek;
  final int thisMonth;
  final int totalMinutes;
  final int totalCalories;
  final int weekMinutes;
  final int weekCalories;

  WorkoutStats({
    required this.totalWorkouts,
    required this.thisWeek,
    required this.thisMonth,
    required this.totalMinutes,
    required this.totalCalories,
    required this.weekMinutes,
    required this.weekCalories,
  });
}

// ============================================
// WORKOUT NOTIFIER
// ============================================

class WorkoutNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  WorkoutNotifier(this.ref) : super(const AsyncValue.data(null));

  /// สร้าง Workout Program
  Future<WorkoutProgram> createProgram({
    required String name,
    String? description,
    WorkoutType type = WorkoutType.strength,
    WorkoutLevel level = WorkoutLevel.intermediate,
    int daysPerWeek = 3,
    int durationMinutes = 45,
  }) async {
    final program = WorkoutProgram()
      ..name = name
      ..description = description
      ..type = type
      ..level = level
      ..daysPerWeek = daysPerWeek
      ..durationMinutes = durationMinutes
      ..emoji = type.emoji
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutPrograms.put(program);
    });

    ref.invalidate(workoutProgramsProvider);
    return program;
  }

  /// ตั้ง Active Program
  Future<void> setActiveProgram(int programId) async {
    await DatabaseService.isar.writeTxn(() async {
      // Deactivate all
      final programs = await DatabaseService.workoutPrograms.where().findAll();
      for (final p in programs) {
        if (p.isActive) {
          p.isActive = false;
          await DatabaseService.workoutPrograms.put(p);
        }
      }

      // Activate selected
      final program = await DatabaseService.workoutPrograms.get(programId);
      if (program != null) {
        program.isActive = true;
        await DatabaseService.workoutPrograms.put(program);
      }
    });

    ref.invalidate(workoutProgramsProvider);
    ref.invalidate(activeProgramProvider);
  }

  /// บันทึก Workout Entry
  Future<WorkoutEntry> logWorkout({
    int? programId,
    required String name,
    required WorkoutType type,
    required int durationMinutes,
    int? caloriesBurned,
    int intensity = 5,
    WorkoutFeeling feeling = WorkoutFeeling.good,
    String? notes,
    DateTime? date,
  }) async {
    // ประมาณแคลอรี่ถ้าไม่ระบุ
    final calories = caloriesBurned ?? _estimateCalories(type, durationMinutes, intensity);

    final entry = WorkoutEntry()
      ..programId = programId
      ..name = name
      ..workoutType = type
      ..durationMinutes = durationMinutes
      ..caloriesBurned = calories
      ..intensity = intensity
      ..feeling = feeling
      ..notes = notes
      ..date = date ?? DateTime.now()
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutEntries.put(entry);
    });

    ref.invalidate(todayWorkoutsProvider);
    ref.invalidate(weekWorkoutsProvider);
    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutProgramsProvider);

    return entry;
  }

  /// ลบ Workout Entry
  Future<void> deleteWorkout(int entryId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutEntries.delete(entryId);
    });

    ref.invalidate(todayWorkoutsProvider);
    ref.invalidate(weekWorkoutsProvider);
    ref.invalidate(workoutStatsProvider);
  }

  /// ลบ Program
  Future<void> deleteProgram(int programId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutPrograms.delete(programId);
    });

    ref.invalidate(workoutProgramsProvider);
    ref.invalidate(activeProgramProvider);
  }

  /// ประมาณแคลอรี่
  int _estimateCalories(WorkoutType type, int minutes, int intensity) {
    // Base calories per minute by type
    double baseRate;
    switch (type) {
      case WorkoutType.strength:
        baseRate = 5.0;
        break;
      case WorkoutType.cardio:
        baseRate = 8.0;
        break;
      case WorkoutType.hiit:
        baseRate = 10.0;
        break;
      case WorkoutType.yoga:
        baseRate = 3.0;
        break;
      case WorkoutType.flexibility:
        baseRate = 2.5;
        break;
      case WorkoutType.sports:
        baseRate = 7.0;
        break;
      case WorkoutType.mixed:
        baseRate = 6.0;
        break;
    }

    // Adjust by intensity (1-10)
    final intensityMultiplier = 0.5 + (intensity / 10);

    return (baseRate * minutes * intensityMultiplier).round();
  }
}

final workoutNotifierProvider =
    StateNotifierProvider<WorkoutNotifier, AsyncValue<void>>((ref) {
  return WorkoutNotifier(ref);
});
```

---

## ขั้นตอนที่ 5: สร้าง Workout Tab UI

**สร้างไฟล์:** `lib/features/health/presentation/health_workout_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/workout_provider.dart';
import '../models/workout_program.dart';
import '../models/workout_entry.dart';

class HealthWorkoutTab extends ConsumerWidget {
  const HealthWorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(workoutStatsProvider);
    final programsAsync = ref.watch(workoutProgramsProvider);
    final todayWorkoutsAsync = ref.watch(todayWorkoutsProvider);

    return CustomScrollView(
      slivers: [
        // Stats Summary
        SliverToBoxAdapter(
          child: statsAsync.when(
            loading: () => const SizedBox(height: 100),
            error: (e, _) => Text('Error: $e'),
            data: (stats) => _buildStatsSummary(stats),
          ),
        ),

        // Quick Log Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showQuickLogDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('บันทึก Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),

        // Today's Workouts
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: const Text(
              '🏃 วันนี้',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        todayWorkoutsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          data: (workouts) {
            if (workouts.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text('😴', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            'ยังไม่ได้ออกกำลังกายวันนี้',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildWorkoutCard(context, ref, workouts[index]),
                childCount: workouts.length,
              ),
            );
          },
        ),

        // Programs Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Text(
                  '📋 โปรแกรม',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('สร้าง'),
                  onPressed: () => _showCreateProgramDialog(context, ref),
                ),
              ],
            ),
          ),
        ),
        programsAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          data: (programs) {
            if (programs.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: const Text('ยังไม่มีโปรแกรม'),
                      subtitle: const Text('สร้างโปรแกรม workout ของคุณ'),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => _showCreateProgramDialog(context, ref),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildProgramCard(context, ref, programs[index]),
                childCount: programs.length,
              ),
            );
          },
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(WorkoutStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'สัปดาห์นี้',
              '${stats.thisWeek}',
              'ครั้ง',
              Icons.fitness_center,
              AppColors.health,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'เวลารวม',
              '${stats.weekMinutes}',
              'นาที',
              Icons.timer,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'แคลอรี่',
              '${stats.weekCalories}',
              'kcal',
              Icons.local_fire_department,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              label,
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

  Widget _buildWorkoutCard(BuildContext context, WidgetRef ref, WorkoutEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.health.withOpacity(0.1),
            child: Text(entry.workoutType.emoji, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(entry.name),
          subtitle: Row(
            children: [
              Text('${entry.durationMinutes} นาที'),
              const SizedBox(width: 12),
              Text('🔥 ${entry.caloriesBurned} kcal'),
              const SizedBox(width: 12),
              Text(entry.feeling.emoji),
            ],
          ),
          trailing: Text(
            DateFormat('HH:mm').format(entry.date),
            style: TextStyle(color: AppColors.textSecondary),
          ),
          onLongPress: () => _showDeleteConfirmation(context, ref, entry),
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, WidgetRef ref, WorkoutProgram program) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: program.isActive ? AppColors.health.withOpacity(0.1) : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: program.isActive ? AppColors.health : Colors.grey,
            child: Text(program.emoji, style: const TextStyle(fontSize: 20)),
          ),
          title: Row(
            children: [
              Text(program.name),
              if (program.isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.health,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            '${program.type.displayName} • ${program.daysPerWeek} วัน/สัปดาห์ • ${program.thisWeekSessions}/${program.daysPerWeek} สัปดาห์นี้',
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              if (!program.isActive)
                const PopupMenuItem(
                  value: 'activate',
                  child: Text('ตั้งเป็น Active'),
                ),
              const PopupMenuItem(
                value: 'log',
                child: Text('บันทึก Workout'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('ลบ', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'activate':
                  ref.read(workoutNotifierProvider.notifier).setActiveProgram(program.id);
                  break;
                case 'log':
                  _showQuickLogDialog(context, ref, program: program);
                  break;
                case 'delete':
                  ref.read(workoutNotifierProvider.notifier).deleteProgram(program.id);
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  void _showQuickLogDialog(BuildContext context, WidgetRef ref, {WorkoutProgram? program}) {
    final nameController = TextEditingController(text: program?.name ?? '');
    WorkoutType selectedType = program?.type ?? WorkoutType.strength;
    int duration = program?.durationMinutes ?? 30;
    int intensity = 5;
    WorkoutFeeling feeling = WorkoutFeeling.good;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏋️ บันทึก Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ Workout',
                    hintText: 'เช่น Chest Day, วิ่ง',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Type
                DropdownButtonFormField<WorkoutType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'ประเภท',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkoutType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text('${t.emoji} ${t.displayName}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 16),

                // Duration
                Row(
                  children: [
                    const Text('ระยะเวลา: '),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: duration > 5
                          ? () => setState(() => duration -= 5)
                          : null,
                    ),
                    Text(
                      '$duration นาที',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => duration += 5),
                    ),
                  ],
                ),

                // Intensity
                Row(
                  children: [
                    const Text('ความเข้มข้น: '),
                    Expanded(
                      child: Slider(
                        value: intensity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$intensity',
                        onChanged: (v) => setState(() => intensity = v.round()),
                      ),
                    ),
                    Text('$intensity/10'),
                  ],
                ),

                // Feeling
                const Text('รู้สึก:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: WorkoutFeeling.values.map((f) {
                    return GestureDetector(
                      onTap: () => setState(() => feeling = f),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: feeling == f
                              ? AppColors.health.withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: feeling == f
                              ? Border.all(color: AppColors.health)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(f.emoji, style: const TextStyle(fontSize: 24)),
                            Text(
                              f.displayName,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) return;

                          await ref.read(workoutNotifierProvider.notifier).logWorkout(
                                programId: program?.id,
                                name: nameController.text.trim(),
                                type: selectedType,
                                durationMinutes: duration,
                                intensity: intensity,
                                feeling: feeling,
                              );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('บันทึก Workout สำเร็จ! 💪')),
                            );
                          }
                        },
                        child: const Text('บันทึก'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateProgramDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    WorkoutType selectedType = WorkoutType.strength;
    WorkoutLevel selectedLevel = WorkoutLevel.intermediate;
    int daysPerWeek = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 สร้างโปรแกรม',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อโปรแกรม',
                    hintText: 'เช่น PPL, Full Body, Cardio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<WorkoutType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'ประเภท',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkoutType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text('${t.emoji} ${t.displayName}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<WorkoutLevel>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'ระดับ',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkoutLevel.values.map((l) {
                    return DropdownMenuItem(
                      value: l,
                      child: Text(l.displayName),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedLevel = v);
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text('วันต่อสัปดาห์: '),
                    ...List.generate(7, (i) => i + 1).map((d) {
                      return GestureDetector(
                        onTap: () => setState(() => daysPerWeek = d),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: daysPerWeek == d
                                ? AppColors.health
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$d',
                              style: TextStyle(
                                color: daysPerWeek == d
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) return;

                          await ref.read(workoutNotifierProvider.notifier).createProgram(
                                name: nameController.text.trim(),
                                type: selectedType,
                                level: selectedLevel,
                                daysPerWeek: daysPerWeek,
                              );

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('สร้าง'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, WorkoutEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ Workout?'),
        content: Text('ลบ "${entry.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(workoutNotifierProvider.notifier).deleteWorkout(entry.id);
              Navigator.pop(context);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 6: อัปเดต Health Page

**แก้ไขไฟล์:** `lib/features/health/presentation/health_page.dart`

**เพิ่ม import และแก้ tab:**

```dart
import 'health_workout_tab.dart';

// ใน TabBarView
children: [
  const HealthTimelineTab(),
  const HealthDietTab(),
  const HealthWorkoutTab(),  // ← แก้จาก placeholder
],
```

---

## ขั้นตอนที่ 7: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Health → Workout tab**
2. **กด "บันทึก Workout"** - บันทึก workout ง่ายๆ
3. **สร้างโปรแกรม** - สร้าง workout program
4. **ตั้ง Active** - ตั้ง program เป็น active
5. **ดูสถิติ** - ตรวจสอบว่าสถิติถูกต้อง

---

## ✅ Checklist

- [ ] ตรวจสอบ/สร้าง workout models แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `workout_provider.dart` แล้ว
- [ ] สร้าง `health_workout_tab.dart` แล้ว
- [ ] อัปเดต `health_page.dart` แล้ว
- [ ] ทดสอบบันทึก Workout ได้
- [ ] ทดสอบสร้าง Program ได้
- [ ] ทดสอบสถิติแสดงถูกต้อง

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/health/
├── models/
│   ├── workout_program.dart    ← CHECK/CREATE
│   ├── workout_program.g.dart  ← GENERATED
│   ├── workout_entry.dart      ← CHECK/CREATE
│   └── workout_entry.g.dart    ← GENERATED
├── providers/
│   └── workout_provider.dart   ← NEW
├── presentation/
│   ├── health_page.dart        ← UPDATED
│   └── health_workout_tab.dart ← NEW
```

---

## ขั้นตอนถัดไป

ไป **Step 17: Finance Assets** เพื่อสร้างระบบติดตาม Assets (หุ้น, crypto, ทอง)
