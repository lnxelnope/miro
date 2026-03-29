/// Days ahead of today (inclusive of the last selectable calendar day) for meal planning.
const int planningHorizonDays = 365;

DateTime _planningDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Last calendar day the user may select in date pickers / forward navigation (inclusive).
DateTime getMaxPlanningDate() {
  return _planningDateOnly(DateTime.now())
      .add(const Duration(days: planningHorizonDays));
}

/// True if [d] (date-only) is not after [getMaxPlanningDate].
bool isOnOrBeforePlanningHorizon(DateTime d) {
  return !_planningDateOnly(d).isAfter(getMaxPlanningDate());
}
