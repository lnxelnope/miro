import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service สำหรับจัดการ Device ID (persistent across reinstalls)
class DeviceIdService {
  static const _storage = FlutterSecureStorage();
  static const _keyDeviceId = 'persistent_device_id';
  
  /// ดึง Device ID ที่ persistent (ไม่เปลี่ยนเมื่อ reinstall)
  /// 
  /// Android: ANDROID_ID (survives reinstall)
  /// iOS: IDFV + Keychain backup (survives reinstall)
  /// Fallback: Hardware fingerprint (เกิดได้หายากมาก < 0.01%)
  static Future<String> getDeviceId() async {
    // ตรวจสอบ cache ใน Keychain/SecureStorage ก่อน
    final cachedId = await _storage.read(key: _keyDeviceId);
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }
    
    // ดึง Device ID จาก platform
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // ANDROID_ID: persistent across app reinstalls (reset เมื่อ factory reset)
        deviceId = androidInfo.id; // เดิมชื่อ androidId
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // IDFV: Identifier for Vendor
        deviceId = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      print('⚠️ Error getting primary device ID: $e');
    }
    
    // ────── Fallback: Hardware Fingerprint ──────
    if (deviceId.isEmpty || deviceId == 'unknown') {
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = '${androidInfo.brand}_${androidInfo.device}_${androidInfo.model}'
              .replaceAll(' ', '_')
              .toLowerCase();
          print('📱 Using Android hardware fingerprint: $deviceId');
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = '${iosInfo.name}_${iosInfo.model}'
              .replaceAll(' ', '_')
              .toLowerCase();
          print('📱 Using iOS hardware fingerprint: $deviceId');
        } else {
          // Web/Desktop: generate UUID และ save ไว้
          final prefs = await SharedPreferences.getInstance();
          deviceId = prefs.getString('fallback_device_id') ?? '';
          if (deviceId.isEmpty) {
            deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
            await prefs.setString('fallback_device_id', deviceId);
          }
        }
      } catch (e) {
        // Last resort: generate random ID
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        print('⚠️ Using random device ID: $deviceId');
      }
    }
    
    // บันทึกลง Keychain/SecureStorage (iOS: จะอยู่ต่อหลัง reinstall)
    await _storage.write(key: _keyDeviceId, value: deviceId);
    
    return deviceId;
  }
  
  /// สำหรับ debug: ดูว่า Device ID คืออะไร
  static Future<void> printDeviceId() async {
    final id = await getDeviceId();
    print('🔑 Device ID: $id');
  }
}
