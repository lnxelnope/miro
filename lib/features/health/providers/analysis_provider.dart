import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/batch_analysis_helper.dart';
import '../models/food_entry.dart';

class _AnalysisJob {
  final List<FoodEntry> entries;
  final DateTime selectedDate;

  _AnalysisJob({required this.entries, required this.selectedDate});
}

/// Global state for analysis — survives navigation.
class AnalysisState {
  final bool isAnalyzing;
  final int total;
  final int current;
  final String currentItemName;
  final bool cancelRequested;

  const AnalysisState({
    this.isAnalyzing = false,
    this.total = 0,
    this.current = 0,
    this.currentItemName = '',
    this.cancelRequested = false,
  });

  AnalysisState copyWith({
    bool? isAnalyzing,
    int? total,
    int? current,
    String? currentItemName,
    bool? cancelRequested,
  }) {
    return AnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      total: total ?? this.total,
      current: current ?? this.current,
      currentItemName: currentItemName ?? this.currentItemName,
      cancelRequested: cancelRequested ?? this.cancelRequested,
    );
  }
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final Ref ref;
  final List<_AnalysisJob> _queue = [];
  bool _processing = false;
  int _completedItems = 0;

  AnalysisNotifier(this.ref) : super(const AnalysisState());

  int get _queuedItemCount =>
      _queue.fold(0, (int sum, j) => sum + j.entries.length);

  /// Fire-and-forget: enqueue entries for background analysis.
  /// Safe to call from any screen — even while another job is running.
  void enqueue({
    required List<FoodEntry> entries,
    required DateTime selectedDate,
  }) {
    if (entries.isEmpty) return;
    _queue.add(_AnalysisJob(entries: entries, selectedDate: selectedDate));
    if (!_processing) _completedItems = 0;
    state = state.copyWith(
      isAnalyzing: true,
      total: _completedItems + _queuedItemCount,
      cancelRequested: false,
    );
    _processQueue();
  }

  void cancel() {
    if (state.isAnalyzing) {
      state = state.copyWith(cancelRequested: true);
    }
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    while (_queue.isNotEmpty && !state.cancelRequested && mounted) {
      final job = _queue.removeAt(0);

      final hasEnergy =
          await BatchAnalysisHelper.checkEnergy(ref, job.entries.length);
      if (!hasEnergy) {
        _completedItems += job.entries.length;
        _emitProgress(0, 0, '');
        continue;
      }

      await BatchAnalysisHelper.analyzeEntries(
        ref: ref,
        entries: job.entries,
        selectedDate: job.selectedDate,
        onProgress: (batchCurrent, batchTotal, itemName) {
          _emitProgress(batchCurrent, batchTotal, itemName);
        },
        shouldCancel: () => state.cancelRequested,
      );

      _completedItems += job.entries.length;
    }

    _processing = false;
    _completedItems = 0;

    if (mounted) {
      state = const AnalysisState();
    }
  }

  void _emitProgress(int batchCurrent, int batchTotal, String itemName) {
    if (!mounted) return;
    state = state.copyWith(
      isAnalyzing: true,
      current: _completedItems + batchCurrent,
      total: _completedItems + batchTotal + _queuedItemCount,
      currentItemName: itemName,
    );
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});
