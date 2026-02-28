import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import 'health_provider.dart';
import 'my_meal_provider.dart';
import '../../profile/providers/profile_provider.dart';

/// Minimal remaining kcal to show suggestions. Below this, hide ghost suggestions.
const double minSuggestionRemainingKcal = 20;

/// A single food suggestion to fulfill remaining calories
///
/// Daily remaining kcal is always the hard cap:
/// effectiveBudget = min(mealBudget, dailyRemaining)
/// If dailyRemaining <= 0, no suggestions are shown.
class FoodSuggestion {
  final String name;
  final String? nameEn;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final int? myMealId;
  final int? ingredientId;
  final bool isMeal; // true = MyMeal, false = Ingredient

  const FoodSuggestion({
    required this.name,
    this.nameEn,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    this.myMealId,
    this.ingredientId,
    required this.isMeal,
  });
}

/// Suggestions for a specific meal slot
class MealSlotSuggestion {
  final MealType mealType;
  final double allocatedCalories;
  final double allocatedProtein;
  final double allocatedCarbs;
  final double allocatedFat;
  final FoodSuggestion? topSuggestion;
  final List<FoodSuggestion> alternatives;
  final bool hasData;
  final bool dailyExceeded; // true = daily kcal already exceeded, no suggestions
  final bool cappedByDaily; // true = effective budget was reduced by daily remaining

  const MealSlotSuggestion({
    required this.mealType,
    required this.allocatedCalories,
    required this.allocatedProtein,
    required this.allocatedCarbs,
    required this.allocatedFat,
    this.topSuggestion,
    this.alternatives = const [],
    this.hasData = true,
    this.dailyExceeded = false,
    this.cappedByDaily = false,
  });
}

/// Overall calorie fulfillment state for the day
class FulfillCalorieState {
  final double remainingCalories;
  final double remainingProtein;
  final double remainingCarbs;
  final double remainingFat;
  final double goalCalories;
  final Map<MealType, MealSlotSuggestion> suggestions;
  final bool hasAnyFoodData;

  const FulfillCalorieState({
    required this.remainingCalories,
    required this.remainingProtein,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.goalCalories,
    required this.suggestions,
    required this.hasAnyFoodData,
  });

  double get completionPercent =>
      goalCalories > 0 ? ((goalCalories - remainingCalories) / goalCalories).clamp(0.0, 1.0) : 0.0;
}

