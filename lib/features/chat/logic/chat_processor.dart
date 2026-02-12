import 'dart:convert';
import 'package:miro_hybrid/core/ai/llm_service.dart';
import 'package:miro_hybrid/core/utils/logger.dart';

/// Chat processor for v1.0 (Food-only)
/// Uses LLMService for text classification
class ChatProcessor {
  final LLMService _brain;

  ChatProcessor(this._brain);

  Future<Map<String, dynamic>> processMessage(String text) async {
    try {
      final jsonStr = await _brain.classifyAndParse(text);
      final data = jsonDecode(jsonStr);
      AppLogger.info('ChatProcessor result: ${data['type']}');
      return data;
    } catch (e) {
      AppLogger.error('ChatProcessor error', e);
      return {'type': 'unknown', 'title': text};
    }
  }
}
