/// Represents a step in the food analysis tutorial
class TutorialStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? highlightText;
  final TutorialStepType type;
  final Map<String, dynamic>? data;

  const TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.highlightText,
    required this.type,
    this.data,
  });
}

enum TutorialStepType {
  introduction,
  editFoodName,
  editQuantity,
  analyzingWithAI,
  viewingResults,
  editingIngredients,
  completion,
}
