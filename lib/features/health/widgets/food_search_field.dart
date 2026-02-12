import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/data/global_food_database.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_colors.dart';

/// Callback when a food is selected from search results
typedef OnFoodSelected = void Function(GlobalFoodData food);

/// Search field with autocomplete for food database
/// Note: Search works with English food names only
class FoodSearchField extends StatefulWidget {
  final TextEditingController controller;
  final OnFoodSelected? onFoodSelected;
  final String? labelText;
  final String? hintText;

  const FoodSearchField({
    super.key,
    required this.controller,
    this.onFoodSelected,
    this.labelText,
    this.hintText,
  });

  @override
  State<FoodSearchField> createState() => _FoodSearchFieldState();
}

class _FoodSearchFieldState extends State<FoodSearchField> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<GlobalFoodData> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(widget.controller.text);
    });
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      _removeOverlay();
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await GlobalFoodDatabase.search(query, limit: 8);
      _suggestions = results;
      
      if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      AppLogger.error('Food search error', e);
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null 
            ? (context.findRenderObject() as RenderBox).size.width 
            : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final food = _suggestions[index];
                  return _buildSuggestionTile(food);
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSuggestionTile(GlobalFoodData food) {
    return InkWell(
      onTap: () => _selectFood(food),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${food.calories.toInt()} kcal • ${food.servingSize.toInt()}${food.servingUnit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Macros preview
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMacroChip('P', food.protein, AppColors.protein),
                const SizedBox(width: 4),
                _buildMacroChip('C', food.carbs, AppColors.carbs),
                const SizedBox(width: 4),
                _buildMacroChip('F', food.fat, AppColors.fat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${value.toInt()}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _selectFood(GlobalFoodData food) {
    widget.controller.text = food.name;
    _removeOverlay();
    _focusNode.unfocus();
    widget.onFoodSelected?.call(food);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'Food Name *',
          hintText: widget.hintText ?? 'Search in English (e.g. Fried Rice)',
          helperText: '🔍 Type to search from 20k+ foods (English only)',
          helperStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        _removeOverlay();
                      },
                    )
                  : const Icon(Icons.search),
        ),
      ),
    );
  }
}
