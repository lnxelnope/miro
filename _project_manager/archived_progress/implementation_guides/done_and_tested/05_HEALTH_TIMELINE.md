# Step 05: Health Timeline

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1.5 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 01 (Core Models), Step 02 (Home Screen)

---

## สิ่งที่ต้องทำ

1. สร้าง Health Provider สำหรับดึงข้อมูล
2. สร้าง Health Timeline Tab
3. สร้าง Timeline Card Widgets
4. สร้าง Daily Summary Card
5. เพิ่มข้อมูล Mock สำหรับทดสอบ

---

## ขั้นตอนที่ 1: สร้าง Health Provider

**สร้างไฟล์:** `lib/features/health/providers/health_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../models/workout_entry.dart';
import '../models/other_health_entry.dart';

// ===== FOOD ENTRIES =====

// Get food entries for a specific date
final foodEntriesByDateProvider = FutureProvider.family<List<FoodEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// Get today's total calories
final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final today = DateTime.now();
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);
  return entries.fold<double>(0, (sum, entry) => sum + entry.calories);
});

// Get today's macros
final todayMacrosProvider = FutureProvider<Map<String, double>>((ref) async {
  final today = DateTime.now();
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);
  
  double protein = 0, carbs = 0, fat = 0;
  for (final entry in entries) {
    protein += entry.protein;
    carbs += entry.carbs;
    fat += entry.fat;
  }
  
  return {
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
});

// ===== WORKOUT ENTRIES =====

final workoutEntriesByDateProvider = FutureProvider.family<List<WorkoutEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.workoutEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// ===== OTHER HEALTH ENTRIES =====

final otherHealthEntriesByDateProvider = FutureProvider.family<List<OtherHealthEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.otherHealthEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// ===== COMBINED TIMELINE =====

class TimelineItem {
  final String type; // 'food', 'workout', 'other'
  final DateTime timestamp;
  final dynamic data;
  
  TimelineItem({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

final healthTimelineProvider = FutureProvider.family<List<TimelineItem>, DateTime>((ref, date) async {
  final foods = await ref.watch(foodEntriesByDateProvider(date).future);
  final workouts = await ref.watch(workoutEntriesByDateProvider(date).future);
  final others = await ref.watch(otherHealthEntriesByDateProvider(date).future);
  
  final items = <TimelineItem>[];
  
  for (final food in foods) {
    items.add(TimelineItem(type: 'food', timestamp: food.timestamp, data: food));
  }
  
  for (final workout in workouts) {
    items.add(TimelineItem(type: 'workout', timestamp: workout.timestamp, data: workout));
  }
  
  for (final other in others) {
    items.add(TimelineItem(type: 'other', timestamp: other.timestamp, data: other));
  }
  
  // Sort by timestamp descending
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return items;
});

// ===== NOTIFIERS FOR ADDING DATA =====

class FoodEntriesNotifier extends StateNotifier<AsyncValue<List<FoodEntry>>> {
  FoodEntriesNotifier() : super(const AsyncValue.loading());

  Future<void> addFoodEntry(FoodEntry entry) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
  }

  Future<void> updateFoodEntry(FoodEntry entry) async {
    entry.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
  }

  Future<void> deleteFoodEntry(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.delete(id);
    });
  }
}

final foodEntriesNotifierProvider =
    StateNotifierProvider<FoodEntriesNotifier, AsyncValue<List<FoodEntry>>>((ref) {
  return FoodEntriesNotifier();
});

class WorkoutEntriesNotifier extends StateNotifier<AsyncValue<List<WorkoutEntry>>> {
  WorkoutEntriesNotifier() : super(const AsyncValue.loading());

  Future<void> addWorkoutEntry(WorkoutEntry entry) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutEntries.put(entry);
    });
  }
}

final workoutEntriesNotifierProvider =
    StateNotifierProvider<WorkoutEntriesNotifier, AsyncValue<List<WorkoutEntry>>>((ref) {
  return WorkoutEntriesNotifier();
});
```

