import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/my_meal_ingredient.dart';

/// Widget สำหรับแสดง MyMealIngredient พร้อมรองรับ nested structure
class MyMealIngredientCard extends StatelessWidget {
  final MyMealIngredient ingredient;
  final int depth; // NEW — ระดับความลึก (0 = root, 1 = sub, 2 = sub-sub)
  final String? detail; // NEW — คำอธิบายเพิ่มเติม (nullable)

  const MyMealIngredientCard({
    super.key,
    required this.ingredient,
    this.depth = 0, // NEW — default = root level
    this.detail, // NEW — optional detail
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              borderRadius: BorderRadius.circular(1),
              ),
            ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: depth == 0
                    ? (isDark ? AppColors.surfaceDark : Colors.white)
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: depth == 0
                      ? (isDark ? AppColors.dividerDark : AppColors.divider)
                      : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (depth == 0)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.health,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (depth == 0) const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ingredient.ingredientName,
                          style: TextStyle(
                            fontSize: depth == 0 ? 16 : 14, // ROOT: 16, SUB: 14
                            fontWeight: depth == 0
                                ? FontWeight.w600 // ROOT: bold
                                : FontWeight.w400, // SUB: normal
                            color: depth == 0
                                ? (isDark ? AppColors.textPrimaryDark : Colors.black87)
                                : (isDark ? AppColors.textSecondaryDark : Colors.black54),
                          ),
                        ),
                      ),
                      Text(
                        '${ingredient.calories.toInt()} kcal',
                        style: TextStyle(
                          fontSize: depth == 0 ? 14 : 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (depth > 0)
                        const SizedBox(width: 16), // indent สำหรับ sub
                      Text(
                        '${ingredient.amount.toStringAsFixed(0)} ${ingredient.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'P:${ingredient.protein.toInt()}  C:${ingredient.carbs.toInt()}  F:${ingredient.fat.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // NEW — แสดง detail text ถ้ามี
                  if (detail != null && detail!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (depth > 0)
                            const SizedBox(width: 16), // indent สำหรับ sub
                          Expanded(
                            child: Text(
                              detail!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
