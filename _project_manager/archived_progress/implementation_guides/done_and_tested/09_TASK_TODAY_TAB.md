# Step 09: Task Today Tab

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1.5 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 01 (Core Models), Step 02 (Home Screen)

---

## สิ่งที่ต้องทำ

1. สร้าง Task Provider
2. สร้าง Today Tab พร้อม Quick Glance
3. สร้าง Task Card Widget
4. สร้าง Add Task Dialog
5. สร้าง Nudge Cards

---

## ขั้นตอนที่ 1: สร้าง Task Provider

**สร้างไฟล์:** `lib/features/tasks/providers/task_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../models/task.dart';

// ===== TASKS BY DATE =====

final tasksByDateProvider = FutureProvider.family<List<Task>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.tasks
      .filter()
      .dueDateIsNotNull()
      .dueDateBetween(startOfDay, endOfDay)
      .sortByDueTime()
      .findAll();
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  return await ref.watch(tasksByDateProvider(DateTime.now()).future);
});

// ===== PENDING TASKS (no due date) =====

final pendingTasksProvider = FutureProvider<List<Task>>((ref) async {
  return await DatabaseService.tasks
      .filter()
      .statusEqualTo(TaskStatus.pending)
      .dueDateIsNull()
      .sortByCreatedAtDesc()
      .findAll();
});

// ===== OVERDUE TASKS =====

final overdueTasksProvider = FutureProvider<List<Task>>((ref) async {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  
  return await DatabaseService.tasks
      .filter()
      .statusEqualTo(TaskStatus.pending)
      .dueDateIsNotNull()
      .dueDateLessThan(startOfToday)
      .findAll();
});

// ===== HABITS =====

final activeHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  return await DatabaseService.habits
      .filter()
      .isActiveEqualTo(true)
      .findAll();
});

final habitCompletionsForDateProvider = 
    FutureProvider.family<List<HabitCompletion>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.isar.habitCompletions
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .findAll();
});

// ===== REMINDERS =====

final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  return await DatabaseService.reminders
      .filter()
      .isActiveEqualTo(true)
      .findAll();
});

// ===== NOTIFIERS =====

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskNotifier() : super(const AsyncValue.loading());

  Future<void> addTask(Task task) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.tasks.put(task);
    });
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.tasks.put(task);
    });
  }

  Future<void> toggleTaskComplete(Task task) async {
    if (task.status == TaskStatus.completed) {
      task.status = TaskStatus.pending;
      task.completedAt = null;
    } else {
      task.status = TaskStatus.completed;
      task.completedAt = DateTime.now();
    }
    await updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.tasks.delete(id);
    });
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier();
});

class HabitNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitNotifier() : super(const AsyncValue.loading());

  Future<void> completeHabitForToday(Habit habit) async {
    final today = DateTime.now();
    final completion = HabitCompletion()
      ..habitId = habit.id
      ..date = today;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.habitCompletions.put(completion);

      // Update streak
      if (habit.lastCompletedDate != null) {
        final daysSinceLast = today.difference(habit.lastCompletedDate!).inDays;
        if (daysSinceLast == 1) {
          habit.currentStreak++;
        } else if (daysSinceLast > 1) {
          habit.currentStreak = 1;
        }
      } else {
        habit.currentStreak = 1;
      }

      if (habit.currentStreak > habit.longestStreak) {
        habit.longestStreak = habit.currentStreak;
      }

      habit.lastCompletedDate = today;
      await DatabaseService.habits.put(habit);
    });
  }
}

final habitNotifierProvider =
    StateNotifierProvider<HabitNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitNotifier();
});
```

---

## ขั้นตอนที่ 2: สร้าง Task Card Widget

**สร้างไฟล์:** `lib/features/tasks/widgets/task_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        !isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : isOverdue
                              ? AppColors.error
                              : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.dueTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(task.dueTime!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Priority indicator
              if (task.priority == TaskPriority.high ||
                  task.priority == TaskPriority.urgent) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.priority == TaskPriority.urgent
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Quick Glance Card

**สร้างไฟล์:** `lib/features/tasks/widgets/quick_glance_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../health/providers/health_provider.dart';
import '../../finance/providers/finance_provider.dart';
import '../../profile/providers/profile_provider.dart';

