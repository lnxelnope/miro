# Step 22: Weekly/Monthly Insights

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 18 (Today Tab)
> **อ้างอิง:** `_project_manager/TASK_FEATURE_DESIGN.md`

---

## 🎯 เป้าหมาย

- สรุปสุขภาพ/การเงิน/งานรายสัปดาห์
- แสดงสถิติและแนวโน้ม
- Cross-feature Insights (AI วิเคราะห์ข้ามหมวด)
- แจ้งเตือน/ชมเชยเมื่อทำได้ดี

---

## สิ่งที่ต้องทำ

1. สร้าง Insights Model
2. สร้าง Insights Provider
3. สร้าง Insights Service
4. สร้าง Weekly Summary Screen
5. สร้าง Insights Widgets
6. เพิ่มปุ่มใน Profile/Home
7. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง Insights Model

**สร้างไฟล์:** `lib/features/insights/models/weekly_insights.dart`

```dart
class WeeklyInsights {
  final DateTime weekStart;
  final DateTime weekEnd;
  
  // Health
  final HealthInsights health;
  
  // Finance
  final FinanceInsights finance;
  
  // Tasks
  final TasksInsights tasks;
  
  // AI-generated insights
  final List<String> aiInsights;

  WeeklyInsights({
    required this.weekStart,
    required this.weekEnd,
    required this.health,
    required this.finance,
    required this.tasks,
    this.aiInsights = const [],
  });
}

class HealthInsights {
  final int avgCalories;
  final int targetCalories;
  final int workoutsCompleted;
  final int workoutsTarget;
  final double? weightStart;
  final double? weightEnd;
  final double waterAvgMl;

  HealthInsights({
    this.avgCalories = 0,
    this.targetCalories = 2000,
    this.workoutsCompleted = 0,
    this.workoutsTarget = 5,
    this.weightStart,
    this.weightEnd,
    this.waterAvgMl = 0,
  });

  double get caloriePercent => targetCalories > 0 
      ? (avgCalories / targetCalories * 100) 
      : 0;

  double get workoutPercent => workoutsTarget > 0 
      ? (workoutsCompleted / workoutsTarget * 100) 
      : 0;

  double? get weightChange => (weightStart != null && weightEnd != null) 
      ? weightEnd! - weightStart! 
      : null;

  String get weightChangeString {
    final change = weightChange;
    if (change == null) return '-';
    if (change > 0) return '+${change.toStringAsFixed(1)} kg';
    return '${change.toStringAsFixed(1)} kg';
  }
}

class FinanceInsights {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final Map<String, double> expenseByCategory;
  final double portfolioChangePercent;

  FinanceInsights({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.netSavings = 0,
    this.expenseByCategory = const {},
    this.portfolioChangePercent = 0,
  });

  String get topCategory {
    if (expenseByCategory.isEmpty) return '-';
    final sorted = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  double get savingsRate => totalIncome > 0 
      ? (netSavings / totalIncome * 100) 
      : 0;
}

class TasksInsights {
  final int tasksCreated;
  final int tasksCompleted;
  final int habitsTotal;
  final int habitsAvgCompleted;
  final int totalStreakDays;
  final int longestStreak;

  TasksInsights({
    this.tasksCreated = 0,
    this.tasksCompleted = 0,
    this.habitsTotal = 0,
    this.habitsAvgCompleted = 0,
    this.totalStreakDays = 0,
    this.longestStreak = 0,
  });

  double get completionRate => tasksCreated > 0 
      ? (tasksCompleted / tasksCreated * 100) 
      : 0;

  double get habitRate => habitsTotal > 0 
      ? (habitsAvgCompleted / habitsTotal * 100) 
      : 0;
}
```

---

## ขั้นตอนที่ 2: สร้าง Folder Structure

```
lib/features/insights/
├── models/
│   └── weekly_insights.dart
├── providers/
│   └── insights_provider.dart
├── services/
│   └── insights_service.dart
├── presentation/
│   └── weekly_summary_screen.dart
└── widgets/
    ├── health_summary_card.dart
    ├── finance_summary_card.dart
    └── tasks_summary_card.dart
```

---

## ขั้นตอนที่ 3: สร้าง Insights Provider

