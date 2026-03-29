// Immutable models for ingredientsJson v2 and parse results.
// No imports from features/ — see Phase 13 CONTEXT.

/// How [parseIngredientsJson] classified the raw string.
enum IngredientsJsonKind {
  empty,
  legacyList,
  version2,
  invalidJson,
}

/// One ingredient row (main or sub) with optional nested subs (v2: max one level in storage).
class IngredientNode {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final List<IngredientNode> subIngredients;

  const IngredientNode({
    required this.name,
    this.nameEn,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.subIngredients = const [],
  });

  IngredientNode copyWith({
    String? name,
    String? nameEn,
    double? amount,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    List<IngredientNode>? subIngredients,
  }) {
    return IngredientNode(
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      subIngredients: subIngredients ?? this.subIngredients,
    );
  }
}

/// Root document for v2 wire format (schemaVersion + mainIngredients).
class IngredientsDocumentV2 {
  static const int currentSchemaVersion = 2;

  final int schemaVersion;
  final List<IngredientNode> mainIngredients;

  const IngredientsDocumentV2({
    this.schemaVersion = currentSchemaVersion,
    required this.mainIngredients,
  });
}

/// Result of [parseIngredientsJson].
class IngredientsParseResult {
  final IngredientsJsonKind kind;
  final IngredientsDocumentV2? documentV2;
  final String? decodeError;

  const IngredientsParseResult._({
    required this.kind,
    this.documentV2,
    this.decodeError,
  });

  factory IngredientsParseResult.empty() =>
      const IngredientsParseResult._(kind: IngredientsJsonKind.empty);

  factory IngredientsParseResult.invalid(String? error) =>
      IngredientsParseResult._(
        kind: IngredientsJsonKind.invalidJson,
        decodeError: error,
      );

  factory IngredientsParseResult.legacy(IngredientsDocumentV2 doc) =>
      IngredientsParseResult._(
        kind: IngredientsJsonKind.legacyList,
        documentV2: doc,
      );

  factory IngredientsParseResult.version2(IngredientsDocumentV2 doc) =>
      IngredientsParseResult._(
        kind: IngredientsJsonKind.version2,
        documentV2: doc,
      );
}

/// Macro + optional micro totals for patching a [FoodEntry] (Phase 16 wiring).
class EntryNutritionRollup {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;

  const EntryNutritionRollup({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
  });
}
