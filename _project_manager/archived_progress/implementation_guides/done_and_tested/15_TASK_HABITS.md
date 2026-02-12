# Step 15: Habits Tracking

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 14 (Task Lists)

---

## 🎯 เป้าหมาย

- สร้าง Habit สำหรับติดตามกิจกรรมที่ทำเป็นประจำ
- แสดง Streak (จำนวนวันติดต่อกัน)
- แสดง Calendar View ของ Habit
- แสดงสถิติ

---

## สิ่งที่ต้องทำ

1. สร้าง Habit Model
2. สร้าง HabitLog Model
3. รัน Build Runner
4. สร้าง Habits Provider
5. สร้าง Habits Tab UI
6. สร้าง Habit Detail Screen
7. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง Habit Model

**สร้างไฟล์:** `lib/features/tasks/models/habit.dart`

```dart
import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  String emoji = '✅';  // Default emoji
  
  @enumerated
  HabitFrequency frequency = HabitFrequency.daily;

  @enumerated
  HabitColor color = HabitColor.blue;

  /// วันในสัปดาห์ที่ต้องทำ (สำหรับ weekly)
  /// เก็บเป็น comma-separated string: "1,2,3,4,5" = จันทร์-ศุกร์
  String? weekDays;

  /// เป้าหมายต่อวัน (เช่น ดื่มน้ำ 8 แก้ว)
  int targetPerDay = 1;

  /// หน่วย (เช่น "แก้ว", "ครั้ง", "นาที")
  String? unit;

  /// เวลาเตือน
  String? reminderTime;  // "08:00"

  bool isArchived = false;
  
  late DateTime createdAt;
  DateTime? archivedAt;

  // ============================================
  // COMPUTED FIELDS (ไม่เก็บใน DB)
  // ============================================

  @ignore
  int currentStreak = 0;

  @ignore
  int longestStreak = 0;

  @ignore
  int totalCompletions = 0;

  @ignore
  bool isCompletedToday = false;

  @ignore
  int todayProgress = 0;

  /// ดึงวันในสัปดาห์เป็น List
  @ignore
  List<int> get weekDaysList {
    if (weekDays == null || weekDays!.isEmpty) return [];
    return weekDays!.split(',').map((e) => int.parse(e)).toList();
  }

  /// ตั้งค่าวันในสัปดาห์จาก List
  set weekDaysList(List<int> days) {
    weekDays = days.join(',');
  }
}

enum HabitFrequency {
  daily,      // ทุกวัน
  weekly,     // ตามวันที่กำหนด
  weekdays,   // จันทร์-ศุกร์
  weekends,   // เสาร์-อาทิตย์
}

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.daily: return 'ทุกวัน';
      case HabitFrequency.weekly: return 'รายสัปดาห์';
      case HabitFrequency.weekdays: return 'จันทร์-ศุกร์';
      case HabitFrequency.weekends: return 'เสาร์-อาทิตย์';
    }
  }
}

enum HabitColor {
  blue,
  green,
  orange,
  red,
  purple,
  pink,
  teal,
  amber,
}

extension HabitColorExtension on HabitColor {
  int get colorValue {
    switch (this) {
      case HabitColor.blue: return 0xFF2196F3;
      case HabitColor.green: return 0xFF4CAF50;
      case HabitColor.orange: return 0xFFFF9800;
      case HabitColor.red: return 0xFFF44336;
      case HabitColor.purple: return 0xFF9C27B0;
      case HabitColor.pink: return 0xFFE91E63;
      case HabitColor.teal: return 0xFF009688;
      case HabitColor.amber: return 0xFFFFC107;
    }
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง HabitLog Model

**สร้างไฟล์:** `lib/features/tasks/models/habit_log.dart`

```dart
import 'package:isar/isar.dart';

part 'habit_log.g.dart';

@collection
class HabitLog {
  Id id = Isar.autoIncrement;

  late int habitId;
  
  /// วันที่ (เก็บเฉพาะวัน ไม่มีเวลา)
  @Index()
  late DateTime date;

  /// จำนวนที่ทำได้ (ถ้า habit มี target > 1)
  int count = 1;

  /// โน้ต
  String? note;

