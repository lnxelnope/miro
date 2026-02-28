import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // ── ช่วงวันที่แสดง ──

  /// วันแรกของช่วงที่เลือก (อิง selectedDate)
  DateTime get _rangeStart {
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate;
      case SummaryPeriod.week:
        // เริ่มต้นสัปดาห์ = วันจันทร์
        final weekday = selectedDate.weekday; // 1=Mon, 7=Sun
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

  DateTime get _rangeEnd {
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate;
      case SummaryPeriod.week:
        return _rangeStart.add(const Duration(days: 6));
      case SummaryPeriod.month:
        return DateTime(selectedDate.year, selectedDate.month + 1, 0);
      case SummaryPeriod.year:
        return DateTime(selectedDate.year, 12, 31);
      case SummaryPeriod.all:
        return DateTime.now();
    }
  }

  String _formatLabel() {
    switch (period) {
      case SummaryPeriod.day:
        return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
      case SummaryPeriod.week:
        final start = _rangeStart;
        final end = _rangeEnd;
        // ถ้าต่างเดือน → แสดงทั้งคู่
        if (start.month != end.month) {
          return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d, yyyy').format(end)}';
        }
        return '${DateFormat('MMM d').format(start)} – ${DateFormat('d, yyyy').format(end)}';
      case SummaryPeriod.month:
        return DateFormat('MMMM yyyy').format(selectedDate);
      case SummaryPeriod.year:
        return selectedDate.year.toString();
      case SummaryPeriod.all:
        return 'All Time';
    }
  }

  bool get _isCurrentPeriod {
    final now = DateTime.now();
    switch (period) {
      case SummaryPeriod.day:
        return selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;
      case SummaryPeriod.week:
        final start = _rangeStart;
        final end = _rangeEnd;
        return !now.isBefore(start) && !now.isAfter(end);
      case SummaryPeriod.month:
        return selectedDate.year == now.year && selectedDate.month == now.month;
      case SummaryPeriod.year:
        return selectedDate.year == now.year;
      case SummaryPeriod.all:
        return true;
    }
  }

  bool get _canGoForward {
    if (period == SummaryPeriod.all) return false;
    return !_isCurrentPeriod;
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
    if (!_canGoForward) return;
    switch (period) {
      case SummaryPeriod.day:
        onDateChanged(selectedDate.add(const Duration(days: 1)));
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

  String get _badgeText {
    switch (period) {
      case SummaryPeriod.day:
        return 'Today';
      case SummaryPeriod.week:
        return 'This Week';
      case SummaryPeriod.month:
        return 'This Month';
      case SummaryPeriod.year:
        return 'This Year';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ◀ ย้อนหลัง
          IconButton(
            icon: Icon(Icons.chevron_left, color: iconColor),
            onPressed: period == SummaryPeriod.all ? null : _goBack,
            tooltip: _prevTooltip,
          ),

          const SizedBox(width: 4),

          // ── ป้ายวันที่ / ช่วงเวลา ──
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
                      _formatLabel(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isCurrentPeriod && period != SummaryPeriod.all) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Text(
                          _badgeText,
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

          // ▶ ไปข้างหน้า
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: _canGoForward ? iconColor : iconColor.withValues(alpha: 0.3)),
            onPressed: _canGoForward ? _goForward : null,
            tooltip: _nextTooltip,
          ),
        ],
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    if (period == SummaryPeriod.day || period == SummaryPeriod.week) {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) onDateChanged(picked);
    } else if (period == SummaryPeriod.month) {
      // Month picker — แสดง date picker แล้วเอาแค่ปีและเดือน
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        helpText: 'Select month',
      );
      if (picked != null) {
        onDateChanged(DateTime(picked.year, picked.month, 1));
      }
    }
  }

  String get _prevTooltip {
    switch (period) {
      case SummaryPeriod.day: return 'Previous day';
      case SummaryPeriod.week: return 'Previous week';
      case SummaryPeriod.month: return 'Previous month';
      case SummaryPeriod.year: return 'Previous year';
      case SummaryPeriod.all: return '';
    }
  }

  String get _nextTooltip {
    switch (period) {
      case SummaryPeriod.day: return 'Next day';
      case SummaryPeriod.week: return 'Next week';
      case SummaryPeriod.month: return 'Next month';
      case SummaryPeriod.year: return 'Next year';
      case SummaryPeriod.all: return '';
    }
  }
}
