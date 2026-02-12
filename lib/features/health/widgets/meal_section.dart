import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';
import 'food_detail_bottom_sheet.dart';
import 'edit_food_bottom_sheet.dart';

class MealSection extends ConsumerWidget {
  final MealType mealType;
  final List<FoodEntry> foods;
  final VoidCallback onAddFood;
  final Function(FoodEntry) onEditFood;
  final Function(FoodEntry) onDeleteFood;
  final DateTime selectedDate;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foods,
    required this.onAddFood,
    required this.onEditFood,
    required this.onDeleteFood,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCalories = foods.fold<double>(0, (sum, f) => sum + f.calories);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                mealType.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                mealType.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalCalories.toInt()} kcal',
                  style: const TextStyle(
                    color: AppColors.health,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: onAddFood,
              ),
            ],
          ),
          
          // Foods list
          if (foods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No entries yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...foods.map((food) => _buildFoodItem(context, ref, food)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, WidgetRef ref, FoodEntry food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showFoodDetail(context, ref, food),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: food.imagePath != null && File(food.imagePath!).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(food.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${food.servingSize} ${food.servingUnit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
                    '${food.calories.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Actions - ลบออกเพราะจะอยู่ใน detail sheet แล้ว
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.restaurant,
        color: AppColors.health,
        size: 20,
      ),
    );
  }

  void _showFoodDetail(BuildContext context, WidgetRef ref, FoodEntry food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FoodDetailBottomSheet(
        entry: food,
        selectedDate: selectedDate,
        // onEdit = null → FoodDetailBottomSheet จะ pop พร้อม result {'action': 'edit'}
        // onDelete = null → FoodDetailBottomSheet จัดการ delete เอง (ยัง mounted อยู่ตอนลบ)
        // onAnalyze = null → FoodDetailBottomSheet จัดการเอง (รองรับทั้งวิเคราะห์จากรูปและจากชื่อ)
      ),
    ).then((result) {
      // จัดการ result จาก FoodDetailBottomSheet
      if (result != null && result is Map) {
        if (result['action'] == 'edit') {
          final entry = result['entry'] as FoodEntry;
          _showEditSheet(context, ref, entry);
        }
      }
    });
  }

  /// เปิด EditFoodBottomSheet ด้วย context/ref ของ MealSection (ยัง alive)
  void _showEditSheet(BuildContext context, WidgetRef ref, FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          ref.invalidate(foodEntriesByDateProvider(selectedDate));
          ref.invalidate(healthTimelineProvider(selectedDate));
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        },
      ),
    );
  }

}
