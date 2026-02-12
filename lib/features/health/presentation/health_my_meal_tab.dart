import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/database/database_service.dart';
import '../providers/my_meal_provider.dart';
import '../providers/health_provider.dart';
import '../models/my_meal.dart';
import '../models/my_meal_ingredient.dart';
import '../models/ingredient.dart';
import '../models/food_entry.dart';
import '../widgets/my_meal_card.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/create_meal_sheet.dart';
import '../widgets/log_from_meal_sheet.dart';
import '../widgets/edit_ingredient_sheet.dart';

class HealthMyMealTab extends ConsumerStatefulWidget {
  const HealthMyMealTab({super.key});

  @override
  ConsumerState<HealthMyMealTab> createState() => _HealthMyMealTabState();
}

class _HealthMyMealTabState extends ConsumerState<HealthMyMealTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _subTabController;
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => false; // Don't keep alive to force refresh

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
    
    // Force refresh when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(allMyMealsProvider);
        ref.invalidate(allIngredientsProvider);
      }
    });
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Column(
      children: [
        // Sub-tabs: My Meals | Ingredients
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _subTabController,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicator: BoxDecoration(
              color: AppColors.health,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            tabs: const [
              Tab(text: '🍽️ My Meals'),
              Tab(text: '🥬 Ingredients'),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildMealsList(),
              _buildIngredientsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    final searchQuery = _searchController.text.trim();
    final mealsAsync = searchQuery.isEmpty
        ? ref.watch(allMyMealsProvider)
        : ref.watch(myMealSearchProvider(searchQuery));

    return mealsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (meals) {
        if (meals.isEmpty) {
          return _buildEmptyMeals();
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MyMealCard(
                  meal: meal,
                  onUse: () => _logFromMeal(meal),
                  onEdit: () => _editMeal(meal),
                  onDelete: () => _deleteMeal(meal),
                  onTap: () => _showMealDetail(meal),
                );
              },
            ),
            // FAB create new meal (left side to avoid Chat button)
            Positioned(
              left: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'createMeal',
                onPressed: _createNewMeal,
                backgroundColor: AppColors.health,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Create Meal'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientsList() {
    final searchQuery = _searchController.text.trim();
    final ingredientsAsync = searchQuery.isEmpty
        ? ref.watch(allIngredientsProvider)
        : ref.watch(ingredientSearchProvider(searchQuery));

    return ingredientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (ingredients) {
        if (ingredients.isEmpty) {
          return _buildEmptyIngredients();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return IngredientCard(
              ingredient: ingredient,
              onEdit: () => _editIngredient(ingredient),
              onDelete: () => _deleteIngredient(ingredient),
              onUse: () => _logFromIngredient(ingredient),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyMeals() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('No meals yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Analyze food with Gemini to auto-save meals\nor tap below to create one manually',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewMeal,
            icon: const Icon(Icons.add),
            label: const Text('Create Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.health,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIngredients() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🥬', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('No ingredients yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'When you analyze food with Gemini\ningredients will be saved automatically',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ===== ACTIONS =====

  /// Create new meal (Manual)
  void _createNewMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealSheet(
        onSave: (meal) {
          ref.invalidate(allMyMealsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Created "${meal.name}"'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  /// Log food from MyMeal
  void _logFromMeal(MyMeal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogFromMealSheet(
        meal: meal,
        onConfirm: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);
          
          // Increment usage count
          await ref.read(myMealNotifierProvider.notifier).incrementMealUsage(meal.id);

          refreshFoodProviders(ref, DateTime.now());
          ref.invalidate(allMyMealsProvider);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Logged "${meal.name}"'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  /// Log food from single Ingredient
  void _logFromIngredient(Ingredient ingredient) {
    _showLogIngredientDialog(ingredient);
  }

  void _showLogIngredientDialog(Ingredient ingredient) {
    final amountController = TextEditingController(text: ingredient.baseAmount.toString());
    MealType selectedMealType = _guessMealType();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final amount = double.tryParse(amountController.text) ?? 0;
          final calories = ingredient.calcCalories(amount);
          final protein = ingredient.calcProtein(amount);

          return AlertDialog(
            title: Text('🥬 ${ingredient.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (${ingredient.baseUnit})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),
                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.health.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('🔥 ${calories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('P:${protein.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Meal type
                Wrap(
                  spacing: 6,
                  children: MealType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.icon, style: const TextStyle(fontSize: 16)),
                      selected: selectedMealType == type,
                      onSelected: (s) {
                        if (s) setDialogState(() => selectedMealType = type);
                      },
                      selectedColor: AppColors.health.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountController.text) ?? 0;
                  if (amt <= 0) return;

                  final entry = FoodEntry()
                    ..foodName = ingredient.name
                    ..mealType = selectedMealType
                    ..timestamp = DateTime.now()
                    ..servingSize = amt
                    ..servingUnit = ingredient.baseUnit
                    ..calories = ingredient.calcCalories(amt)
                    ..protein = ingredient.calcProtein(amt)
                    ..carbs = ingredient.calcCarbs(amt)
                    ..fat = ingredient.calcFat(amt)
                    ..baseCalories = ingredient.caloriesPerBase / ingredient.baseAmount
                    ..baseProtein = ingredient.proteinPerBase / ingredient.baseAmount
                    ..baseCarbs = ingredient.carbsPerBase / ingredient.baseAmount
                    ..baseFat = ingredient.fatPerBase / ingredient.baseAmount
                    ..ingredientId = ingredient.id
                    ..source = DataSource.manual;

                  final notifier = ref.read(foodEntriesNotifierProvider.notifier);
                  await notifier.addFoodEntry(entry);
                  refreshFoodProviders(ref, DateTime.now());

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Logged "${ingredient.name}" ${amt.toStringAsFixed(0)}${ingredient.baseUnit}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editMeal(MyMeal meal) async {
    // Load meal ingredients
    final ingredientsAsync = ref.read(mealIngredientsProvider(meal.id));
    List<MyMealIngredient> mealIngredients = [];

    ingredientsAsync.whenData((data) => mealIngredients = data);

    // If provider not loaded, query directly from DB
    if (mealIngredients.isEmpty) {
      mealIngredients = await DatabaseService.myMealIngredients
          .filter()
          .myMealIdEqualTo(meal.id)
          .sortBySortOrder()
          .findAll();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealSheet(
        existingMeal: meal,
        existingIngredients: mealIngredients,
        onSave: (updatedMeal) {
          ref.invalidate(allMyMealsProvider);
          ref.invalidate(mealIngredientsProvider(meal.id));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Updated "${updatedMeal.name}"'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMeal(MyMeal meal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Delete "${meal.name}"?\n\n⚠️ Ingredients will not be deleted'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(myMealNotifierProvider.notifier).deleteMeal(meal.id);
      ref.invalidate(allMyMealsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Meal deleted'), backgroundColor: AppColors.success),
      );
    }
  }

  void _editIngredient(Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIngredientSheet(
        ingredient: ingredient,
        onSave: (updatedIngredient) {
          ref.invalidate(allIngredientsProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Updated "${updatedIngredient.name}"'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text('Delete "${ingredient.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(myMealNotifierProvider.notifier).deleteIngredient(ingredient.id);
      ref.invalidate(allIngredientsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Ingredient deleted'), backgroundColor: AppColors.success),
      );
    }
  }

  void _showMealDetail(MyMeal meal) {
    final ingredientsAsync = ref.read(mealIngredientsProvider(meal.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🍽️ ${meal.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              meal.baseServingDescription,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // Nutrition summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nutritionBadge('🔥', '${meal.totalCalories.toInt()}', 'kcal'),
                  _nutritionBadge('🥩', '${meal.totalProtein.toInt()}g', 'Protein'),
                  _nutritionBadge('🍞', '${meal.totalCarbs.toInt()}g', 'Carbs'),
                  _nutritionBadge('🫒', '${meal.totalFat.toInt()}g', 'Fat'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Ingredients list
            ingredientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e'),
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return const Text('No ingredients data', style: TextStyle(color: AppColors.textSecondary));
                }
                return Column(
                  children: ingredients.map((ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Text('  •  '),
                        Expanded(
                          child: Text('${ing.ingredientName} (${ing.amount.toStringAsFixed(0)} ${ing.unit})'),
                        ),
                        Text(
                          '${ing.calories.toInt()} kcal',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            // Use button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logFromMeal(meal);
                },
                icon: const Icon(Icons.restaurant),
                label: const Text('Use this meal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionBadge(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
