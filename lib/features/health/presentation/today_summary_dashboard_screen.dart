import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/features/health/providers/nutrition_summary_provider.dart';
import 'package:miro_hybrid/features/health/widgets/date_navigation_bar.dart';
import 'package:miro_hybrid/features/health/widgets/goals_vs_actual_table.dart';
import 'package:miro_hybrid/features/health/widgets/time_period_cards.dart';
import 'package:miro_hybrid/features/health/widgets/micronutrient_charts_section.dart';

class TodaySummaryDashboardScreen extends ConsumerStatefulWidget {
  const TodaySummaryDashboardScreen({super.key});

  @override
  ConsumerState<TodaySummaryDashboardScreen> createState() =>
      _TodaySummaryDashboardScreenState();
}

class _TodaySummaryDashboardScreenState
    extends ConsumerState<TodaySummaryDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(nutritionSummaryProvider(_selectedDate));
    final timePeriodSummariesAsync = ref.watch(timePeriodSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nutritionSummaryProvider);
          ref.invalidate(timePeriodSummariesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Navigation
              DateNavigationBar(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              const SizedBox(height: 8),

              // Today's Summary
              summaryAsync.when(
                data: (summary) => GoalsVsActualTable(summary: summary),
                loading: () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
              ),

              // Time Period Summaries
              timePeriodSummariesAsync.when(
                data: (summaries) => TimePeriodCards(summaries: summaries),
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${error.toString()}'),
                ),
              ),

              // Micronutrient Charts (from Task #11)
              const MicronutrientChartsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
