import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../models/my_meal.dart';
import '../models/ingredient.dart';

/// ข้อมูลสำหรับ Quick Add
class QuickAddItem {
  final String name;
  final String emoji;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final int? myMealId;
  final int? ingredientId;
  final int usageCount;

  QuickAddItem({
    required this.name,
    required this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    this.myMealId,
    this.ingredientId,
    required this.usageCount,
  });
}

/// ดึง Top 5 อาหารที่กินบ่อยสุด (จาก MyMeal + Ingredient)
final topQuickAddItemsProvider = FutureProvider<List<QuickAddItem>>((ref) async {
  final items = <QuickAddItem>[];

  // 1. ดึง MyMeal ที่ใช้บ่อยสุด
  final topMeals = await DatabaseService.myMeals
      .where()
      .sortByUsageCountDesc()
      .limit(5)
      .findAll();

  for (final meal in topMeals) {
    if (meal.usageCount > 0) {
      items.add(QuickAddItem(
        name: meal.name,
        emoji: '🍽️',
        calories: meal.totalCalories,
        protein: meal.totalProtein,
        carbs: meal.totalCarbs,
        fat: meal.totalFat,
        servingSize: meal.parsedServingSize,
        servingUnit: meal.parsedServingUnit,
        baseCalories: meal.caloriesPerUnit,
        baseProtein: meal.proteinPerUnit,
        baseCarbs: meal.carbsPerUnit,
        baseFat: meal.fatPerUnit,
        myMealId: meal.id,
        usageCount: meal.usageCount,
      ));
    }
  }

  // 2. ดึง Ingredient ที่ใช้บ่อยสุด (เติมจนครบ 5)
  if (items.length < 5) {
    final remaining = 5 - items.length;
    final topIngredients = await DatabaseService.ingredients
        .where()
        .sortByUsageCountDesc()
        .limit(remaining)
        .findAll();

    for (final ing in topIngredients) {
      if (ing.usageCount > 0) {
        items.add(QuickAddItem(
          name: ing.name,
          emoji: '🥬',
          calories: ing.caloriesPerBase,
          protein: ing.proteinPerBase,
          carbs: ing.carbsPerBase,
          fat: ing.fatPerBase,
          servingSize: ing.baseAmount,
          servingUnit: ing.baseUnit,
          baseCalories: ing.caloriesPerBase / ing.baseAmount,
          baseProtein: ing.proteinPerBase / ing.baseAmount,
          baseCarbs: ing.carbsPerBase / ing.baseAmount,
          baseFat: ing.fatPerBase / ing.baseAmount,
          ingredientId: ing.id,
          usageCount: ing.usageCount,
        ));
      }
    }
  }

  // Sort by usage count
  items.sort((a, b) => b.usageCount.compareTo(a.usageCount));

  return items.take(5).toList();
});

/// ดึง entries ของเมื่อวาน แยกตามมื้อ
final yesterdayEntriesProvider = FutureProvider<Map<MealType, List<FoodEntry>>>((ref) async {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final entries = await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .findAll();

  final grouped = <MealType, List<FoodEntry>>{};
  for (final entry in entries) {
    grouped.putIfAbsent(entry.mealType, () => []).add(entry);
  }

  return grouped;
});

/// ข้อมูล repeat meal
class RepeatMealInfo {
  final MealType mealType;
  final List<FoodEntry> entries;
  final double totalCalories;

  RepeatMealInfo({
    required this.mealType,
    required this.entries,
    required this.totalCalories,
  });
}

/// ข้อมูล "Same as Yesterday" (ทั้งวัน)
class RepeatDayInfo {
  final List<FoodEntry> entries;
  final double totalCalories;

  RepeatDayInfo({
    required this.entries,
    required this.totalCalories,
  });
}

/// ดึง repeat day option (ถ้าเมื่อวานมีรายการ)
final repeatDayProvider = FutureProvider<RepeatDayInfo?>((ref) async {
  final grouped = await ref.watch(yesterdayEntriesProvider.future);
  
  if (grouped.isEmpty) return null;
  
  final allEntries = grouped.values.expand((list) => list).toList();
  final totalCal = allEntries.fold<double>(0, (sum, entry) => sum + entry.calories);
  
  return RepeatDayInfo(
    entries: allEntries,
    totalCalories: totalCal,
  );
});

/// ดึง repeat options (มื้อที่เมื่อวานมี entries)
final repeatOptionsProvider = FutureProvider<List<RepeatMealInfo>>((ref) async {
  final grouped = await ref.watch(yesterdayEntriesProvider.future);

  return grouped.entries.map((e) {
    final totalCal = e.value.fold<double>(0, (sum, entry) => sum + entry.calories);
    return RepeatMealInfo(
      mealType: e.key,
      entries: e.value,
      totalCalories: totalCal,
    );
  }).toList()
    ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));
});