  late DateTime loggedAt;
}
```

---

## ขั้นตอนที่ 3: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม imports:**

```dart
import '../../features/tasks/models/habit.dart';
import '../../features/tasks/models/habit_log.dart';
```

**เพิ่มใน schemas list:**

```dart
static Future<void> initialize() async {
  final dir = await getApplicationDocumentsDirectory();
  
  _isar = await Isar.open(
    [
      // ... schemas ที่มีอยู่ ...
      HabitSchema,      // เพิ่ม
      HabitLogSchema,   // เพิ่ม
    ],
    directory: dir.path,
  );
}
```

**เพิ่ม getters:**

```dart
static IsarCollection<Habit> get habits => _isar!.habits;
static IsarCollection<HabitLog> get habitLogs => _isar!.habitLogs;
```

---

## ขั้นตอนที่ 4: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 5: สร้าง Habits Provider

**สร้างไฟล์:** `lib/features/tasks/providers/habits_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

// ============================================
// HABITS PROVIDERS
// ============================================

/// Provider สำหรับ Habits ทั้งหมด
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final habits = await DatabaseService.habits
      .filter()
      .isArchivedEqualTo(false)
      .sortByCreatedAtDesc()
      .findAll();

  // Load stats for each habit
  for (final habit in habits) {
    await _loadHabitStats(habit);
  }

  return habits;
});

/// Load stats สำหรับ habit
Future<void> _loadHabitStats(Habit habit) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Get all logs for this habit
  final logs = await DatabaseService.habitLogs
      .filter()
      .habitIdEqualTo(habit.id)
      .sortByDateDesc()
      .findAll();

  if (logs.isEmpty) {
    habit.currentStreak = 0;
    habit.longestStreak = 0;
    habit.totalCompletions = 0;
    habit.isCompletedToday = false;
    habit.todayProgress = 0;
    return;
  }

  // Total completions
  habit.totalCompletions = logs.fold(0, (sum, log) => sum + log.count);

  // Today's progress
  final todayLogs = logs.where((log) {
    final logDate = DateTime(log.date.year, log.date.month, log.date.day);
    return logDate == today;
  }).toList();

  habit.todayProgress = todayLogs.fold(0, (sum, log) => sum + log.count);
  habit.isCompletedToday = habit.todayProgress >= habit.targetPerDay;

  // Calculate streaks
  habit.currentStreak = _calculateCurrentStreak(habit, logs, today);
  habit.longestStreak = _calculateLongestStreak(habit, logs);
}

int _calculateCurrentStreak(Habit habit, List<HabitLog> logs, DateTime today) {
  if (logs.isEmpty) return 0;

  // Get unique dates with completions
  final completedDates = <DateTime>{};
  for (final log in logs) {
    final date = DateTime(log.date.year, log.date.month, log.date.day);
    // Check if completed for that day
    final dayLogs = logs.where((l) {
      final d = DateTime(l.date.year, l.date.month, l.date.day);
      return d == date;
    }).toList();
    final dayCount = dayLogs.fold(0, (sum, l) => sum + l.count);
    if (dayCount >= habit.targetPerDay) {
      completedDates.add(date);
    }
  }

  if (completedDates.isEmpty) return 0;

  int streak = 0;
  DateTime checkDate = today;

  // Check if today is a habit day
  if (!_isHabitDay(habit, checkDate)) {
    // Find the last habit day
    while (!_isHabitDay(habit, checkDate) && checkDate.isAfter(today.subtract(const Duration(days: 7)))) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
  }

  // Count streak
  while (completedDates.contains(checkDate) || !_isHabitDay(habit, checkDate)) {
    if (completedDates.contains(checkDate)) {
      streak++;
    }
    checkDate = checkDate.subtract(const Duration(days: 1));
    
    // Safety limit
    if (streak > 365) break;
  }

  return streak;
}

int _calculateLongestStreak(Habit habit, List<HabitLog> logs) {
  if (logs.isEmpty) return 0;

  // Get sorted unique dates
  final dates = logs.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet().toList()
    ..sort();

  if (dates.isEmpty) return 0;

  int longestStreak = 0;
  int currentStreak = 1;

  for (int i = 1; i < dates.length; i++) {
    final diff = dates[i].difference(dates[i - 1]).inDays;
    
    if (diff == 1 || (diff > 1 && !_hasHabitDayBetween(habit, dates[i - 1], dates[i]))) {
      currentStreak++;
    } else {
      longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
      currentStreak = 1;
    }
  }

  return longestStreak > currentStreak ? longestStreak : currentStreak;
}

