import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide JsonKey, Column;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/my_meal_cover_image.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/my_meal_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/my_meal_card.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/create_meal_sheet.dart';
import '../widgets/log_from_meal_sheet.dart';
import '../widgets/edit_ingredient_sheet.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/utils/unit_converter.dart';

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
        const SizedBox(height: AppSpacing.sm),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.lg,
      ),
      child: TabBar(
        controller: _subTabController,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          color: AppColors.health,
          borderRadius: AppRadius.md,
          boxShadow: [
            BoxShadow(
              color: AppColors.health.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.meal, size: 18, color: AppIcons.mealColor),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(L10n.of(context)!.tabMeals),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🥬', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(L10n.of(context)!.tabIngredients),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md + 2, AppSpacing.xl, AppSpacing.xs + 2),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          borderRadius: AppRadius.lg,
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: 15, color: isDark ? AppColors.textPrimaryDark : null),
          decoration: InputDecoration(
            hintText: L10n.of(context)!.searchMealsOrIngredients,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.textTertiary, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                size: 20, color: isDark ? Colors.white38 : AppColors.textTertiary),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: isDark ? Colors.white38 : AppColors.textTertiary),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
      error: (e, st) => Center(child: Text('${L10n.of(context)!.error}: $e')),
      data: (meals) {
        if (meals.isEmpty) {
          return _buildEmptyMeals();
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxxl * 2.5),
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.health, AppColors.health.withValues(alpha: 0.85)],
          ),
          borderRadius: AppRadius.lg,
          boxShadow: [
            BoxShadow(
              color: AppColors.health.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              L10n.of(context)!.createNewMeal,
              style: const TextStyle(
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
      error: (e, st) => Center(child: Text('${L10n.of(context)!.error}: $e')),
      data: (ingredients) {
        if (ingredients.isEmpty) {
          return _buildEmptyIngredients();
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxxl * 2.5),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return IngredientCard(
                  ingredient: ingredient,
                  imperial: ref.watch(isImperialProvider),
                  onEdit: () => _editIngredient(ingredient),
                  onDelete: () => _deleteIngredient(ingredient),
                  onUse: () => _logFromIngredient(ingredient),
                );
              },
            ),
            // Add ingredient button — bottom-center
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildAddIngredientButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddIngredientButton() {
    return GestureDetector(
      onTap: _addIngredient,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success, AppColors.success.withValues(alpha: 0.85)],
          ),
          borderRadius: AppRadius.lg,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              L10n.of(context)!.addIngredient,
              style: const TextStyle(
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

  // ===== EMPTY STATES =====

  Widget _buildEmptyMeals() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.health.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(AppIcons.meal, size: 48, color: AppIcons.mealColor),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              L10n.of(context)!.noMealsYet,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : null,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              L10n.of(context)!.noMealsYetDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl + 4),
            GestureDetector(
              onTap: _createNewMeal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 4, vertical: AppSpacing.md + 2),
                decoration: BoxDecoration(
                  color: AppColors.health,
                  borderRadius: AppRadius.lg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.health.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      L10n.of(context)!.createMeal,
                      style: const TextStyle(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🥬', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              L10n.of(context)!.noIngredientsYet,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : null,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              L10n.of(context)!.noIngredientsYetDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 14, height: 1.5),
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
              content: Text(L10n.of(context)!.mealCreated(meal.name)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              duration: const Duration(seconds: 2),
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
        onConfirm: (FoodEntry entry) async {
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
              content: Text(L10n.of(context)!.mealLogged(meal.name)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              duration: const Duration(seconds: 2),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadius.md,
                      ),
                      child: const Center(
                          child: Text('🥬', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : null,
                            letterSpacing: -0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Amount input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                    borderRadius: AppRadius.lg,
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : null),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.ingredientAmount(
                        ref.read(isImperialProvider)
                            ? (UnitConverter.imperialDisplay(1, ingredient.baseUnit, imperial: true).unit)
                            : ingredient.baseUnit,
                      ),
                      labelStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                ),
                const SizedBox(height: AppSpacing.md + 2),

                // Preview nutrition
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.protein.withValues(alpha: 0.06),
                    borderRadius: AppRadius.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniNutrition('${calories.toInt()}', 'kcal',
                          AppColors.protein),
                      _miniNutrition('${protein.toStringAsFixed(1)}g',
                          'Protein', AppColors.tasks),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md + 2),

                // Meal type chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MealType.values.map((type) {
                      final selected = selectedMealType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedMealType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.health.withValues(alpha: 0.15)
                                  : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                              borderRadius: AppRadius.xl,
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
                const SizedBox(height: AppSpacing.xl),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                            borderRadius: AppRadius.lg,
                          ),
                          child: Center(
                            child: Text(
                              L10n.of(context)!.cancel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final amt =
                              double.tryParse(amountController.text) ?? 0;
                          if (amt <= 0) return;

                          final now = DateTime.now();
                          final entry = FoodEntry(
                            id: 0,
                            foodName: ingredient.name,
                            mealType: selectedMealType,
                            timestamp: now,
                            servingSize: amt,
                            servingUnit: ingredient.baseUnit,
                            calories: ingredient.calcCalories(amt),
                            protein: ingredient.calcProtein(amt),
                            carbs: ingredient.calcCarbs(amt),
                            fat: ingredient.calcFat(amt),
                            baseCalories: ingredient.caloriesPerBase / ingredient.baseAmount,
                            baseProtein: ingredient.proteinPerBase / ingredient.baseAmount,
                            baseCarbs: ingredient.carbsPerBase / ingredient.baseAmount,
                            baseFat: ingredient.fatPerBase / ingredient.baseAmount,
                            ingredientId: ingredient.id,
                            source: DataSource.manual,
                            searchMode: FoodSearchMode.normal,
                            isVerified: false,
                            isDeleted: false,
                            isGroupOriginal: false,
                            editCount: 0,
                            isUserCorrected: false,
                            isCalibrated: false,
                            isSynced: false,
                            createdAt: now,
                            updatedAt: now,
                          );

                          final notifier =
                              ref.read(foodEntriesNotifierProvider.notifier);
                          await notifier.addFoodEntry(entry);
                          refreshFoodProviders(ref, DateTime.now());

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                  L10n.of(context)!.ingredientLogged(ingredient.name, amt.toStringAsFixed(0), ingredient.baseUnit)),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.md),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                          decoration: BoxDecoration(
                            color: AppColors.health,
                            borderRadius: AppRadius.lg,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.health.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              L10n.of(context)!.save,
                              style: const TextStyle(
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
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.6))),
      ],
    );
  }

  Future<void> _editMeal(MyMeal meal) async {
    // โหลด meal ล่าสุดจาก database
    final freshMeal = await (DatabaseService.db.select(DatabaseService.db.myMeals)..where((tbl) => tbl.id.equals(meal.id))).getSingleOrNull();
    if (freshMeal == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.mealNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // โหลด ALL ingredients ของ meal (ทั้ง root + sub) แล้วแยกเป็น tree
    final allIngredients = await (DatabaseService.db.select(DatabaseService.db.myMealIngredients)
        ..where((tbl) => tbl.myMealId.equals(freshMeal.id))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();

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
        existingMeal: freshMeal,
        existingIngredients: rootIngredients, // ส่งแค่ ROOT
        onSave: (updatedMeal) {
          ref.invalidate(allMyMealsProvider);
          ref.invalidate(mealIngredientsProvider(freshMeal.id));
          ref.invalidate(mealIngredientTreeProvider(freshMeal.id)); // NEW

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.mealUpdated(updatedMeal.name)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMeal(MyMeal meal) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        title: Row(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(L10n.of(context)!.deleteMealTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : null)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L10n.of(context)!.deleteMealMessage(meal.name),
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(L10n.of(context)!.deleteMealNote,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500)),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl / 2),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
            ),
            child:
                Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl / 2),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
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
          content: Text(L10n.of(context)!.mealDeleted),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: AppRadius.md),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addIngredient() {
    // Create a blank ingredient for create mode
    final blankIngredient = Ingredient(
      id: 0,
      name: '',
      baseAmount: 100,
      baseUnit: 'g',
      caloriesPerBase: 0,
      proteinPerBase: 0,
      carbsPerBase: 0,
      fatPerBase: 0,
      source: 'manual',
      usageCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIngredientSheet(
        ingredient: blankIngredient,
        isCreateMode: true,
        onSave: (newIngredient) async {
          // Ingredient already saved by EditIngredientSheet
          // Just invalidate and show success message
          ref.invalidate(allIngredientsProvider);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.ingredientCreated(newIngredient.name)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: AppRadius.md),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editIngredient(Ingredient ingredient) async {
    // โหลด ingredient ล่าสุดจาก database ก่อนเปิด sheet
    final freshIngredient = await (DatabaseService.db.select(DatabaseService.db.ingredients)..where((tbl) => tbl.id.equals(ingredient.id))).getSingleOrNull();
    if (freshIngredient == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.ingredientNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIngredientSheet(
        ingredient: freshIngredient,
        onSave: (updatedIngredient) async {
          // Wait for invalidate
          ref.invalidate(allIngredientsProvider);
          
          // Small delay to ensure provider refreshes
          await Future.delayed(const Duration(milliseconds: 100));

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.ingredientUpdated(updatedIngredient.name)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        title: Row(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(L10n.of(context)!.deleteIngredientTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : null)),
            ),
          ],
        ),
        content: Text(L10n.of(context)!.deleteIngredientMessage(ingredient.name),
            style: TextStyle(
                fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade700)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl / 2),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
            ),
            child:
                Text(L10n.of(context)!.cancel, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl / 2),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              elevation: 0,
            ),
            child: Text(L10n.of(context)!.delete),
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
          content: Text(L10n.of(context)!.ingredientDeleted),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: AppRadius.md),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatMealDetailAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  /// แถววัตถุดิบหลัก (root) ใน sheet รายละเอียดเมนู
  Widget _buildMealDetailMainIngredientTile(
    MyMealIngredient ing,
    bool isDark,
    BuildContext context,
  ) {
    final l10n = L10n.of(context)!;
    final imp = ref.watch(isImperialProvider);
    final _d = UnitConverter.imperialDisplay(ing.amount, ing.unit, imperial: imp);
    final amt = _formatMealDetailAmount(_d.amount);
    final displayUnit = _d.unit;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.surfaceVariant,
        borderRadius: AppRadius.md,
        border: Border(
          left: BorderSide(color: AppColors.health, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ing.ingredientName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$amt $displayUnit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.ingredientCalories(ing.calories.toInt()),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.health,
            ),
          ),
        ],
      ),
    );
  }

  /// แถว sub-ingredient (เยื้อง + ไอคอนลำดับชั้น)
  Widget _buildMealDetailSubIngredientTile(
    MyMealIngredient ing,
    bool isDark,
    BuildContext context,
  ) {
    final l10n = L10n.of(context)!;
    final imp = ref.watch(isImperialProvider);
    final _dSub = UnitConverter.imperialDisplay(ing.amount, ing.unit, imperial: imp);
    final amt = _formatMealDetailAmount(_dSub.amount);
    final nameColor =
        isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.92) : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : AppColors.surfaceVariant.withValues(alpha: 0.65),
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.divider.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.subdirectory_arrow_right_rounded,
              size: 18,
              color: isDark ? Colors.white38 : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ing.ingredientName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: nameColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$amt ${_dSub.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.ingredientCalories(ing.calories.toInt()),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMealDetailIngredientTree(
    List<IngredientTreeNode> tree,
    bool isDark,
    BuildContext context,
  ) {
    final children = <Widget>[];
    for (var ti = 0; ti < tree.length; ti++) {
      final node = tree[ti];
      children.add(
        _buildMealDetailMainIngredientTile(node.ingredient, isDark, context),
      );
      for (final sub in node.children) {
        children.add(
          _buildMealDetailSubIngredientTile(sub, isDark, context),
        );
      }
      if (ti < tree.length - 1) {
        children.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return children;
  }

  void _showMealDetail(MyMeal meal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, consumerRef, _) {
          final treeAsync = consumerRef.watch(mealIngredientTreeProvider(meal.id));
          final keyboardBottom = MediaQuery.viewInsetsOf(ctx).bottom;
          final sheetH = (MediaQuery.sizeOf(ctx).height * 0.88).clamp(280.0, 820.0);

          Widget scrollableBody() {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dividerDark : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  MyMealCoverImage(
                    meal: meal,
                    height: 168,
                    width: double.infinity,
                    borderRadius: AppRadius.lg,
                    allowNetworkThumbnail: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : null,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    meal.baseServingDescription,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl - 2),
                  Row(
                    children: [
                      _detailNutritionPill(
                        '${meal.totalCalories.toInt()}',
                        'kcal',
                        AppColors.protein,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _detailNutritionPill(
                        '${meal.totalProtein.toInt()}g',
                        'Protein',
                        AppColors.tasks,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _detailNutritionPill(
                        '${meal.totalCarbs.toInt()}g',
                        'Carbs',
                        AppColors.carbs,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _detailNutritionPill(
                        '${meal.totalFat.toInt()}g',
                        'Fat',
                        AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    L10n.of(ctx)!.tabIngredients,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  treeAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) => Text(
                      '${L10n.of(ctx)!.error}: $e',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    data: (tree) {
                      if (tree.isEmpty) {
                        return Text(
                          L10n.of(ctx)!.noIngredientsData,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildMealDetailIngredientTree(tree, isDark, ctx),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(bottom: keyboardBottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: sheetH,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: scrollableBody()),
                      const SizedBox(height: AppSpacing.sm),
                      SafeArea(
                        top: false,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _logFromMeal(meal);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.health,
                              borderRadius: AppRadius.lg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.health.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.restaurant_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  L10n.of(ctx)!.useThisMeal,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _detailNutritionPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl / 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: AppRadius.md,
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
            const SizedBox(height: AppSpacing.xxs),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
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
