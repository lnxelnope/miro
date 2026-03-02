import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miro_hybrid/features/chat/logic/chat_processor.dart';
import 'package:miro_hybrid/core/ai/llm_service.dart';

part 'chat_processor_provider.g.dart';

@riverpod
ChatProcessor chatProcessor(Ref ref) {
  return ChatProcessor(LLMService());
}
