import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/database/model_extensions.dart';
import '../../../core/utils/batch_analysis_helper.dart';
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

  /// ID of the entry currently being analyzed (for per-item UI)
  final int? currentItemId;

  /// IDs of entries waiting to be analyzed (for grey-out UI)
  final Set<int> pendingItemIds;

  const AnalysisState({
    this.isAnalyzing = false,
    this.total = 0,
    this.current = 0,
    this.currentItemName = '',
    this.cancelRequested = false,
    this.currentItemId,
    this.pendingItemIds = const {},
  });

  /// Check if a specific entry is currently being analyzed
  bool isItemAnalyzing(int id) => currentItemId == id;

  /// Check if a specific entry is pending (queued but not yet started)
  bool isItemPending(int id) =>
      pendingItemIds.contains(id) && currentItemId != id;

  /// Check if a specific entry is in any analysis state (analyzing or pending)
  bool isItemInQueue(int id) =>
      currentItemId == id || pendingItemIds.contains(id);

  AnalysisState copyWith({
    bool? isAnalyzing,
    int? total,
    int? current,
    String? currentItemName,
    bool? cancelRequested,
    int? Function()? currentItemId,
    Set<int>? pendingItemIds,
  }) {
    return AnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      total: total ?? this.total,
      current: current ?? this.current,
      currentItemName: currentItemName ?? this.currentItemName,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      currentItemId:
          currentItemId != null ? currentItemId() : this.currentItemId,
      pendingItemIds: pendingItemIds ?? this.pendingItemIds,
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

    // Collect all pending IDs from queue
    final allPendingIds = <int>{};
    for (final job in _queue) {
      allPendingIds.addAll(job.entries.map((e) => e.id));
    }

    state = state.copyWith(
      isAnalyzing: true,
      total: _completedItems + _queuedItemCount,
      cancelRequested: false,
      pendingItemIds: allPendingIds,
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
        _emitProgress(0, 0, '', null);
        continue;
      }

      await BatchAnalysisHelper.analyzeEntries(
        ref: ref,
        entries: job.entries,
        selectedDate: job.selectedDate,
        onProgress: (batchCurrent, batchTotal, itemName, {int? itemId}) {
          _emitProgress(batchCurrent, batchTotal, itemName, itemId);
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

  void _emitProgress(
      int batchCurrent, int batchTotal, String itemName, int? itemId) {
    if (!mounted) return;

    // Remove completed item from pending set
    final updatedPending = Set<int>.from(state.pendingItemIds);
    if (itemId != null) updatedPending.remove(itemId);

    state = state.copyWith(
      isAnalyzing: true,
      current: _completedItems + batchCurrent,
      total: _completedItems + batchTotal + _queuedItemCount,
      currentItemName: itemName,
      currentItemId: () => itemId,
      pendingItemIds: updatedPending,
    );
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});
