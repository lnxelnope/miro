import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device_id_service.dart';

class ReferralService {
  static const String _baseUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net';

  /// Submit referral code
  static Future<Map<String, dynamic>> submitReferralCode(
    String referralCode,
  ) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final url = Uri.parse('$_baseUrl/submitReferralCode');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'referralCode': referralCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to submit referral code');
      }
    } catch (e) {
      throw Exception('Referral code submission failed: $e');
    }
  }

  /// Get referral stats
  static Future<Map<String, dynamic>> getReferralStats() async {
    // TODO: Implement API endpoint for referral stats
    // For now, return mock data
    return {
      'referralCount': 0,
      'pendingReferrals': 0,
      'completedReferrals': 0,
    };
  }
}
