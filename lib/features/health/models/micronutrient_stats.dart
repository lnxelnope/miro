/// Statistics for a single micronutrient over time
class MicronutrientStats {
  final String name;
  final String key;
  final String unit;
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final double yearlyAverage;
  final double? fdaDailyValue;
  final List<DailyValue> dailyValues;

  const MicronutrientStats({
    required this.name,
    required this.key,
    required this.unit,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.yearlyAverage,
    this.fdaDailyValue,
    required this.dailyValues,
  });

  double get percentOfFda =>
      fdaDailyValue != null && fdaDailyValue! > 0
          ? (dailyAverage / fdaDailyValue!) * 100
          : 0;
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
  final MicronutrientStats? transFat;
  final MicronutrientStats? unsaturatedFat;
  final MicronutrientStats? monounsaturatedFat;
  final MicronutrientStats? polyunsaturatedFat;
  final MicronutrientStats? potassium;

  const MicronutrientStatistics({
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.unsaturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.potassium,
  });

  bool get hasAnyData =>
      fiber != null ||
      sugar != null ||
      sodium != null ||
      cholesterol != null ||
      saturatedFat != null ||
      transFat != null ||
      potassium != null;

  List<MicronutrientStats> get allStats => [
        if (fiber != null) fiber!,
        if (sugar != null) sugar!,
        if (sodium != null) sodium!,
        if (cholesterol != null) cholesterol!,
        if (saturatedFat != null) saturatedFat!,
        if (transFat != null) transFat!,
        if (unsaturatedFat != null) unsaturatedFat!,
        if (monounsaturatedFat != null) monounsaturatedFat!,
        if (polyunsaturatedFat != null) polyunsaturatedFat!,
        if (potassium != null) potassium!,
      ];
}