---

## ขั้นตอนที่ 2: สร้าง Timeline Card Widgets

**สร้างไฟล์:** `lib/features/health/widgets/food_timeline_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';

class FoodTimelineCard extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const FoodTimelineCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: entry.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          entry.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.mealType.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.foodName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildCalorieBadge(),
                        const SizedBox(width: 8),
                        if (onEdit != null)
                          GestureDetector(
                            onTap: onEdit,
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildMacros(),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTime(entry.timestamp)} • ${entry.mealType.displayName}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.restaurant,
        color: AppColors.health,
        size: 28,
      ),
    );
  }

  Widget _buildCalorieBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.health.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            '${entry.calories.toInt()} kcal',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.health,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacros() {
    return Row(
      children: [
        _buildMacroChip('P', entry.protein, AppColors.protein),
        const SizedBox(width: 8),
        _buildMacroChip('C', entry.carbs, AppColors.carbs),
        const SizedBox(width: 8),
        _buildMacroChip('F', entry.fat, AppColors.fat),
      ],
    );
  }

  Widget _buildMacroChip(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        Text(
          '${value.toInt()}g',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
```

**สร้างไฟล์:** `lib/features/health/widgets/workout_timeline_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/workout_entry.dart';

class WorkoutTimelineCard extends StatelessWidget {
  final WorkoutEntry entry;
  final VoidCallback? onTap;

  const WorkoutTimelineCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    entry.activityType.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.activityName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '-${entry.caloriesBurned.toInt()} kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.durationMinutes} นาที',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (entry.distanceKm != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${entry.distanceKm!.toStringAsFixed(1)} กม.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Time
              Text(
                _formatTime(entry.timestamp),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
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

**สร้างไฟล์:** `lib/features/health/widgets/other_health_timeline_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/other_health_entry.dart';

class OtherHealthTimelineCard extends StatelessWidget {
  final OtherHealthEntry entry;
  final VoidCallback? onTap;

