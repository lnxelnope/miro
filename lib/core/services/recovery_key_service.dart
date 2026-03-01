import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'device_id_service.dart';

/// Manages the Recovery Key for cross-device account restoration.
/// Recovery Key is auto-generated at first sync and stored securely.
/// Users can view it in Settings and use it on a new device to reclaim their data.
class RecoveryKeyService {
  static const _storage = FlutterSecureStorage();
  static const String _keyRecovery = 'recovery_key';
  static const String _keyRecoveryGeneratedAt = 'recovery_key_generated_at';
  static const String _baseUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net';

  /// Get the current recovery key. Returns null if not generated yet.
  static Future<String?> getRecoveryKey() async {
    return await _storage.read(key: _keyRecovery);
  }

  /// Generate or retrieve recovery key.
  /// Calls server to register the key (server stores hash only).
  static Future<String?> generateRecoveryKey() async {
    // Check if already exists locally
    final existing = await _storage.read(key: _keyRecovery);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final key = _generateKey();

      final response = await http.post(
        Uri.parse('$_baseUrl/registerRecoveryKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'recoveryKey': key,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storage.write(key: _keyRecovery, value: key);
        await _storage.write(
          key: _keyRecoveryGeneratedAt,
          value: DateTime.now().toIso8601String(),
        );
        debugPrint('[RecoveryKey] Generated and registered: MIRO-****');
        return key;
      } else {
        debugPrint('[RecoveryKey] Server rejected: ${response.statusCode}');
        // Still store locally as fallback
        await _storage.write(key: _keyRecovery, value: key);
        return key;
      }
    } catch (e) {
      debugPrint('[RecoveryKey] Generation failed: $e');
      // Generate locally even if server is unreachable
      final key = _generateKey();
      await _storage.write(key: _keyRecovery, value: key);
      return key;
    }
  }

  /// Regenerate recovery key (invalidates old one).
  static Future<String?> regenerateRecoveryKey() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final newKey = _generateKey();

      final response = await http.post(
        Uri.parse('$_baseUrl/registerRecoveryKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'recoveryKey': newKey,
          'regenerate': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storage.write(key: _keyRecovery, value: newKey);
        await _storage.write(
          key: _keyRecoveryGeneratedAt,
          value: DateTime.now().toIso8601String(),
        );
        debugPrint('[RecoveryKey] Regenerated successfully');
        return newKey;
      }

      return null;
    } catch (e) {
      debugPrint('[RecoveryKey] Regeneration failed: $e');
      return null;
    }
  }

  /// Redeem recovery key on a new device.
  /// Links new deviceId to the existing miroId.
  /// Returns server data (balance, entries, meals, etc.) or null on failure.
  static Future<Map<String, dynamic>?> redeemRecoveryKey(String key) async {
    try {
      final newDeviceId = await DeviceIdService.getDeviceId();

      final response = await http.post(
        Uri.parse('$_baseUrl/redeemRecoveryKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recoveryKey': key.trim().toUpperCase(),
          'newDeviceId': newDeviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Store the new recovery key provided by server
        final newKey = data['newRecoveryKey'] as String?;
        if (newKey != null) {
          await _storage.write(key: _keyRecovery, value: newKey);
        }

        // Store miroId
        final miroId = data['miroId'] as String?;
        if (miroId != null) {
          await _storage.write(key: 'miro_id', value: miroId);
        }

        debugPrint('[RecoveryKey] Redeemed successfully');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to redeem key');
      }
    } catch (e) {
      debugPrint('[RecoveryKey] Redemption failed: $e');
      rethrow;
    }
  }

  /// Check if recovery key has been generated.
  static Future<bool> hasRecoveryKey() async {
    final key = await _storage.read(key: _keyRecovery);
    return key != null && key.isNotEmpty;
  }

  /// Generate a human-readable key: MIRO-XXXX-XXXX
  static String _generateKey() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final part1 = List.generate(4, (_) => chars[random.nextInt(chars.length)])
        .join();
    final part2 = List.generate(4, (_) => chars[random.nextInt(chars.length)])
        .join();
    return 'MIRO-$part1-$part2';
  }
}
