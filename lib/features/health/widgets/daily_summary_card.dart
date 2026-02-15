import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../presentation/today_summary_dashboard_screen.dart';

class DailySummaryCard extends ConsumerWidget {
  /// วันที่ที่ต้องการแสดงสรุป (ถ้าไม่ระบุ = วันนี้)
  final DateTime? selectedDate;

  const DailySummaryCard({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = selectedDate ?? DateTime.now();
    final isToday = _isToday(date);

    // ใช้ foodEntriesByDateProvider(date) แทน todayCaloriesProvider
    final foodsAsync = ref.watch(foodEntriesByDateProvider(date));
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
          Text(
            isToday
                ? '📊 Today\'s Summary'
                : '📊 Summary ${DateFormat('d MMM', 'en').format(date)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calories + Macros - คำนวณจาก foodEntries ของวันที่เลือก
          profileAsync.when(
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, __) => const SizedBox(),
            data: (profile) => foodsAsync.when(
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
              data: (entries) {
                final calories = entries.fold<double>(0, (sum, e) => sum + e.calories);
                final protein = entries.fold<double>(0, (sum, e) => sum + e.protein);
                final carbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);
                final fat = entries.fold<double>(0, (sum, e) => sum + e.fat);

                final goal = profile.calorieGoal;
                final percent = goal > 0 ? (calories / goal).clamp(0.0, 1.0) : 0.0;
                
                return Column(
                  children: [
                    // Calories
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(percent * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          calories >= goal
                              ? 'Goal reached! 🎉'
                              : '${(goal - calories).toInt()} kcal left',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Macros
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
                    const SizedBox(height: 12),

                    // Details button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TodaySummaryDashboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      label: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
