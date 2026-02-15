import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/energy_transaction.dart';
import 'device_id_service.dart';
import 'energy_token_service.dart';

/// Service หลักสำหรับจัดการ Energy Balance
class EnergyService {
  static const String _keyBalance = 'energy_balance';
  static const String _keyWelcomeClaimed = 'welcome_claimed_'; // + deviceId
  static const String _keyFirstAiUsage = 'first_ai_usage_time'; // สำหรับ Welcome Offer
  
  // Production Launch: 100 Energy for all new users
  static const int welcomeGift = 100;
  
  static const _storage = FlutterSecureStorage();
  
  final Isar _isar;
  
  EnergyService(this._isar);
  
  // ───────────────────────────────────────────────────────────
  // 1. BALANCE MANAGEMENT
  // ───────────────────────────────────────────────────────────
  
  /// ดึงยอด Energy ปัจจุบัน (จาก SharedPreferences — เร็วกว่า Isar)
  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBalance) ?? 0;
  }
  
  /// ตรวจสอบว่ามี Energy พอใช้หรือไม่
  Future<bool> hasEnergy() async {
    final balance = await getBalance();
    return balance >= 1;
  }
  
  /// ใช้ Energy 1 หน่วย (เรียกหลังจาก AI analysis สำเร็จ)
  /// 
  /// Returns: true ถ้าใช้ได้, false ถ้า Energy ไม่พอ
  Future<bool> consumeEnergy({String? description}) async {
    final currentBalance = await getBalance();
    if (currentBalance < 1) {
      return false;
    }
    
    final newBalance = currentBalance - 1;
    await _updateBalance(newBalance);
    
    // บันทึก transaction
    await _saveTransaction(
      type: 'usage',
      amount: -1,
      balanceAfter: newBalance,
      description: description ?? 'AI food analysis',
    );
    
    // ตรวจสอบว่าใช้ครบ 3 ครั้งหรือยัง (สำหรับเปิด Welcome Offer)
    await _checkAiUsageCount();
    
    return true;
  }
  
  /// เพิ่ม Energy (หลังจากซื้อหรือได้รับของขวัญ)
  Future<void> addEnergy(
    int amount, {
    required String type,
    String? packageId,
    String? purchaseToken,
    String? description,
  }) async {
    final currentBalance = await getBalance();
    final newBalance = currentBalance + amount;
    await _updateBalance(newBalance);
    
    // บันทึก transaction
    await _saveTransaction(
      type: type,
      amount: amount,
      balanceAfter: newBalance,
      packageId: packageId,
      purchaseToken: purchaseToken,
      description: description,
    );
  }
  
  /// อัพเดทยอด Energy ใน SharedPreferences
  Future<void> _updateBalance(int newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalance, newBalance);
  }
  
  // ───────────────────────────────────────────────────────────
  // 2. WELCOME GIFT (100 FREE ENERGY) - PRODUCTION
  // ───────────────────────────────────────────────────────────
  
  /// ตรวจสอบและมอบ Welcome Gift (100 Energy ฟรี)
  /// ผูกกับ Device ID — ได้รับแค่ครั้งเดียวต่อเครื่อง
  /// 
  /// Returns: true ถ้าได้รับ gift, false ถ้าเคยได้แล้ว
  Future<bool> initializeWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    // ตรวจสอบ SharedPreferences
    if (prefs.getBool(key) == true) {
      return false; // เคยได้แล้ว
    }
    
    // ตรวจสอบ SecureStorage (iOS Keychain — อยู่ต่อหลัง reinstall)
    final secureFlag = await _storage.read(key: 'welcome_$deviceId');
    if (secureFlag == 'claimed') {
      // เคยได้แล้ว แต่ reinstall → sync กลับไป SharedPreferences
      await prefs.setBool(key, true);
      return false;
    }
    
    // มอบของขวัญ!
    await addEnergy(
      welcomeGift,
      type: 'welcome_gift',
      description: 'Welcome to MIRO! 🎉',
    );
    
    // บันทึก flag ทั้ง 2 ที่
    await prefs.setBool(key, true);
    await _storage.write(key: 'welcome_$deviceId', value: 'claimed');
    
    print('🎁 Welcome Gift granted: $welcomeGift Energy');
    return true;
  }
  
  /// ตรวจสอบว่าเคยได้ Welcome Gift หรือยัง
  Future<bool> hasClaimedWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) == true;
  }
  
  // ───────────────────────────────────────────────────────────
  // 3. WELCOME OFFER (24-HOUR DISCOUNT)
  // ───────────────────────────────────────────────────────────
  
  static const String _keyAiUsageCount = 'ai_usage_count';
  
  /// ตรวจสอบว่าใช้ AI ครบ 3 ครั้งหรือยัง
  /// ถ้าครบ 3 ครั้ง → เริ่มนับ 24 ชั่วโมง Welcome Offer
  /// 
  /// **Design Decision:** เริ่ม offer หลังใช้ 3 ครั้ง (ไม่ใช่ครั้งแรก)
  /// เพราะผู้ใช้จะเห็นคุณค่าของ AI มากขึ้น → conversion rate สูงกว่า
  Future<void> _checkAiUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ถ้าเริ่ม offer ไปแล้ว → ไม่ต้องทำอะไร
    if (prefs.getInt(_keyFirstAiUsage) != null) {
      return;
    }
    
    // นับจำนวนครั้งที่ใช้
    final currentCount = prefs.getInt(_keyAiUsageCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyAiUsageCount, newCount);
    
    // ถ้าใช้ครบ 3 ครั้ง → เริ่ม Welcome Offer!
    if (newCount >= 3) {
      await prefs.setInt(_keyFirstAiUsage, DateTime.now().millisecondsSinceEpoch);
      print('🎉 Used AI 3 times! Welcome Offer started (24h countdown).');
    } else {
      print('📊 AI usage count: $newCount/3');
    }
  }
  
  // ───────────────────────────────────────────────────────────
  // 4. TRANSACTION HISTORY
  // ───────────────────────────────────────────────────────────
  
  /// บันทึก transaction ลง Isar database
  Future<void> _saveTransaction({
    required String type,
    required int amount,
    required int balanceAfter,
    String? packageId,
    String? purchaseToken,
    String? description,
  }) async {
    final deviceId = await DeviceIdService.getDeviceId();
    
    final transaction = EnergyTransaction(
      type: type,
      amount: amount,
      balanceAfter: balanceAfter,
      packageId: packageId,
      purchaseToken: purchaseToken,
      description: description,
      deviceId: deviceId,
    );
    
    await _isar.writeTxn(() async {
      await _isar.energyTransactions.put(transaction);
    });
  }
  
  /// ดึงประวัติ transaction ทั้งหมด (ใหม่สุดก่อน)
  Future<List<EnergyTransaction>> getTransactionHistory({int limit = 50}) async {
    return await _isar.energyTransactions
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
  
  /// ดึงประวัติการใช้ (เฉพาะ type='usage')
  Future<List<EnergyTransaction>> getUsageHistory({int limit = 30}) async {
    return await _isar.energyTransactions
        .filter()
        .typeEqualTo('usage')
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
  
  // ───────────────────────────────────────────────────────────
  // 5. MIGRATION (สำหรับ existing users)
  // ───────────────────────────────────────────────────────────
  
  /// Migration: แปลง Pro user → 2,000 Energy
  /// Migration: แปลง Free user → 100 Energy (ถ้ายังไม่ได้รับ welcome gift)
  /// Migration: Beta testers → 1,000 Energy (พิเศษ!)
  Future<void> migrateFromProSystem({
    required bool wasProUser,
    bool isBetaTester = false,
  }) async {
    // ถ้าเคยได้ Welcome Gift แล้ว → ไม่ migrate
    if (await hasClaimedWelcomeGift()) {
      print('⚠️ User already migrated or claimed welcome gift');
      return;
    }
    
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    if (isBetaTester) {
      // Beta tester → ได้ 1,000 Energy (รางวัลพิเศษ!)
      await addEnergy(
        1000,
        type: 'beta_tester_reward',
        description: 'Thank you for being a beta tester! 🙏💙',
      );
      print('✅ Beta tester migrated: 1,000 Energy');
    } else if (wasProUser) {
      // Pro user → ได้ 2,000 Energy
      await addEnergy(
        2000,
        type: 'pro_migration',
        description: 'Thank you for being an early Pro user! 🙏',
      );
      print('✅ Pro user migrated: 2,000 Energy');
    } else {
      // Free user → ได้ 100 Energy (เหมือน welcome gift)
      await addEnergy(
        100,
        type: 'pro_migration',
        description: 'Welcome to the new Energy system! 🎉',
      );
      print('✅ Free user migrated: 100 Energy');
    }
    
    // ทำเครื่องหมายว่า migrated แล้ว (ไม่ให้ได้ welcome gift ซ้ำ)
    await prefs.setBool(key, true);
    await _storage.write(key: 'welcome_$deviceId', value: 'claimed');
  }
  
  // ───────────────────────────────────────────────────────────
  // 6. TOKEN GENERATION (สำหรับส่งให้ Backend)
  // ───────────────────────────────────────────────────────────
  
  /// สร้าง Energy Token สำหรับส่งให้ Backend
  Future<String> generateEnergyToken() async {
    final balance = await getBalance();
    return EnergyTokenService.generateToken(balance);
  }
  
  /// อัพเดท Energy จาก Backend response (หลังจากใช้ AI)
  /// Backend จะส่ง newEnergyToken กลับมา
  Future<void> updateFromBackendToken(String newToken) async {
    final decoded = EnergyTokenService.decodeToken(newToken);
    if (decoded != null && decoded['balance'] != null) {
      await _updateBalance(decoded['balance'] as int);
    }
  }
}
