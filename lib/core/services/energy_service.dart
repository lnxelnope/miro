import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/energy_transaction.dart';
import 'data_sync_service.dart';
import 'device_id_service.dart';
import 'energy_token_service.dart';

/// Service หลักสำหรับจัดการ Energy Balance
class EnergyService {
  static const String _keyBalance = 'energy_balance';
  static const String _keyWelcomeClaimed = 'welcome_claimed_'; // + deviceId
  static const String _keyFirstAiUsage =
      'first_ai_usage_time'; // สำหรับ Welcome Offer

  // Production Launch: 10 Energy for all new users
  static const int welcomeGift = 10;

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
  /// 
  /// **Subscription Feature:** Subscribers (Energy Pass) ไม่ต้องใช้ Energy
  Future<bool> consumeEnergy({
    String? description,
    bool hasSubscription = false,
  }) async {
    // 🎁 Subscribers get unlimited AI analysis (no energy cost)
    if (hasSubscription) {
      debugPrint('[EnergyService] ⚡ Subscriber - no energy consumed');
      // Still save transaction for analytics
      await _saveTransaction(
        type: 'subscriber_usage',
        amount: 0,
        balanceAfter: await getBalance(),
        description: description ?? 'AI food analysis (Energy Pass)',
      );
      return true;
    }

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
  /// Returns full data map from server including balance, miroId,
  /// challenges, milestones, subscription, tier, streak
  Future<Map<String, dynamic>> syncBalanceWithServer() async {
    try {
      final localBalance = await getBalance();
      final deviceId = await DeviceIdService.getDeviceId();

      const url =
          'https://us-central1-miro-d6856.cloudfunctions.net/syncBalance';

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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final serverBalance = (data['balance'] as num?)?.toInt() ?? 0;

        debugPrint(
            '[EnergyService] ✅ Synced with server: $serverBalance (${data['action']})');

        await updateFromServerResponse(serverBalance);

        final miroId = data['miroId']?.toString() ?? '';
        if (miroId.isNotEmpty) {
          await _storage.write(key: 'miro_id', value: miroId);
        }

        return {
          'miroId': miroId,
          'balance': serverBalance,
          'isNew': false,
          'tier': data['tier']?.toString() ?? 'none',
          'currentStreak': (data['currentStreak'] as num?)?.toInt() ?? 0,
          'longestStreak': (data['longestStreak'] as num?)?.toInt() ?? 0,
          'lastCheckInDate': data['lastCheckInDate'],
          'canClaimToday': data['canClaimToday'] ?? true,
          'challenges': data['challenges'] ?? {},
          'milestones': data['milestones'] ?? {},
          'totalSpent': (data['totalSpent'] as num?)?.toInt() ?? 0,
          'bonusRate': (data['bonusRate'] as num?)?.toDouble() ?? 0.0,
          'subscription': data['subscription'] ?? {},
          'tierCelebration': data['tierCelebration'] ?? {},
          'seasonalQuests': data['seasonalQuests'] ?? [],
        };
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[EnergyService] ❌ Sync failed: $e');
      final balance = await getBalance();
      final cachedMiroId = await _storage.read(key: 'miro_id');
      return {
        'miroId': cachedMiroId ?? '',
        'balance': balance,
        'isNew': false,
      };
    }
  }

  /// เรียก registerUser เพื่อ sync ข้อมูลครบ (balance, challenges, milestones, subscription, tier)
  /// เรียกตอน app startup — registerUser handles both new & existing users
  Future<Map<String, dynamic>> registerOrSync() async {
    final deviceId = await DeviceIdService.getDeviceId();

    const url = 'https://us-central1-miro-d6856.cloudfunctions.net/registerUser';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Safe parsing - ไม่ใช้ as int/String ที่อาจ crash
        final miroId = data['miroId']?.toString() ?? '';
        final balance = (data['balance'] as num?)?.toInt() ?? 0;

        // Cache MiRO ID
        if (miroId.isNotEmpty) {
          await _storage.write(key: 'miro_id', value: miroId);
        }

        // Update local balance
        await updateFromServerResponse(balance);

        debugPrint('[EnergyService] ✅ registerOrSync OK: miroId=$miroId, balance=$balance');

        return {
          'miroId': miroId,
          'balance': balance,
          'isNew': data['isNew'] ?? false,
          'tier': data['tier']?.toString() ?? 'none',
          'currentStreak': (data['currentStreak'] as num?)?.toInt() ?? 0,
          'longestStreak': (data['longestStreak'] as num?)?.toInt() ?? 0,
          'lastCheckInDate': data['lastCheckInDate'],
          'canClaimToday': data['canClaimToday'] ?? true,
          'challenges': data['challenges'] ?? {},
          'milestones': data['milestones'] ?? {},
          'totalSpent': (data['totalSpent'] as num?)?.toInt() ?? 0,
          'bonusRate': (data['bonusRate'] as num?)?.toDouble() ?? 0.0,
          'subscription': data['subscription'] ?? {},
          'tierCelebration': data['tierCelebration'] ?? {},
          'seasonalQuests': data['seasonalQuests'] ?? [],
        };
      }

      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('[EnergyService] ❌ registerOrSync failed: $e');
      // Fallback: ใช้ syncBalanceWithServer ซึ่งตอนนี้ return ข้อมูลครบแล้ว
      try {
        return await syncBalanceWithServer();
      } catch (syncError) {
        debugPrint('[EnergyService] ❌ syncBalance also failed: $syncError');
        final balance = await getBalance();
        final cachedMiroId = await _storage.read(key: 'miro_id');
        return {
          'miroId': cachedMiroId ?? '',
          'balance': balance,
          'isNew': false,
        };
      }
    }
  }

  /// ดึง MiRO ID ที่ cached ไว้
  Future<String?> getMiroId() async {
    return await _storage.read(key: 'miro_id');
  }

  // ───────────────────────────────────────────────────────────
  // 2. WELCOME GIFT (10 FREE ENERGY) - PRODUCTION
  // ───────────────────────────────────────────────────────────

  /// Check and grant Welcome Gift (10 Energy for free)
  /// Tied to Device ID — can only claim once per device
  ///
  /// Returns: true if gift was granted, false if already claimed
  Future<bool> initializeWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();

    // Check SharedPreferences
    if (prefs.getBool(key) == true) {
      return false; // Already claimed
    }

    // Check SecureStorage (iOS Keychain — persists after reinstall)
    final secureFlag = await _storage.read(key: 'welcome_$deviceId');
    if (secureFlag == 'claimed') {
      // Already claimed but reinstalled → sync back to SharedPreferences
      await prefs.setBool(key, true);
      return false;
    }

    // Grant the gift!
    await addEnergy(
      welcomeGift,
      type: 'welcome_gift',
      description: 'Welcome to MIRO! 🎉',
    );

    // Save flag in both places
    await prefs.setBool(key, true);
    await _storage.write(key: 'welcome_$deviceId', value: 'claimed');

    print('🎁 Welcome Gift granted: $welcomeGift Energy');
    return true;
  }

  /// Check if Welcome Gift has been claimed
  Future<bool> hasClaimedWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) == true;
  }

  // ───────────────────────────────────────────────────────────
  // 3. FIRST-TIME ENERGY EMPTY BONUS (50 FREE ENERGY + WELCOME OFFER)
  // ───────────────────────────────────────────────────────────

  static const String _keyFirstEnergyEmptyHandled = 'first_energy_empty_handled';
  static const int firstTimeBonus = 50;

  /// Check if Energy is empty (first time) → Grant 50 Energy bonus + unlock Welcome Offer (40% OFF - 24h)
  ///
  /// Returns: true if this was the first time energy ran out and bonus was granted
  Future<bool> checkAndHandleFirstEnergyEmpty() async {
    final currentBalance = await getBalance();
    
    // If still has energy → do nothing
    if (currentBalance > 0) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Check if already handled
    if (prefs.getBool(_keyFirstEnergyEmptyHandled) == true) {
      return false; // Already received bonus
    }

    // 🎁 Grant 50 Energy bonus!
    await addEnergy(
      firstTimeBonus,
      type: 'first_empty_bonus',
      description: 'First-time bonus: 50 Energy + 40% OFF (24h)! 🎉',
    );

    // 🎉 Unlock Welcome Offer (40% OFF for 24 hours)
    await prefs.setInt(
      _keyFirstAiUsage, 
      DateTime.now().millisecondsSinceEpoch,
    );

    // Mark as handled
    await prefs.setBool(_keyFirstEnergyEmptyHandled, true);

    debugPrint('🎉 First Energy Empty → 50 Energy bonus + Welcome Offer unlocked!');
    return true;
  }

  /// Check if "First Energy Empty" bonus has been handled
  Future<bool> hasHandledFirstEnergyEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstEnergyEmptyHandled) ?? false;
  }

  // ───────────────────────────────────────────────────────────
  // 3B. FIRST FREE ANALYSIS (once per user)
  // ───────────────────────────────────────────────────────────

  static const String _keyFirstFreeAnalysisUsed = 'first_free_analysis_used';

  /// Check if the user still has their first free analysis available
  Future<bool> isFirstFreeAnalysisAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstFreeAnalysisUsed) != true;
  }

  /// Grant bonus energy to cover the first analysis, then mark as used.
  /// Returns true if granted, false if already used.
  Future<bool> grantFirstFreeAnalysis(int itemCount) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyFirstFreeAnalysisUsed) == true) {
      return false;
    }

    await addEnergy(
      itemCount,
      type: 'first_free_analysis',
      description: 'First analysis bonus: $itemCount Energy 🎁',
    );

    await prefs.setBool(_keyFirstFreeAnalysisUsed, true);
    debugPrint('[EnergyService] 🎁 First free analysis granted: +$itemCount Energy');
    return true;
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
  Future<List<EnergyTransaction>> getTransactionHistory(
      {int limit = 50}) async {
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
  /// Migration: แปลง Free user → 10 Energy (ถ้ายังไม่ได้รับ welcome gift)
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
      // Free user → ได้ 10 Energy (เหมือน welcome gift)
      await addEnergy(
        10,
        type: 'pro_migration',
        description: 'Welcome to the new Energy system! 🎉',
      );
      print('✅ Free user migrated: 10 Energy');
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

  /// V3: Claim Daily Energy (Manual) — Static helper
  /// Also piggybacks a data sync payload (food entries + meals since last sync)
  /// for automatic cloud backup. Server stores this in Firestore.
  /// Returns: { success, energyClaimed, newBalance, newStreak, tierUpgraded, ... }
  static Future<Map<String, dynamic>> claimDailyEnergy() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      const url =
          'https://us-central1-miro-d6856.cloudfunctions.net/claimDailyEnergy';

      // Build sync payload (food entries + meals since last sync)
      Map<String, dynamic>? syncPayload;
      try {
        syncPayload = await DataSyncService.buildSyncPayload();
      } catch (e) {
        debugPrint('[EnergyService] Sync payload build failed (non-fatal): $e');
      }

      final requestBody = <String, dynamic>{
        'deviceId': deviceId,
      };
      if (syncPayload != null &&
          ((syncPayload['entries'] as List).isNotEmpty ||
           (syncPayload['meals'] as List).isNotEmpty)) {
        requestBody['sync'] = syncPayload;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Update local balance (static helper)
        if (data['newBalance'] != null) {
          final newBalance = (data['newBalance'] as num).toInt();
          await _storage.write(
            key: _keyBalance,
            value: newBalance.toString(),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_keyBalance, newBalance);
          debugPrint('[EnergyService] ✅ Daily claim balance updated: $newBalance');
        }

        // Mark sync as successful if server acknowledged it
        if (syncPayload != null && data['syncAck'] == true) {
          await DataSyncService.markSyncSuccess(
            syncPayload['syncTimestamp'] as int,
          );
          final entryIds = (syncPayload['entries'] as List)
              .map((e) => (e as Map<String, dynamic>)['id'] as int)
              .toList();
          if (entryIds.isNotEmpty) {
            await DataSyncService.markEntriesSynced(entryIds);
          }
          debugPrint('[EnergyService] ✅ Data sync acknowledged by server');
        }

        return data;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Failed to claim daily energy');
      }
    } catch (e) {
      debugPrint('[EnergyService] ❌ claimDailyEnergy error: $e');
      rethrow;
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
          debugPrint(
              '[EnergyService] 🔄 Migrated balance to SecureStorage: $balance');
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
