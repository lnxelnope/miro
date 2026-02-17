import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/constants/ai_loading_messages.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/food_timeline_card.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/food_detail_bottom_sheet.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../widgets/quick_add_section.dart';
import '../models/food_entry.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';

class HealthTimelineTab extends ConsumerStatefulWidget {
  final Key? timelineKey;
  
  const HealthTimelineTab({super.key, this.timelineKey});

  @override
  ConsumerState<HealthTimelineTab> createState() => _HealthTimelineTabState();
}

class _HealthTimelineTabState extends ConsumerState<HealthTimelineTab> {
  DateTime _selectedDate = dateOnly(DateTime.now());
  
  // ป้องกันการ analyze ซ้ำ
  final Set<int> _analyzingEntryIds = {};

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));

    return RefreshIndicator(
      key: widget.timelineKey,
      onRefresh: () async {
        AppLogger.info('Pull-to-refresh starting...');
        
        // 1. Trigger auto-scan for new images
        try {
          AppLogger.info('Starting to scan new images from Gallery...');
          final count = await ref.read(galleryScanNotifierProvider.notifier).scanNewImages();
          AppLogger.info('Scan complete - found: $count entries');
        } catch (e) {
          AppLogger.error('Scan failed', e);
        }
        
        // 2. Refresh existing data
        refreshFoodProviders(ref, _selectedDate);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Upsell Banner
          SliverToBoxAdapter(
            child: _buildUpsellBanner(),
          ),

          // Daily Summary Card
          SliverToBoxAdapter(
            child: DailySummaryCard(selectedDate: _selectedDate),
          ),

          // Date Selector
          SliverToBoxAdapter(
            child: _buildDateSelector(),
          ),

          // Quick Add Section (Favorite + Repeat Yesterday)
          SliverToBoxAdapter(
            child: QuickAddSection(selectedDate: _selectedDate),
          ),

          // Timeline Items
          timelineAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverToBoxAdapter(
                child: _buildMealsHorizontalCard(items),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('d MMM yyyy');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📅 ${isToday ? "Today" : dateFormat.format(_selectedDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday
                ? null
                : () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildUpsellBanner() {
    return FutureBuilder<bool>(
      future: UsageLimiter.isPro(),
      builder: (context, proSnapshot) {
        if (proSnapshot.data == true) return const SizedBox.shrink();

        return FutureBuilder<int>(
          future: UsageLimiter.remainingToday(),
          builder: (context, countSnapshot) {
            final remaining = countSnapshot.data ?? 3;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Analysis: $remaining/${UsageLimiter.freeAiCallsPerDay} remaining today',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const Text(
                          'Upgrade to Pro for unlimited use',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => PurchaseService.buyPro(),
                    child: const Text('Upgrade',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📭',
            style: TextStyle(fontSize: 64),
          ),
          SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'Pull to refresh and I\'ll search for food photos you\'ve taken',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'or just tell me what you ate today :)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal scrollable meals card
  Widget _buildMealsHorizontalCard(List<TimelineItem> items) {
    // Filter เฉพาะ food items
    final foodItems = items.where((i) => i.type == 'food').toList();
    if (foodItems.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Text(
                'Meals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${foodItems.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.health,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal scroll
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foodItems.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final entry = foodItems[index].data as FoodEntry;
                return _buildHorizontalFoodItem(entry);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build single food item for horizontal scroll
  Widget _buildHorizontalFoodItem(FoodEntry entry) {
    return GestureDetector(
      onTap: () => _showFoodDetail(entry),
      onLongPress: () {
        // Show bottom sheet with edit/delete options
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _editFoodEntry(entry);
                  },
                ),
                if (entry.imagePath != null || !entry.isVerified)
                  ListTile(
                    leading: const Icon(Icons.auto_awesome, color: Colors.amber),
                    title: const Text('Analyze with AI'),
                    onTap: () {
                      Navigator.pop(context);
                      _analyzeFoodWithGemini(entry);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteFoodEntry(entry);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // รูปวงกลม
            Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.health.withOpacity(0.1),
                  backgroundImage: _getImageProvider(entry),
                  child: _getImageProvider(entry) == null
                      ? const Icon(
                          Icons.restaurant,
                          color: AppColors.health,
                          size: 28,
                        )
                      : null,
                ),
                // Verified badge
                if (entry.isVerified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // ชื่ออาหาร
            Text(
              entry.foodName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            // แคลอรี่
            Text(
              '${entry.calories.toInt()} kcal',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            // เวลา
            Text(
              _formatTime(entry.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get image provider (with error handling)
  ImageProvider? _getImageProvider(FoodEntry entry) {
    if (entry.imagePath == null) return null;
    
    try {
      final file = File(entry.imagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (e) {
      AppLogger.error('Error loading image', e);
    }
    
    return null;
  }

  /// Format time (HH:mm)
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showFoodDetail(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FoodDetailBottomSheet(
        entry: entry,
        selectedDate: _selectedDate,
        onAnalyze: (entry) async {
          await _analyzeFoodWithGemini(entry);
        },
      ),
    ).then((result) {
      if (result != null && result is Map) {
        if (result['action'] == 'edit') {
          final foodEntry = result['entry'] as FoodEntry;
          _editFoodEntry(foodEntry);
        }
      }
    });
  }

  void _editFoodEntry(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          
          // ────── เช็ค mounted ก่อน invalidate ──────
          if (!mounted) return;
          refreshFoodProviders(ref, _selectedDate);
        },
      ),
    );
  }

  /// Delete food entry
  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Do you want to delete "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final notifier = ref.read(foodEntriesNotifierProvider.notifier);
        await notifier.deleteFoodEntry(entry.id);
        
        // ────── เช็ค mounted ก่อน invalidate ──────
        if (!mounted) return;
        refreshFoodProviders(ref, _selectedDate);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entry deleted successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Analyze food with Gemini (supports both image and text-only)
  Future<void> _analyzeFoodWithGemini(FoodEntry entry) async {
    // ────── ป้องกันการกดซ้ำ (เช็คก่อนทุกอย่าง) ──────
    if (_analyzingEntryIds.contains(entry.id)) {
      AppLogger.info('[Timeline] Already analyzing entry ${entry.id}, skipping duplicate request');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Analysis in progress - please wait'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // ────── ถ้า entry วิเคราะห์แล้ว ให้ถามยืนยันก่อน ──────
    if (entry.isVerified && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(child: Text('Re-analyze?')),
            ],
          ),
          content: Text(
            '"${entry.foodName}" has already been analyzed.\n\n'
            'Analyzing again will use 1 Energy.\n\n'
            'Continue?',
            style: const TextStyle(fontSize: 15),
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
    
    // ────── แสดง Confirmation Dialog ──────
    final analyzeParams = await _showAnalyzeConfirmation(entry);
    if (analyzeParams == null) return; // User cancelled

    final String confirmedFoodName = analyzeParams['foodName'] as String;
    final double confirmedQuantity = analyzeParams['quantity'] as double;
    final String confirmedUnit = analyzeParams['unit'] as String;
    
    // ────── เพิ่ม entry.id เข้า set ทันทีเพื่อป้องกันการกดซ้ำ ──────
    _analyzingEntryIds.add(entry.id);
    
    final hasImage = entry.imagePath != null && File(entry.imagePath!).existsSync();

    // ────── ตรวจสอบ Energy ก่อนเรียก API ──────
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      _analyzingEntryIds.remove(entry.id);
      
      if (context.mounted) {
        await NoEnergyDialog.show(context);
      }
      return;
    }
    
    if (!context.mounted) return;
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
                ? AILoadingMessages.getImageMessage(0)
                : 'Estimating "${entry.foodName}" with AI...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    try {
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);
      FoodAnalysisResult? result;
      if (hasImage) {
        result = await notifier.analyzeImage(
          File(entry.imagePath!),
          foodName: confirmedFoodName.isNotEmpty ? confirmedFoodName : null,
          quantity: confirmedQuantity > 0 ? confirmedQuantity : null,
          unit: confirmedUnit,
        );
      } else {
        result = await GeminiService.analyzeFoodByName(
          confirmedFoodName.isNotEmpty ? confirmedFoodName : entry.foodName,
          servingSize: confirmedQuantity > 0 ? confirmedQuantity : entry.servingSize,
          servingUnit: confirmedUnit,
        );
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result == null) {
        _analyzingEntryIds.remove(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Unable to analyze'), backgroundColor: AppColors.error),
        );
        return;
      }

      await UsageLimiter.recordAiUsage();
      
      // === อัพเดท Energy Badge ===
      if (!mounted) return;
      ref.invalidate(energyBalanceProvider);
      ref.invalidate(currentEnergyProvider);

      if (!context.mounted) return;
      
      // ────── showModalBottomSheet แล้วรอให้ปิด (await) ──────
      // จะไม่ลบ entry.id ออกจนกว่า sheet จะปิด
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

            if (!mounted) return;
            refreshFoodProviders(ref, _selectedDate);

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
                
                if (!mounted) return;
                ref.invalidate(allMyMealsProvider);
                ref.invalidate(allIngredientsProvider);
                
                AppLogger.info('Auto-saved: ${confirmedData.ingredientsDetail!.length} ingredients + 1 meal');
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Updated + saved ${confirmedData.ingredientsDetail!.length} ingredients to My Meal',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                AppLogger.warn('Could not auto-save meal: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Updated successfully'), backgroundColor: AppColors.success),
                  );
                }
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Updated successfully'), backgroundColor: AppColors.success),
                );
              }
            }
          },
        ),
      );
      
      // ────── ลบ entry.id ออกจาก set หลัง sheet ปิดแล้ว ──────
      _analyzingEntryIds.remove(entry.id);
      
    } catch (e, stackTrace) {
      AppLogger.error('Error', e, stackTrace);
      
      // ────── ลบ entry.id ออกจาก set ──────
      _analyzingEntryIds.remove(entry.id);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      // ตรวจสอบว่าเป็น Energy error หรือไม่
      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
        return;
      }
      
      String errorMessage = 'An error occurred';
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

  /// แสดง Confirmation Dialog ก่อนส่งวิเคราะห์
  /// Return null = user cancelled
  /// Return Map = { foodName, quantity, unit }
  Future<Map<String, dynamic>?> _showAnalyzeConfirmation(FoodEntry entry) async {
    final foodNameController = TextEditingController(
      text: entry.foodName == 'food' ? '' : entry.foodName,
    );
    final quantityController = TextEditingController(
      text: entry.servingSize > 0 ? entry.servingSize.toString() : '',
    );
    final entryUnit = entry.servingUnit.isNotEmpty ? entry.servingUnit : 'serving';
    final validatedUnit = UnitConverter.ensureValid(entryUnit);
    String selectedUnit = validatedUnit;

    final hasImage = entry.imagePath != null && File(entry.imagePath!).existsSync();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text('Analyze with AI', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image Preview
                      if (hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(entry.imagePath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Food Name
                      const Text('Food Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: foodNameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Pad Krapow, Salmon Sushi...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quantity
                      const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 300',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Unit
                      const Text('Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: selectedUnit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: UnitConverter.allDropdownItems,
                        onChanged: (v) {
                          if (v != null && v.isNotEmpty) setDialogState(() => selectedUnit = v);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Text('⚡', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will use 1 Energy.\nProviding food name & quantity improves accuracy.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, null),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(quantityController.text.trim()) ?? 0.0,
                                'unit': selectedUnit,
                              });
                            },
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Analyze'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
