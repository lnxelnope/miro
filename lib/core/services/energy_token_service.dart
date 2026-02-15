import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_id_service.dart';

/// Service สำหรับสร้างและตรวจสอบ Energy Token
/// Token นี้ส่งไปให้ Backend เพื่อ verify ว่าเรามี Energy พอหรือไม่
class EnergyTokenService {
  // ⚠️ ต้องใช้ค่าเดียวกับ Backend!
  // จาก BACKEND_SETUP_COMPLETE.md: ENERGY_ENCRYPTION_SECRET
  static const String _encryptionSecret = 
      'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2';
  
  /// สร้าง Energy Token ใหม่
  /// Format: { userId, balance, timestamp, signature }
  static Future<String> generateToken(int balance) async {
    final userId = await DeviceIdService.getDeviceId();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = '$userId:$balance:$timestamp';
    final signature = _generateSignature(payload);
    
    final token = {
      'userId': userId,
      'balance': balance,
      'timestamp': timestamp,
      'signature': signature,
    };
    
    return base64Encode(utf8.encode(json.encode(token)));
  }
  
  /// สร้าง HMAC-SHA256 signature
  static String _generateSignature(String payload) {
    final key = utf8.encode(_encryptionSecret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
  
  /// Decode token เพื่อดูข้อมูลภายใน (ใช้สำหรับ debug)
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      return json.decode(decoded);
    } catch (e) {
      return null;
    }
  }
}