class QuickGlanceCard extends ConsumerWidget {
  const QuickGlanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caloriesAsync = ref.watch(todayCaloriesProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tasks.withOpacity(0.8),
            AppColors.tasks,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.tasks.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Quick Glance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Calories
              profileAsync.when(
                loading: () => _buildGlanceItem('🍎', 'kcal', '-/-'),
                error: (_, __) => _buildGlanceItem('🍎', 'kcal', '-/-'),
                data: (profile) => caloriesAsync.when(
                  loading: () => _buildGlanceItem('🍎', 'kcal', '-/${profile.calorieGoal.toInt()}'),
                  error: (_, __) => _buildGlanceItem('🍎', 'kcal', '-/${profile.calorieGoal.toInt()}'),
                  data: (calories) => _buildGlanceItem(
                    '🍎',
                    'kcal',
                    '${calories.toInt()}/${profile.calorieGoal.toInt()}',
                  ),
                ),
              ),
              
              // Workout placeholder
              _buildGlanceItem('🏃', 'Workout', 'Legs Day'),
              
              // Spending placeholder
              _buildGlanceItem('💰', 'ใช้ไป', '฿850'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlanceItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
```

---

## ขั้นตอนที่ 4: สร้าง Today Tab

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_today_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/quick_glance_card.dart';
import '../models/task.dart';

class TasksTodayTab extends ConsumerWidget {
  const TasksTodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final pendingTasksAsync = ref.watch(pendingTasksProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayTasksProvider);
        ref.invalidate(pendingTasksProvider);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            _buildDateHeader(),

            // Quick Glance
            const QuickGlanceCard(),

            // Nudges section
            _buildNudgesSection(context),

            // Today's tasks
            todayTasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (tasks) => _buildTasksSection(
                context,
                ref,
                title: '📋 Tasks วันนี้',
                tasks: tasks,
                emptyMessage: 'ไม่มี task วันนี้',
              ),
            ),

            // Pending tasks (no due date)
            pendingTasksAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (tasks) {
                if (tasks.isEmpty) return const SizedBox();
                return _buildTasksSection(
                  context,
                  ref,
                  title: '📝 Tasks อื่นๆ',
                  tasks: tasks,
                );
              },
            ),

            // Add task button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _showAddTaskDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('เพิ่ม Task'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'th');
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        '📅 ${dateFormat.format(DateTime.now())}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNudgesSection(BuildContext context) {
    // Placeholder nudges
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Nudges',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildNudgeCard(
            icon: '🍔',
            title: 'ยังไม่ได้บันทึกอาหารเที่ยง',
            actions: ['📷 ถ่ายรูป', '⏰ เตือนอีกที'],
            onAction: (action) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$action - Coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNudgeCard({
    required String icon,
    required String title,
    required List<String> actions,
    required Function(String) onAction,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: actions.map((action) {
                return ActionChip(
                  label: Text(action, style: const TextStyle(fontSize: 12)),
                  onPressed: () => onAction(action),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<Task> tasks,
    String? emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (tasks.isEmpty && emptyMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              emptyMessage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...tasks.map((task) => TaskCard(
                task: task,
                onTap: () => _showTaskDetail(context, task),
                onComplete: () async {
                  final notifier = ref.read(taskNotifierProvider.notifier);
                  await notifier.toggleTaskComplete(task);
                  ref.invalidate(todayTasksProvider);
                  ref.invalidate(pendingTasksProvider);
                },
              )),
      ],
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: 8),
              Text(task.description!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (task.dueDate != null)
                  Chip(
                    label: Text(
                      '📅 ${DateFormat('d MMM').format(task.dueDate!)}',
                    ),
                  ),
                if (task.dueTime != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      '⏰ ${DateFormat('HH:mm').format(task.dueTime!)}',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📝 เพิ่ม Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'เช่น ประชุม Team Weekly',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;

                  final task = Task()
                    ..title = titleController.text.trim()
                    ..type = TaskType.todoList
                    ..status = TaskStatus.pending
                    ..priority = TaskPriority.medium
                    ..source = TaskSource.user;

                  final notifier = ref.read(taskNotifierProvider.notifier);
                  await notifier.addTask(task);
                  ref.invalidate(pendingTasksProvider);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('เพิ่ม Task สำเร็จ!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('บันทึก'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 5: อัปเดต Tasks Page

**แก้ไขไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'tasks_today_tab.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.tasks,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.tasks,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Calendar'),
              Tab(text: 'Lists'),
              Tab(text: 'Habits'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const TasksTodayTab(), // ← Updated
              _buildPlaceholder('Calendar', '📆'),
              _buildPlaceholder('Lists', '📝'),
              _buildPlaceholder('Habits', '🔥'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist

- [ ] สร้าง task_provider.dart แล้ว
- [ ] สร้าง task_card.dart แล้ว
- [ ] สร้าง quick_glance_card.dart แล้ว
- [ ] สร้าง tasks_today_tab.dart แล้ว
- [ ] อัปเดต tasks_page.dart แล้ว
- [ ] ทดสอบเพิ่ม task ได้
- [ ] ทดสอบ check task ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/tasks/
├── presentation/
│   ├── tasks_page.dart      ← UPDATED
│   └── tasks_today_tab.dart ← NEW
├── providers/
│   └── task_provider.dart   ← NEW
└── widgets/
    ├── task_card.dart       ← NEW
    └── quick_glance_card.dart ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 10: Chat UI** เพื่อสร้าง Chat Interface
