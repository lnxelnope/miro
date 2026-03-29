import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miro_hybrid/core/constants/date_planning_limits.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';
import '../providers/health_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../presentation/today_summary_dashboard_screen.dart';

class DateNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final SummaryPeriod period;

  const DateNavigationBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.period = SummaryPeriod.day,
  });

  DateTime _weekRangeStart(DateTime d) {
    final weekday = d.weekday;
    return dateOnly(
      DateTime(d.year, d.month, d.day),
    ).subtract(Duration(days: weekday - 1));
  }

  DateTime _weekRangeEndFromStart(DateTime start) =>
      start.add(const Duration(days: 6));

  /// วันแรกของช่วงที่เลือก (อิง selectedDate)
  DateTime _rangeStart() {
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate;
      case SummaryPeriod.week:
        final weekday = selectedDate.weekday;
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ).subtract(Duration(days: weekday - 1));
      case SummaryPeriod.month:
        return DateTime(selectedDate.year, selectedDate.month, 1);
      case SummaryPeriod.year:
        return DateTime(selectedDate.year, 1, 1);
      case SummaryPeriod.all:
        return DateTime(2020);
    }
  }

  DateTime _rangeEnd() {
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate;
      case SummaryPeriod.week:
        return _rangeStart().add(const Duration(days: 6));
      case SummaryPeriod.month:
        return DateTime(selectedDate.year, selectedDate.month + 1, 0);
      case SummaryPeriod.year:
        return DateTime(selectedDate.year, 12, 31);
      case SummaryPeriod.all:
        return getMaxPlanningDate();
    }
  }

  String _formatLabel(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toString();
    switch (period) {
      case SummaryPeriod.day:
        return DateFormat('EEEE, MMMM d, yyyy', localeTag).format(selectedDate);
      case SummaryPeriod.week:
        final start = _rangeStart();
        final end = _rangeEnd();
        if (start.month != end.month) {
          return '${DateFormat('MMM d', localeTag).format(start)} – ${DateFormat('MMM d, yyyy', localeTag).format(end)}';
        }
        return '${DateFormat('MMM d', localeTag).format(start)} – ${DateFormat('d, yyyy', localeTag).format(end)}';
      case SummaryPeriod.month:
        return DateFormat('MMMM yyyy', localeTag).format(selectedDate);
      case SummaryPeriod.year:
        return selectedDate.year.toString();
      case SummaryPeriod.all:
        return L10n.of(context)!.summaryPeriodAllTime;
    }
  }

  bool _isCurrentPeriod() {
    final now = DateTime.now();
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;
      case SummaryPeriod.week:
        final start = _rangeStart();
        final end = _rangeEnd();
        return !now.isBefore(start) && !now.isAfter(end);
      case SummaryPeriod.month:
        return selectedDate.year == now.year && selectedDate.month == now.month;
      case SummaryPeriod.year:
        return selectedDate.year == now.year;
      case SummaryPeriod.all:
        return true;
    }
  }

  bool _canGoForward() {
    if (period == SummaryPeriod.all) return false;
    final maxD = dateOnly(getMaxPlanningDate());
    switch (period) {
      case SummaryPeriod.day:
        final next = dateOnly(selectedDate).add(const Duration(days: 1));
        return !next.isAfter(maxD);
      case SummaryPeriod.week:
        final nextSel = selectedDate.add(const Duration(days: 7));
        final start = _weekRangeStart(nextSel);
        final end = _weekRangeEndFromStart(start);
        return !dateOnly(end).isAfter(maxD);
      case SummaryPeriod.month:
        final nextEnd =
            DateTime(selectedDate.year, selectedDate.month + 2, 0);
        return !dateOnly(nextEnd).isAfter(maxD);
      case SummaryPeriod.year:
        final nextEnd = DateTime(selectedDate.year + 1, 12, 31);
        return !dateOnly(nextEnd).isAfter(maxD);
      case SummaryPeriod.all:
        return false;
    }
  }

  void _goBack() {
    switch (period) {
      case SummaryPeriod.day:
        onDateChanged(selectedDate.subtract(const Duration(days: 1)));
        break;
      case SummaryPeriod.week:
        onDateChanged(selectedDate.subtract(const Duration(days: 7)));
        break;
      case SummaryPeriod.month:
        onDateChanged(DateTime(selectedDate.year, selectedDate.month - 1, 1));
        break;
      case SummaryPeriod.year:
        onDateChanged(DateTime(selectedDate.year - 1, 1, 1));
        break;
      case SummaryPeriod.all:
        break;
    }
  }

  void _goForward() {
    if (!_canGoForward()) return;
    final maxD = dateOnly(getMaxPlanningDate());
    switch (period) {
      case SummaryPeriod.day:
        final next = dateOnly(selectedDate).add(const Duration(days: 1));
        onDateChanged(next.isAfter(maxD) ? maxD : next);
        break;
      case SummaryPeriod.week:
        onDateChanged(selectedDate.add(const Duration(days: 7)));
        break;
      case SummaryPeriod.month:
        onDateChanged(DateTime(selectedDate.year, selectedDate.month + 1, 1));
        break;
      case SummaryPeriod.year:
        onDateChanged(DateTime(selectedDate.year + 1, 1, 1));
        break;
      case SummaryPeriod.all:
        break;
    }
  }

  String _badgeText(BuildContext context) {
    final l10n = L10n.of(context)!;
    switch (period) {
      case SummaryPeriod.day:
        return l10n.summaryBadgeToday;
      case SummaryPeriod.week:
        return l10n.summaryBadgeThisWeek;
      case SummaryPeriod.month:
        return l10n.summaryBadgeThisMonth;
      case SummaryPeriod.year:
        return l10n.summaryBadgeThisYear;
      case SummaryPeriod.all:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final iconColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final canFwd = _canGoForward();
    final l10n = L10n.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black)
                .withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: iconColor),
            onPressed: period == SummaryPeriod.all ? null : _goBack,
            tooltip: _prevTooltip(l10n),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              borderRadius: AppRadius.md,
              onTap: period == SummaryPeriod.all || period == SummaryPeriod.year
                  ? null
                  : () async {
                      await _showPicker(context);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Text(
                      _formatLabel(context),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isCurrentPeriod() && period != SummaryPeriod.all) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Text(
                          _badgeText(context),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: canFwd ? iconColor : iconColor.withValues(alpha: 0.3)),
            onPressed: canFwd ? _goForward : null,
            tooltip: _nextTooltip(l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final last = getMaxPlanningDate();
    final l10n = L10n.of(context)!;
    if (period == SummaryPeriod.day || period == SummaryPeriod.week) {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: last,
      );
      if (picked != null) onDateChanged(picked);
    } else if (period == SummaryPeriod.month) {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: last,
        helpText: l10n.summaryDatePickerSelectMonthHelp,
      );
      if (picked != null) {
        onDateChanged(DateTime(picked.year, picked.month, 1));
      }
    }
  }

  String _prevTooltip(L10n l10n) {
    switch (period) {
      case SummaryPeriod.day:
        return l10n.dateNavPreviousDay;
      case SummaryPeriod.week:
        return l10n.dateNavPreviousWeek;
      case SummaryPeriod.month:
        return l10n.dateNavPreviousMonth;
      case SummaryPeriod.year:
        return l10n.dateNavPreviousYear;
      case SummaryPeriod.all:
        return '';
    }
  }

  String _nextTooltip(L10n l10n) {
    switch (period) {
      case SummaryPeriod.day:
        return l10n.dateNavNextDay;
      case SummaryPeriod.week:
        return l10n.dateNavNextWeek;
      case SummaryPeriod.month:
        return l10n.dateNavNextMonth;
      case SummaryPeriod.year:
        return l10n.dateNavNextYear;
      case SummaryPeriod.all:
        return '';
    }
  }
}
