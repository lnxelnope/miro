import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/my_meal_ingredient.dart';

/// Expandable card สำหรับแสดง ingredient พร้อม sub-ingredients
class ExpandableIngredientCard extends StatefulWidget {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;
  final int depth;
  final bool isEditable;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpandableIngredientCard({
    super.key,
    required this.ingredient,
    required this.children,
    this.depth = 0,
    this.isEditable = false,
    this.onTap,
    this.onDelete,
  });

  @override
  State<ExpandableIngredientCard> createState() =>
      _ExpandableIngredientCardState();
}

class _ExpandableIngredientCardState extends State<ExpandableIngredientCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.children.isNotEmpty;
    final indent = widget.depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Parent card
          _buildParentCard(hasChildren),

          // Children (expandable)
          if (hasChildren)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children.map((child) {
                  return _buildChildCard(child);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParentCard(bool hasChildren) {
    return GestureDetector(
      onTap: hasChildren ? _toggleExpanded : widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.depth == 0 ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.depth == 0 ? Colors.grey[300]! : Colors.grey[200]!,
          ),
          boxShadow: widget.depth == 0
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          children: [
            // Expand/collapse icon (ถ้ามี children)
            if (hasChildren)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5)
                      .animate(_expandAnimation),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Vertical line (ถ้าเป็น sub)
            if (widget.depth > 0)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

            // Ingredient info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.ingredient.ingredientName,
                    style: TextStyle(
                      fontSize: widget.depth == 0 ? 16 : 14,
                      fontWeight:
                          widget.depth == 0 ? FontWeight.w600 : FontWeight.w400,
                      color:
                          widget.depth == 0 ? Colors.black87 : Colors.black54,
                    ),
                  ),

                  // Amount
                  const SizedBox(height: 4),
                  Text(
                    '${widget.ingredient.amount.toStringAsFixed(0)} ${widget.ingredient.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  // Detail (ถ้ามี)
                  if (widget.ingredient.detail != null &&
                      widget.ingredient.detail!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.ingredient.detail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Calories
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.ingredient.calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: widget.depth == 0 ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: widget.depth == 0
                        ? AppColors.health
                        : Colors.orange[400],
                  ),
                ),

                // Composite indicator
                if (hasChildren)
                  Text(
                    '${widget.children.length} items',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),

            // Delete button (ถ้า editable)
            if (widget.isEditable && widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[400],
                onPressed: widget.onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(MyMealIngredient child) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 2, right: 8, bottom: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Connection line
          Container(
            width: 2,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.ingredientName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${child.amount.toStringAsFixed(0)} ${child.unit}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (child.detail != null && child.detail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      child.detail!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          Text(
            '${child.calories.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
