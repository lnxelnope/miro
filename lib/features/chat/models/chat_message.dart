import 'package:isar/isar.dart';

part 'chat_message.g.dart';

enum MessageRole { user, assistant }

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;

  late String sessionId;

  @enumerated
  late MessageRole role;

  late String content;

  // Rich content
  String? responseType; // text, confirmCard, listCard, workoutCard
  String? cardDataJson; // JSON string ของ card data
  String? actionsJson;  // JSON string ของ actions

  // Metadata
  String? detectedIntent;
  double? confidence;

  DateTime createdAt = DateTime.now();
}

@collection
class ChatSession {
  Id id = Isar.autoIncrement;

  late String title;
  String? sessionId; // UUID

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
