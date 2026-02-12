# Step 18: Today Tab + Proactive Nudges

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ปานกลาง-ยาก
> **ต้องทำก่อน:** Step 15 (Habits), Step 16 (Workout)
> **อ้างอิง:** `_project_manager/TASK_FEATURE_DESIGN.md`

---

## 🎯 เป้าหมาย

- สร้าง Today Tab ที่แสดง Quick Glance (สรุปทุกอย่างวันนี้)
- แสดง Workout Program ของวันนี้
- แสดง Tasks/Events วันนี้
- สร้าง Proactive Nudges (แจ้งเตือนอัจฉริยะ)

---

## สิ่งที่ต้องทำ

1. สร้าง Nudge Model
2. สร้าง Today Provider
3. สร้าง Nudge Service
4. สร้าง Quick Glance Widget
5. สร้าง Nudge Card Widget
6. สร้าง Today Tab UI
7. อัปเดต Tasks Page
8. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง Nudge Model

**สร้างไฟล์:** `lib/features/tasks/models/nudge.dart`

```dart
import 'package:isar/isar.dart';

part 'nudge.g.dart';

@collection
class Nudge {
  Id id = Isar.autoIncrement;

  late String title;
  late String message;

  @enumerated
  late NudgeType type;

  /// Actions ที่ผู้ใช้ทำได้ (JSON)
  String? actionsJson;

  /// สถานะ
  bool isRead = false;
  bool isDismissed = false;
  DateTime? actionTakenAt;
  String? actionTaken;

  /// Timing
  late DateTime createdAt;
  DateTime? expiresAt;

  /// Reference
  String? referenceType;  // 'food', 'workout', 'bill'
  int? referenceId;
}

enum NudgeType {
  foodLogging,    // ยังไม่บันทึกอาหาร
  workout,        // วันนี้มี workout
  medicine,       // ถึงเวลากินยา
  billDue,        // บิลจะถึงกำหนด
  healthCheck,    // ควรตรวจสุขภาพ
  streakRisk,     // ใกล้เสีย streak
  habitReminder,  // เตือน habit
  general,        // ทั่วไป
}

extension NudgeTypeExtension on NudgeType {
  String get emoji {
    switch (this) {
      case NudgeType.foodLogging: return '🍔';
      case NudgeType.workout: return '🏃';
      case NudgeType.medicine: return '💊';
      case NudgeType.billDue: return '💳';
      case NudgeType.healthCheck: return '🩺';
      case NudgeType.streakRisk: return '🔥';
      case NudgeType.habitReminder: return '✅';
      case NudgeType.general: return '💡';
    }
  }

  String get displayName {
    switch (this) {
      case NudgeType.foodLogging: return 'บันทึกอาหาร';
      case NudgeType.workout: return 'ออกกำลังกาย';
      case NudgeType.medicine: return 'กินยา';
      case NudgeType.billDue: return 'บิลถึงกำหนด';
      case NudgeType.healthCheck: return 'ตรวจสุขภาพ';
      case NudgeType.streakRisk: return 'Streak';
      case NudgeType.habitReminder: return 'Habit';
      case NudgeType.general: return 'ทั่วไป';
    }
  }
}
```

---

## ขั้นตอนที่ 2: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม import:**

```dart
import '../../features/tasks/models/nudge.dart';
```

**เพิ่มใน schemas:**

```dart
NudgeSchema,
```

**เพิ่ม getter:**

```dart
static IsarCollection<Nudge> get nudges => _isar!.nudges;
```

---

## ขั้นตอนที่ 3: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 4: สร้าง Today Provider