bool _isHabitDay(Habit habit, DateTime date) {
  final weekday = date.weekday; // 1 = Monday, 7 = Sunday

  switch (habit.frequency) {
    case HabitFrequency.daily:
      return true;
    case HabitFrequency.weekdays:
      return weekday >= 1 && weekday <= 5;
    case HabitFrequency.weekends:
      return weekday == 6 || weekday == 7;
    case HabitFrequency.weekly:
      return habit.weekDaysList.contains(weekday);
  }
}

bool _hasHabitDayBetween(Habit habit, DateTime start, DateTime end) {
  DateTime current = start.add(const Duration(days: 1));
  while (current.isBefore(end)) {
    if (_isHabitDay(habit, current)) return true;
    current = current.add(const Duration(days: 1));
  }
  return false;
}

// ============================================
// HABITS NOTIFIER
// ============================================

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final Ref ref;

  HabitsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(habitsProvider.future);
    });
  }

  Future<Habit> createHabit({
    required String name,
    String? description,
    String emoji = '✅',
    HabitFrequency frequency = HabitFrequency.daily,
    HabitColor color = HabitColor.blue,
    int targetPerDay = 1,
    String? unit,
    List<int>? weekDays,
  }) async {
    final habit = Habit()
      ..name = name
      ..description = description
      ..emoji = emoji
      ..frequency = frequency
      ..color = color
      ..targetPerDay = targetPerDay
      ..unit = unit
      ..createdAt = DateTime.now();

    if (weekDays != null) {
      habit.weekDaysList = weekDays;
    }

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.habits.put(habit);
    });

    await loadHabits();
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.habits.put(habit);
    });

    await loadHabits();
  }

  Future<void> deleteHabit(int habitId) async {
    await DatabaseService.isar.writeTxn(() async {
      // Delete all logs
      await DatabaseService.habitLogs.filter().habitIdEqualTo(habitId).deleteAll();
      // Delete habit
      await DatabaseService.habits.delete(habitId);
    });

    await loadHabits();
  }

  Future<void> archiveHabit(int habitId) async {
    final habit = await DatabaseService.habits.get(habitId);
    if (habit != null) {
      habit.isArchived = true;
      habit.archivedAt = DateTime.now();
      await updateHabit(habit);
    }
  }

  /// Log completion for today
  Future<void> logCompletion(Habit habit, {int count = 1, String? note}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final log = HabitLog()
      ..habitId = habit.id
      ..date = today
      ..count = count
      ..note = note
      ..loggedAt = now;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.habitLogs.put(log);
    });

    await loadHabits();
  }

  /// Undo today's completion
  Future<void> undoTodayCompletion(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.habitLogs
          .filter()
          .habitIdEqualTo(habit.id)
          .dateBetween(today, tomorrow)
          .deleteAll();
    });

    await loadHabits();
  }
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitsNotifier(ref);
});

// ============================================
// HABIT LOGS PROVIDER
// ============================================

/// Provider สำหรับ logs ของ habit ในเดือนที่ระบุ
final habitMonthLogsProvider = FutureProvider.family<Map<DateTime, int>, HabitMonthParams>((ref, params) async {
  final startOfMonth = DateTime(params.year, params.month, 1);
  final endOfMonth = DateTime(params.year, params.month + 1, 0, 23, 59, 59);

  final logs = await DatabaseService.habitLogs
      .filter()
      .habitIdEqualTo(params.habitId)
      .dateBetween(startOfMonth, endOfMonth)
      .findAll();

  final Map<DateTime, int> result = {};
  for (final log in logs) {
    final date = DateTime(log.date.year, log.date.month, log.date.day);
    result[date] = (result[date] ?? 0) + log.count;
  }

  return result;
});

class HabitMonthParams {
  final int habitId;
  final int year;
  final int month;

