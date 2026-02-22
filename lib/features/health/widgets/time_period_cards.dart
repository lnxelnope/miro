import 'package:flutter/material.dart';
import 'package:miro_hybrid/features/health/models/time_period_summary.dart';
import '../../../core/theme/app_colors.dart';

class TimePeriodCards extends StatelessWidget {
  final List<TimePeriodSummary> summaries;

  const TimePeriodCards({
    super.key,
    required this.summaries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Time Period Summaries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...summaries.map((summary) => _buildPeriodCard(summary)),
      ],
    );
  }

  Widget _buildPeriodCard(TimePeriodSummary summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          summary.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${summary.days} days tracked',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Calories',
                  summary.totalCaloriesDifference,
                  summary.averageCaloriesPerDay,
                  'kcal',
                  summary.isCaloriesSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Protein',
                  summary.totalProteinDifference,
                  summary.averageProteinPerDay,
                  'g',
                  summary.isProteinSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Carbs',
                  summary.totalCarbsDifference,
                  summary.averageCarbsPerDay,
                  'g',
                  summary.isCarbsSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Fat',
                  summary.totalFatDifference,
                  summary.averageFatPerDay,
                  'g',
                  summary.isFatSurplus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double totalDiff,
    double avgPerDay,
    String unit,
    bool isSurplus,
  ) {
    final color = isSurplus ? AppColors.error : AppColors.success;
    final icon = isSurplus ? Icons.arrow_upward : Icons.arrow_downward;
    final totalText = totalDiff >= 0
        ? '+${totalDiff.toStringAsFixed(0)}'
        : totalDiff.toStringAsFixed(0);
    final avgText = avgPerDay >= 0
        ? '+${avgPerDay.toStringAsFixed(1)}'
        : avgPerDay.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Total: $totalText $unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg/day: $avgText $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