**สร้างไฟล์:** `lib/features/tasks/providers/today_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../health/models/food_entry.dart';
import '../../health/models/workout_program.dart';
import '../../health/models/workout_entry.dart';
import '../../finance/models/transaction.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/nudge.dart';

// ============================================
// QUICK GLANCE DATA
// ============================================

class QuickGlanceData {
  // Health
  final int todayCalories;
  final int calorieTarget;
  final String? todayWorkoutName;
  final bool workoutCompleted;
  
  // Finance
  final double todaySpending;
  final double portfolioChange; // %
  
  // Tasks
  final int tasksTotal;
  final int tasksCompleted;
  final int habitsTotal;
  final int habitsCompleted;

  QuickGlanceData({
    this.todayCalories = 0,
    this.calorieTarget = 2000,
    this.todayWorkoutName,
    this.workoutCompleted = false,
    this.todaySpending = 0,
    this.portfolioChange = 0,
    this.tasksTotal = 0,
    this.tasksCompleted = 0,
    this.habitsTotal = 0,
    this.habitsCompleted = 0,
  });

  double get caloriePercent => calorieTarget > 0 
      ? (todayCalories / calorieTarget * 100).clamp(0, 100) 
      : 0;

  double get taskPercent => tasksTotal > 0 
      ? (tasksCompleted / tasksTotal * 100) 
      : 0;
}

/// Provider สำหรับ Quick Glance
final quickGlanceProvider = FutureProvider<QuickGlanceData>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // ========== HEALTH ==========
  // Calories
  final foodEntries = await DatabaseService.foodEntries
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .findAll();
  final todayCalories = foodEntries.fold<int>(
    0, (sum, e) => sum + (e.calories?.toInt() ?? 0),
  );

  // Workout
  final activeProgram = await DatabaseService.workoutPrograms
      .filter()
      .isActiveEqualTo(true)
      .findFirst();
  
  final todayWorkouts = await DatabaseService.workoutEntries
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .findAll();

  // ========== FINANCE ==========
  final todayTransactions = await DatabaseService.transactions
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .typeEqualTo(TransactionType.expense)
      .findAll();
  final todaySpending = todayTransactions.fold<double>(
    0, (sum, t) => sum + t.amount,
  );

  // ========== TASKS ==========
  final todayTasks = await DatabaseService.tasks
      .filter()
      .dueDateBetween(startOfDay, endOfDay)
      .findAll();
  final completedTasks = todayTasks.where((t) => t.status == TaskStatus.completed).length;

  // ========== HABITS ==========
  final habits = await DatabaseService.habits
      .filter()
      .isActiveEqualTo(true)
      .findAll();
  
  int habitsCompleted = 0;
  for (final habit in habits) {
    final log = await DatabaseService.habitLogs
        .filter()
        .habitIdEqualTo(habit.id)
        .completedDateBetween(startOfDay, endOfDay)
        .findFirst();
    if (log != null) habitsCompleted++;
  }

  return QuickGlanceData(
    todayCalories: todayCalories,
    calorieTarget: 2000, // TODO: ดึงจาก UserProfile
    todayWorkoutName: activeProgram?.name,
    workoutCompleted: todayWorkouts.isNotEmpty,
    todaySpending: todaySpending,
    portfolioChange: 0, // TODO: คำนวณจาก Assets
    tasksTotal: todayTasks.length,
    tasksCompleted: completedTasks,
    habitsTotal: habits.length,
    habitsCompleted: habitsCompleted,
  );
});

// ============================================
// TODAY TASKS
// ============================================

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return await DatabaseService.tasks
      .filter()
      .dueDateBetween(startOfDay, endOfDay)
      .sortByDueTime()
      .findAll();
});

// ============================================
// TODAY NUDGES
// ============================================

final todayNudgesProvider = FutureProvider<List<Nudge>>((ref) async {
  final now = DateTime.now();
  
  // Get nudges that are not dismissed and not expired
  return await DatabaseService.nudges
      .filter()
      .isDismissedEqualTo(false)
      .group((q) => q
          .expiresAtIsNull()
          .or()
          .expiresAtGreaterThan(now)
      )
      .sortByCreatedAtDesc()
      .findAll();
});
```

---

## ขั้นตอนที่ 5: สร้าง Nudge Service