/// Provider that calculates fulfillment suggestions for a given date
final fulfillCalorieProvider =
    FutureProvider.family<FulfillCalorieState, DateTime>((ref, date) async {
  final foodEntries = await ref.watch(foodEntriesByDateProvider(date).future);
  final profileAsync = ref.watch(profileNotifierProvider);
  final allMeals = await ref.watch(allMyMealsProvider.future);
  final allIngredients = await ref.watch(allIngredientsProvider.future);

  final profile = profileAsync.valueOrNull;
  final goalCalories = profile?.calorieGoal ?? 2000;
  final goalProtein = profile?.proteinGoal ?? 150;
  final goalCarbs = profile?.carbGoal ?? 250;
  final goalFat = profile?.fatGoal ?? 65;

  // User-defined per-meal budgets (from settings), with safe fallbacks
  double safeBudget(double? val, double fallback) =>
      (val == null || val.isNaN || val.isInfinite || val <= 0) ? fallback : val;

  final mealBudget = {
    MealType.breakfast: safeBudget(profile?.breakfastBudget, goalCalories * 0.28),
    MealType.lunch: safeBudget(profile?.lunchBudget, goalCalories * 0.35),
    MealType.dinner: safeBudget(profile?.dinnerBudget, goalCalories * 0.30),
    MealType.snack: safeBudget(profile?.snackBudget, goalCalories * 0.07),
  };

  // Suggestion threshold (± kcal from meal budget)
  final threshold = safeBudget(profile?.suggestionThreshold, 100);

  // Calculate consumed totals per meal type
  double consumed = 0, consumedP = 0, consumedC = 0, consumedF = 0;
  final mealsWithEntries = <MealType>{};
  final consumedPerMeal = <MealType, double>{};

  for (final entry in foodEntries) {
    consumed += entry.calories;
    consumedP += entry.protein;
    consumedC += entry.carbs;
    consumedF += entry.fat;
    mealsWithEntries.add(entry.mealType);
    consumedPerMeal[entry.mealType] =
        (consumedPerMeal[entry.mealType] ?? 0) + entry.calories;
  }

  final remaining = (goalCalories - consumed).clamp(0.0, double.infinity);
  final remainP = (goalProtein - consumedP).clamp(0.0, double.infinity);
  final remainC = (goalCarbs - consumedC).clamp(0.0, double.infinity);
  final remainF = (goalFat - consumedF).clamp(0.0, double.infinity);

  // Fetch yesterday's food entries as fallback suggestions
  final yesterday = date.subtract(const Duration(days: 1));
  final yesterdayEntries = await ref.watch(foodEntriesByDateProvider(yesterday).future);

  final hasData = allMeals.isNotEmpty || allIngredients.isNotEmpty || yesterdayEntries.isNotEmpty;

  // Build the combined pool: MyMeals first (priority), then Ingredients, then yesterday
  final pool = <FoodSuggestion>[];
  final addedNames = <String>{}; // deduplicate by name

  for (final meal in allMeals) {
    pool.add(FoodSuggestion(
      name: meal.name,
      nameEn: meal.nameEn,
      calories: meal.totalCalories,
      protein: meal.totalProtein,
      carbs: meal.totalCarbs,
      fat: meal.totalFat,
      servingSize: meal.parsedServingSize,
      servingUnit: meal.parsedServingUnit,
      myMealId: meal.id,
      isMeal: true,
    ));
    addedNames.add(meal.name.toLowerCase());
  }

  for (final ing in allIngredients) {
    pool.add(FoodSuggestion(
      name: ing.name,
      nameEn: ing.nameEn,
      calories: ing.caloriesPerBase,
      protein: ing.proteinPerBase,
      carbs: ing.carbsPerBase,
      fat: ing.fatPerBase,
      servingSize: ing.baseAmount,
      servingUnit: ing.baseUnit,
      ingredientId: ing.id,
      isMeal: false,
    ));
    addedNames.add(ing.name.toLowerCase());
  }

  // Add yesterday's entries as fallback (avoid duplicates)
  for (final entry in yesterdayEntries) {
    if (entry.calories <= 0) continue;
    if (addedNames.contains(entry.foodName.toLowerCase())) continue;
    pool.add(FoodSuggestion(
      name: entry.foodName,
      nameEn: entry.foodNameEn,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      servingSize: entry.servingSize,
      servingUnit: entry.servingUnit,
      myMealId: entry.myMealId,
      isMeal: entry.myMealId != null,
    ));
    addedNames.add(entry.foodName.toLowerCase());
  }

  // Determine empty meal slots
  final allMealTypes = [MealType.breakfast, MealType.lunch, MealType.dinner, MealType.snack];
  final emptySlots = allMealTypes.where((m) => !mealsWithEntries.contains(m)).toList();

  final suggestions = <MealType, MealSlotSuggestion>{};

  // Used items tracker to avoid suggesting the same food twice
  final usedIds = <String>{};

  for (final slot in emptySlots) {
    final mealBudgetCal = mealBudget[slot]!;

    // Don't suggest if remaining at or below minimal threshold (20 kcal)
    if (remaining <= minSuggestionRemainingKcal) {
      suggestions[slot] = MealSlotSuggestion(
        mealType: slot,
        allocatedCalories: 0,
        allocatedProtein: 0,
        allocatedCarbs: 0,
        allocatedFat: 0,
        hasData: hasData,
        dailyExceeded: true,
      );
      continue;
    }

    // Effective budget = min(per-meal budget, daily remaining)
    final allocCal = mealBudgetCal > remaining ? remaining : mealBudgetCal;
    final cappedByDaily = allocCal < mealBudgetCal;

    final ratio = goalCalories > 0 ? allocCal / goalCalories : 0.33;
    final allocP = goalProtein * ratio;
    final allocC = goalCarbs * ratio;
    final allocF = goalFat * ratio;

    if (!hasData || pool.isEmpty) {
      suggestions[slot] = MealSlotSuggestion(
        mealType: slot,
        allocatedCalories: allocCal,
        allocatedProtein: allocP,
        allocatedCarbs: allocC,
        allocatedFat: allocF,
        hasData: false,
        cappedByDaily: cappedByDaily,
      );
      continue;
    }

    // Find foods within threshold range, capped by effective budget
    final lower = (allocCal - threshold).clamp(0, double.infinity);
    final upper = allocCal + threshold;
    final candidates = pool
        .where((f) => f.calories >= lower && f.calories <= upper && f.calories > 0)
        .where((f) {
          final key = f.isMeal ? 'meal_${f.myMealId}' : 'ing_${f.ingredientId}';
          return !usedIds.contains(key);
        })
        .toList();

    // Sort by proximity to effective budget (closest first)
    candidates.sort((a, b) {
      final diffA = (a.calories - allocCal).abs();
      final diffB = (b.calories - allocCal).abs();
      return diffA.compareTo(diffB);
    });

    FoodSuggestion? top;
    final alts = <FoodSuggestion>[];

    if (candidates.isNotEmpty) {
      top = candidates.first;
      final topKey = top.isMeal ? 'meal_${top.myMealId}' : 'ing_${top.ingredientId}';
      usedIds.add(topKey);

      for (int i = 1; i < candidates.length && alts.length < 4; i++) {
        final alt = candidates[i];
        final altKey = alt.isMeal ? 'meal_${alt.myMealId}' : 'ing_${alt.ingredientId}';
        if (!usedIds.contains(altKey)) {
          alts.add(alt);
          usedIds.add(altKey);
        }
      }
    }

    suggestions[slot] = MealSlotSuggestion(
      mealType: slot,
      allocatedCalories: allocCal,
      allocatedProtein: allocP,
      allocatedCarbs: allocC,
      allocatedFat: allocF,
      topSuggestion: top,
      alternatives: alts,
      hasData: hasData,
      cappedByDaily: cappedByDaily,
    );
  }

  // Also add filled slots with their budget info (for header display)
  for (final slot in allMealTypes.where((m) => mealsWithEntries.contains(m))) {
    final budgetCal = mealBudget[slot]!;

    suggestions[slot] = MealSlotSuggestion(
      mealType: slot,
      allocatedCalories: budgetCal, // Budget from settings
      allocatedProtein: 0,
      allocatedCarbs: 0,
      allocatedFat: 0,
      hasData: true,
      topSuggestion: null, // No suggestion needed (already has food)
    );
  }

  return FulfillCalorieState(
    remainingCalories: remaining,
    remainingProtein: remainP,
    remainingCarbs: remainC,
    remainingFat: remainF,
    goalCalories: goalCalories,
    suggestions: suggestions,
    hasAnyFoodData: hasData,
  );
});