**สร้างไฟล์:** `lib/features/insights/providers/insights_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../health/models/food_entry.dart';
import '../../health/models/workout_entry.dart';
import '../../health/models/other_health_entry.dart';
import '../../finance/models/transaction.dart';
import '../../tasks/models/task.dart';
import '../../tasks/models/habit.dart';
import '../../tasks/models/habit_log.dart';
import '../models/weekly_insights.dart';

// ============================================
// WEEK SELECTOR
// ============================================

final selectedWeekProvider = StateProvider<DateTime>((ref) {
  // Default to current week
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
});

// ============================================
// WEEKLY INSIGHTS
// ============================================

final weeklyInsightsProvider = FutureProvider<WeeklyInsights>((ref) async {
  final weekStart = ref.watch(selectedWeekProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));

  // Parallel fetch
  final healthFuture = _fetchHealthInsights(weekStart, weekEnd);
  final financeFuture = _fetchFinanceInsights(weekStart, weekEnd);
  final tasksFuture = _fetchTasksInsights(weekStart, weekEnd);

  final results = await Future.wait([
    healthFuture,
    financeFuture,
    tasksFuture,
  ]);

  final health = results[0] as HealthInsights;
  final finance = results[1] as FinanceInsights;
  final tasks = results[2] as TasksInsights;

  // Generate AI insights
  final aiInsights = _generateInsights(health, finance, tasks);

  return WeeklyInsights(
    weekStart: weekStart,
    weekEnd: weekEnd,
    health: health,
    finance: finance,
    tasks: tasks,
    aiInsights: aiInsights,
  );
});

Future<HealthInsights> _fetchHealthInsights(DateTime start, DateTime end) async {
  // Food entries
  final foodEntries = await DatabaseService.foodEntries
      .filter()
      .dateBetween(start, end)
      .findAll();

  final totalCalories = foodEntries.fold<int>(
    0, (sum, e) => sum + (e.calories?.toInt() ?? 0),
  );
  final days = foodEntries.map((e) => 
    DateTime(e.date!.year, e.date!.month, e.date!.day)
  ).toSet().length;
  final avgCalories = days > 0 ? (totalCalories / days).round() : 0;

  // Workouts
  final workouts = await DatabaseService.workoutEntries
      .filter()
      .dateBetween(start, end)
      .findAll();

  // Weight
  final weights = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.weight)
      .timestampBetween(start, end)
      .sortByTimestamp()
      .findAll();

  // Water
  final waterEntries = await DatabaseService.otherHealthEntries
      .filter()
      .entryTypeEqualTo(HealthEntryType.water)
      .timestampBetween(start, end)
      .findAll();
  final totalWater = waterEntries.fold<double>(
    0, (sum, e) => sum + (e.waterMl ?? 0),
  );
  final waterDays = waterEntries.map((e) => 
    DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)
  ).toSet().length;

  return HealthInsights(
    avgCalories: avgCalories,
    targetCalories: 2000, // TODO: from profile
    workoutsCompleted: workouts.length,
    workoutsTarget: 5, // TODO: from active program
    weightStart: weights.isNotEmpty ? weights.first.weightKg : null,
    weightEnd: weights.isNotEmpty ? weights.last.weightKg : null,
    waterAvgMl: waterDays > 0 ? totalWater / waterDays : 0,
  );
}

Future<FinanceInsights> _fetchFinanceInsights(DateTime start, DateTime end) async {
  final transactions = await DatabaseService.transactions
      .filter()
      .dateBetween(start, end)
      .findAll();

  double income = 0;
  double expense = 0;
  Map<String, double> byCategory = {};

  for (final txn in transactions) {
    if (txn.type == TransactionType.income) {
      income += txn.amount;
    } else {
      expense += txn.amount;
      byCategory[txn.category ?? 'Other'] = 
          (byCategory[txn.category ?? 'Other'] ?? 0) + txn.amount;
    }
  }

  return FinanceInsights(
    totalIncome: income,
    totalExpense: expense,
    netSavings: income - expense,
    expenseByCategory: byCategory,
    portfolioChangePercent: 0, // TODO: calculate from assets
  );
}

Future<TasksInsights> _fetchTasksInsights(DateTime start, DateTime end) async {
  final tasks = await DatabaseService.tasks
      .filter()
      .createdAtBetween(start, end)
      .findAll();

  final completed = tasks.where((t) => t.status == TaskStatus.completed).length;

  // Habits
  final habits = await DatabaseService.habits
      .filter()
      .isActiveEqualTo(true)
      .findAll();

  int totalLogs = 0;
  int maxStreak = 0;
  int totalStreak = 0;

  for (final habit in habits) {
    final logs = await DatabaseService.habitLogs
        .filter()
        .habitIdEqualTo(habit.id)
        .completedDateBetween(start, end)
        .findAll();
    totalLogs += logs.length;
    
    if (habit.currentStreak > maxStreak) {
      maxStreak = habit.currentStreak;
    }
    totalStreak += habit.currentStreak;
  }

  return TasksInsights(
    tasksCreated: tasks.length,
    tasksCompleted: completed,
    habitsTotal: habits.length,
    habitsAvgCompleted: habits.isNotEmpty ? (totalLogs / 7).round() : 0,
    totalStreakDays: totalStreak,
    longestStreak: maxStreak,
  );
}

List<String> _generateInsights(
  HealthInsights health,
  FinanceInsights finance,
  TasksInsights tasks,
) {
  final insights = <String>[];

  // Health insights
  if (health.workoutPercent >= 80) {
    insights.add('🏆 ออกกำลังกายครบตามเป้า! ยอดเยี่ยม!');
  } else if (health.workoutsCompleted == 0) {
    insights.add('😴 สัปดาห์นี้ยังไม่ได้ออกกำลังกายเลย ลองหาเวลาดูนะ');
  }

  if (health.weightChange != null) {
    if (health.weightChange! < -0.5) {
      insights.add('📉 น้ำหนักลดลง ${health.weightChangeString}!');
    } else if (health.weightChange! > 0.5) {
      insights.add('📈 น้ำหนักเพิ่มขึ้น ${health.weightChangeString}');
    }
  }

  // Finance insights
  if (finance.savingsRate >= 20) {
    insights.add('💰 ออมได้ ${finance.savingsRate.toStringAsFixed(0)}% ยอดเยี่ยม!');
  } else if (finance.netSavings < 0) {
    insights.add('⚠️ ใช้เงินเกินรายรับ ฿${(-finance.netSavings).toStringAsFixed(0)}');
  }

  if (finance.expenseByCategory.isNotEmpty) {
    insights.add('💸 ใช้จ่ายมากสุด: ${finance.topCategory}');
  }

  // Tasks insights
  if (tasks.completionRate >= 80) {
    insights.add('✅ ทำ Task เสร็จ ${tasks.completionRate.toStringAsFixed(0)}%!');
  }

  if (tasks.longestStreak >= 7) {
    insights.add('🔥 Streak สูงสุด ${tasks.longestStreak} วัน!');
  }

  return insights;
}
```

