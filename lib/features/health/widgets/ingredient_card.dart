import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUse;
  final int depth; // NEW — ระดับความลึก (0 = root, 1 = sub, 2 = sub-sub)
  final String? detail; // NEW — คำอธิบายเพิ่มเติม (nullable)

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    required this.onUse,
    this.depth = 0, // NEW — default = root level
    this.detail, // NEW — optional detail
  });

  @override
  Widget build(BuildContext context) {
    final isAi = ingredient.source == 'gemini';
    // คำนวณ indent สำหรับ sub-ingredients
    final double indent = depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Row(
        children: [
          // เส้นแนวตั้งสำหรับ sub-ingredients
          if (depth > 0)
            Container(
              width: 2,
              height: 50, // adjust ตามขนาด card
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(1),
              ),
            ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: depth == 0
                    ? Colors.white
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.lg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.lg,
                  onTap: onUse,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.finance.withValues(alpha: 0.1),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Center(
                            child: Text('🥬', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ingredient.name,
                                      style: TextStyle(
                                        fontSize: depth == 0
                                            ? 15
                                            : 14, // ROOT: 15, SUB: 14
                                        fontWeight: depth == 0
                                            ? FontWeight.w600 // ROOT: bold
                                            : FontWeight.w400, // SUB: normal
                                        letterSpacing: -0.2,
                                        color: depth == 0
                                            ? Colors.black87 // ROOT: เข้ม
                                            : Colors.black54, // SUB: จาง
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Source badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAi
                                          ? AppColors.premium
                                              .withValues(alpha: 0.1)
                                          : AppColors.surfaceVariant,
                                      borderRadius: AppRadius.sm,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isAi ? AppIcons.aiAnalyzed : AppIcons.edit,
                                          size: 12,
                                          color: isAi
                                              ? AppIcons.aiAnalyzedColor
                                              : AppIcons.editColor,
                                        ),
                                        if (isAi) ...[
                                          const SizedBox(width: 2),
                                          Text(
                                            'AI',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppIcons.aiAnalyzedColor,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Nutrition compact row
                              Row(
                                children: [
                                  Text(
                                    '${ingredient.baseAmount.toStringAsFixed(0)} ${ingredient.baseUnit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  _dot(),
                                  Text(
                                    '${ingredient.caloriesPerBase.toInt()} kcal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  _dot(),
                                  Text(
                                    'P:${ingredient.proteinPerBase.toInt()}  C:${ingredient.carbsPerBase.toInt()}  F:${ingredient.fatPerBase.toInt()}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ingredient.usageCount} uses',
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textTertiary),
                              ),

                              // NEW — แสดง detail text ถ้ามี
                              if (detail != null && detail!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    detail!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Actions
                        Column(
                          children: [
                            // Log button
                            GestureDetector(
                              onTap: onUse,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.health.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.md,
                                ),
                                child: const Icon(Icons.add_rounded,
                                    size: 20, color: AppColors.health),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // More menu
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.more_horiz_rounded,
                                  size: 18, color: AppColors.textTertiary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.lg),
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    onEdit();
                                    break;
                                  case 'delete':
                                    onDelete();
                                    break;
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 10),
                                      const Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 18, color: AppColors.error.withValues(alpha: 0.7)),
                                      const SizedBox(width: 10),
                                      Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.error.withValues(alpha: 0.7))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