  HabitMonthParams(this.habitId, this.year, this.month);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitMonthParams &&
          habitId == other.habitId &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => habitId.hashCode ^ year.hashCode ^ month.hashCode;
}
```

---

## ขั้นตอนที่ 6: สร้าง Habits Tab UI

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_habits_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/habits_provider.dart';
import '../models/habit.dart';
import 'habit_detail_screen.dart';

class TasksHabitsTab extends ConsumerWidget {
  const TasksHabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (habits) {
        if (habits.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return Column(
          children: [
            // Stats summary
            _buildStatsSummary(habits),

            // Habits list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: habits.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == habits.length) {
                    return _buildAddHabitButton(context, ref);
                  }
                  return _buildHabitCard(context, ref, habits[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSummary(List<Habit> habits) {
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    final totalActive = habits.length;
    final longestStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('วันนี้', '$completedToday/$totalActive', '✅'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Streak สูงสุด', '$longestStreak วัน', '🔥'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, WidgetRef ref, Habit habit) {
    final progress = habit.targetPerDay > 0
        ? habit.todayProgress / habit.targetPerDay
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habit: habit),
            ),
          ).then((_) => ref.invalidate(habitsNotifierProvider));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion button
              GestureDetector(
                onTap: () => _toggleCompletion(ref, habit),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.isCompletedToday
                        ? Color(habit.color.colorValue)
                        : Color(habit.color.colorValue).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(habit.color.colorValue),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: habit.isCompletedToday
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                            habit.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (habit.currentStreak > 0) ...[
                          Text(
                            '🔥 ${habit.currentStreak}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          habit.frequency.displayName,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (habit.targetPerDay > 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                Color(habit.color.colorValue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${habit.todayProgress}/${habit.targetPerDay}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Increment button (for habits with target > 1)
              if (habit.targetPerDay > 1 && !habit.isCompletedToday)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Color(habit.color.colorValue),
                  onPressed: () => _incrementProgress(ref, habit),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddHabitButton(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 80),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.add),
        ),
        title: const Text('สร้าง Habit ใหม่'),
        subtitle: const Text('ติดตามกิจกรรมที่ทำเป็นประจำ'),
        onTap: () => _showCreateHabitDialog(context, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'ยังไม่มี Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'สร้าง habit เพื่อติดตามกิจกรรม\nที่คุณต้องการทำเป็นประจำ',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('สร้าง Habit แรก'),
              onPressed: () => _showCreateHabitDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCompletion(WidgetRef ref, Habit habit) {
    if (habit.isCompletedToday) {
      ref.read(habitsNotifierProvider.notifier).undoTodayCompletion(habit);
    } else {
      if (habit.targetPerDay == 1) {
        ref.read(habitsNotifierProvider.notifier).logCompletion(habit);
      } else {
        // For multi-target habits, increment by 1
        ref.read(habitsNotifierProvider.notifier).logCompletion(habit, count: 1);
      }
    }
  }

  void _incrementProgress(WidgetRef ref, Habit habit) {
    ref.read(habitsNotifierProvider.notifier).logCompletion(habit, count: 1);
  }

  void _showCreateHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedEmoji = '✅';
    HabitFrequency selectedFrequency = HabitFrequency.daily;
    HabitColor selectedColor = HabitColor.blue;
    int targetPerDay = 1;

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
                  'สร้าง Habit ใหม่',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Emoji picker
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['✅', '💧', '📚', '🏃', '🧘', '💪', '🍎', '😴', '💊', '🎯']
                        .map((emoji) => GestureDetector(
                              onTap: () => setState(() => selectedEmoji = emoji),
                              child: Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: selectedEmoji == emoji
                                      ? Color(selectedColor.colorValue).withOpacity(0.2)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: selectedEmoji == emoji
                                      ? Border.all(color: Color(selectedColor.colorValue))
                                      : null,
                                ),
                                child: Center(
                                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ Habit',
                    hintText: 'เช่น ดื่มน้ำ, ออกกำลังกาย',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Frequency
                DropdownButtonFormField<HabitFrequency>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'ความถี่',
                    border: OutlineInputBorder(),
                  ),
                  items: HabitFrequency.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedFrequency = value);
                  },
                ),
                const SizedBox(height: 16),

                // Target per day
                Row(
                  children: [
                    const Text('เป้าหมายต่อวัน: '),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: targetPerDay > 1
                          ? () => setState(() => targetPerDay--)
                          : null,
                    ),
                    Text(
                      '$targetPerDay',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => targetPerDay++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color picker
                Wrap(
                  spacing: 8,
                  children: HabitColor.values.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(color.colorValue),
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
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

                          await ref.read(habitsNotifierProvider.notifier).createHabit(
                                name: nameController.text.trim(),
                                emoji: selectedEmoji,
                                frequency: selectedFrequency,
                                color: selectedColor,
                                targetPerDay: targetPerDay,
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
}
```

---

## ขั้นตอนที่ 7: สร้าง Habit Detail Screen

