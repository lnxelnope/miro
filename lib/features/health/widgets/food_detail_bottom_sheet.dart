import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import 'gemini_analysis_sheet.dart';

class FoodDetailBottomSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;
  final Function(FoodEntry)? onEdit;
  final Function(FoodEntry)? onDelete;
  final Function(FoodEntry)? onAnalyze;
  final DateTime? selectedDate; // สำหรับ refresh providers

  const FoodDetailBottomSheet({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.onAnalyze,
    this.selectedDate,
  });

  @override
  ConsumerState<FoodDetailBottomSheet> createState() => _FoodDetailBottomSheetState();
}

class _FoodDetailBottomSheetState extends ConsumerState<FoodDetailBottomSheet> {
  bool _isAnalyzing = false; // Prevent double-tap

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasImage = entry.imagePath != null && File(entry.imagePath!).existsSync();
    // แสดงปุ่ม AI Analysis เสมอ (แต่ถ้า verified แล้วจะถามยืนยันก่อน)
    const canAnalyze = true;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปภาพใหญ่ (ถ้ามี)
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(entry.imagePath!),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ชื่ออาหาร
                  Row(
                    children: [
                      Text(
                        entry.mealType.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.foodName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // เวลาและมื้ออาหาร
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(entry.timestamp)} • ${entry.mealType.displayName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // แคลอรี่
                  _buildInfoCard(
                    icon: '🔥',
                    label: 'Calories',
                    value: '${entry.calories.toInt()} kcal',
                    color: AppColors.health,
                  ),
                  const SizedBox(height: 12),

                  // Macros
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroCard(
                          label: 'Protein',
                          value: entry.protein,
                          unit: 'g',
                          color: AppColors.protein,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroCard(
                          label: 'Carbs',
                          value: entry.carbs,
                          unit: 'g',
                          color: AppColors.carbs,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroCard(
                          label: 'Fat',
                          value: entry.fat,
                          unit: 'g',
                          color: AppColors.fat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ปริมาณ
                  if (entry.servingSize > 0)
                    _buildInfoCard(
                      icon: '📏',
                      label: 'Amount',
                      value: '${entry.servingSize} ${entry.servingUnit}',
                      color: AppColors.textSecondary,
                    ),
                  
                  // หมายเหตุ (ถ้ามี)
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.note,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.notes!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ปุ่ม Actions
                  Row(
                    children: [
                      // ปุ่มแก้ไข
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleEdit(),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ปุ่มค้นด้วย Gemini (ถ้ามีรูปและยังไม่ verified)
                      if (canAnalyze)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAnalyze(),
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('AI Analysis'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      // ปุ่มลบ
                      IconButton(
                        onPressed: () => _handleDelete(),
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withOpacity(0.1),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.health.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: AppColors.health,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required String label,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handleEdit() {
    // Pop detail sheet พร้อม result บอกว่าต้อง edit
    // ให้ caller เป็นคนเปิด EditFoodBottomSheet ด้วย context/ref ของตัวเอง
    // เพราะหลัง pop แล้ว context/ref ของ FoodDetailBottomSheet จะ dispose
    Navigator.pop(context, {'action': 'edit', 'entry': widget.entry});
  }

  Future<void> _handleAnalyze() async {
    // Prevent double-tap
    if (_isAnalyzing) return;
    
    final entry = widget.entry;
    final hasImage = entry.imagePath != null && File(entry.imagePath!).existsSync();

    // === ถ้าวิเคราะห์แล้ว ให้ถามยืนยันก่อน ===
    if (entry.isVerified && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Re-analyze?'),
            ],
          ),
          content: const Text(
            'This food has already been analyzed.\n\n'
            'Analyzing again will use 1 Energy.\n\n'
            'Continue?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-analyze (1 Energy)'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return; // User cancelled
    }

    // === ตรวจสอบ Energy ก่อนเรียก AI ===
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      await NoEnergyDialog.show(context);
      return;
    }

    // ใช้ callback ถ้ามี (timeline tab จัดการเอง)
    if (widget.onAnalyze != null) {
      Navigator.pop(context); // ปิด detail sheet ก่อน
      await widget.onAnalyze!(entry);
      return;
    }

    // Default behavior (ใน detail sheet เอง)
    if (!mounted) return;
    
    setState(() => _isAnalyzing = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              hasImage
                ? '📸 PROCESSING IMAGE DATA...'
                : '📝 PARSING FOOD NAME...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Processing advanced nutrition analysis',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    try {
      FoodAnalysisResult? result;
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);

      if (hasImage) {
        AppLogger.info('Starting Gemini image analysis...');
        result = await GeminiService.analyzeFoodImage(File(entry.imagePath!));
      } else {
        AppLogger.info('Starting Gemini analysis from name...');
        result = await GeminiService.analyzeFoodByName(
          entry.foodName,
          servingSize: entry.servingSize,
          servingUnit: entry.servingUnit,
        );
      }

      if (result != null) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();
        
        // === อัพเดท Energy Badge ===
        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);
        
        Navigator.pop(context); // ปิด loading dialog
        
        // แสดง GeminiAnalysisSheet ให้ user แก้ไขก่อนบันทึก
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => GeminiAnalysisSheet(
            analysisResult: result!,
            onConfirm: (confirmedData) async {
              String? ingredientsJsonStr;
              if (confirmedData.ingredientsDetail != null && confirmedData.ingredientsDetail!.isNotEmpty) {
                ingredientsJsonStr = jsonEncode(confirmedData.ingredientsDetail);
              }

              await notifier.updateFromGeminiConfirmed(
                entry.id,
                foodName: confirmedData.foodName,
                foodNameEn: confirmedData.foodNameEn,
                calories: confirmedData.calories,
                protein: confirmedData.protein,
                carbs: confirmedData.carbs,
                fat: confirmedData.fat,
                baseCalories: confirmedData.baseCalories,
                baseProtein: confirmedData.baseProtein,
                baseCarbs: confirmedData.baseCarbs,
                baseFat: confirmedData.baseFat,
                servingSize: confirmedData.servingSize,
                servingUnit: confirmedData.servingUnit,
                servingGrams: confirmedData.servingGrams,
                confidence: confirmedData.confidence,
                fiber: confirmedData.fiber,
                sugar: confirmedData.sugar,
                sodium: confirmedData.sodium,
                notes: confirmedData.notes,
                ingredientsJson: ingredientsJsonStr,
              );

              // Auto-save ingredients + meal
              if (confirmedData.ingredientsDetail != null &&
                  confirmedData.ingredientsDetail!.isNotEmpty) {
                try {
                  await notifier.saveIngredientsAndMeal(
                    mealName: confirmedData.foodName,
                    mealNameEn: confirmedData.foodNameEn,
                    servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                    imagePath: entry.imagePath,
                    ingredientsData: confirmedData.ingredientsDetail!,
                  );
                  
                  // Invalidate MyMeal providers to refresh UI
                  if (!mounted) return;
                  ref.invalidate(allMyMealsProvider);
                  ref.invalidate(allIngredientsProvider);
                  
                  AppLogger.info('Auto-saved: ${confirmedData.ingredientsDetail!.length} ingredients + 1 meal');
                } catch (e) {
                  AppLogger.warn('Could not auto-save meal: $e');
                }
              }

              // ────── เช็ค mounted ก่อน invalidate ──────
              if (!mounted) return;
              
              if (widget.selectedDate != null) {
                ref.invalidate(foodEntriesByDateProvider(widget.selectedDate!));
                ref.invalidate(healthTimelineProvider(widget.selectedDate!));
              }
              ref.invalidate(todayCaloriesProvider);
              ref.invalidate(todayMacrosProvider);

              if (!context.mounted) return;
              Navigator.pop(context); // ปิด detail sheet
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Updated successfully${confirmedData.ingredientsDetail != null && confirmedData.ingredientsDetail!.isNotEmpty ? ' + saved to My Meal' : ''}'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      } else {
        // No result from Gemini
        if (!mounted) return;
        Navigator.pop(context); // ปิด loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Could not analyze - please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error', e, stackTrace);
      
      setState(() => _isAnalyzing = false);
      
      if (!mounted) return;
      Navigator.pop(context); // ปิด loading dialog
      if (!mounted) return;
      
      // ตรวจสอบว่าเป็น Energy error หรือไม่
      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
        return;
      }
      
      String errorMessage = 'An error occurred. Please try again.';
      if (e.toString().contains('parse JSON')) {
        errorMessage = 'Could not read AI result - please try again';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.length > 100) {
          errorMessage = '${errorMessage.substring(0, 100)}...';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('Do you want to delete "${widget.entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (widget.onDelete != null) {
          // ใช้ callback ที่ส่งมา (จะ refresh providers เอง)
          await widget.onDelete!(widget.entry);
        } else {
          // Default behavior
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.deleteFoodEntry(widget.entry.id);
          
          // ────── เช็ค mounted ก่อน invalidate ──────
          if (!mounted) return;
          
          if (widget.selectedDate != null) {
            ref.invalidate(foodEntriesByDateProvider(widget.selectedDate!));
            ref.invalidate(healthTimelineProvider(widget.selectedDate!));
          }
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        }
        
        if (!mounted) return;
        Navigator.pop(context); // ปิด detail sheet
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entry deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
