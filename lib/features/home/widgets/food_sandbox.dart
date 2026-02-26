import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';

class FoodSandbox extends ConsumerStatefulWidget {
  final List<FoodEntry> entries;
  final void Function(FoodEntry entry) onTap;
  final void Function(List<FoodEntry> selected) onDeleteSelected;
  final void Function(List<FoodEntry> selected) onAnalyzeSelected;

  const FoodSandbox({
    super.key,
    required this.entries,
    required this.onTap,
    required this.onDeleteSelected,
    required this.onAnalyzeSelected,
  });

  @override
  ConsumerState<FoodSandbox> createState() => _FoodSandboxState();
}

class _FoodSandboxState extends ConsumerState<FoodSandbox>
    with TickerProviderStateMixin {
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  void _enterSelectionMode(int entryId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectionMode = true;
      _selectedIds.add(entryId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(int entryId) {
    setState(() {
      if (_selectedIds.contains(entryId)) {
        _selectedIds.remove(entryId);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(entryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sort by timestamp ascending (oldest first = top-left)
    final sorted = List<FoodEntry>.from(widget.entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selection action bar
        if (_selectionMode) _buildSelectionBar(l10n, isDark),

        // Empty state
        if (sorted.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxxl),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: isDark ? Colors.white24 : AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.sandboxEmpty,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: sorted.map((entry) {
                final isSelected = _selectedIds.contains(entry.id);
                return _FoodBubble(
                  entry: entry,
                  isSelectionMode: _selectionMode,
                  isSelected: isSelected,
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelection(entry.id);
                    } else {
                      widget.onTap(entry);
                    }
                  },
                  onLongPress: () {
                    if (!_selectionMode) {
                      _enterSelectionMode(entry.id);
                    }
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionBar(L10n l10n, bool isDark) {
    final selectedEntries = widget.entries
        .where((e) => _selectedIds.contains(e.id))
        .toList();
    final unanalyzedSelected =
        selectedEntries.where((e) => !e.hasNutritionData).toList();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Count
          Text(
            '${_selectedIds.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          const Spacer(),

          // Delete selected
          GestureDetector(
            onTap: () {
              widget.onDeleteSelected(selectedEntries);
              _exitSelectionMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.deleteSelected,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),

          // Analyze selected (only if some are unanalyzed)
          if (unanalyzedSelected.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                widget.onAnalyzeSelected(unanalyzedSelected);
                _exitSelectionMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.analyzeSelected,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Close selection
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _exitSelectionMode,
            child: Icon(Icons.close_rounded,
                size: 20,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// แต่ละ bubble ใน sandbox
class _FoodBubble extends StatefulWidget {
  final FoodEntry entry;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FoodBubble({
    required this.entry,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_FoodBubble> createState() => _FoodBubbleState();
}

class _FoodBubbleState extends State<_FoodBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    // Wiggle: rotate สลับ -2 ถึง +2 degrees
    _wiggleAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant _FoodBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelectionMode && !_wiggleController.isAnimating) {
      // Random delay ให้ bubble สั่นไม่พร้อมกัน
      Future.delayed(Duration(milliseconds: Random().nextInt(100)), () {
        if (mounted && widget.isSelectionMode) {
          _wiggleController.repeat(reverse: true);
        }
      });
    } else if (!widget.isSelectionMode) {
      _wiggleController.stop();
      _wiggleController.reset();
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();
    final isUnanalyzed = !entry.hasNutritionData;
    final isProduct = entry.searchMode == FoodSearchMode.product;

    // Border color differs between normal items and products
    Color borderColor;
    if (widget.isSelected) {
      borderColor = AppColors.primary;
    } else if (isUnanalyzed) {
      borderColor = AppColors.warning.withValues(alpha: 0.4);
    } else if (isProduct) {
      borderColor = isDark
          ? AppColors.health.withValues(alpha: 0.6)
          : AppColors.health.withValues(alpha: 0.5);
    } else {
      borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    }

    Widget bubble = GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 105,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : isProduct
                  ? (isDark
                      ? AppColors.health.withValues(alpha: 0.08)
                      : AppColors.health.withValues(alpha: 0.05))
                  : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: borderColor,
            width: widget.isSelected ? 2 : (isProduct ? 1.5 : 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product badge
            if (isProduct && !isUnanalyzed)
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.health.withValues(alpha: 0.2)
                      : AppColors.health.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FoodSearchMode.product.icon, size: 8,
                        color: isDark ? AppColors.health : AppColors.health),
                    const SizedBox(width: 2),
                    Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.health : AppColors.health,
                      ),
                    ),
                  ],
                ),
              ),
            // Image (แสดงเฉพาะเมื่อมีรูป)
            if (hasImage) ...[
              ClipRRect(
                borderRadius: AppRadius.sm,
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Image.file(
                    File(entry.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            // Name
            Text(
              entry.foodName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            // Calories
            Text(
              isUnanalyzed ? '-- kcal' : '${entry.calories.toInt()} kcal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isUnanalyzed ? AppColors.warning : AppColors.health,
              ),
            ),
            // Macros row
            if (!isUnanalyzed)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _macroText('P${entry.protein.toInt()}', AppColors.protein),
                  const SizedBox(width: 3),
                  _macroText('C${entry.carbs.toInt()}', AppColors.carbs),
                  const SizedBox(width: 3),
                  _macroText('F${entry.fat.toInt()}', AppColors.fat),
                ],
              ),

            // Selection checkbox overlay
            if (widget.isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  widget.isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: widget.isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );

    // Wiggle animation ตอนอยู่ใน selection mode
    if (widget.isSelectionMode) {
      return AnimatedBuilder(
        animation: _wiggleAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _wiggleAnimation.value,
            child: child,
          );
        },
        child: bubble,
      );
    }

    return bubble;
  }

  Widget _macroText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
