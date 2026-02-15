import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Reset on error to prevent corrupted data issues
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Gemini API Key
  static Future<void> saveGeminiApiKey(String apiKey) async {
    try {
      await _storage.write(
        key: AppConstants.apiKeyStorageKey,
        value: apiKey,
      );
      debugPrint('✅ API Key saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save API Key: $e');
      rethrow;
    }
  }

  static Future<String?> getGeminiApiKey() async {
    try {
      final key = await _storage.read(key: AppConstants.apiKeyStorageKey);
      debugPrint('🔑 API Key read: ${key != null ? "Found" : "Not found"}');
      return key;
    } catch (e) {
      debugPrint('❌ Failed to read API Key: $e');
      return null;
    }
  }

  static Future<void> deleteGeminiApiKey() async {
    try {
      await _storage.delete(key: AppConstants.apiKeyStorageKey);
      debugPrint('🗑️ API Key deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete API Key: $e');
      rethrow;
    }
  }

  static Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  // Clear all
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🧹 Secure storage cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear storage: $e');
      rethrow;
    }
  }
}
