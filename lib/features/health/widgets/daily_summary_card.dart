import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../presentation/today_summary_dashboard_screen.dart';

class DailySummaryCard extends ConsumerWidget {
  /// วันที่ที่ต้องการแสดงสรุป (ถ้าไม่ระบุ = วันนี้)
  final DateTime? selectedDate;

  const DailySummaryCard({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = selectedDate ?? dateOnly(DateTime.now());
    final isToday = _isToday(date);

    // ใช้ foodEntriesByDateProvider(date) แทน todayCaloriesProvider
    final foodsAsync = ref.watch(foodEntriesByDateProvider(date));
    final profileAsync = ref.watch(profileNotifierProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TodaySummaryDashboardScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20), // เปลี่ยนจาก 16 → 20
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // เปลี่ยนจาก gradient → สีขาว/เทา
          borderRadius: AppRadius.lg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), // เปลี่ยน shadow
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // เพิ่มบรรทัดนี้
          children: [
            // ===== ส่วนที่ 1: Title + Circular Progress =====
            profileAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
              data: (profile) => foodsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error'),
                data: (entries) {
                  final calories =
                      entries.fold<double>(0, (sum, e) => sum + e.calories);
                  final protein =
                      entries.fold<double>(0, (sum, e) => sum + e.protein);
                  final carbs =
                      entries.fold<double>(0, (sum, e) => sum + e.carbs);
                  final fat = entries.fold<double>(0, (sum, e) => sum + e.fat);

                  final goal = profile.calorieGoal;
                  final percent =
                      goal > 0 ? (calories / goal).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    children: [
                      // Row 1: Title ซ้าย + Circular Progress ขวา
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== ฝั่งซ้าย: Title + Subtitle =====
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isToday ? "Today's Intake" : "Daily Intake",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 24,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isToday
                                      ? DateFormat('EEEE, d MMM', 'en')
                                          .format(date)
                                      : DateFormat('d MMMM yyyy', 'en')
                                          .format(date),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // ===== ฝั่งขวา: Circular Progress =====
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: percent,
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.divider,
                                    valueColor: const AlwaysStoppedAnimation(
                                        AppColors.primary),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${calories.toInt()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '/ ${goal.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Text(
                                      'kcal',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Row 2: Macros
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMacroItem(
                            label: 'Protein',
                            value: protein,
                            goal: profile.proteinGoal,
                            color: AppColors.protein,
                          ),
                          _buildMacroItem(
                            label: 'Carbs',
                            value: carbs,
                            goal: profile.carbGoal,
                            color: AppColors.carbs,
                          ),
                          _buildMacroItem(
                            label: 'Fat',
                            value: fat,
                            goal: profile.fatGoal,
                            color: AppColors.fat,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildMacroItem({
    required String label,
    required double value,
    required double goal,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}g',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            '/ ${goal.toInt()}g',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
