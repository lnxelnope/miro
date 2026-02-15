import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavigationBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(selectedDate);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onDateChanged(selectedDate.subtract(const Duration(days: 1)));
            },
            tooltip: 'Previous day',
          ),

          const SizedBox(width: 8),

          // Date display with picker
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onDateChanged(picked);
                }
              },
              child: Column(
                children: [
                  Text(
                    dateFormat.format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Next day button (disabled if today or future)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isToday(selectedDate) || _isFuture(selectedDate)
                ? null
                : () {
                    onDateChanged(selectedDate.add(const Duration(days: 1)));
                  },
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }
}
