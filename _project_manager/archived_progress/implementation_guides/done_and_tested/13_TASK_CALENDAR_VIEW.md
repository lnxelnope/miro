# Step 13: Task Calendar View

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 12 (Google Calendar Sync)

---

## 🎯 เป้าหมาย

- แสดง Calendar แบบ Month View
- แสดง Tasks/Events ในแต่ละวัน
- กดวันเพื่อดูรายละเอียด
- แสดง Events จาก Google Calendar ด้วย

---

## สิ่งที่ต้องทำ

1. เพิ่ม table_calendar package
2. สร้าง Calendar Provider
3. สร้าง Calendar Tab UI
4. สร้าง Day Events Bottom Sheet
5. เชื่อมต่อกับ Tasks Page
6. ทดสอบ

---

## ขั้นตอนที่ 1: เพิ่ม Package

**รันคำสั่ง:**

```bash
flutter pub add table_calendar
```

---

## ขั้นตอนที่ 2: สร้าง Calendar Provider

**สร้างไฟล์:** `lib/features/tasks/providers/calendar_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/calendar_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../models/task.dart';

/// Provider สำหรับวันที่ที่เลือก
final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Provider สำหรับเดือนที่กำลังแสดง
final focusedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider สำหรับ Tasks ของเดือนที่แสดง
final monthTasksProvider = FutureProvider<Map<DateTime, List<Task>>>((ref) async {
  final focusedMonth = ref.watch(focusedMonthProvider);
  
  // ดึง Tasks ทั้งเดือน
  final startOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
  final endOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0, 23, 59, 59);
  
  final tasks = await DatabaseService.tasks
      .filter()
      .dueDateBetween(startOfMonth, endOfMonth)
      .findAll();
  
  // Group by date
  final Map<DateTime, List<Task>> grouped = {};
  for (final task in tasks) {
    if (task.dueDate != null) {
      final dateKey = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(task);
    }
  }
  
  return grouped;
});

/// Provider สำหรับ Google Calendar Events ของเดือนที่แสดง
final monthGoogleEventsProvider = FutureProvider<Map<DateTime, List<CalendarEvent>>>((ref) async {
  if (!GoogleAuthService.isSignedIn) {
    return {};
  }
  
  final focusedMonth = ref.watch(focusedMonthProvider);
  
  try {
    final events = await CalendarService.getMonthEvents(
      focusedMonth.year,
      focusedMonth.month,
    );
    
    // Group by date
    final Map<DateTime, List<CalendarEvent>> grouped = {};
    for (final event in events) {
      final dateKey = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(event);
    }
    
    return grouped;
  } catch (e) {
    return {};
  }
});

/// Provider สำหรับ Tasks ของวันที่เลือก
final selectedDayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final selectedDay = ref.watch(selectedDayProvider);
  
  final startOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.tasks
      .filter()
      .dueDateBetween(startOfDay, endOfDay)
      .sortByDueTime()
      .findAll();
});

/// Provider สำหรับ Google Events ของวันที่เลือก
final selectedDayGoogleEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  if (!GoogleAuthService.isSignedIn) {
    return [];
  }
  
  final selectedDay = ref.watch(selectedDayProvider);
  
  final startOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  try {
    return await CalendarService.getEvents(start: startOfDay, end: endOfDay);
  } catch (e) {
    return [];
  }
});
```

---

## ขั้นตอนที่ 3: สร้าง Calendar Tab

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_calendar_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/calendar_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../providers/calendar_provider.dart';
import '../models/task.dart';

class TasksCalendarTab extends ConsumerStatefulWidget {
  const TasksCalendarTab({super.key});

  @override
  ConsumerState<TasksCalendarTab> createState() => _TasksCalendarTabState();
}