**สร้างไฟล์:** `lib/core/services/nudge_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database/database_service.dart';
import '../../features/tasks/models/nudge.dart';
import '../../features/health/models/food_entry.dart';
import '../../features/health/models/workout_program.dart';
import '../../features/health/models/workout_entry.dart';
import '../../features/tasks/models/habit.dart';
import '../../features/tasks/models/habit_log.dart';

/// Service สำหรับจัดการ Nudges
class NudgeService {
  
  /// สร้าง Nudges ตามสถานการณ์ปัจจุบัน
  static Future<void> generateNudges() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 1. Food Logging Nudge
    await _checkFoodLoggingNudge(now, startOfDay, endOfDay);

    // 2. Workout Nudge
    await _checkWorkoutNudge(now, startOfDay, endOfDay);

    // 3. Habit Streak Risk
    await _checkStreakRiskNudge(now, startOfDay, endOfDay);

    debugPrint('✅ Nudges generated');
  }

  /// ตรวจสอบว่าควรเตือนบันทึกอาหารหรือไม่
  static Future<void> _checkFoodLoggingNudge(
    DateTime now,
    DateTime startOfDay,
    DateTime endOfDay,
  ) async {
    // ตรวจสอบว่ามี nudge อยู่แล้วหรือไม่
    final existingNudge = await DatabaseService.nudges
        .filter()
        .typeEqualTo(NudgeType.foodLogging)
        .isDismissedEqualTo(false)
        .createdAtBetween(startOfDay, endOfDay)
        .findFirst();
    
    if (existingNudge != null) return;

    // ตรวจสอบว่าบันทึกอาหารมื้อนี้หรือยัง
    final hour = now.hour;
    String mealType;
    String mealName;

    if (hour >= 10 && hour < 14) {
      mealType = 'lunch';
      mealName = 'มื้อเที่ยง';
    } else if (hour >= 14 && hour < 18) {
      mealType = 'snack';
      mealName = 'ของว่าง';
    } else if (hour >= 18 && hour < 21) {
      mealType = 'dinner';
      mealName = 'มื้อเย็น';
    } else {
      return; // ไม่ต้องเตือน
    }

    // ตรวจสอบว่าบันทึกมื้อนี้หรือยัง
    final meals = await DatabaseService.foodEntries
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .mealTypeEqualTo(mealType)
        .findAll();

    if (meals.isEmpty) {
      // สร้าง nudge
      final nudge = Nudge()
        ..title = 'ยังไม่ได้บันทึก$mealName'
        ..message = 'อย่าลืมบันทึกอาหาร$mealNameนะครับ'
        ..type = NudgeType.foodLogging
        ..createdAt = now
        ..expiresAt = now.add(const Duration(hours: 4));

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.nudges.put(nudge);
      });
    }
  }

  /// ตรวจสอบว่าควรเตือน Workout หรือไม่
  static Future<void> _checkWorkoutNudge(
    DateTime now,
    DateTime startOfDay,
    DateTime endOfDay,
  ) async {
    // ตรวจสอบว่ามี nudge อยู่แล้วหรือไม่
    final existingNudge = await DatabaseService.nudges
        .filter()
        .typeEqualTo(NudgeType.workout)
        .isDismissedEqualTo(false)
        .createdAtBetween(startOfDay, endOfDay)
        .findFirst();
    
    if (existingNudge != null) return;

    // ตรวจสอบว่ามี active program และเป็นวันออกกำลังหรือไม่
    final activeProgram = await DatabaseService.workoutPrograms
        .filter()
        .isActiveEqualTo(true)
        .findFirst();
    
    if (activeProgram == null) return;

    // ตรวจสอบว่าออกกำลังวันนี้แล้วหรือยัง
    final todayWorkouts = await DatabaseService.workoutEntries
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();

    if (todayWorkouts.isEmpty && now.hour >= 16) {
      // เย็นแล้วยังไม่ได้ออกกำลัง
      final nudge = Nudge()
        ..title = 'อย่าลืมออกกำลังกาย!'
        ..message = 'วันนี้เป็น ${activeProgram.name}'
        ..type = NudgeType.workout
        ..referenceType = 'workout_program'
        ..referenceId = activeProgram.id
        ..createdAt = now
        ..expiresAt = endOfDay;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.nudges.put(nudge);
      });
    }
  }

  /// ตรวจสอบว่า Habit ใกล้เสีย Streak หรือไม่
  static Future<void> _checkStreakRiskNudge(
    DateTime now,
    DateTime startOfDay,
    DateTime endOfDay,
  ) async {
    final habits = await DatabaseService.habits
        .filter()
        .isActiveEqualTo(true)
        .findAll();

    for (final habit in habits) {
      // ตรวจสอบว่ามี nudge อยู่แล้วหรือไม่
      final existingNudge = await DatabaseService.nudges
          .filter()
          .typeEqualTo(NudgeType.streakRisk)
          .referenceIdEqualTo(habit.id)
          .isDismissedEqualTo(false)
          .createdAtBetween(startOfDay, endOfDay)
          .findFirst();
      
      if (existingNudge != null) continue;

      // ตรวจสอบว่าทำวันนี้หรือยัง
      final todayLog = await DatabaseService.habitLogs
          .filter()
          .habitIdEqualTo(habit.id)
          .completedDateBetween(startOfDay, endOfDay)
          .findFirst();

      // ถ้ามี streak มากกว่า 3 วัน และยังไม่ได้ทำวันนี้ และเย็นแล้ว
      if (todayLog == null && 
          habit.currentStreak >= 3 && 
          now.hour >= 18) {
        final nudge = Nudge()
          ..title = 'อย่าเสีย Streak! 🔥${habit.currentStreak}'
          ..message = 'อย่าลืม${habit.name}วันนี้'
          ..type = NudgeType.streakRisk
          ..referenceType = 'habit'
          ..referenceId = habit.id
          ..createdAt = now
          ..expiresAt = endOfDay;

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.nudges.put(nudge);
        });
      }
    }
  }

  /// Dismiss nudge
  static Future<void> dismissNudge(int nudgeId) async {
    await DatabaseService.isar.writeTxn(() async {
      final nudge = await DatabaseService.nudges.get(nudgeId);
      if (nudge != null) {
        nudge.isDismissed = true;
        nudge.actionTakenAt = DateTime.now();
        nudge.actionTaken = 'dismissed';
        await DatabaseService.nudges.put(nudge);
      }
    });
  }

  /// Mark nudge as actioned
  static Future<void> markActioned(int nudgeId, String action) async {
    await DatabaseService.isar.writeTxn(() async {
      final nudge = await DatabaseService.nudges.get(nudgeId);
      if (nudge != null) {
        nudge.isDismissed = true;
        nudge.actionTakenAt = DateTime.now();
        nudge.actionTaken = action;
        await DatabaseService.nudges.put(nudge);
      }
    });
  }

  /// ลบ nudges เก่า
  static Future<void> cleanupOldNudges() async {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.nudges
          .filter()
          .createdAtLessThan(oneWeekAgo)
          .deleteAll();
    });
  }
}
```

