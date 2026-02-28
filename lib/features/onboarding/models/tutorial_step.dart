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
  analyzeDemo, // Step 1: วิเคราะห์อาหาร + Search Mode toggle
  editAndResearch, // Step 2: แก้ไข + ค้นหาซ้ำ (interactive)
  completion, // Step 3: สรุป
}
