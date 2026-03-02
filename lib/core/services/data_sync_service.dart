import 'dart:convert';

import 'package:drift/drift.dart' hide JsonKey, Column;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../database/database_service.dart';
import '../database/model_extensions.dart';
import 'device_id_service.dart';
import '../utils/logger.dart';

/// Builds compact sync payloads for food entries and meals.
/// Attached to claimDailyEnergy requests for automatic cloud backup.
/// Also handles auto-sync on first app open of each day.
class DataSyncService {
  static const String _keyLastSync = 'data_sync_last_timestamp';
  static const String _keyAutoSyncDate = 'auto_sync_last_date';

  // ─── Auto Sync (once per day on first app open) ────────────

  /// Auto-sync to Firestore if not already synced today.
  /// Called from app startup. Writes directly to Firestore
  /// without requiring claimDailyEnergy or user interaction.
  static Future<void> autoSyncIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayString();
      final lastAutoSync = prefs.getString(_keyAutoSyncDate);

      if (lastAutoSync == today) {
        debugPrint('[DataSync] Already auto-synced today, skipping');
        return;
      }

      final deviceId = await DeviceIdService.getDeviceId();
      final payload = await buildSyncPayload();

      final entries = payload['entries'] as List;
      final meals = payload['meals'] as List;
      final hasProfile = payload['profile'] != null;
      final hasSummary = payload['summary'] != null;

      // Sync เมื่อมี entries, meals, profile หรือ summary (net energy สำหรับ data mining)
      if (entries.isEmpty && meals.isEmpty && !hasProfile && !hasSummary) {
        await prefs.setString(_keyAutoSyncDate, today);
        debugPrint('[DataSync] Payload empty, marking today done');
        return;
      }

      final db = FirebaseFirestore.instance;
      final syncDoc = db
          .collection('users')
          .doc(deviceId)
          .collection('daily_sync')
          .doc(today);

      await syncDoc.set({
        'entries': entries,
        'meals': meals,
        if (payload['profile'] != null) 'profile': payload['profile'],
        if (payload['summary'] != null) 'summary': payload['summary'],
        'syncTimestamp': FieldValue.serverTimestamp(),
        'entryCount': entries.length,
        'mealCount': meals.length,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      }, SetOptions(merge: true));

      final syncTs = payload['syncTimestamp'] as int;
      await markSyncSuccess(syncTs);
      final entryIds = entries
          .map((e) => (e as Map<String, dynamic>)['id'] as int)
          .toList();
      if (entryIds.isNotEmpty) {
        await markEntriesSynced(entryIds);
      }