---

## ขั้นตอนที่ 6: สร้าง Quick Glance Widget

**สร้างไฟล์:** `lib/features/tasks/widgets/quick_glance_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/today_provider.dart';

class QuickGlanceCard extends ConsumerWidget {
  const QuickGlanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(quickGlanceProvider);

    return dataAsync.when(
      loading: () => const Card(
        child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => Card(child: Text('Error: $e')),
      data: (data) => _buildCard(data),
    );
  }

  Widget _buildCard(QuickGlanceData data) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Quick Glance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Health
                Expanded(
                  child: _buildGlanceItem(
                    '🍎',
                    '${data.todayCalories}/${data.calorieTarget}',
                    'kcal',
                    data.caloriePercent / 100,
                    AppColors.health,
                  ),
                ),
                const SizedBox(width: 12),
                // Workout
                Expanded(
                  child: _buildGlanceItem(
                    '🏃',
                    data.todayWorkoutName ?? 'ไม่มี',
                    data.workoutCompleted ? '✅' : '',
                    data.workoutCompleted ? 1.0 : 0.0,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Finance
                Expanded(
                  child: _buildGlanceItem(
                    '💰',
                    '฿${data.todaySpending.toStringAsFixed(0)}',
                    'ใช้ไป',
                    0.5, // TODO: เทียบกับ budget
                    AppColors.finance,
                  ),
                ),
                const SizedBox(width: 12),
                // Tasks
                Expanded(
                  child: _buildGlanceItem(
                    '📅',
                    '${data.tasksCompleted}/${data.tasksTotal}',
                    'Tasks',
                    data.taskPercent / 100,
                    AppColors.tasks,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlanceItem(
    String emoji,
    String value,
    String label,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 7: สร้าง Nudge Card Widget

**สร้างไฟล์:** `lib/features/tasks/widgets/nudge_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/nudge_service.dart';
import '../models/nudge.dart';
import '../providers/today_provider.dart';

