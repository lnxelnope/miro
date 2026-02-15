/// Summary of surplus/deficit over a time period
class TimePeriodSummary {
  final String label; // "1 Day", "1 Week", etc.
  final int days;
  final double totalCaloriesDifference;
  final double totalProteinDifference;
  final double totalCarbsDifference;
  final double totalFatDifference;
  final double averageCaloriesPerDay;
  final double averageProteinPerDay;
  final double averageCarbsPerDay;
  final double averageFatPerDay;

  const TimePeriodSummary({
    required this.label,
    required this.days,
    required this.totalCaloriesDifference,
    required this.totalProteinDifference,
    required this.totalCarbsDifference,
    required this.totalFatDifference,
    required this.averageCaloriesPerDay,
    required this.averageProteinPerDay,
    required this.averageCarbsPerDay,
    required this.averageFatPerDay,
  });

  bool get isCaloriesSurplus => totalCaloriesDifference > 0;
  bool get isProteinSurplus => totalProteinDifference > 0;
  bool get isCarbsSurplus => totalCarbsDifference > 0;
  bool get isFatSurplus => totalFatDifference > 0;
}