---

## ขั้นตอนที่ 4: สร้าง Summary Cards

**สร้างไฟล์:** `lib/features/insights/widgets/health_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/weekly_insights.dart';

class HealthSummaryCard extends StatelessWidget {
  final HealthInsights data;

  const HealthSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.health.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🍎', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'สุขภาพ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    '🔥 แคลอรี่เฉลี่ย',
                    '${data.avgCalories}',
                    '/ ${data.targetCalories}',
                    data.caloriePercent,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetric(
                    '🏃 ออกกำลัง',
                    '${data.workoutsCompleted}',
                    '/ ${data.workoutsTarget} ครั้ง',
                    data.workoutPercent,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    '⚖️ น้ำหนัก',
                    data.weightChangeString,
                    '',
                    null,
                    data.weightChange != null && data.weightChange! < 0
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetric(
                    '💧 น้ำเฉลี่ย',
                    '${(data.waterAvgMl / 1000).toStringAsFixed(1)}',
                    'ลิตร/วัน',
                    (data.waterAvgMl / 2500 * 100).clamp(0, 100),
                    Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    String unit,
    double? percent,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (percent != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (percent / 100).clamp(0, 1),
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ],
        ],
      ),
    );
  }
}
```

**สร้างไฟล์:** `lib/features/insights/widgets/finance_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/weekly_insights.dart';

class FinanceSummaryCard extends StatelessWidget {
  final FinanceInsights data;

  const FinanceSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'th');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.finance.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('💰', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'การเงิน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Income / Expense Row
            Row(
              children: [
                Expanded(
                  child: _buildAmountBox(
                    '📈 รายรับ',
                    '+฿${formatter.format(data.totalIncome)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAmountBox(
                    '📉 รายจ่าย',
                    '-฿${formatter.format(data.totalExpense)}',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAmountBox(
                    '💵 คงเหลือ',
                    '฿${formatter.format(data.netSavings)}',
                    data.netSavings >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Savings Rate
            Row(
              children: [
                const Text('อัตราออม: '),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (data.savingsRate / 100).clamp(0, 1),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      data.savingsRate >= 20 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${data.savingsRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: data.savingsRate >= 20 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (data.expenseByCategory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '📊 รายจ่ายตามหมวด',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...data.expenseByCategory.entries.take(3).map((e) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text('฿${formatter.format(e.value)}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

**สร้างไฟล์:** `lib/features/insights/widgets/tasks_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/weekly_insights.dart';