class NudgeCard extends ConsumerWidget {
  final Nudge nudge;
  final VoidCallback? onAction;

  const NudgeCard({
    super.key,
    required this.nudge,
    this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nudge.type.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nudge.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        nudge.message,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () async {
                    await NudgeService.dismissNudge(nudge.id);
                    ref.invalidate(todayNudgesProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await NudgeService.dismissNudge(nudge.id);
                      ref.invalidate(todayNudgesProvider);
                    },
                    child: const Text('⏰ เตือนอีกที'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      onAction?.call();
                      await NudgeService.markActioned(nudge.id, 'action');
                      ref.invalidate(todayNudgesProvider);
                    },
                    child: Text(_getActionText(nudge.type)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getActionText(NudgeType type) {
    switch (type) {
      case NudgeType.foodLogging:
        return '📷 ถ่ายรูป';
      case NudgeType.workout:
        return '🏃 ดูโปรแกรม';
      case NudgeType.medicine:
        return '✅ ทำแล้ว';
      case NudgeType.streakRisk:
        return '✅ ทำเลย';
      case NudgeType.habitReminder:
        return '✅ ทำแล้ว';
      default:
        return 'ดู';
    }
  }
}
```

---

## ขั้นตอนที่ 8: สร้าง Today Tab UI

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_today_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/nudge_service.dart';
import '../providers/today_provider.dart';
import '../models/task.dart';
import '../widgets/quick_glance_card.dart';
import '../widgets/nudge_card.dart';

class TasksTodayTab extends ConsumerStatefulWidget {
  const TasksTodayTab({super.key});

  @override
  ConsumerState<TasksTodayTab> createState() => _TasksTodayTabState();
}

class _TasksTodayTabState extends ConsumerState<TasksTodayTab> {
  @override
  void initState() {
    super.initState();
    // Generate nudges when tab opens
    Future.microtask(() => NudgeService.generateNudges().then((_) {
      ref.invalidate(todayNudgesProvider);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final nudgesAsync = ref.watch(todayNudgesProvider);
    final tasksAsync = ref.watch(todayTasksProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await NudgeService.generateNudges();
        ref.invalidate(quickGlanceProvider);
        ref.invalidate(todayNudgesProvider);
        ref.invalidate(todayTasksProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Date Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '📅 วันนี้ - ${DateFormat('d MMM yyyy', 'th').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Quick Glance
          const SliverToBoxAdapter(
            child: QuickGlanceCard(),
          ),

          // Nudges Section
          nudgesAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
            data: (nudges) {
              if (nudges.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              '💡 Nudges',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${nudges.length}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return NudgeCard(
                      nudge: nudges[index - 1],
                      onAction: () => _handleNudgeAction(nudges[index - 1]),
                    );
                  },
                  childCount: nudges.length + 1,
                ),
              );
            },
          ),

          // Tasks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: const Text(
                '📋 Tasks วันนี้',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          tasksAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
            data: (tasks) {
              if (tasks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              'ไม่มี Tasks วันนี้',
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
                  (context, index) => _buildTaskCard(tasks[index]),
                  childCount: tasks.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCompleted = task.status == TaskStatus.completed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: isCompleted,
            onChanged: (value) {
              // TODO: Update task status
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? AppColors.textSecondary : null,
            ),
          ),
          subtitle: task.dueTime != null
              ? Text(
                  '⏰ ${DateFormat('HH:mm').format(task.dueTime!)}',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              : null,
          trailing: task.priority == TaskPriority.high
              ? const Icon(Icons.priority_high, color: Colors.red)
              : null,
        ),
      ),
    );
  }

  void _handleNudgeAction(dynamic nudge) {
    // TODO: Navigate based on nudge type
    switch (nudge.type) {
      case 'foodLogging':
        // Navigate to camera
        break;
      case 'workout':
        // Navigate to workout tab
        break;
      default:
        break;
    }
  }
}
```

---

## ขั้นตอนที่ 9: อัปเดต Tasks Page

**แก้ไขไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

**เพิ่ม import และแก้ tabs:**

```dart
import 'tasks_today_tab.dart';

// แก้ไข TabBar ให้มี Today tab
TabBar(
  controller: _tabController,
  tabs: const [
    Tab(text: 'Today'),     // เพิ่ม
    Tab(text: 'Calendar'),
    Tab(text: 'Lists'),
    Tab(text: 'Habits'),
  ],
),

// TabBarView
TabBarView(
  controller: _tabController,
  children: const [
    TasksTodayTab(),        // เพิ่ม
    TasksCalendarTab(),
    TasksListsTab(),
    TasksHabitsTab(),
  ],
),
```

**อย่าลืมแก้ `TabController` length เป็น 4:**

```dart
_tabController = TabController(length: 4, vsync: this);
```

---

## ขั้นตอนที่ 10: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Tasks → Today tab**
2. **ดู Quick Glance** - แสดงสรุปสุขภาพ/การเงิน/งาน
3. **ดู Nudges** - แสดงการแจ้งเตือน
4. **Dismiss nudge** - กดปิด nudge
5. **ดู Tasks วันนี้**

---

## ✅ Checklist

- [ ] สร้าง `nudge.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `today_provider.dart` แล้ว
- [ ] สร้าง `nudge_service.dart` แล้ว
- [ ] สร้าง `quick_glance_card.dart` แล้ว
- [ ] สร้าง `nudge_card.dart` แล้ว
- [ ] สร้าง `tasks_today_tab.dart` แล้ว
- [ ] อัปเดต `tasks_page.dart` แล้ว (4 tabs)
- [ ] ทดสอบ Quick Glance แสดงข้อมูลถูกต้อง
- [ ] ทดสอบ Nudges แสดงและ dismiss ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/
│   ├── database/
│   │   └── database_service.dart   ← UPDATED
│   └── services/
│       └── nudge_service.dart      ← NEW
└── features/tasks/
    ├── models/
    │   ├── nudge.dart              ← NEW
    │   └── nudge.g.dart            ← GENERATED
    ├── providers/
    │   └── today_provider.dart     ← NEW
    ├── widgets/
    │   ├── quick_glance_card.dart  ← NEW
    │   └── nudge_card.dart         ← NEW
    └── presentation/
        ├── tasks_page.dart         ← UPDATED (4 tabs)
        └── tasks_today_tab.dart    ← NEW
```

---

## ⚠️ Troubleshooting

### Error: NudgeType not found
- ตรวจสอบว่า `nudge.dart` export enum ถูกต้อง
- รัน `dart run build_runner build`

### Nudges ไม่แสดง
- ตรวจสอบว่า `NudgeService.generateNudges()` ถูกเรียก
- ตรวจสอบเงื่อนไขเวลา (hour >= 10, 14, 18, etc.)

### Quick Glance แสดงค่า 0 หมด
- ตรวจสอบว่ามีข้อมูลในวันนี้หรือไม่
- ตรวจสอบ date filter

---

## ขั้นตอนถัดไป

ไป **Step 19: Health Other Tab** เพื่อสร้าง Tab สำหรับน้ำ, ยา, Biometrics
