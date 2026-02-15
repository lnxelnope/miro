import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/micronutrient_stats.dart';
import '../providers/micronutrient_stats_provider.dart';

class MicronutrientChartsSection extends ConsumerStatefulWidget {
  const MicronutrientChartsSection({super.key});

  @override
  ConsumerState<MicronutrientChartsSection> createState() =>
      _MicronutrientChartsSectionState();
}

class _MicronutrientChartsSectionState
    extends ConsumerState<MicronutrientChartsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(micronutrientStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (!stats.hasAnyData) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with expand/collapse button
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.show_chart,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Micronutrient Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (_isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing average daily intake. No goals set for micronutrients.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Individual micronutrient charts
                      if (stats.fiber != null)
                        _buildMicronutrientCard(
                          stats.fiber!,
                          Colors.green,
                          Icons.grass,
                        ),
                      
                      if (stats.sugar != null)
                        _buildMicronutrientCard(
                          stats.sugar!,
                          Colors.pink,
                          Icons.cake,
                        ),
                      
                      if (stats.sodium != null)
                        _buildMicronutrientCard(
                          stats.sodium!,
                          Colors.orange,
                          Icons.water_drop,
                        ),
                      
                      if (stats.cholesterol != null)
                        _buildMicronutrientCard(
                          stats.cholesterol!,
                          Colors.red,
                          Icons.favorite,
                        ),
                      
                      if (stats.saturatedFat != null)
                        _buildMicronutrientCard(
                          stats.saturatedFat!,
                          Colors.purple,
                          Icons.opacity,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildMicronutrientCard(
    MicronutrientStats stats,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stats.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Average values
          Row(
            children: [
              Expanded(
                child: _buildAverageBox(
                  'Daily',
                  stats.dailyAverage,
                  stats.unit,
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAverageBox(
                  'Weekly',
                  stats.weeklyAverage,
                  stats.unit,
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAverageBox(
                  'Monthly',
                  stats.monthlyAverage,
                  stats.unit,
                  color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chart (last 30 days)
          if (stats.dailyValues.isNotEmpty) ...[
            const Text(
              'Last 30 Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: _buildLineChart(stats, color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAverageBox(
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(MicronutrientStats stats, Color color) {
    if (stats.dailyValues.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final spots = stats.dailyValues
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    final maxY = stats.dailyValues.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 5 : 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: stats.dailyValues.length > 10 ? stats.dailyValues.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < stats.dailyValues.length) {
                  final date = stats.dailyValues[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (stats.dailyValues.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
