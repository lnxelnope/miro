/// ผลลัพธ์จากการดำเนินการตาม Intent
class ActionResult {
  final bool success;
  final String message;
  final String? entryType; // 'food', 'expense', 'task', etc.
  final int? entryId;
  final Map<String, dynamic>? data;

  ActionResult({
    required this.success,
    required this.message,
    this.entryType,
    this.entryId,
    this.data,
  });

  factory ActionResult.success({
    required String message,
    String? entryType,
    int? entryId,
    Map<String, dynamic>? data,
  }) {
    return ActionResult(
      success: true,
      message: message,
      entryType: entryType,
      entryId: entryId,
      data: data,
    );
  }

  factory ActionResult.failure(String message) {
    return ActionResult(
      success: false,
      message: message,
    );
  }
}
