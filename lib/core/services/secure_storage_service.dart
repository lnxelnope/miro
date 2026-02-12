import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Gemini API Key
  static Future<void> saveGeminiApiKey(String apiKey) async {
    await _storage.write(
      key: AppConstants.apiKeyStorageKey,
      value: apiKey,
    );
  }

  static Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: AppConstants.apiKeyStorageKey);
  }

  static Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: AppConstants.apiKeyStorageKey);
  }

  static Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  // Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