      await prefs.setString(_keyAutoSyncDate, today);
      await prefs.setInt('last_backup_date', DateTime.now().millisecondsSinceEpoch);
      AppLogger.info('Auto-synced ${entries.length} entries, '
          '${meals.length} meals to Firestore');
    } catch (e) {
      AppLogger.warn('Auto-sync failed (non-fatal): $e');
    }
  }

  /// Manual sync — no date guard, loops until all entries are synced.
  static Future<void> syncNow() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final db = FirebaseFirestore.instance;
      final today = _todayString();
      int totalSynced = 0;

      while (true) {
        final payload = await buildSyncPayload();
        final entries = payload['entries'] as List;
        final meals = payload['meals'] as List;
        final hasProfile = payload['profile'] != null;
        final hasSummary = payload['summary'] != null;

        // Sync เมื่อมี entries, meals, profile หรือ summary
        if (entries.isEmpty && meals.isEmpty && !hasProfile && !hasSummary) break;

        final syncDoc = db
            .collection('users')
            .doc(deviceId)
            .collection('daily_sync')
            .doc(today);

        await syncDoc.set({
          'entries': entries,
          'meals': meals,
          if (payload['profile'] != null) 'profile': payload['profile'],
          if (payload['summary'] != null) 'summary': payload['summary'],
          'syncTimestamp': FieldValue.serverTimestamp(),
          'entryCount': entries.length,
          'mealCount': meals.length,
          'platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        }, SetOptions(merge: true));

        final syncTs = payload['syncTimestamp'] as int;
        await markSyncSuccess(syncTs);
        final entryIds = entries
            .map((e) => (e as Map<String, dynamic>)['id'] as int)
            .toList();
        if (entryIds.isNotEmpty) {
          await markEntriesSynced(entryIds);
          totalSynced += entryIds.length;
        }

        if (entries.length < 100) break;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAutoSyncDate, today);
      await prefs.setInt(
          'last_backup_date', DateTime.now().millisecondsSinceEpoch);
      AppLogger.info('Manual sync complete: $totalSynced entries synced');
    } catch (e) {
      AppLogger.warn('Manual sync failed: $e');
      rethrow;
    }
  }

  /// Returns the last auto-sync date as a readable string, or null.
  static Future<String?> getLastAutoSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAutoSyncDate);
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ─── Sync Payload Builder ─────────────────────────────────

  /// Get entries that haven't been synced yet.
  /// Uses isSynced flag instead of timestamp to catch older unsynced entries.
  static Future<Map<String, dynamic>> buildSyncPayload() async {
    final now = DateTime.now();

    final entries = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isSynced.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
      ..limit(100))
        .get();

    final prefs = await SharedPreferences.getInstance();
    final lastSyncMs = prefs.getInt(_keyLastSync) ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    final meals = await (DatabaseService.db.select(DatabaseService.db.myMeals)
      ..where((tbl) => tbl.updatedAt.isBiggerThanValue(lastSync)))
        .get();

    Map<String, dynamic>? profileData;
    try {
      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
        ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      if (profile != null) {
        profileData = _compactProfile(profile);
      }
    } catch (e) {
      debugPrint('[DataSync] Profile read failed (non-fatal): $e');
    }

    // Today's DailySummary (net energy) — สำคัญต่อ data mining
    Map<String, dynamic>? summaryData;
    try {
      final today = DateTime(now.year, now.month, now.day);
      final summary = await (DatabaseService.db.select(DatabaseService.db.dailySummaries)
        ..where((tbl) => tbl.date.equals(today)))
          .getSingleOrNull();
      if (summary != null) {
        summaryData = _compactSummary(summary);
      }
    } catch (e) {
      debugPrint('[DataSync] DailySummary read failed (non-fatal): $e');
    }

    debugPrint('[DataSync] Payload: ${entries.length} entries, '
        '${meals.length} meals since ${lastSync.toIso8601String()}'
        '${summaryData != null ? ", netEnergy=${summaryData!['ne']}" : ""}');

    return {
      'lastSyncTimestamp': lastSyncMs,
      'syncTimestamp': now.millisecondsSinceEpoch,
      'entries': entries.map(_compactEntry).toList(),
      'meals': meals.map(_compactMeal).toList(),
      if (profileData != null) 'profile': profileData,
      if (summaryData != null) 'summary': summaryData,
    };
  }

  /// Compact DailySummary for sync — net energy สำคัญต่อ data mining
  static Map<String, dynamic> _compactSummary(DailySummary s) {
    return {
      'ne': _round(s.netEnergy),
      'ce': _round(s.caloriesEaten),
      'td': _round(s.tdee),
      'dz': s.deficitZone,
      'ec': s.entryCount,
      'cc': s.correctionCount,
      'cg': _round(s.calorieGoal),
    };
  }

  /// Mark sync as successful — advances the lastSyncTimestamp.
  static Future<void> markSyncSuccess(int syncTimestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSync, syncTimestamp);
    debugPrint('[DataSync] Sync marked successful at $syncTimestamp');
  }

  /// Mark entries as synced in local DB after successful server sync.
  static Future<void> markEntriesSynced(List<int> entryIds) async {
    await DatabaseService.db.transaction(() async {
      for (final id in entryIds) {
        final entry = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
          ..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
        if (entry != null) {
          entry.isSynced = true;
          entry.syncedAt = DateTime.now();
          await DatabaseService.db
              .into(DatabaseService.db.foodEntries)
              .insertOnConflictUpdate(entry);
        }
      }
    });
  }

  /// Restore food entries from server data (called on new device).
  static Future<int> restoreEntries(List<dynamic> entriesJson) async {
    int imported = 0;

    for (final json in entriesJson) {
      try {
        final entry = _expandEntry(json as Map<String, dynamic>);
        if (entry == null) continue;

        final existing = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
          ..where((tbl) =>
              tbl.foodName.equals(entry.foodName) &
              tbl.timestamp.equals(entry.timestamp))
          ..limit(1))
            .getSingleOrNull();

        if (existing != null) continue;

        await DatabaseService.db
            .into(DatabaseService.db.foodEntries)
            .insertOnConflictUpdate(entry);
        imported++;
      } catch (e) {
        debugPrint('[DataSync] Error restoring entry: $e');
      }
    }

    debugPrint('[DataSync] Restored $imported entries');
    return imported;
  }

  /// Restore My Meals from server data.
  static Future<int> restoreMeals(List<dynamic> mealsJson) async {
    int imported = 0;

    for (final json in mealsJson) {
      try {
        final meal = _expandMeal(json as Map<String, dynamic>);
        if (meal == null) continue;

        final existing = await (DatabaseService.db.select(DatabaseService.db.myMeals)
          ..where((tbl) => tbl.name.equals(meal.name))
          ..limit(1))
            .getSingleOrNull();

        if (existing != null) continue;

        await DatabaseService.db
            .into(DatabaseService.db.myMeals)
            .insertOnConflictUpdate(meal);
        imported++;
      } catch (e) {
        debugPrint('[DataSync] Error restoring meal: $e');
      }
    }

    debugPrint('[DataSync] Restored $imported meals');
    return imported;
  }

  /// Restore user profile from server data (called on new device).
  static Future<bool> restoreProfile(Map<String, dynamic> profileJson) async {
    try {
      final existing = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
        ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();

      final profile = existing ?? UserProfile(
        id: 1,
        calorieGoal: 2000,
        proteinGoal: 50,
        carbGoal: 250,
        fatGoal: 65,
        waterGoal: 2500,
        cuisinePreference: 'general',
        customBmr: 1500,
        tdee: 0,
        breakfastBudget: 500,
        lunchBudget: 600,
        dinnerBudget: 600,
        snackBudget: 300,
        suggestionThreshold: 100,
        mealSuggestionsEnabled: false,
        isDarkMode: false,
        hasGeminiApiKey: false,
        isGoogleCalendarConnected: false,
        isHealthConnectConnected: false,
        onboardingComplete: false,
        foodResearchConsent: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (profileJson['g'] != null) profile.gender = profileJson['g'] as String;
      if (profileJson['a'] != null) profile.age = profileJson['a'] as int;
      if (profileJson['w'] != null) {
        profile.weight = (profileJson['w'] as num).toDouble();
      }
      if (profileJson['h'] != null) {
        profile.height = (profileJson['h'] as num).toDouble();
      }
      if (profileJson['tw'] != null) {
        profile.targetWeight = (profileJson['tw'] as num).toDouble();
      }
      if (profileJson['al'] != null) {
        profile.activityLevel = profileJson['al'] as String;
      }
      if (profileJson['kg'] != null) {
        profile.calorieGoal = (profileJson['kg'] as num).toDouble();
      }
      if (profileJson['pg'] != null) {
        profile.proteinGoal = (profileJson['pg'] as num).toDouble();
      }
      if (profileJson['cg'] != null) {
        profile.carbGoal = (profileJson['cg'] as num).toDouble();
      }
      if (profileJson['fg'] != null) {
        profile.fatGoal = (profileJson['fg'] as num).toDouble();
      }
      if (profileJson['cu'] != null) {
        profile.cuisinePreference = profileJson['cu'] as String;
      }
      if (profileJson['td'] != null) {
        profile.tdee = (profileJson['td'] as num).toDouble();
      }
      if (profileJson['bm'] != null) {
        profile.customBmr = (profileJson['bm'] as num).toDouble();
      }
      if (profileJson['bb'] != null) {
        profile.breakfastBudget = (profileJson['bb'] as num).toDouble();
      }
      if (profileJson['lb'] != null) {
        profile.lunchBudget = (profileJson['lb'] as num).toDouble();
      }
      if (profileJson['db'] != null) {
        profile.dinnerBudget = (profileJson['db'] as num).toDouble();
      }
      if (profileJson['sb'] != null) {
        profile.snackBudget = (profileJson['sb'] as num).toDouble();
      }

      profile.onboardingComplete = true;
      profile.updatedAt = DateTime.now();

      await DatabaseService.db
          .into(DatabaseService.db.userProfiles)
          .insertOnConflictUpdate(profile);

      debugPrint('[DataSync] Profile restored successfully');
      return true;
    } catch (e) {
      debugPrint('[DataSync] Error restoring profile: $e');
      return false;
    }
  }

  // ─── Compact serialization (minimize payload size) ─────────

  static Map<String, dynamic> _compactEntry(FoodEntry e) {
    final map = <String, dynamic>{
      'id': e.id,
      'fn': e.foodName,
      'ts': e.timestamp.millisecondsSinceEpoch,
      'mt': e.mealType.index,
      'ss': e.servingSize,
      'su': e.servingUnit,
      'k': _round(e.calories),
      'p': _round(e.protein),
      'c': _round(e.carbs),
      'f': _round(e.fat),
      'bk': _round(e.baseCalories),
      'bp': _round(e.baseProtein),
      'bc': _round(e.baseCarbs),
      'bf': _round(e.baseFat),
      'src': e.source.index,
      'v': e.isVerified,
      'ca': e.createdAt.millisecondsSinceEpoch,
    };

    if (e.foodNameEn != null) map['fe'] = e.foodNameEn;
    if (e.servingGrams != null) map['sg'] = _round(e.servingGrams!);
    if (e.fiber != null) map['fi'] = _round(e.fiber!);
    if (e.sugar != null) map['su2'] = _round(e.sugar!);
    if (e.sodium != null) map['so'] = _round(e.sodium!);
    if (e.cholesterol != null) map['ch'] = _round(e.cholesterol!);
    if (e.saturatedFat != null) map['sf'] = _round(e.saturatedFat!);
    if (e.transFat != null) map['tf'] = _round(e.transFat!);
    if (e.unsaturatedFat != null) map['uf'] = _round(e.unsaturatedFat!);
    if (e.monounsaturatedFat != null) map['mf'] = _round(e.monounsaturatedFat!);
    if (e.polyunsaturatedFat != null) map['pf'] = _round(e.polyunsaturatedFat!);
    if (e.potassium != null) map['po'] = _round(e.potassium!);
    if (e.aiConfidence != null) map['ac'] = _round(e.aiConfidence!);
    if (e.notes != null) map['n'] = e.notes;
    if (e.searchMode.index != 0) map['sm'] = e.searchMode.index;
    if (e.ingredientsJson != null) map['ij'] = e.ingredientsJson;
    if (e.thumbnailUrl != null) map['tu'] = e.thumbnailUrl;
    if (e.referenceObjectUsed != null) map['ro'] = e.referenceObjectUsed;
    if (e.isCalibrated) map['cal'] = true;

    // AR Scale data
    if (e.referenceConfidence != null) map['rcf'] = _round(e.referenceConfidence!);
    if (e.plateDiameterCm != null) map['pd'] = _round(e.plateDiameterCm!);
    if (e.estimatedVolumeMl != null) map['ev'] = _round(e.estimatedVolumeMl!);
    if (e.arLabelsJson != null) map['alj'] = e.arLabelsJson;
    if (e.arImageWidth != null) map['aiw'] = _round(e.arImageWidth!);
    if (e.arImageHeight != null) map['aih'] = _round(e.arImageHeight!);
    if (e.arPixelPerCm != null) map['apc'] = _round(e.arPixelPerCm!);

    // Scene context
    if (e.sceneContext != null) map['scj'] = e.sceneContext;

    // Group data
    if (e.groupId != null) map['gi'] = e.groupId;
    if (e.groupSource != null) map['gs'] = e.groupSource;
    if (e.groupOrder != null) map['go'] = e.groupOrder;
    if (e.isGroupOriginal) map['igo'] = true;

    // User input & correction tracking
    if (e.userInputText != null) map['uit'] = e.userInputText;
    if (e.originalFoodName != null) map['ofn'] = e.originalFoodName;
    if (e.originalFoodNameEn != null) map['ofe'] = e.originalFoodNameEn;
    if (e.originalCalories != null) map['ok'] = _round(e.originalCalories!);
    if (e.originalProtein != null) map['op'] = _round(e.originalProtein!);
    if (e.originalCarbs != null) map['oc'] = _round(e.originalCarbs!);
    if (e.originalFat != null) map['of'] = _round(e.originalFat!);
    if (e.originalIngredientsJson != null) map['oij'] = e.originalIngredientsJson;
    if (e.editCount > 0) map['ec'] = e.editCount;
    if (e.isUserCorrected) map['uc'] = true;

    // Brand / product data
    if (e.brandName != null) map['bn'] = e.brandName;
    if (e.productName != null) map['bne'] = e.productName;
    if (e.productBarcode != null) map['bc2'] = e.productBarcode;

    return map;
  }

  static Map<String, dynamic> _compactMeal(MyMeal m) {
    return {
      'n': m.name,
      'ne': m.nameEn,
      'k': _round(m.totalCalories),
      'p': _round(m.totalProtein),
      'c': _round(m.totalCarbs),
      'f': _round(m.totalFat),
      'bs': m.baseServingDescription,
      'src': m.source,
      'uc': m.usageCount,
      'ca': m.createdAt.millisecondsSinceEpoch,
    };
  }

  // ─── Expand from compact format ─────────────────────────

  static FoodEntry? _expandEntry(Map<String, dynamic> j) {
    try {
      final now = DateTime.now();
      return FoodEntry(
        id: 0,
        foodName: j['fn'] as String,
        foodNameEn: j['fe'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
        mealType: MealType.values[j['mt'] as int],
        servingSize: (j['ss'] as num).toDouble(),
        servingUnit: j['su'] as String,
        servingGrams: (j['sg'] as num?)?.toDouble(),
        calories: (j['k'] as num).toDouble(),
        protein: (j['p'] as num).toDouble(),
        carbs: (j['c'] as num).toDouble(),
        fat: (j['f'] as num).toDouble(),
        baseCalories: (j['bk'] as num).toDouble(),
        baseProtein: (j['bp'] as num).toDouble(),
        baseCarbs: (j['bc'] as num).toDouble(),
        baseFat: (j['bf'] as num).toDouble(),
        fiber: (j['fi'] as num?)?.toDouble(),
        sugar: (j['su2'] as num?)?.toDouble(),
        sodium: (j['so'] as num?)?.toDouble(),
        cholesterol: (j['ch'] as num?)?.toDouble(),
        saturatedFat: (j['sf'] as num?)?.toDouble(),
        transFat: (j['tf'] as num?)?.toDouble(),
        unsaturatedFat: (j['uf'] as num?)?.toDouble(),
        monounsaturatedFat: (j['mf'] as num?)?.toDouble(),
        polyunsaturatedFat: (j['pf'] as num?)?.toDouble(),
        potassium: (j['po'] as num?)?.toDouble(),
        source: DataSource.values[j['src'] as int],
        searchMode: FoodSearchMode.values[j['sm'] as int? ?? 0],
        aiConfidence: (j['ac'] as num?)?.toDouble(),
        isVerified: j['v'] as bool? ?? false,
        isDeleted: false,
        notes: j['n'] as String?,
        ingredientsJson: j['ij'] as String?,
        thumbnailUrl: j['tu'] as String?,
        referenceObjectUsed: j['ro'] as String?,
        isCalibrated: j['cal'] as bool? ?? false,
        referenceConfidence: (j['rcf'] as num?)?.toDouble(),
        plateDiameterCm: (j['pd'] as num?)?.toDouble(),
        estimatedVolumeMl: (j['ev'] as num?)?.toDouble(),
        arLabelsJson: j['alj'] as String?,
        arImageWidth: (j['aiw'] as num?)?.toDouble(),
        arImageHeight: (j['aih'] as num?)?.toDouble(),
        arPixelPerCm: (j['apc'] as num?)?.toDouble(),
        sceneContext: j['scj'] as String?,
        groupId: j['gi'] as String?,
        groupSource: j['gs'] as String?,
        groupOrder: j['go'] as int?,
        isGroupOriginal: j['igo'] as bool? ?? false,
        userInputText: j['uit'] as String?,
        originalFoodName: j['ofn'] as String?,
        originalFoodNameEn: j['ofe'] as String?,
        originalCalories: (j['ok'] as num?)?.toDouble(),
        originalProtein: (j['op'] as num?)?.toDouble(),
        originalCarbs: (j['oc'] as num?)?.toDouble(),
        originalFat: (j['of'] as num?)?.toDouble(),
        originalIngredientsJson: j['oij'] as String?,
        editCount: j['ec'] as int? ?? 0,
        isUserCorrected: j['uc'] as bool? ?? false,
        brandName: j['bn'] as String?,
        productName: j['bne'] as String?,
        productBarcode: j['bc2'] as String?,
        isSynced: true,
        imagePath: null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['ca'] as int),
        updatedAt: now,
      );
    } catch (e) {
      debugPrint('[DataSync] Error expanding entry: $e');
      return null;
    }
  }

  static MyMeal? _expandMeal(Map<String, dynamic> j) {
    try {
      return MyMeal(
        id: 0,
        name: j['n'] as String,
        nameEn: j['ne'] as String?,
        totalCalories: (j['k'] as num).toDouble(),
        totalProtein: (j['p'] as num).toDouble(),
        totalCarbs: (j['c'] as num).toDouble(),
        totalFat: (j['f'] as num).toDouble(),
        baseServingDescription: j['bs'] as String,
        source: j['src'] as String,
        usageCount: j['uc'] as int? ?? 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['ca'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(j['ca'] as int),
      );
    } catch (e) {
      debugPrint('[DataSync] Error expanding meal: $e');
      return null;
    }
  }

  static Map<String, dynamic> _compactProfile(UserProfile p) {
    final map = <String, dynamic>{
      'kg': _round(p.calorieGoal),
      'pg': _round(p.proteinGoal),
      'cg': _round(p.carbGoal),
      'fg': _round(p.fatGoal),
      'cu': p.cuisinePreference,
      'bb': _round(p.breakfastBudget),
      'lb': _round(p.lunchBudget),
      'db': _round(p.dinnerBudget),
      'sb': _round(p.snackBudget),
    };

    if (p.gender != null) map['g'] = p.gender;
    if (p.age != null) map['a'] = p.age;
    if (p.weight != null) map['w'] = _round(p.weight!);
    if (p.height != null) map['h'] = _round(p.height!);
    if (p.targetWeight != null) map['tw'] = _round(p.targetWeight!);
    if (p.activityLevel != null) map['al'] = p.activityLevel;
    if (p.tdee > 0) map['td'] = _round(p.tdee);
    if (p.customBmr != 1500) map['bm'] = _round(p.customBmr);

    return map;
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(1));

  /// Get count of unsynced entries (for UI display).
  static Future<int> getUnsyncedCount() async {
    final results = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isSynced.equals(false)))
        .get();
    return results.length;
  }

  /// Get estimated payload size in bytes (for debugging).
  static Future<int> estimatePayloadSize() async {
    final payload = await buildSyncPayload();
    return utf8.encode(jsonEncode(payload)).length;
  }
}