class TasksSummaryCard extends StatelessWidget {
  final TasksInsights data;

  const TasksSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.tasks.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('📅', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'งาน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStat(
                    '✅ Tasks เสร็จ',
                    '${data.tasksCompleted}/${data.tasksCreated}',
                    data.completionRate,
                    AppColors.tasks,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStat(
                    '🔄 Habits',
                    '${data.habitsAvgCompleted}/${data.habitsTotal}',
                    data.habitRate,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Streak สูงสุด',
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              '${data.longestStreak} วัน',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Streak รวม',
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              '${data.totalStreakDays} วัน',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (percent / 100).clamp(0, 1),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          const SizedBox(height: 2),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 5: สร้าง Weekly Summary Screen

**สร้างไฟล์:** `lib/features/insights/presentation/weekly_summary_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/insights_provider.dart';
import '../widgets/health_summary_card.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/tasks_summary_card.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(weeklyInsightsProvider);
    final selectedWeek = ref.watch(selectedWeekProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 สรุปสัปดาห์'),
      ),
      body: Column(
        children: [
          // Week Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    ref.read(selectedWeekProvider.notifier).state = 
                        selectedWeek.subtract(const Duration(days: 7));
                  },
                ),
                Text(
                  '${DateFormat('d MMM', 'th').format(selectedWeek)} - ${DateFormat('d MMM yyyy', 'th').format(selectedWeek.add(const Duration(days: 6)))}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: selectedWeek.add(const Duration(days: 7))
                          .isBefore(DateTime.now())
                      ? () {
                          ref.read(selectedWeekProvider.notifier).state =
                              selectedWeek.add(const Duration(days: 7));
                        }
                      : null,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: insightsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (insights) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(weeklyInsightsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // AI Insights
                      if (insights.aiInsights.isNotEmpty)
                        _buildInsightsCard(insights.aiInsights),

                      // Health Summary
                      HealthSummaryCard(data: insights.health),

                      // Finance Summary
                      FinanceSummaryCard(data: insights.finance),

                      // Tasks Summary
                      TasksSummaryCard(data: insights.tasks),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                insight,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 6: เพิ่มปุ่มเข้าถึง Insights

**แก้ไขไฟล์:** `lib/features/profile/presentation/profile_screen.dart`

**เพิ่ม ListTile ใน menu:**

```dart
import '../../insights/presentation/weekly_summary_screen.dart';

// ใน build method, เพิ่ม:
ListTile(
  leading: const Icon(Icons.insights),
  title: const Text('สรุปสัปดาห์'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeeklySummaryScreen()),
    );
  },
),
```

---

## ขั้นตอนที่ 7: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Profile → สรุปสัปดาห์**
2. **ดูข้อมูลสุขภาพ/การเงิน/งาน**
3. **เลื่อนดูสัปดาห์ก่อนหน้า**
4. **ดู AI Insights**

---

## ✅ Checklist

- [ ] สร้าง `weekly_insights.dart` model แล้ว
- [ ] สร้าง `insights_provider.dart` แล้ว
- [ ] สร้าง `health_summary_card.dart` แล้ว
- [ ] สร้าง `finance_summary_card.dart` แล้ว
- [ ] สร้าง `tasks_summary_card.dart` แล้ว
- [ ] สร้าง `weekly_summary_screen.dart` แล้ว
- [ ] เพิ่มปุ่มใน Profile screen แล้ว
- [ ] ทดสอบแสดงข้อมูลถูกต้อง
- [ ] ทดสอบเลื่อนสัปดาห์ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/insights/
├── models/
│   └── weekly_insights.dart       ← NEW
├── providers/
│   └── insights_provider.dart     ← NEW
├── widgets/
│   ├── health_summary_card.dart   ← NEW
│   ├── finance_summary_card.dart  ← NEW
│   └── tasks_summary_card.dart    ← NEW
└── presentation/
    └── weekly_summary_screen.dart ← NEW

lib/features/profile/presentation/
└── profile_screen.dart            ← UPDATED
```

---


## 🎉 Congratulations!

คุณได้ทำ Implementation Guides ครบทั้ง **22 Steps** แล้ว!

**สรุปสิ่งที่ทำได้:**
- ✅ Foundation (Setup, Models, Navigation)
- ✅ Health (Timeline, Diet, Food AI, Workout, Other, Lab)
- ✅ Finance (Timeline, Transactions, Assets)
- ✅ Tasks (Today, Calendar, Lists, Habits)
- ✅ Chat + AI Integration
- ✅ Google Calendar Sync
- ✅ Voice Input
- ✅ Weekly Insights
