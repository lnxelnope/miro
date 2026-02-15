/// Statistics for a single micronutrient over time
class MicronutrientStats {
  final String name;
  final String unit;
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final double yearlyAverage;
  final List<DailyValue> dailyValues; // Last 30 days

  const MicronutrientStats({
    required this.name,
    required this.unit,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.yearlyAverage,
    required this.dailyValues,
  });
}

/// A single day's micronutrient value
class DailyValue {
  final DateTime date;
  final double value;

  const DailyValue({
    required this.date,
    required this.value,
  });
}

/// All micronutrient statistics
class MicronutrientStatistics {
  final MicronutrientStats? fiber;
  final MicronutrientStats? sugar;
  final MicronutrientStats? sodium;
  final MicronutrientStats? cholesterol;
  final MicronutrientStats? saturatedFat;

  const MicronutrientStatistics({
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
  });

  bool get hasAnyData =>
      fiber != null ||
      sugar != null ||
      sodium != null ||
      cholesterol != null ||
      saturatedFat != null;
}