**สร้างไฟล์:** `lib/features/tasks/presentation/habit_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/habits_provider.dart';
import '../models/habit.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(habitMonthLogsProvider(
      HabitMonthParams(widget.habit.id, _focusedMonth.year, _focusedMonth.month),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.habit.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(widget.habit.name),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('แก้ไข'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('ลบ', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditDialog();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats cards
            _buildStatsCards(),

            const SizedBox(height: 16),

            // Calendar
            _buildCalendarHeader(),
            logsAsync.when(
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (logs) => _buildCalendarGrid(logs),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logToday,
        backgroundColor: Color(widget.habit.color.colorValue),
        icon: Icon(
          widget.habit.isCompletedToday ? Icons.check : Icons.add,
          color: Colors.white,
        ),
        label: Text(
          widget.habit.isCompletedToday ? 'เสร็จแล้ว!' : 'บันทึกวันนี้',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '🔥 Streak',
              '${widget.habit.currentStreak} วัน',
              Color(widget.habit.color.colorValue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '🏆 สูงสุด',
              '${widget.habit.longestStreak} วัน',
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '✅ รวม',
              '${widget.habit.totalCompletions} ครั้ง',
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              });
            },
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', 'th').format(_focusedMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, int> logs) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Day labels
    const dayLabels = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day labels row
          Row(
            children: dayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }

              final day = index - startWeekday + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isToday = _isToday(date);
              final count = logs[date] ?? 0;
              final isCompleted = count >= widget.habit.targetPerDay;
              final isFuture = date.isAfter(DateTime.now());

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Color(widget.habit.color.colorValue)
                      : count > 0
                          ? Color(widget.habit.color.colorValue).withOpacity(0.3)
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Color(widget.habit.color.colorValue), width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.white
                          : isFuture
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : null,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _logToday() {
    if (widget.habit.isCompletedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('วันนี้บันทึกแล้ว! 🎉')),
      );
      return;
    }

    ref.read(habitsNotifierProvider.notifier).logCompletion(widget.habit);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกสำเร็จ! 🔥')),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: widget.habit.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไข Habit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'ชื่อ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              widget.habit.name = nameController.text.trim();
              ref.read(habitsNotifierProvider.notifier).updateHabit(widget.habit);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ Habit?'),
        content: const Text('ประวัติทั้งหมดจะถูกลบด้วย'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(habitsNotifierProvider.notifier).deleteHabit(widget.habit.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
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

## ขั้นตอนที่ 8: อัปเดต Tasks Page

**แก้ไขไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

**เพิ่ม import:**

```dart
import 'tasks_habits_tab.dart';
```

**เปลี่ยน placeholder เป็น TasksHabitsTab:**

```dart
TabBarView(
  controller: _tabController,
  children: [
    const TasksTodayTab(),
    const TasksCalendarTab(),
    const TasksListsTab(),
    const TasksHabitsTab(),  // ← แก้จาก placeholder
  ],
),
```

---

## ขั้นตอนที่ 9: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Tasks → Habits tab**
   - ควรเห็นหน้าว่างพร้อมปุ่มสร้าง Habit

2. **สร้าง Habit ใหม่**
   - เลือก emoji, ตั้งชื่อ, เลือกความถี่, สี
   - กด สร้าง

3. **บันทึก Habit**
   - กดวงกลมเพื่อบันทึกว่าทำเสร็จวันนี้
   - ควรเห็น Streak เพิ่มขึ้น

4. **ดูรายละเอียด**
   - กดที่ Habit card
   - ดู calendar view
   - ดูสถิติ

---

## ✅ Checklist

- [ ] สร้าง `habit.dart` model แล้ว
- [ ] สร้าง `habit_log.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `habits_provider.dart` แล้ว
- [ ] สร้าง `tasks_habits_tab.dart` แล้ว
- [ ] สร้าง `habit_detail_screen.dart` แล้ว
- [ ] อัปเดต `tasks_page.dart` แล้ว
- [ ] ทดสอบสร้าง Habit ได้
- [ ] ทดสอบบันทึกได้
- [ ] ทดสอบ Streak แสดงถูกต้อง
- [ ] ทดสอบ Calendar view แสดงถูกต้อง

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/tasks/
├── models/
│   ├── habit.dart           ← NEW
│   ├── habit.g.dart         ← GENERATED
│   ├── habit_log.dart       ← NEW
│   └── habit_log.g.dart     ← GENERATED
├── providers/
│   └── habits_provider.dart ← NEW
├── presentation/
│   ├── tasks_page.dart      ← UPDATED
│   ├── tasks_habits_tab.dart ← NEW
│   └── habit_detail_screen.dart ← NEW
lib/core/database/
└── database_service.dart    ← UPDATED
```

---

## ขั้นตอนถัดไป

ไป **Step 16: Health Workout** เพื่อสร้างระบบบันทึกการออกกำลังกาย