class _TasksCalendarTabState extends ConsumerState<TasksCalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);
    final monthTasksAsync = ref.watch(monthTasksProvider);
    final monthGoogleEventsAsync = ref.watch(monthGoogleEventsProvider);

    return Column(
      children: [
        // Calendar
        _buildCalendar(
          selectedDay: selectedDay,
          focusedMonth: focusedMonth,
          monthTasks: monthTasksAsync.valueOrNull ?? {},
          googleEvents: monthGoogleEventsAsync.valueOrNull ?? {},
        ),

        const Divider(height: 1),

        // Selected day events
        Expanded(
          child: _buildSelectedDayEvents(),
        ),
      ],
    );
  }

  Widget _buildCalendar({
    required DateTime selectedDay,
    required DateTime focusedMonth,
    required Map<DateTime, List<Task>> monthTasks,
    required Map<DateTime, List<CalendarEvent>> googleEvents,
  }) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedMonth,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: _calendarFormat,
      locale: 'th_TH',
      startingDayOfWeek: StartingDayOfWeek.sunday,

      // Header style
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: AppColors.tasks),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(color: AppColors.tasks),
        titleTextFormatter: (date, locale) {
          return DateFormat('MMMM yyyy', 'th').format(date);
        },
      ),

      // Calendar style
      calendarStyle: CalendarStyle(
        // Today
        todayDecoration: BoxDecoration(
          color: AppColors.tasks.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),

        // Selected day
        selectedDecoration: BoxDecoration(
          color: AppColors.tasks,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Markers
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: AppColors.tasks,
          shape: BoxShape.circle,
        ),
      ),

      // Events
      eventLoader: (day) {
        final dateKey = DateTime(day.year, day.month, day.day);
        final tasks = monthTasks[dateKey] ?? [];
        final events = googleEvents[dateKey] ?? [];
        
        // Return combined count
        final total = tasks.length + events.length;
        return List.generate(total > 3 ? 3 : total, (_) => null);
      },

      // Callbacks
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(selectedDayProvider.notifier).state = selectedDay;
        ref.read(focusedMonthProvider.notifier).state = focusedDay;
      },

      onPageChanged: (focusedDay) {
        ref.read(focusedMonthProvider.notifier).state = focusedDay;
      },

      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },

      // Custom builders
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          final dateKey = DateTime(date.year, date.month, date.day);
          final tasks = monthTasks[dateKey] ?? [];
          final googleEvts = googleEvents[dateKey] ?? [];

          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Task markers (blue)
                if (tasks.isNotEmpty)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: AppColors.tasks,
                      shape: BoxShape.circle,
                    ),
                  ),
                // Google Calendar markers (green)
                if (googleEvts.isNotEmpty)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final selectedDay = ref.watch(selectedDayProvider);
    final tasksAsync = ref.watch(selectedDayTasksProvider);
    final googleEventsAsync = ref.watch(selectedDayGoogleEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                _formatSelectedDate(selectedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!GoogleAuthService.isSignedIn)
                TextButton.icon(
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Sync Google'),
                  onPressed: _promptGoogleLogin,
                ),
            ],
          ),
        ),

        // Events list
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (tasks) {
              final googleEvents = googleEventsAsync.valueOrNull ?? [];
              
              if (tasks.isEmpty && googleEvents.isEmpty) {
                return _buildEmptyState();
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Tasks section
                  if (tasks.isNotEmpty) ...[
                    _buildSectionTitle('📌 Tasks', tasks.length),
                    ...tasks.map((task) => _buildTaskCard(task)),
                    const SizedBox(height: 16),
                  ],
                  
                  // Google Calendar section
                  if (googleEvents.isNotEmpty) ...[
                    _buildSectionTitle('📅 Google Calendar', googleEvents.length),
                    ...googleEvents.map((event) => _buildGoogleEventCard(event)),
                  ],
                  
                  const SizedBox(height: 80), // FAB space
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.tasks.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: AppColors.tasks,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          activeColor: AppColors.tasks,
          onChanged: (value) => _toggleTaskStatus(task),
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
        trailing: _buildPriorityIndicator(task.priority),
        onTap: () => _showTaskDetail(task),
      ),
    );
  }

  Widget _buildGoogleEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green.shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.event, color: Colors.white, size: 20),
        ),
        title: Text(event.title),
        subtitle: event.isAllDay
            ? const Text('ทั้งวัน')
            : Text(
                '${DateFormat('HH:mm').format(event.start)} - ${DateFormat('HH:mm').format(event.end)}',
              ),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () => _showGoogleEventDetail(event),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.urgent:
        color = Colors.red;
        break;
      case TaskPriority.high:
        color = Colors.orange;
        break;
      case TaskPriority.medium:
        color = Colors.blue;
        break;
      case TaskPriority.low:
        color = Colors.grey;
        break;
    }

    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'ไม่มีกิจกรรมในวันนี้',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('เพิ่ม Task'),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'วันนี้';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'พรุ่งนี้';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'เมื่อวาน';
    }

    return DateFormat('EEEE d MMMM', 'th').format(date);
  }

  void _toggleTaskStatus(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    task.status = newStatus;
    if (newStatus == TaskStatus.completed) {
      task.completedAt = DateTime.now();
    } else {
      task.completedAt = null;
    }

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.tasks.put(task);
    });

    // Refresh
    ref.invalidate(selectedDayTasksProvider);
    ref.invalidate(monthTasksProvider);
  }

  void _showTaskDetail(Task task) {
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
            if (task.dueTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(DateFormat('HH:mm').format(task.dueTime!)),
                ],
              ),
            if (task.googleEventId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sync, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Synced with Google Calendar',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ปิด'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleTaskStatus(task);
                    },
                    child: Text(
                      task.status == TaskStatus.completed
                          ? 'ยังไม่เสร็จ'
                          : 'เสร็จแล้ว',
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

  void _showGoogleEventDetail(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (event.description != null && event.description!.isNotEmpty) ...[
              Text(event.description!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  event.isAllDay
                      ? 'ทั้งวัน'
                      : '${DateFormat('HH:mm').format(event.start)} - ${DateFormat('HH:mm').format(event.end)}',
                ),
              ],
            ),
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.location!)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _promptGoogleLogin() async {
    final result = await GoogleAuthService.signIn();
    if (result != null) {
      // Refresh events
      ref.invalidate(monthGoogleEventsProvider);
      ref.invalidate(selectedDayGoogleEventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เชื่อมต่อ Google สำเร็จ: ${result.email}')),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final selectedDay = ref.read(selectedDayProvider);
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่ม Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ Task',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'วันที่: ${DateFormat('d MMMM yyyy', 'th').format(selectedDay)}',
              style: TextStyle(color: AppColors.textSecondary),
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
              if (titleController.text.trim().isEmpty) return;

              final task = Task()
                ..title = titleController.text.trim()
                ..dueDate = selectedDay
                ..status = TaskStatus.pending
                ..priority = TaskPriority.medium
                ..createdAt = DateTime.now();

              await DatabaseService.isar.writeTxn(() async {
                await DatabaseService.tasks.put(task);
              });

              // Refresh
              ref.invalidate(selectedDayTasksProvider);
              ref.invalidate(monthTasksProvider);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 4: อัปเดต Tasks Page

**แก้ไขไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'tasks_today_tab.dart';
import 'tasks_calendar_tab.dart';

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
        // Sub-tabs
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
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const TasksTodayTab(),
              const TasksCalendarTab(),  // ← แก้จาก placeholder
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

## ขั้นตอนที่ 5: เพิ่ม Import ใน Calendar Tab

**ตรวจสอบว่า import DatabaseService ถูกต้อง:**

```dart
// เพิ่มที่ต้นไฟล์ tasks_calendar_tab.dart
import '../../../core/database/database_service.dart';
```

---

## ขั้นตอนที่ 6: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **เปิดแอป → Tasks → Calendar tab**
   - ควรเห็น calendar แบบ month view
   - ควรเลื่อนเดือนได้

2. **กดวันที่ใดก็ได้**
   - ควรแสดงรายการ tasks/events ของวันนั้น

3. **สร้าง Task ใหม่ผ่าน Chat**
   - พิมพ์ "พรุ่งนี้ประชุม 14:00"
   - กลับมาดู Calendar tab
   - ควรเห็น marker ในวันพรุ่งนี้

4. **ถ้า Login Google แล้ว**
   - ควรเห็น events จาก Google Calendar ด้วย (marker สีเขียว)

---

## ✅ Checklist

- [ ] เพิ่ม `table_calendar` package แล้ว
- [ ] สร้าง `calendar_provider.dart` แล้ว
- [ ] สร้าง `tasks_calendar_tab.dart` แล้ว
- [ ] อัปเดต `tasks_page.dart` แล้ว
- [ ] Calendar แสดงได้ถูกต้อง
- [ ] เลือกวันแล้วแสดง events ได้
- [ ] Task markers แสดงถูกต้อง
- [ ] Google Calendar events แสดง (ถ้า login)
- [ ] Toggle task status ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/tasks/
├── providers/
│   └── calendar_provider.dart    ← NEW
├── presentation/
│   ├── tasks_page.dart           ← UPDATED
│   └── tasks_calendar_tab.dart   ← NEW
```

---

## ⚠️ Troubleshooting

### Error: 'th_TH' locale not found
- ตรวจสอบว่า `initializeDateFormatting('th', null)` ถูกเรียกใน `main.dart`
- ลองใช้ `'th'` แทน `'th_TH'`

### Calendar ไม่แสดง markers
- ตรวจสอบ `eventLoader` callback
- ตรวจสอบว่า tasks มี `dueDate` ที่ถูกต้อง

### Google Events ไม่แสดง
- ตรวจสอบว่า login Google แล้ว
- ตรวจสอบ Calendar API permissions

---

## ขั้นตอนถัดไป

ไป **Step 14: Task Lists** เพื่อสร้างระบบ Todo Lists และ Notes
