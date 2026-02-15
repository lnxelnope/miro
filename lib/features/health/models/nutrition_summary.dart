/// Summary of nutritional intake for a specific date
class NutritionSummary {
  final DateTime date;
  final double actualCalories;
  final double actualProtein;
  final double actualCarbs;
  final double actualFat;
  final double goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;

  const NutritionSummary({
    required this.date,
    required this.actualCalories,
    required this.actualProtein,
    required this.actualCarbs,
    required this.actualFat,
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFat,
  });

  // Calculate differences
  double get caloriesDifference => actualCalories - goalCalories;
  double get proteinDifference => actualProtein - goalProtein;
  double get carbsDifference => actualCarbs - goalCarbs;
  double get fatDifference => actualFat - goalFat;

  // Calculate percentages
  double get caloriesPercentage => goalCalories > 0 ? (actualCalories / goalCalories) * 100 : 0;
  double get proteinPercentage => goalProtein > 0 ? (actualProtein / goalProtein) * 100 : 0;
  double get carbsPercentage => goalCarbs > 0 ? (actualCarbs / goalCarbs) * 100 : 0;
  double get fatPercentage => goalFat > 0 ? (actualFat / goalFat) * 100 : 0;

  // Is over/under goal
  bool get isCaloriesOver => actualCalories > goalCalories;
  bool get isProteinOver => actualProtein > goalProtein;
  bool get isCarbsOver => actualCarbs > goalCarbs;
  bool get isFatOver => actualFat > goalFat;
}
