# Basic Mode - Implementation Guide

> คู่มือสำหรับ Junior Developer  
> ทำตามทีละขั้น ไม่ต้องคิดเอง ไม่ต้องถาม  
> ทำเสร็จแล้วทดสอบตาม Checklist ท้ายเอกสาร

---

## สารบัญ

1. [ภาพรวม](#1-ภาพรวม)
2. [ไฟล์ที่ต้องสร้างใหม่ (6 ไฟล์)](#2-ไฟล์ที่ต้องสร้างใหม่)
3. [ไฟล์ที่ต้องแก้ไข (14 ไฟล์)](#3-ไฟล์ที่ต้องแก้ไข)
4. [ลำดับการทำงาน](#4-ลำดับการทำงาน)
5. [Step 1: App Mode Provider](#step-1-app-mode-provider)
6. [Step 2: Mode Toggle Widget](#step-2-mode-toggle-widget)
7. [Step 3: Batch Analysis Utility (Extract)](#step-3-batch-analysis-utility)
8. [Step 4: Food Sandbox Widget](#step-4-food-sandbox-widget)
9. [Step 5: Simple Food Detail Bottom Sheet](#step-5-simple-food-detail-bottom-sheet)
10. [Step 6: Quick Add Dialog](#step-6-quick-add-dialog)
11. [Step 7: Basic Mode Tab (หน้าจอหลัก)](#step-7-basic-mode-tab)
12. [Step 8: แก้ไข HomeScreen](#step-8-แก้ไข-homescreen)
13. [Step 9: Localization (l10n)](#step-9-localization)
14. [Step 10: Run gen-l10n](#step-10-run-gen-l10n)
15. [Checklist ทดสอบ](#checklist-ทดสอบ)

---

## 1. ภาพรวม

### ก่อนทำ (Pro Mode - เดิม)
```
HomeScreen
├── AppBar (Energy Badge | Title | Profile Icon)
├── BottomNavigationBar (Dashboard | My Meals | Camera | AI Chat)
└── IndexedStack
    ├── HealthTimelineTab (Dashboard - มี MealSections แยก Breakfast/Lunch/Dinner/Snack)
    ├── HealthMyMealTab
    └── ChatScreen
```

### หลังทำ (เพิ่ม Basic Mode)
```
HomeScreen
├── AppBar (Energy Badge | Title | [MODE TOGGLE] | Profile Icon)  ← เพิ่ม toggle
├── IF Pro Mode → เหมือนเดิมทุกประการ
└── IF Basic Mode → BasicModeTab (หน้าเดียว ไม่มี BottomNav)
    ├── QuestBar (widget เดิม)
    ├── DailySummaryCard (widget เดิม)
    ├── Analyze All Button + Energy Cost
    ├── Food Sandbox (Wrap ของ bubbles - widget ใหม่)
    ├── Action Buttons (Camera | Gallery | Add)
    └── Chat Input Field
```

### กฎสำคัญ
- ข้อมูลทั้งหมดใช้ `FoodEntry` model เดิม ไม่สร้าง model ใหม่
- ใช้ providers เดิม (`foodEntriesByDateProvider`, `healthTimelineProvider`, `chatNotifierProvider` ฯลฯ)
- ใช้ services เดิม (`GeminiService`, `ImagePickerService`, `DatabaseService`)
- ทุก string ที่แสดงต้องผ่าน l10n (`L10n.of(context)!.xxx`)
- ใช้ design tokens จาก `app_tokens.dart` และ colors จาก `app_colors.dart`
- **ห้ามแก้ไข** logic ของ Pro Mode ที่มีอยู่เดิม

---

## 2. ไฟล์ที่ต้องสร้างใหม่

| # | Path | คำอธิบาย |
|---|------|---------|
| 1 | `lib/core/providers/app_mode_provider.dart` | Provider เก็บ Basic/Pro mode |
| 2 | `lib/core/widgets/mode_toggle.dart` | Toggle widget สำหรับ AppBar |
| 3 | `lib/core/utils/batch_analysis_helper.dart` | Extract batch analysis logic ใช้ร่วม 2 โหมด |
| 4 | `lib/features/home/widgets/food_sandbox.dart` | Sandbox bubble grid widget |
| 5 | `lib/features/home/widgets/simple_food_detail_sheet.dart` | Bottom sheet แบบ simple |
| 6 | `lib/features/home/presentation/basic_mode_tab.dart` | หน้าจอ Basic Mode |

---

## 3. ไฟล์ที่ต้องแก้ไข

| # | Path | เปลี่ยนอะไร |
|---|------|-----------|
| 1 | `lib/features/home/presentation/home_screen.dart` | เพิ่ม toggle + สลับ body/bottomNav |
| 2 | `lib/l10n/app_en.arb` | เพิ่ม l10n keys |
| 3 | `lib/l10n/app_th.arb` | เพิ่ม l10n keys (ไทย) |
| 4 | `lib/l10n/app_zh.arb` | เพิ่ม l10n keys |
| 5 | `lib/l10n/app_ja.arb` | เพิ่ม l10n keys |
| 6 | `lib/l10n/app_ko.arb` | เพิ่ม l10n keys |
| 7 | `lib/l10n/app_es.arb` | เพิ่ม l10n keys |
| 8 | `lib/l10n/app_fr.arb` | เพิ่ม l10n keys |
| 9 | `lib/l10n/app_de.arb` | เพิ่ม l10n keys |
| 10 | `lib/l10n/app_hi.arb` | เพิ่ม l10n keys |
| 11 | `lib/l10n/app_id.arb` | เพิ่ม l10n keys |
| 12 | `lib/l10n/app_pt.arb` | เพิ่ม l10n keys |
| 13 | `lib/l10n/app_vi.arb` | เพิ่ม l10n keys |
| 14 | `lib/features/health/presentation/health_timeline_tab.dart` | ย้าย batch analysis ไปใช้ helper |

---

## 4. ลำดับการทำงาน

**ทำตามลำดับนี้เป๊ะ ๆ ห้ามข้าม:**

```
Step 1  → App Mode Provider (ไม่มี dependency)
Step 2  → Mode Toggle Widget (ต้องมี Step 1)
Step 3  → Batch Analysis Utility (ไม่มี dependency)
Step 4  → Food Sandbox Widget (ไม่มี dependency)
Step 5  → Simple Food Detail Sheet (ไม่มี dependency)
Step 6  → Quick Add Dialog (ไม่มี dependency)
Step 7  → Basic Mode Tab (ต้องมี Step 1, 3, 4, 5, 6)
Step 8  → แก้ไข HomeScreen (ต้องมี Step 1, 2, 7)
Step 9  → Localization ทุกภาษา
Step 10 → Run flutter gen-l10n
```

---

## Step 1: App Mode Provider

### สร้างไฟล์: `lib/core/providers/app_mode_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { basic, pro }

final appModeProvider = StateNotifierProvider<AppModeNotifier, AppMode>((ref) {
  return AppModeNotifier();
});

class AppModeNotifier extends StateNotifier<AppMode> {
  static const String _key = 'app_mode';

  AppModeNotifier() : super(AppMode.pro) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'basic') {
      state = AppMode.basic;
    } else {
      state = AppMode.pro;
    }
  }

  Future<void> toggle() async {
    final newMode = state == AppMode.basic ? AppMode.pro : AppMode.basic;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newMode.name);
  }

  Future<void> setMode(AppMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
```

### ทดสอบ Step 1
- Import ไฟล์ในไฟล์อื่นได้โดยไม่ error
- `ref.watch(appModeProvider)` return `AppMode.pro` (default)
- `ref.read(appModeProvider.notifier).toggle()` สลับเป็น basic ได้

---

## Step 2: Mode Toggle Widget

### สร้างไฟล์: `lib/core/widgets/mode_toggle.dart`

**Design spec:**
- ขนาด: กว้างประมาณ 90px สูง 32px
- รูปแบบ: pill-shaped (`BorderRadius.circular(999)`)
- สี active: `AppColors.primary` (teal)
- สี inactive: `AppColors.surfaceVariant`
- มี animation ตอนสลับ
- แสดง icon + text ย่อ

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_mode_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';

class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final isBasic = mode == AppMode.basic;
    final l10n = L10n.of(context)!;

    return GestureDetector(
      onTap: () => ref.read(appModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isBasic
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.ai.withValues(alpha: 0.12),
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isBasic
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.ai.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBasic ? Icons.grid_view_rounded : Icons.auto_awesome_rounded,
              size: 14,
              color: isBasic ? AppColors.primary : AppColors.ai,
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                isBasic ? l10n.basicMode : l10n.proMode,
                key: ValueKey(isBasic),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isBasic ? AppColors.primary : AppColors.ai,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### ทดสอบ Step 2
- กด toggle → สลับสี + text ระหว่าง "Basic" / "Pro"
- มี animation smooth

---

## Step 3: Batch Analysis Utility

### สร้างไฟล์: `lib/core/utils/batch_analysis_helper.dart`

**จุดประสงค์:** Extract logic จาก `HealthTimelineTab._startBatchAnalysis()` มาเป็น helper ที่ทั้ง Pro Mode และ Basic Mode ใช้ร่วมกันได้

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/gemini_service.dart';
import '../database/database_service.dart';
import '../services/usage_limiter.dart';
import '../utils/logger.dart';
import '../constants/enums.dart';
import '../../features/health/models/food_entry.dart';
import '../../features/health/models/my_meal.dart';
import '../../features/health/providers/health_provider.dart';
import '../../features/health/providers/my_meal_provider.dart';
import '../../features/energy/providers/energy_provider.dart';
import '../../l10n/app_localizations.dart';

class BatchAnalysisResult {
  final int successCount;
  final int failedCount;
  final bool wasCancelled;

  BatchAnalysisResult({
    required this.successCount,
    required this.failedCount,
    required this.wasCancelled,
  });
}

class BatchAnalysisHelper {
  static const int _batchSize = 5;

  /// ตรวจสอบ energy ก่อน analyze
  /// return true ถ้าพอใช้
  static Future<bool> checkEnergy(WidgetRef ref, int requiredEnergy) async {
    final energyService = GeminiService.energyService;
    if (energyService != null) {
      final isFirstFree = await energyService.isFirstFreeAnalysisAvailable();
      if (isFirstFree) {
        await energyService.grantFirstFreeAnalysis(requiredEnergy);
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);
      }
    }

    final energyAsync = ref.read(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;
    return currentBalance >= requiredEnergy;
  }

  /// Extract ingredient data จาก FoodEntry
  static ({List<String>? names, List<Map<String, dynamic>>? userIngredients})
      extractIngredientsFromJson(FoodEntry entry) {
    if (entry.ingredientsJson == null || entry.ingredientsJson!.isEmpty) {
      return (names: null, userIngredients: null);
    }
    try {
      final decoded = jsonDecode(entry.ingredientsJson!) as List<dynamic>;
      final names = decoded
          .map((item) => item['name'] as String?)
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();

      final userIngredients = decoded
          .where((item) =>
              item['name'] != null &&
              item['amount'] != null &&
              (item['amount'] as num) > 0)
          .map((item) => <String, dynamic>{
                'name': item['name'] as String,
                'amount': (item['amount'] as num).toDouble(),
                'unit': item['unit'] as String? ?? 'g',
              })
          .toList();

      return (
        names: names.isNotEmpty ? names : null,
        userIngredients: userIngredients.isNotEmpty ? userIngredients : null,
      );
    } catch (err) {
      AppLogger.warn('[extractIngredientsFromJson] Failed: $err');
      return (names: null, userIngredients: null);
    }
  }

  /// Apply AI result ไปที่ FoodEntry
  static void applyResultToEntry(FoodEntry entry, FoodAnalysisResult result) {
    entry.foodName = result.foodName;
    entry.foodNameEn = result.foodNameEn;
    entry.calories = result.nutrition.calories;
    entry.protein = result.nutrition.protein;
    entry.carbs = result.nutrition.carbs;
    entry.fat = result.nutrition.fat;
    entry.fiber = result.nutrition.fiber;
    entry.sugar = result.nutrition.sugar;
    entry.sodium = result.nutrition.sodium;

    final serving = result.servingSize > 0 ? result.servingSize : 1.0;
    entry.baseCalories = result.nutrition.calories / serving;
    entry.baseProtein = result.nutrition.protein / serving;
    entry.baseCarbs = result.nutrition.carbs / serving;
    entry.baseFat = result.nutrition.fat / serving;
    entry.servingSize = result.servingSize;
    entry.servingUnit = result.servingUnit;
    entry.servingGrams = result.servingGrams?.toDouble();
    entry.source = DataSource.aiAnalyzed;
    entry.isVerified = true;
    entry.aiConfidence = result.confidence;

    if (result.ingredientsDetail != null &&
        result.ingredientsDetail!.isNotEmpty) {
      entry.ingredientsJson = jsonEncode(
        result.ingredientsDetail!.map((item) => item.toJson()).toList(),
      );
    }
  }

  /// Auto-save meal + ingredients ไป database
  static Future<void> autoSaveToDatabase(
    WidgetRef ref,
    FoodEntry entry,
    FoodAnalysisResult result,
  ) async {
    if (result.ingredientsDetail == null ||
        result.ingredientsDetail!.isEmpty) {
      return;
    }

    try {
      final all = await DatabaseService.myMeals.where().findAll();
      final uniqueName = _getUniqueMealName(result.foodName, all);

      final ingredientsData =
          result.ingredientsDetail!.map((e) => e.toJson()).toList();

      await ref
          .read(foodEntriesNotifierProvider.notifier)
          .saveIngredientsAndMeal(
            mealName: uniqueName,
            mealNameEn: result.foodNameEn,
            servingDescription: '${result.servingSize} ${result.servingUnit}',
            imagePath: entry.imagePath,
            ingredientsData: ingredientsData,
          );

      ref.invalidate(allMyMealsProvider);
      ref.invalidate(allIngredientsProvider);
      AppLogger.info(
          '[AutoSave] Saved "$uniqueName" + ${ingredientsData.length} ingredients');
    } catch (e) {
      AppLogger.warn('[AutoSave] Failed for "${result.foodName}": $e');
    }
  }

  static String _getUniqueMealName(String baseName, List<MyMeal> allMeals) {
    final names = allMeals.map((m) => m.name).toSet();
    if (!names.contains(baseName)) return baseName;

    int counter = 2;
    while (names.contains('$baseName ($counter)')) {
      counter++;
    }
    return '$baseName ($counter)';
  }

  /// Analyze รายการที่เลือก (ใช้ได้ทั้ง analyze all และ analyze selected)
  /// [onProgress] callback: (currentIndex, totalCount, currentItemName)
  /// [shouldCancel] callback: return true เพื่อยกเลิก
  static Future<BatchAnalysisResult> analyzeEntries({
    required WidgetRef ref,
    required List<FoodEntry> entries,
    required DateTime selectedDate,
    required void Function(int current, int total, String itemName) onProgress,
    required bool Function() shouldCancel,
  }) async {
    int totalSuccessCount = 0;
    List<int> failedIds = [];
    var entriesToProcess = entries;

    while (entriesToProcess.isNotEmpty && !shouldCancel()) {
      int batchSuccessCount = 0;

      final textEntries = entriesToProcess
          .where((e) => e.imagePath == null || e.imagePath!.isEmpty)
          .toList();
      final imageEntries = entriesToProcess
          .where((e) => e.imagePath != null && e.imagePath!.isNotEmpty)
          .toList();

      // Process text entries in batches of 5
      for (int chunkStart = 0;
          chunkStart < textEntries.length;
          chunkStart += _batchSize) {
        if (shouldCancel()) break;

        final chunkEnd =
            (chunkStart + _batchSize).clamp(0, textEntries.length);
        final chunk = textEntries.sublist(chunkStart, chunkEnd);

        onProgress(
          totalSuccessCount + batchSuccessCount + failedIds.length + 1,
          entries.length,
          '${chunk.length} items',
        );

        try {
          final batchItems = chunk.map((e) {
            final extracted = extractIngredientsFromJson(e);
            return (
              name: e.foodName,
              servingSize: e.servingSize as double?,
              servingUnit: e.servingUnit as String?,
              searchMode: e.searchMode,
              ingredientNames: extracted.names,
              userIngredients: extracted.userIngredients,
            );
          }).toList();

          final results = await GeminiService.analyzeFoodBatch(batchItems);

          for (int i = 0; i < chunk.length; i++) {
            final entry = chunk[i];
            var result = i < results.length ? results[i] : null;

            if (result != null && result.confidence > 0) {
              final userIngs = batchItems[i].userIngredients;
              if (userIngs != null && userIngs.isNotEmpty) {
                result = GeminiService.enforceUserIngredientAmounts(
                    result, userIngs);
              }
              applyResultToEntry(entry, result);
              await ref
                  .read(foodEntriesNotifierProvider.notifier)
                  .updateFoodEntry(entry);
              await autoSaveToDatabase(ref, entry, result);
              await UsageLimiter.recordAiUsage();
              batchSuccessCount++;
            } else {
              failedIds.add(entry.id);
            }
          }
        } catch (e) {
          AppLogger.error('[BatchAnalyze] Batch failed, falling back', e);
          for (final entry in chunk) {
            if (shouldCancel()) break;
            try {
              onProgress(
                totalSuccessCount + batchSuccessCount + failedIds.length + 1,
                entries.length,
                entry.foodName,
              );

              final extracted = extractIngredientsFromJson(entry);
              var result = await GeminiService.analyzeFoodByName(
                entry.foodName,
                servingSize: entry.servingSize,
                servingUnit: entry.servingUnit,
                searchMode: entry.searchMode,
                ingredientNames: extracted.names,
                userIngredients: extracted.userIngredients,
              );
              if (result != null) {
                if (extracted.userIngredients != null &&
                    extracted.userIngredients!.isNotEmpty) {
                  result = GeminiService.enforceUserIngredientAmounts(
                      result, extracted.userIngredients!);
                }
                applyResultToEntry(entry, result);
                await ref
                    .read(foodEntriesNotifierProvider.notifier)
                    .updateFoodEntry(entry);
                await autoSaveToDatabase(ref, entry, result);
                await UsageLimiter.recordAiUsage();
                batchSuccessCount++;
              } else {
                failedIds.add(entry.id);
              }
            } catch (e2) {
              AppLogger.error('[BatchAnalyze] Individual failed', e2);
              failedIds.add(entry.id);
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }

        if (chunkStart + _batchSize < textEntries.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Process image entries one-by-one
      for (int i = 0; i < imageEntries.length; i++) {
        if (shouldCancel()) break;

        final entry = imageEntries[i];
        onProgress(
          totalSuccessCount + batchSuccessCount + failedIds.length + 1,
          entries.length,
          entry.foodName,
        );

        try {
          final result = await GeminiService.analyzeFoodImage(
            File(entry.imagePath!),
            foodName: entry.foodName,
            quantity: entry.servingSize,
            unit: entry.servingUnit,
            searchMode: entry.searchMode,
          );

          if (result != null) {
            applyResultToEntry(entry, result);
            await ref
                .read(foodEntriesNotifierProvider.notifier)
                .updateFoodEntry(entry);
            await autoSaveToDatabase(ref, entry, result);
            await UsageLimiter.recordAiUsage();
            batchSuccessCount++;
          } else {
            failedIds.add(entry.id);
          }
        } catch (e) {
          AppLogger.error('[BatchAnalyze] Image failed', e);
          failedIds.add(entry.id);
        }

        if (i < imageEntries.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      totalSuccessCount += batchSuccessCount;

      // Refresh providers
      ref.invalidate(healthTimelineProvider(selectedDate));
      ref.invalidate(todayCaloriesProvider);
      ref.invalidate(todayMacrosProvider);

      if (shouldCancel()) break;

      // Check for new unanalyzed entries
      try {
        final refreshed =
            await ref.read(foodEntriesByDateProvider(selectedDate).future);
        entriesToProcess = refreshed
            .where(
                (f) => !f.hasNutritionData && !failedIds.contains(f.id))
            .toList();

        if (entriesToProcess.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        break;
      }
    }

    return BatchAnalysisResult(
      successCount: totalSuccessCount,
      failedCount: failedIds.length,
      wasCancelled: shouldCancel(),
    );
  }
}
```

### ทำเพิ่ม: แก้ `health_timeline_tab.dart`
เปลี่ยน `_startBatchAnalysis` ให้เรียก `BatchAnalysisHelper.analyzeEntries()` แทน logic เดิม แต่ **ยังเก็บ state variables** (`_isAnalyzing`, `_analyzeTotal`, `_analyzeCurrent`, `_currentItemName`, `_failedIds`, `_cancelRequested`) ไว้ใน widget เหมือนเดิม เปลี่ยนแค่ body ของ method

---

## Step 4: Food Sandbox Widget

### สร้างไฟล์: `lib/features/home/widgets/food_sandbox.dart`

**Spec:**
- ใช้ `Wrap` widget เรียงตามเวลา (เก่าสุดอยู่บนซ้าย ใหม่สุดอยู่ล่างขวา)
- แต่ละ bubble: Card ขนาดประมาณ 100-110px กว้าง
- แสดง: รูป (ถ้ามี), ชื่อ (ตัดสั้น), kcal, P/C/F
- Long-press: เข้า selection mode + wiggle animation
- Tap: เปิด SimpleFoodDetailSheet
- Selection mode: แสดง action bar ด้านบน (ลบที่เลือก + วิเคราะห์ที่เลือก)

```dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
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
            child: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.textSecondary),
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
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : isUnanalyzed
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : isDark
                        ? AppColors.dividerDark
                        : AppColors.divider,
            width: widget.isSelected ? 2 : 1,
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
            // Image or icon
            ClipRRect(
              borderRadius: AppRadius.sm,
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: hasImage
                    ? Image.file(
                        File(entry.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(isDark),
                      )
                    : _buildPlaceholder(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
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
                      : AppColors.textTertiary,
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

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 24,
          color: isDark ? Colors.white24 : AppColors.textTertiary,
        ),
      ),
    );
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
```

> **หมายเหตุ:** `AnimatedBuilder` ใช้สำหรับ wiggle ตอน selection mode

---

## Step 5: Simple Food Detail Bottom Sheet

### สร้างไฟล์: `lib/features/home/widgets/simple_food_detail_sheet.dart`

**Spec ของ Bottom Sheet:**
1. รูปอาหาร (เต็มความกว้าง)
2. ชื่อ + ปุ่ม quick edit inline
3. Summary energy + macros
4. Ingredients (ถ้ามี) - เรียงกันมา แต่ละตัวมี badge ลบที่มุมขวาบน
5. Info text: "สำหรับแก้ไขแบบละเอียด ใช้โหมด Pro"
6. ปุ่ม OK / Save

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';
import '../../health/providers/health_provider.dart';
import '../../../core/database/database_service.dart';

class SimpleFoodDetailSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;

  const SimpleFoodDetailSheet({super.key, required this.entry});

  @override
  ConsumerState<SimpleFoodDetailSheet> createState() =>
      _SimpleFoodDetailSheetState();
}

class _SimpleFoodDetailSheetState extends ConsumerState<SimpleFoodDetailSheet> {
  late TextEditingController _nameController;
  bool _isEditingName = false;
  bool _hasChanges = false;
  List<Map<String, dynamic>> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.foodName);
    _loadIngredients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadIngredients() {
    if (widget.entry.ingredientsJson != null &&
        widget.entry.ingredientsJson!.isNotEmpty) {
      try {
        final decoded =
            jsonDecode(widget.entry.ingredientsJson!) as List<dynamic>;
        _ingredients = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    final entry = widget.entry;
    bool changed = false;

    if (_nameController.text.trim() != entry.foodName) {
      entry.foodName = _nameController.text.trim();
      changed = true;
    }

    if (_hasChanges) {
      entry.ingredientsJson =
          _ingredients.isNotEmpty ? jsonEncode(_ingredients) : null;
      changed = true;
    }

    if (changed) {
      entry.updatedAt = DateTime.now();
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });
      refreshFoodProviders(ref, entry.timestamp);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Image.file(
                        File(entry.imagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 2. Name + Quick Edit
                  Row(
                    children: [
                      Expanded(
                        child: _isEditingName
                            ? TextField(
                                controller: _nameController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.md,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                                onSubmitted: (_) {
                                  setState(() {
                                    _isEditingName = false;
                                    if (_nameController.text.trim() !=
                                        widget.entry.foodName) {
                                      _hasChanges = true;
                                    }
                                  });
                                },
                              )
                            : Text(
                                _nameController.text,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isEditingName = !_isEditingName);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.sm,
                          ),
                          child: Icon(
                            _isEditingName
                                ? Icons.check_rounded
                                : Icons.edit_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Summary Energy + Macros
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.health.withValues(alpha: 0.08),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.hasNutritionData
                              ? '${entry.calories.toInt()} kcal'
                              : '-- kcal',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: entry.hasNutritionData
                                ? AppColors.health
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _macroChip(
                                'P', entry.protein, AppColors.protein),
                            _macroChip('C', entry.carbs, AppColors.carbs),
                            _macroChip('F', entry.fat, AppColors.fat),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Ingredients (ถ้ามี)
                  if (_ingredients.isNotEmpty) ...[
                    Text(
                      l10n.ingredients,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: List.generate(_ingredients.length, (i) {
                        final ing = _ingredients[i];
                        final name = ing['name'] ?? '';
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.surfaceVariant,
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            // Delete badge
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => _removeIngredient(i),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 5. Info text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.06),
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.useProModeForDetail,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 6. OK / Save button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonMedium,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasChanges ||
                                _nameController.text.trim() !=
                                    widget.entry.foodName
                            ? AppColors.primary
                            : isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                        foregroundColor: _hasChanges ||
                                _nameController.text.trim() !=
                                    widget.entry.foodName
                            ? Colors.white
                            : isDark
                                ? Colors.white70
                                : AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md,
                        ),
                      ),
                      child: Text(
                        _hasChanges ||
                                _nameController.text.trim() !=
                                    widget.entry.foodName
                            ? l10n.saveChanges
                            : l10n.ok,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String prefix, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        '$prefix ${value.toInt()}g',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
```

---

## Step 6: Quick Add Dialog

ไม่สร้างไฟล์แยก - เขียนเป็น static method ใน `BasicModeTab` หรือจะสร้างแยกก็ได้ ให้สร้างเป็น function ที่ return `FoodEntry?`

### Logic ของ Quick Add:

```dart
/// แสดง Quick Add Dialog
/// return FoodEntry ที่สร้างใหม่ (calories=0, unanalyzed) หรือ null ถ้ายกเลิก
static Future<FoodEntry?> showQuickAddDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  String selectedUnit = 'serving';
  final l10n = L10n.of(context)!;

  final result = await showModalBottomSheet<FoodEntry>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).cardColor,
            borderRadius: AppRadius.sheetTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                l10n.quickAddTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Food name
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.foodName,
                  hintText: l10n.quickAddHint,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.md,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Quantity + Unit row
              Row(
                children: [
                  // Quantity
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.quantity,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Unit
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.servingUnit,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                        ),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'serving', child: Text('serving')),
                        DropdownMenuItem(value: 'piece', child: Text('piece')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'cup', child: Text('cup')),
                        DropdownMenuItem(value: 'tbsp', child: Text('tbsp')),
                        DropdownMenuItem(value: 'plate', child: Text('plate')),
                        DropdownMenuItem(value: 'bowl', child: Text('bowl')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedUnit = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Add button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonMedium,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final qty = double.tryParse(quantityController.text) ?? 1.0;
                    final now = DateTime.now();

                    // Auto-assign meal type ตามเวลา
                    MealType mealType;
                    final hour = now.hour;
                    if (hour >= 5 && hour < 11) {
                      mealType = MealType.breakfast;
                    } else if (hour >= 11 && hour < 15) {
                      mealType = MealType.lunch;
                    } else if (hour >= 15 && hour < 21) {
                      mealType = MealType.dinner;
                    } else {
                      mealType = MealType.snack;
                    }

                    final entry = FoodEntry()
                      ..foodName = name
                      ..timestamp = now
                      ..mealType = mealType
                      ..servingSize = qty
                      ..servingUnit = selectedUnit
                      ..calories = 0
                      ..protein = 0
                      ..carbs = 0
                      ..fat = 0
                      ..baseCalories = 0
                      ..baseProtein = 0
                      ..baseCarbs = 0
                      ..baseFat = 0
                      ..source = DataSource.manual
                      ..isVerified = false;

                    Navigator.pop(ctx, entry);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md,
                    ),
                  ),
                  child: Text(
                    l10n.addToSandbox,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return result;
}
```

> **import เพิ่ม:** `DataSource`, `MealType` จาก `enums.dart`, `FoodEntry` จาก `food_entry.dart`

---

## Step 7: Basic Mode Tab

### สร้างไฟล์: `lib/features/home/presentation/basic_mode_tab.dart`

**นี่คือไฟล์ที่ใหญ่ที่สุด** - รวมทุกอย่างในหน้าเดียว

**โครงสร้างหลัก:**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/batch_analysis_helper.dart';
import '../../../core/database/database_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';
import '../../health/providers/health_provider.dart';
import '../../health/widgets/daily_summary_card.dart';
import '../../energy/widgets/quest_bar.dart';
import '../../energy/providers/energy_provider.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../chat/providers/chat_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/image_picker_service.dart';
import '../widgets/food_sandbox.dart';
import '../widgets/simple_food_detail_sheet.dart';

class BasicModeTab extends ConsumerStatefulWidget {
  const BasicModeTab({super.key});

  @override
  ConsumerState<BasicModeTab> createState() => _BasicModeTabState();
}

class _BasicModeTabState extends ConsumerState<BasicModeTab> {
  final _chatController = TextEditingController();
  bool _isComposing = false;
  bool _isScanning = false;

  // Batch analysis state
  bool _isAnalyzing = false;
  int _analyzeTotal = 0;
  int _analyzeCurrent = 0;
  String _currentItemName = '';
  bool _cancelRequested = false;

  DateTime get _selectedDate => dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _chatController.addListener(() {
      setState(() => _isComposing = _chatController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));
    final l10n = L10n.of(context)!;

    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: RefreshIndicator(
            onRefresh: _scanForFood,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. QuestBar
                const SliverToBoxAdapter(child: QuestBar()),

                // 2. DailySummaryCard
                SliverToBoxAdapter(
                  child: DailySummaryCard(selectedDate: _selectedDate),
                ),

                // 3. Analyze All / Progress Bar
                SliverToBoxAdapter(
                  child: _buildAnalyzeSection(timelineAsync),
                ),

                // 4. Food Sandbox
                SliverToBoxAdapter(
                  child: _buildSandbox(timelineAsync),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),

        // 5. Action Buttons (Camera | Gallery | Add)
        _buildActionButtons(l10n),

        // 6. Chat Input
        _buildChatInput(l10n),
      ],
    );
  }

  // ============================================================
  // SANDBOX
  // ============================================================
  Widget _buildSandbox(AsyncValue<List<TimelineItem>> timelineAsync) {
    final items = timelineAsync.valueOrNull ?? [];
    final foodEntries = items
        .where((i) => i.type == 'food')
        .map((i) => i.data as FoodEntry)
        .where((f) => !f.isDeleted)
        .toList();

    return FoodSandbox(
      entries: foodEntries,
      onTap: (entry) => _showFoodDetail(entry),
      onDeleteSelected: _deleteSelectedEntries,
      onAnalyzeSelected: _analyzeSelectedEntries,
    );
  }

  // ============================================================
  // ANALYZE SECTION (Analyze All button / Progress bar)
  // ============================================================
  Widget _buildAnalyzeSection(AsyncValue<List<TimelineItem>> timelineAsync) {
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = timelineAsync.valueOrNull ?? [];
    final foodEntries = items
        .where((i) => i.type == 'food')
        .map((i) => i.data as FoodEntry)
        .where((f) => !f.isDeleted)
        .toList();
    final unanalyzed = foodEntries.where((f) => !f.hasNutritionData).toList();
    final energyCost = unanalyzed.length;

    if (_isAnalyzing) {
      // Progress bar
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2, vertical: AppSpacing.xl / 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl / 2),
                Expanded(
                  child: Text(
                    l10n.analyzeProgress(
                        _currentItemName, _analyzeCurrent, _analyzeTotal),
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _cancelRequested = true),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _analyzeTotal > 0 ? _analyzeCurrent / _analyzeTotal : 0,
                minHeight: 4,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (energyCost <= 0) return const SizedBox.shrink();

    // Analyze All button
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => _startBatchAnalysis(unanalyzed),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.ai, size: 18, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.analyzeAll,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '$energyCost',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppIcons.energyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS (Camera | Gallery | Add)
  // ============================================================
  Widget _buildActionButtons(L10n l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Camera
          _actionButton(
            icon: Icons.camera_alt_rounded,
            label: l10n.navCamera,
            onTap: _openCamera,
          ),
          // Gallery
          _actionButton(
            icon: Icons.photo_library_rounded,
            label: l10n.gallery,
            onTap: _pickFromGallery,
          ),
          // Quick Add (+)
          _actionButton(
            icon: Icons.add_rounded,
            label: l10n.addFood,
            onTap: _quickAdd,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.surfaceVariant,
          borderRadius: AppRadius.xl,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHAT INPUT
  // ============================================================
  Widget _buildChatInput(L10n l10n) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.xxl,
              ),
              child: TextField(
                controller: _chatController,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: l10n.tellMeWhatYouAte,
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
                onSubmitted: (_) => _sendChat(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isComposing ? AppColors.primary : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isComposing ? _sendChat : null,
                borderRadius: AppRadius.xl,
                child: Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: _isComposing ? Colors.white : AppColors.textTertiary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _sendChat() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;
    ref.read(chatNotifierProvider.notifier).sendMessage(message);
    _chatController.clear();
    // Refresh providers หลัง chat save entry
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) refreshFoodProviders(ref, _selectedDate);
    });
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (capturedImage != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(imageFile: capturedImage),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final File? image = await ImagePickerService.pickFromGallery();
    if (image != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(imageFile: image),
        ),
      );
    }
  }

  Future<void> _quickAdd() async {
    // ใช้ Quick Add Dialog จาก Step 6 (สร้างเป็น static method ในไฟล์นี้
    // หรือ import จากไฟล์แยก)
    final entry = await _showQuickAddDialog();
    if (entry != null) {
      await ref.read(foodEntriesNotifierProvider.notifier).addFoodEntry(entry);
      refreshFoodProviders(ref, _selectedDate);
    }
  }

  Future<void> _scanForFood() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final count = await ref
          .read(galleryScanNotifierProvider.notifier)
          .scanNewImages(specificDate: _selectedDate);
      refreshFoodProviders(ref, _selectedDate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? L10n.of(context)!.scanFoundNewImages(
                  count, DateFormat('d MMM yyyy').format(_selectedDate))
              : L10n.of(context)!.scanNoNewImages(
                  DateFormat('d MMM yyyy').format(_selectedDate))),
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showFoodDetail(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SimpleFoodDetailSheet(entry: entry),
    );
  }

  Future<void> _deleteSelectedEntries(List<FoodEntry> entries) async {
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    for (final entry in entries) {
      await notifier.deleteFoodEntry(entry.id);
    }
    refreshFoodProviders(ref, _selectedDate);
  }

  Future<void> _analyzeSelectedEntries(List<FoodEntry> entries) async {
    await _startBatchAnalysis(entries);
  }

  Future<void> _startBatchAnalysis(List<FoodEntry> entries) async {
    if (entries.isEmpty) return;

    final hasEnergy =
        await BatchAnalysisHelper.checkEnergy(ref, entries.length);
    if (!hasEnergy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.notEnoughEnergy)),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analyzeTotal = entries.length;
      _analyzeCurrent = 0;
      _currentItemName = '';
      _cancelRequested = false;
    });

    final result = await BatchAnalysisHelper.analyzeEntries(
      ref: ref,
      entries: entries,
      selectedDate: _selectedDate,
      onProgress: (current, total, itemName) {
        if (mounted) {
          setState(() {
            _analyzeCurrent = current;
            _analyzeTotal = total;
            _currentItemName = itemName;
          });
        }
      },
      shouldCancel: () => _cancelRequested,
    );

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final l10n = L10n.of(context)!;
    final message = result.wasCancelled
        ? l10n.analyzeCancelled(result.successCount)
        : result.failedCount == 0
            ? l10n.analyzeSuccessAll(result.successCount)
            : l10n.analyzeSuccessPartial(
                result.successCount,
                result.successCount + result.failedCount,
                result.failedCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // Quick Add Dialog (วาง code จาก Step 6 ตรงนี้)
  Future<FoodEntry?> _showQuickAddDialog() async {
    // ... paste Quick Add Dialog code จาก Step 6 ตรงนี้ ...
    // return FoodEntry หรือ null
  }
}
```

---

## Step 8: แก้ไข HomeScreen

### ไฟล์: `lib/features/home/presentation/home_screen.dart`

### 8.1 เพิ่ม imports

ที่บรรทัดบนสุด เพิ่ม:

```dart
import '../../../core/providers/app_mode_provider.dart';
import '../../../core/widgets/mode_toggle.dart';
import 'basic_mode_tab.dart';
```

### 8.2 แก้ `build()` method

**เดิม** (line ~237-249):
```dart
child: Scaffold(
  appBar: _buildAppBar(),
  body: IndexedStack(
    index: stackIndex,
    children: const [
      HealthTimelineTab(),
      HealthMyMealTab(),
      ChatScreen(),
    ],
  ),
  bottomNavigationBar: _buildBottomNav(),
),
```

**ใหม่:**
```dart
child: Scaffold(
  appBar: _buildAppBar(),
  body: _buildBody(stackIndex),
  bottomNavigationBar: _buildBottomNavOrNull(),
),
```

### 8.3 เพิ่ม `_buildBody()` method

```dart
Widget _buildBody(int stackIndex) {
  final mode = ref.watch(appModeProvider);
  if (mode == AppMode.basic) {
    return const BasicModeTab();
  }
  return IndexedStack(
    index: stackIndex,
    children: const [
      HealthTimelineTab(),
      HealthMyMealTab(),
      ChatScreen(),
    ],
  );
}
```

### 8.4 เปลี่ยน `_buildBottomNav()` → `_buildBottomNavOrNull()`

```dart
Widget? _buildBottomNavOrNull() {
  final mode = ref.watch(appModeProvider);
  if (mode == AppMode.basic) return null; // ซ่อน bottom nav ใน basic mode
  return _buildBottomNav(); // method เดิม
}
```

**(เก็บ `_buildBottomNav()` เดิมไว้เหมือนเดิม ไม่ต้องแก้)**

### 8.5 แก้ `_buildAppBar()` - เพิ่ม ModeToggle

**เดิม** (line ~281-293):
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.person_outline),
    onPressed: () { ... },
    tooltip: L10n.of(context)!.navProfile,
  ),
],
```

**ใหม่:**
```dart
actions: [
  const ModeToggle(),
  const SizedBox(width: 4),
  IconButton(
    icon: const Icon(Icons.person_outline),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    },
    tooltip: L10n.of(context)!.navProfile,
  ),
],
```

### 8.6 แก้ title ให้รองรับ Basic Mode

**เดิม:**
```dart
String title;
switch (_currentIndex) {
  case 0: title = L10n.of(context)!.appBarTodayIntake; break;
  ...
}
```

**ใหม่:**
```dart
final mode = ref.watch(appModeProvider);
String title;
if (mode == AppMode.basic) {
  title = L10n.of(context)!.appBarTodayIntake;
} else {
  switch (_currentIndex) {
    case 0: title = L10n.of(context)!.appBarTodayIntake; break;
    case 1: title = L10n.of(context)!.appBarMyMeals; break;
    case 2: title = L10n.of(context)!.appBarCamera; break;
    case 3: title = L10n.of(context)!.appBarAiChat; break;
    default: title = L10n.of(context)!.appBarMiro;
  }
}
```

---

## Step 9: Localization

### เพิ่มใน `lib/l10n/app_en.arb` (ก่อน `}` สุดท้าย):

```json
  "basicMode": "Basic",
  "proMode": "Pro",
  "sandboxEmpty": "No food items yet. Chat, snap a photo, or tap + to add!",
  "deleteSelected": "Delete",
  "analyzeSelected": "Analyze",
  "useProModeForDetail": "For detailed editing, switch to Pro mode.",
  "saveChanges": "Save Changes",
  "quickAddTitle": "Quick Add",
  "quickAddHint": "e.g. Pad Thai, Rice...",
  "quantity": "Quantity",
  "addToSandbox": "Add",
  "gallery": "Gallery",
  "ingredients": "Ingredients",
  "longPressToSelect": "Long-press to select items"
```

### เพิ่มใน `lib/l10n/app_th.arb` (ก่อน `}` สุดท้าย):

```json
  "basicMode": "Basic",
  "proMode": "Pro",
  "sandboxEmpty": "ยังไม่มีรายการอาหาร แชท ถ่ายรูป หรือกด + เพื่อเพิ่ม!",
  "deleteSelected": "ลบ",
  "analyzeSelected": "วิเคราะห์",
  "useProModeForDetail": "สำหรับแก้ไขแบบละเอียด ใช้โหมด Pro",
  "saveChanges": "บันทึก",
  "quickAddTitle": "เพิ่มด่วน",
  "quickAddHint": "เช่น ผัดไทย, ข้าวสวย...",
  "quantity": "ปริมาณ",
  "addToSandbox": "เพิ่ม",
  "gallery": "แกลเลอรี",
  "ingredients": "ส่วนประกอบ",
  "longPressToSelect": "กดค้างเพื่อเลือกรายการ"
```

### ภาษาอื่นทั้งหมด (10 ไฟล์ที่เหลือ)

**Copy key เหมือน `app_en.arb` ไปวางในไฟล์ภาษาอื่น** (ใช้ภาษาอังกฤษเป็น fallback ก่อน แล้วค่อยแปลทีหลังได้):

ไฟล์ที่ต้องเพิ่ม keys เดียวกัน:
- `app_zh.arb`, `app_ja.arb`, `app_ko.arb`
- `app_es.arb`, `app_fr.arb`, `app_de.arb`
- `app_hi.arb`, `app_id.arb`, `app_pt.arb`, `app_vi.arb`

---

## Step 10: Run gen-l10n

```bash
flutter gen-l10n
```

ถ้า error ให้ตรวจ:
- JSON syntax ถูกต้อง (ไม่ขาด comma, ไม่มี trailing comma ตัวสุดท้าย)
- ทุกไฟล์มี key เดียวกัน (ถ้าขาดจะ warning ไม่ error)

---

## Checklist ทดสอบ

### Mode Toggle
- [ ] เปิดแอป → default เป็น Pro Mode
- [ ] กด toggle → สลับเป็น Basic Mode ทันที
- [ ] กด toggle อีกครั้ง → กลับเป็น Pro Mode
- [ ] ปิด-เปิดแอป → จำ mode ที่เลือกไว้
- [ ] Pro Mode → มี BottomNavigationBar + 4 tabs เหมือนเดิม
- [ ] Basic Mode → ไม่มี BottomNavigationBar

### Basic Mode - Chat
- [ ] พิมพ์ชื่ออาหารในช่องแชท → กด send → อาหารเพิ่มใน sandbox
- [ ] ช่องแชทล้างหลัง send

### Basic Mode - Camera
- [ ] กดปุ่มกล้อง → เปิด CameraScreen fullscreen
- [ ] ถ่ายรูป → ไป ImageAnalysisPreviewScreen → กลับมามี entry ใน sandbox

### Basic Mode - Gallery
- [ ] กดปุ่ม gallery → เปิด image picker
- [ ] เลือกรูป → ไป ImageAnalysisPreviewScreen → กลับมามี entry ใน sandbox

### Basic Mode - Quick Add (+)
- [ ] กดปุ่ม + → เปิด Quick Add dialog
- [ ] ใส่ชื่อ + ปริมาณ + หน่วย → กด Add → entry เพิ่มใน sandbox (0 kcal)
- [ ] ไม่ใส่ชื่อ → กด Add → ไม่เกิดอะไร

### Basic Mode - Sandbox
- [ ] Bubble แสดงรูป (ถ้ามี), ชื่อ, kcal, macros
- [ ] Entry ที่ยังไม่วิเคราะห์แสดง "-- kcal" + ขอบสีเหลือง
- [ ] Tap bubble → เปิด SimpleFoodDetailSheet
- [ ] Long-press bubble → เข้า selection mode + bubble สั่น
- [ ] เลือกหลาย bubble → แสดง action bar (ลบ + วิเคราะห์)
- [ ] กดลบ → ลบ entries ที่เลือก
- [ ] กดวิเคราะห์ → analyze เฉพาะ entries ที่เลือก

### Basic Mode - Analyze All
- [ ] มี entry ที่ยังไม่วิเคราะห์ → แสดงปุ่ม Analyze All + energy cost
- [ ] กด Analyze All → แสดง progress bar → วิเคราะห์ทั้งหมด
- [ ] กด cancel → หยุดวิเคราะห์

### Basic Mode - Summary
- [ ] DailySummaryCard แสดง calories/macros ถูกต้อง
- [ ] กด Summary → ไป TodaySummaryDashboardScreen

### Basic Mode - QuestBar
- [ ] QuestBar แสดงเหมือนใน Pro Mode

### Basic Mode - Simple Detail Sheet
- [ ] แสดงรูป, ชื่อ, energy, macros, ingredients (ถ้ามี)
- [ ] กด quick edit → แก้ชื่อได้
- [ ] ลบ ingredient → badge X ทำงาน
- [ ] มีการเปลี่ยนแปลง → ปุ่มเปลี่ยนเป็น "Save Changes"
- [ ] กด Save → บันทึก + ปิด sheet

### Basic Mode - Pull to Refresh
- [ ] ดึงลง → scan gallery → แสดง snackbar ผลลัพธ์

### Cross-mode
- [ ] เพิ่มอาหารใน Basic Mode → สลับไป Pro Mode → เห็นอาหารใน meal section ที่ถูกต้อง
- [ ] เพิ่มอาหารใน Pro Mode → สลับไป Basic Mode → เห็นอาหารใน sandbox
