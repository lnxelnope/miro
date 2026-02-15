import 'package:flutter/material.dart';
import 'package:miro_hybrid/features/health/models/nutrition_summary.dart';

class GoalsVsActualTable extends StatelessWidget {
  final NutritionSummary summary;

  const GoalsVsActualTable({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals vs Actual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  children: [
                    _buildHeaderCell('Nutrient'),
                    _buildHeaderCell('Goal'),
                    _buildHeaderCell('Actual'),
                    _buildHeaderCell('Diff'),
                  ],
                ),
                
                // Calories row
                _buildDataRow(
                  'Calories',
                  '${summary.goalCalories.toStringAsFixed(0)} kcal',
                  '${summary.actualCalories.toStringAsFixed(0)} kcal',
                  summary.caloriesDifference,
                  summary.isCaloriesOver,
                ),
                
                // Protein row
                _buildDataRow(
                  'Protein',
                  '${summary.goalProtein.toStringAsFixed(1)} g',
                  '${summary.actualProtein.toStringAsFixed(1)} g',
                  summary.proteinDifference,
                  summary.isProteinOver,
                ),
                
                // Carbs row
                _buildDataRow(
                  'Carbohydrates',
                  '${summary.goalCarbs.toStringAsFixed(1)} g',
                  '${summary.actualCarbs.toStringAsFixed(1)} g',
                  summary.carbsDifference,
                  summary.isCarbsOver,
                ),
                
                // Fat row
                _buildDataRow(
                  'Fat',
                  '${summary.goalFat.toStringAsFixed(1)} g',
                  '${summary.actualFat.toStringAsFixed(1)} g',
                  summary.fatDifference,
                  summary.isFatOver,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(
    String nutrient,
    String goal,
    String actual,
    double difference,
    bool isOver,
  ) {
    final diffText = difference >= 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0);
    final diffColor = isOver ? Colors.red : Colors.green;

    return TableRow(
      children: [
        _buildDataCell(nutrient, fontWeight: FontWeight.w600),
        _buildDataCell(goal),
        _buildDataCell(actual),
        _buildDataCell(
          diffText,
          color: diffColor,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildDataCell(
    String text, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
