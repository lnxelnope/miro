import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  
  /// อ่าน balance จาก local cache
  /// ⚠️ PHASE 1: นี่เป็นแค่ cache — Server = Source of Truth
  Future<int> getBalance() async {
    // ลองอ่านจาก SecureStorage ก่อน (encrypted)
    try {
      final cached = await _storage.read(key: _keyBalance);
      if (cached != null) {
        return int.tryParse(cached) ?? 0;
      }
    } catch (e) {
      debugPrint('[EnergyService] Error reading from SecureStorage: $e');
    }
    
    // Fallback: อ่านจาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getInt(_keyBalance) ?? 0;
    
    // Migrate ไป SecureStorage
    if (balance > 0) {
      await _storage.write(key: _keyBalance, value: balance.toString());
    }
    
    return balance;
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
  /// ⚠️ PHASE 1: เปลี่ยนให้เรียก updateFromServerResponse แทน
  Future<void> _updateBalance(int newBalance) async {
    await updateFromServerResponse(newBalance);
  }
  
  /// อัพเดท balance จาก Server response
  /// ✅ PHASE 1: Server = Source of Truth, Client sync ตามนี้
  /// 
  /// เรียก method นี้เมื่อ:
  /// - ได้ response จาก analyzeFood (หลังใช้ energy)
  /// - ได้ response จาก syncBalance (ตอน app startup)
  /// - ได้ response จาก verifyPurchase (หลังซื้อ energy)
  Future<void> updateFromServerResponse(int newBalance) async {
    try {
      // เก็บใน SecureStorage (encrypted, primary storage)
      await _storage.write(
        key: _keyBalance,
        value: newBalance.toString(),
      );
      
      // เก็บใน SharedPreferences ด้วย (fast read cache)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyBalance, newBalance);
      
      debugPrint('[EnergyService] ✅ Balance updated from server: $newBalance');
      
    } catch (e) {
      debugPrint('[EnergyService] ❌ Error updating balance: $e');
      throw Exception('Failed to update balance');
    }
  }
  
  /// Sync balance กับ Server (เรียกตอน app startup)
  /// 
  /// Migration strategy:
  /// - ถ้ามี balance เดิมใน local → ส่งไปให้ Server (one-time migration)
  /// - ถ้า Server มี balance แล้ว → ใช้ค่าจาก Server (server wins)
  Future<int> syncBalanceWithServer() async {
    try {
      // อ่าน balance เดิมจาก local (สำหรับ migration)
      final localBalance = await getBalance();
      
      // ดึง deviceId
      final deviceId = await DeviceIdService.getDeviceId();
      
      // เรียก Backend
      const url = 'https://us-central1-miro-d6856.cloudfunctions.net/syncBalance';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'localBalance': localBalance > 0 ? localBalance : null,
          'type': localBalance > 0 ? 'migration' : 'startup',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverBalance = data['balance'] as int;
        
        debugPrint('[EnergyService] ✅ Synced with server: $serverBalance (${data['action']})');
        
        // อัพเดท local cache
        await updateFromServerResponse(serverBalance);
        
        return serverBalance;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('[EnergyService] ❌ Sync failed: $e');
      // Fallback: ใช้ local balance
      return await getBalance();
    }
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
  /// ✅ PHASE 3: ไม่ต้องส่ง balance อีกต่อไป
  Future<String> generateEnergyToken() async {
    return EnergyTokenService.generateToken();
  }
  
  /// อัพเดท Energy จาก Backend response (หลังจากใช้ AI)
  /// Backend จะส่ง newEnergyToken กลับมา
  /// ⚠️ PHASE 3: Deprecated - ใช้ updateFromServerResponse() แทน
  @Deprecated('Use updateFromServerResponse() instead (Phase 1)')
  Future<void> updateFromBackendToken(String newToken) async {
    final decoded = EnergyTokenService.decodeToken(newToken);
    if (decoded != null && decoded['balance'] != null) {
      await _updateBalance(decoded['balance'] as int);
    }
  }
  
  /// Migrate data จาก SharedPreferences → FlutterSecureStorage
  /// เรียกครั้งเดียวตอน app startup
  Future<void> migrateToSecureStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // ─── Migrate balance ───
      final balance = prefs.getInt(_keyBalance);
      if (balance != null) {
        // เช็คว่า SecureStorage มีหรือยัง
        final existing = await _storage.read(key: _keyBalance);
        if (existing == null) {
          // ยังไม่มี → migrate
          await _storage.write(
            key: _keyBalance,
            value: balance.toString(),
          );
          debugPrint('[EnergyService] 🔄 Migrated balance to SecureStorage: $balance');
        }
      }
      
      // ─── Migrate welcome gift flag (ถ้ามี) ───
      final deviceId = await DeviceIdService.getDeviceId();
      final welcomeKey = '$_keyWelcomeClaimed$deviceId';
      final welcomeGift = prefs.getBool(welcomeKey);
      if (welcomeGift != null) {
        final existing = await _storage.read(key: 'welcome_$deviceId');
        if (existing == null) {
          await _storage.write(
            key: 'welcome_$deviceId',
            value: welcomeGift.toString(),
          );
          debugPrint('[EnergyService] 🔄 Migrated welcome gift flag');
        }
      }
      
      // ⚠️ ไม่ลบจาก SharedPreferences ทันที
      // เก็บไว้เป็น fallback สำหรับ user ที่ downgrade app
      
    } catch (e) {
      debugPrint('[EnergyService] ❌ Migration error: $e');
    }
  }
}
