import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'device_id_service.dart';

/// Service สำหรับจัดการ Welcome Offer (40% OFF — 24 ชั่วโมง)
/// 
/// **Trigger:** หลังจากใช้ AI ครบ 10 ครั้ง
/// **Limit:** ซื้อได้เพียง 1 package ต่อ 1 device (ไม่ว่าจะเป็น package ไหน)
class WelcomeOfferService {
  static const String _keyAiUsageCount = 'ai_usage_count'; // นับจำนวนครั้งที่ใช้ AI
  static const String _keyFirstAiUsage = 'first_ai_usage_time';
  static const String _keyOfferClaimed = 'welcome_offer_claimed_'; // + deviceId
  static const String _keyPurchasedPackage = 'welcome_package_purchased'; // เก็บว่าซื้อ package ไหนไปแล้ว
  static const int triggerCount = 10; // ต้องใช้ AI ครบ 10 ครั้ง
  static const Duration offerDuration = Duration(hours: 24);
  static const _storage = FlutterSecureStorage();
  
  // ───────────────────────────────────────────────────────────
  // 1. OFFER STATUS
  // ───────────────────────────────────────────────────────────
  
  /// ตรวจสอบสถานะของ Welcome Offer
  static Future<WelcomeOfferStatus> getStatus() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyOfferClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    // ตรวจสอบว่าซื้อแล้วหรือยัง
    if (prefs.getBool(key) == true) {
      return WelcomeOfferStatus.claimed;
    }
    
    // ตรวจสอบ SecureStorage (iOS Keychain)
    final secureFlag = await _storage.read(key: 'offer_$deviceId');
    if (secureFlag == 'claimed') {
      await prefs.setBool(key, true); // sync
      return WelcomeOfferStatus.claimed;
    }
    
    // ตรวจสอบว่าเคยใช้ AI หรือยัง
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) {
      return WelcomeOfferStatus.notStarted; // ยังไม่ได้ใช้ AI เลย
    }
    
    // ตรวจสอบว่าหมดเวลาหรือยัง
    final firstUsage = DateTime.fromMillisecondsSinceEpoch(firstUsageMs);
    final expiresAt = firstUsage.add(offerDuration);
    final now = DateTime.now();
    
    if (now.isBefore(expiresAt)) {
      return WelcomeOfferStatus.active; // ยังใช้ได้อยู่
    }
    
    return WelcomeOfferStatus.expired; // หมดเวลาแล้ว
  }
  
  /// ดึงเวลาที่เหลือของ Offer
  /// Returns: null ถ้ายังไม่เริ่มหรือหมดเวลาแล้ว
  static Future<Duration?> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) return null;
    
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(firstUsageMs)
        .add(offerDuration);
    final remaining = expiresAt.difference(DateTime.now());
    
    return remaining.isNegative ? null : remaining;
  }
  
  /// นับจำนวนครั้งที่ใช้ AI และเริ่มจับเวลา 24 ชั่วโมงเมื่อครบ 10 ครั้ง
  /// 
  /// Returns: true ถ้าเพิ่งเริ่ม timer (ครบ 10 ครั้งพอดี)
  static Future<bool> incrementUsageAndCheckTimer() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ถ้า timer เริ่มแล้ว ไม่ต้องนับต่อ
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs != null) {
      return false; // timer เริ่มไปแล้ว
    }
    
    // นับจำนวนครั้งที่ใช้ AI
    final currentCount = prefs.getInt(_keyAiUsageCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyAiUsageCount, newCount);
    
    print('🔢 AI usage count: $newCount/$triggerCount');
    
    // ถ้าครบ 10 ครั้ง → เริ่ม timer
    if (newCount >= triggerCount) {
      await prefs.setInt(_keyFirstAiUsage, DateTime.now().millisecondsSinceEpoch);
      print('🎉 Welcome Offer unlocked! Timer started: 24 hours');
      return true; // เพิ่งเริ่ม timer
    }
    
    return false;
  }
  
  /// ดึงจำนวนครั้งที่ใช้ AI ปัจจุบัน
  static Future<int> getUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAiUsageCount) ?? 0;
  }
  
  /// ดึงจำนวนครั้งที่เหลือก่อนจะปลดล็อค Welcome Offer
  static Future<int> getRemainingUsages() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    
    // ถ้า timer เริ่มแล้ว → ไม่มีครั้งที่เหลือ (ปลดล็อคแล้ว)
    if (firstUsageMs != null) return 0;
    
    final currentCount = prefs.getInt(_keyAiUsageCount) ?? 0;
    return (triggerCount - currentCount).clamp(0, triggerCount);
  }
  
  /// [DEPRECATED] ใช้ incrementUsageAndCheckTimer() แทน
  @Deprecated('Use incrementUsageAndCheckTimer() instead')
  static Future<bool> startTimer() async {
    return incrementUsageAndCheckTimer();
  }
  
  /// ทำเครื่องหมายว่าซื้อ Welcome Offer แล้ว
  /// 
  /// **Important:** ซื้อได้แค่ 1 package — หลังจากซื้อแล้ว
  /// ทุก welcome package จะหายไป แม้ยังไม่หมด 24 ชั่วโมง
  static Future<void> markClaimed(String packageId) async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyOfferClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(key, true);
    await prefs.setString(_keyPurchasedPackage, packageId);
    await _storage.write(key: 'offer_$deviceId', value: 'claimed');
    await _storage.write(key: 'package_$deviceId', value: packageId);
    print('✅ Welcome Offer claimed: $packageId');
  }
  
  /// ตรวจสอบว่าซื้อ package ไหนไปแล้ว (สำหรับ analytics)
  static Future<String?> getPurchasedPackage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPurchasedPackage);
  }
  
  /// ตรวจสอบว่าซื้อแล้วหรือยัง
  static Future<bool> hasClaimed() async {
    final status = await getStatus();
    return status == WelcomeOfferStatus.claimed;
  }
  
  /// ดึงเวลาที่หมดอายุ (สำหรับแสดง countdown)
  static Future<DateTime?> getExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(firstUsageMs).add(offerDuration);
  }
  
  /// Format เวลาที่เหลือเป็นข้อความ (เช่น "23h 41m")
  static String formatRemainingTime(Duration remaining) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// สถานะของ Welcome Offer
enum WelcomeOfferStatus {
  notStarted,  // ยังไม่ได้ใช้ AI เลย
  active,      // กำลังนับเวลา 24 ชั่วโมง — แสดง offer
  expired,     // หมดเวลาแล้ว
  claimed,     // ซื้อไปแล้ว
}
