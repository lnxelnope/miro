import 'dart:convert';

import 'package:http/http.dart' as http;

import 'device_id_service.dart';

/// Thrown when redeem API returns a non-success response.
class PromoRedeemException implements Exception {
  final String errorKey;

  PromoRedeemException(this.errorKey);

  @override
  String toString() => 'PromoRedeemException($errorKey)';
}

class PromoCodeService {
  static const _baseUrl = 'https://us-central1-miro-d6856.cloudfunctions.net';

  static Future<Map<String, dynamic>> redeemCode(String code) async {
    final deviceId = await DeviceIdService.getDeviceId();
    final response = await http.post(
      Uri.parse('$_baseUrl/redeemPromoCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId, 'code': code.trim()}),
    );

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'error': 'unknown'};
    } catch (_) {
      throw PromoRedeemException('unknown');
    }

    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }

    final err = body['error']?.toString() ?? 'unknown';
    throw PromoRedeemException(err);
  }
}