  const OtherHealthTimelineCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getIcon(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getSubtitle(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Time
              Text(
                _formatTime(entry.timestamp),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIcon() {
    switch (entry.entryType) {
      case HealthEntryType.supplement:
      case HealthEntryType.medicine:
        return '💊';
      case HealthEntryType.water:
        return '💧';
      case HealthEntryType.weight:
        return '⚖️';
      case HealthEntryType.bloodPressure:
        return '🩺';
      case HealthEntryType.bloodSugar:
        return '🩸';
      case HealthEntryType.heartRate:
        return '❤️';
      case HealthEntryType.sleep:
        return '😴';
      default:
        return '📊';
    }
  }

  Color _getColor() {
    switch (entry.entryType) {
      case HealthEntryType.supplement:
      case HealthEntryType.medicine:
        return Colors.purple;
      case HealthEntryType.water:
        return Colors.blue;
      case HealthEntryType.weight:
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getTitle() {
    switch (entry.entryType) {
      case HealthEntryType.supplement:
      case HealthEntryType.medicine:
        return entry.name ?? 'ยา/วิตามิน';
      case HealthEntryType.water:
        return 'ดื่มน้ำ';
      case HealthEntryType.weight:
        return 'น้ำหนัก';
      case HealthEntryType.bloodPressure:
        return 'ความดัน';
      case HealthEntryType.bloodSugar:
        return 'น้ำตาล';
      default:
        return 'สุขภาพอื่นๆ';
    }
  }

  String _getSubtitle() {
    switch (entry.entryType) {
      case HealthEntryType.supplement:
      case HealthEntryType.medicine:
        return '${entry.dosage ?? ''} ${entry.unit ?? ''}';
      case HealthEntryType.water:
        return '${entry.waterMl?.toInt() ?? 0} ml';
      case HealthEntryType.weight:
        return '${entry.weightKg ?? 0} kg';
      case HealthEntryType.bloodPressure:
        return '${entry.systolicBP ?? 0}/${entry.diastolicBP ?? 0}';
      case HealthEntryType.bloodSugar:
        return '${entry.bloodSugar ?? 0} mg/dL';
      default:
        return entry.notes ?? '';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Daily Summary Card

**สร้างไฟล์:** `lib/features/health/widgets/daily_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';

class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caloriesAsync = ref.watch(todayCaloriesProvider);
    final macrosAsync = ref.watch(todayMacrosProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

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
        children: [
          const Text(
            '📊 สรุปวันนี้',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calories
          profileAsync.when(
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, __) => const SizedBox(),
            data: (profile) => caloriesAsync.when(
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
              data: (calories) {
                final goal = profile.calorieGoal;
                final percent = (calories / goal).clamp(0.0, 1.0);
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 4),
                        Text(
                          '${calories.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${goal.toInt()} kcal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Macros
          profileAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (profile) => macrosAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (macros) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroItem(
                    label: 'Protein',
                    value: macros['protein']!,
                    goal: profile.proteinGoal,
                    color: AppColors.protein,
                  ),
                  _buildMacroItem(
                    label: 'Carbs',
                    value: macros['carbs']!,
                    goal: profile.carbGoal,
                    color: AppColors.carbs,
                  ),
                  _buildMacroItem(
                    label: 'Fat',
                    value: macros['fat']!,
                    goal: profile.fatGoal,
                    color: AppColors.fat,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
```

---

## ขั้นตอนที่ 4: สร้าง Health Timeline Tab

**สร้างไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/health_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/food_timeline_card.dart';
import '../widgets/workout_timeline_card.dart';
import '../widgets/other_health_timeline_card.dart';
import '../models/food_entry.dart';
import '../models/workout_entry.dart';
import '../models/other_health_entry.dart';

class HealthTimelineTab extends ConsumerStatefulWidget {
  const HealthTimelineTab({super.key});

  @override
  ConsumerState<HealthTimelineTab> createState() => _HealthTimelineTabState();
}

class _HealthTimelineTabState extends ConsumerState<HealthTimelineTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(healthTimelineProvider(_selectedDate));
      },
      child: CustomScrollView(
        slivers: [
          // Daily Summary Card
          const SliverToBoxAdapter(
            child: DailySummaryCard(),
          ),

          // Date Selector
          SliverToBoxAdapter(
            child: _buildDateSelector(),
          ),

          // Timeline Items
          timelineAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];

                    switch (item.type) {
                      case 'food':
                        return FoodTimelineCard(
                          entry: item.data as FoodEntry,
                          onTap: () => _showFoodDetail(item.data),
                          onEdit: () => _editFoodEntry(item.data),
                        );
                      case 'workout':
                        return WorkoutTimelineCard(
                          entry: item.data as WorkoutEntry,
                          onTap: () => _showWorkoutDetail(item.data),
                        );
                      case 'other':
                        return OtherHealthTimelineCard(
                          entry: item.data as OtherHealthEntry,
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                  childCount: items.length,
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

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('d MMM yyyy', 'th');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📅 ${isToday ? "วันนี้" : dateFormat.format(_selectedDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday
                ? null
                : () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📭',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีข้อมูล',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กดปุ่ม ✨ เพื่อเพิ่มข้อมูล',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMockData,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มข้อมูลทดสอบ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showFoodDetail(FoodEntry entry) {
    // TODO: Show food detail dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.foodName} - ${entry.calories} kcal')),
    );
  }

  void _editFoodEntry(FoodEntry entry) {
    // TODO: Open edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit - Coming Soon!')),
    );
  }

  void _showWorkoutDetail(WorkoutEntry entry) {
    // TODO: Show workout detail dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.activityName} - ${entry.caloriesBurned} kcal')),
    );
  }

  Future<void> _addMockData() async {
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final workoutNotifier = ref.read(workoutEntriesNotifierProvider.notifier);
    
    // Add mock food entries
    final food1 = FoodEntry()
      ..foodName = 'ข้าวผัดกุ้ง'
      ..calories = 520
      ..protein = 25
      ..carbs = 65
      ..fat = 18
      ..mealType = MealType.lunch
      ..timestamp = DateTime.now().subtract(const Duration(hours: 2))
      ..servingSize = 1
      ..servingUnit = 'จาน'
      ..source = DataSource.manual;
    
    final food2 = FoodEntry()
      ..foodName = 'สลัดผัก'
      ..calories = 180
      ..protein = 8
      ..carbs = 15
      ..fat = 10
      ..mealType = MealType.breakfast
      ..timestamp = DateTime.now().subtract(const Duration(hours: 6))
      ..servingSize = 1
      ..servingUnit = 'ถ้วย'
      ..source = DataSource.manual;

    await notifier.addFoodEntry(food1);
    await notifier.addFoodEntry(food2);
    
    // Add mock workout
    final workout = WorkoutEntry()
      ..activityName = 'วิ่ง'
      ..activityType = ActivityType.running
      ..caloriesBurned = 280
      ..durationMinutes = 25
      ..distanceKm = 3.0
      ..timestamp = DateTime.now().subtract(const Duration(hours: 8))
      ..source = DataSource.manual;
    
    await workoutNotifier.addWorkoutEntry(workout);

    // Refresh
    ref.invalidate(healthTimelineProvider(_selectedDate));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เพิ่มข้อมูลทดสอบสำเร็จ!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
```

---

## ขั้นตอนที่ 5: อัปเดต Health Page

**แก้ไขไฟล์:** `lib/features/health/presentation/health_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'health_timeline_tab.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
            isScrollable: true,
            labelColor: AppColors.health,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.health,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Diet'),
              Tab(text: 'Workout'),
              Tab(text: 'Other'),
              Tab(text: 'Lab'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const HealthTimelineTab(), // ← Updated!
              _buildPlaceholder('Diet', '🍽️'),
              _buildPlaceholder('Workout', '🏋️'),
              _buildPlaceholder('Other', '📦'),
              _buildPlaceholder('Lab Results', '🩺'),
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
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 6: เพิ่ม intl package และ localization

**ตรวจสอบ pubspec.yaml:**

```yaml
dependencies:
  intl: ^0.18.1
```

---

## ขั้นตอนที่ 7: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- ไปที่ tab สุขภาพ → เห็น Timeline tab
- มี Daily Summary Card ด้านบน
- สามารถเลือกวันที่ได้
- กดปุ่ม "เพิ่มข้อมูลทดสอบ" → แสดงข้อมูลใน Timeline
- แสดง Food Card และ Workout Card

---

## ✅ Checklist

- [ ] สร้าง health_provider.dart แล้ว
- [ ] สร้าง food_timeline_card.dart แล้ว
- [ ] สร้าง workout_timeline_card.dart แล้ว
- [ ] สร้าง other_health_timeline_card.dart แล้ว
- [ ] สร้าง daily_summary_card.dart แล้ว
- [ ] สร้าง health_timeline_tab.dart แล้ว
- [ ] อัปเดต health_page.dart แล้ว
- [ ] ทดสอบ run app สำเร็จ
- [ ] สามารถเพิ่มข้อมูลทดสอบและแสดงได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/health/
├── presentation/
│   ├── health_page.dart           ← UPDATED
│   └── health_timeline_tab.dart   ← NEW
├── providers/
│   └── health_provider.dart       ← NEW
└── widgets/
    ├── daily_summary_card.dart         ← NEW
    ├── food_timeline_card.dart         ← NEW
    ├── workout_timeline_card.dart      ← NEW
    └── other_health_timeline_card.dart ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 06: Health Diet Tab** เพื่อสร้างหน้า Diet ที่แสดงรายละเอียดอาหารตามมื้อ
