import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
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
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));

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
    super.build(context);
    return Column(
      children: [
        const SizedBox(height: 8),

        // Modern toggle tab bar
        _buildToggleTabBar(),

        // Search bar
        _buildSearchBar(),

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

  Widget _buildToggleTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _subTabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          color: AppColors.health,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: AppColors.health.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.meal, size: 18, color: AppIcons.mealColor),
                SizedBox(width: 6),
                Text('Meals'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🥬', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text('Ingredients'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search meals or ingredients...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                size: 20, color: Colors.grey.shade400),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: Colors.grey.shade400),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ===== MEALS LIST =====

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
            // Create meal button — bottom-center
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildCreateMealButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateMealButton() {
    return GestureDetector(
      onTap: _createNewMeal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.health, AppColors.health.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.health.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Create New Meal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== INGREDIENTS LIST =====

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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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

  // ===== EMPTY STATES =====

  Widget _buildEmptyMeals() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(AppIcons.meal, size: 48, color: AppIcons.mealColor),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No meals yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze food with AI to auto-save meals\nor create one manually',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _createNewMeal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.health,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.health.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create Meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyIngredients() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🥬', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No ingredients yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'When you analyze food with AI\ningredients will be saved automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ===== ACTIONS =====

  void _createNewMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealSheet(
        onSave: (meal) {
          ref.invalidate(allMyMealsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created "${meal.name}"'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

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

          await ref
              .read(myMealNotifierProvider.notifier)
              .incrementMealUsage(meal.id);

          refreshFoodProviders(ref, DateTime.now());
          ref.invalidate(allMyMealsProvider);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged "${meal.name}"'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  void _logFromIngredient(Ingredient ingredient) {
    _showLogIngredientDialog(ingredient);
  }

  void _showLogIngredientDialog(Ingredient ingredient) {
    final amountController =
        TextEditingController(text: ingredient.baseAmount.toString());
    MealType selectedMealType = _guessMealType();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final amount = double.tryParse(amountController.text) ?? 0;
          final calories = ingredient.calcCalories(amount);
          final protein = ingredient.calcProtein(amount);

          return Container(
            margin:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Center(
                          child: Text('🥬', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Amount input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Amount (${ingredient.baseUnit})',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                ),
                const SizedBox(height: 14),

                // Preview nutrition
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniNutrition('${calories.toInt()}', 'kcal',
                          const Color(0xFFEF4444)),
                      _miniNutrition('${protein.toStringAsFixed(1)}g',
                          'Protein', const Color(0xFF3B82F6)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Meal type chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MealType.values.map((type) {
                      final selected = selectedMealType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedMealType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.health.withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: selected
                                  ? Border.all(
                                      color: AppColors.health, width: 1.5)
                                  : null,
                            ),
                            child: Icon(
                              type.icon,
                              color: type.iconColor,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final amt =
                              double.tryParse(amountController.text) ?? 0;
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
                            ..baseCalories = ingredient.caloriesPerBase /
                                ingredient.baseAmount
                            ..baseProtein = ingredient.proteinPerBase /
                                ingredient.baseAmount
                            ..baseCarbs =
                                ingredient.carbsPerBase / ingredient.baseAmount
                            ..baseFat =
                                ingredient.fatPerBase / ingredient.baseAmount
                            ..ingredientId = ingredient.id
                            ..source = DataSource.manual;

                          final notifier =
                              ref.read(foodEntriesNotifierProvider.notifier);
                          await notifier.addFoodEntry(entry);
                          refreshFoodProviders(ref, DateTime.now());

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Logged "${ingredient.name}" ${amt.toStringAsFixed(0)}${ingredient.baseUnit}'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.health,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.health.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniNutrition(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.6))),
      ],
    );
  }

  Future<void> _editMeal(MyMeal meal) async {
    // โหลด ALL ingredients ของ meal (ทั้ง root + sub) แล้วแยกเป็น tree
    final allIngredients = await DatabaseService.myMealIngredients
        .filter()
        .myMealIdEqualTo(meal.id)
        .sortBySortOrder()
        .findAll();

    // แยก root vs sub แล้ว set isComposite ให้ root ที่มี children
    final childParentIds = <int>{};
    for (final item in allIngredients) {
      if (item.parentId != null) {
        childParentIds.add(item.parentId!);
      }
    }

    final rootIngredients =
        allIngredients.where((e) => e.parentId == null).map((root) {
      // Mark root ว่ามี sub-ingredients หรือไม่
      if (childParentIds.contains(root.id) && !root.isComposite) {
        root.isComposite = true;
      }
      return root;
    }).toList();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealSheet(
        existingMeal: meal,
        existingIngredients: rootIngredients, // ส่งแค่ ROOT
        onSave: (updatedMeal) {
          ref.invalidate(allMyMealsProvider);
          ref.invalidate(mealIngredientsProvider(meal.id));
          ref.invalidate(mealIngredientTreeProvider(meal.id)); // NEW

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated "${updatedMeal.name}"'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMeal(MyMeal meal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Meal?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${meal.name}"',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('Ingredients will not be deleted.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
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
        SnackBar(
          content: const Text('Meal deleted'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
              content: Text('Updated "${updatedIngredient.name}"'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Delete Ingredient?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text('"${ingredient.name}"',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(myMealNotifierProvider.notifier)
          .deleteIngredient(ingredient.id);
      ref.invalidate(allIngredientsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingredient deleted'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showMealDetail(MyMeal meal) {
    final ingredientsAsync = ref.read(mealIngredientsProvider(meal.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.health.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                      child: Icon(AppIcons.meal, size: 28, color: AppIcons.mealColor)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meal.baseServingDescription,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Nutrition pills
            Row(
              children: [
                _detailNutritionPill('${meal.totalCalories.toInt()}', 'kcal',
                    const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _detailNutritionPill('${meal.totalProtein.toInt()}g', 'Protein',
                    const Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                _detailNutritionPill('${meal.totalCarbs.toInt()}g', 'Carbs',
                    const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _detailNutritionPill('${meal.totalFat.toInt()}g', 'Fat',
                    const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients header
            Text('Ingredients',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 10),

            // Ingredients list
            ingredientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e'),
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return Text('No ingredients data',
                      style: TextStyle(color: Colors.grey.shade500));
                }
                return Column(
                  children: ingredients
                      .map((ing) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.health,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${ing.ingredientName} (${ing.amount.toStringAsFixed(0)} ${ing.unit})',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${ing.calories.toInt()} kcal',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Use meal button
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _logFromMeal(meal);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.health,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.health.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Use This Meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailNutritionPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
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
