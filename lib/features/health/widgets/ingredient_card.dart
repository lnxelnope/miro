import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUse;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.health.withOpacity(0.1),
          child: const Text('🥬', style: TextStyle(fontSize: 20)),
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ingredient.baseAmount.toStringAsFixed(0)} ${ingredient.baseUnit} = '
              '${ingredient.caloriesPerBase.toInt()} kcal  '
              'P:${ingredient.proteinPerBase.toInt()}g  '
              'C:${ingredient.carbsPerBase.toInt()}g  '
              'F:${ingredient.fatPerBase.toInt()}g',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              'Used ${ingredient.usageCount} times · ${ingredient.source == 'gemini' ? '✨ AI' : '✏️ Manual'}',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onUse,
              icon: const Icon(Icons.add_circle_outline, size: 22),
              color: AppColors.health,
              tooltip: 'Save this item',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit': onEdit(); break;
                  case 'delete': onDelete(); break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
