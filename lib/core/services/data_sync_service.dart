import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/health/models/food_entry.dart';
import '../../features/health/models/my_meal.dart';
import '../../features/profile/models/user_profile.dart';
import '../constants/enums.dart';
import '../database/database_service.dart';

/// Builds compact sync payloads for food entries and meals.
/// Attached to claimDailyEnergy requests for automatic cloud backup.
class DataSyncService {
  static const String _keyLastSync = 'data_sync_last_timestamp';

  /// Get entries created/updated since last successful sync.
  /// Includes ALL entries (image-based and text-only).
  static Future<Map<String, dynamic>> buildSyncPayload() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMs = prefs.getInt(_keyLastSync) ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    final now = DateTime.now();

    final isar = DatabaseService.isar;

    // Food entries since last sync (max 100 per batch to keep payload small)
    final entries = await isar.foodEntrys
        .filter()
        .isDeletedEqualTo(false)
        .createdAtGreaterThan(lastSync)
        .sortByCreatedAt()
        .limit(100)
        .findAll();

    // My Meals created/updated since last sync
    final meals = await isar.myMeals
        .filter()
        .updatedAtGreaterThan(lastSync)
        .findAll();

    // Profile data (always include latest snapshot)
    Map<String, dynamic>? profileData;
    try {
      final profile = await DatabaseService.userProfiles.get(1);
      if (profile != null) {
        profileData = _compactProfile(profile);
      }
    } catch (e) {
      debugPrint('[DataSync] Profile read failed (non-fatal): $e');
    }

    debugPrint('[DataSync] Payload: ${entries.length} entries, '
        '${meals.length} meals since ${lastSync.toIso8601String()}');

    return {
      'lastSyncTimestamp': lastSyncMs,
      'syncTimestamp': now.millisecondsSinceEpoch,
      'entries': entries.map(_compactEntry).toList(),
      'meals': meals.map(_compactMeal).toList(),
      if (profileData != null) 'profile': profileData,
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
    final isar = DatabaseService.isar;
    await isar.writeTxn(() async {
      for (final id in entryIds) {
        final entry = await isar.foodEntrys.get(id);
        if (entry != null) {
          entry.isSynced = true;
          entry.syncedAt = DateTime.now();
          await isar.foodEntrys.put(entry);
        }
      }
    });
  }

  /// Restore food entries from server data (called on new device).
  static Future<int> restoreEntries(List<dynamic> entriesJson) async {
    final isar = DatabaseService.isar;
    int imported = 0;

    for (final json in entriesJson) {
      try {
        final entry = _expandEntry(json as Map<String, dynamic>);
        if (entry == null) continue;

        // Deduplicate by foodName + timestamp
        final existing = await isar.foodEntrys
            .filter()
            .foodNameEqualTo(entry.foodName)
            .timestampEqualTo(entry.timestamp)
            .findFirst();

        if (existing != null) continue;

        await isar.writeTxn(() async {
          await isar.foodEntrys.put(entry);
        });
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
    final isar = DatabaseService.isar;
    int imported = 0;

    for (final json in mealsJson) {
      try {
        final meal = _expandMeal(json as Map<String, dynamic>);
        if (meal == null) continue;

        final existing = await isar.myMeals
            .filter()
            .nameEqualTo(meal.name)
            .findFirst();

        if (existing != null) continue;

        await isar.writeTxn(() async {
          await isar.myMeals.put(meal);
        });
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
      final isar = DatabaseService.isar;
      final existing = await isar.userProfiles.get(1) ?? UserProfile();

      // Only restore values that exist in the backup
      if (profileJson['g'] != null) existing.gender = profileJson['g'] as String;
      if (profileJson['a'] != null) existing.age = profileJson['a'] as int;
      if (profileJson['w'] != null) {
        existing.weight = (profileJson['w'] as num).toDouble();
      }
      if (profileJson['h'] != null) {
        existing.height = (profileJson['h'] as num).toDouble();
      }
      if (profileJson['tw'] != null) {
        existing.targetWeight = (profileJson['tw'] as num).toDouble();
      }
      if (profileJson['al'] != null) {
        existing.activityLevel = profileJson['al'] as String;
      }
      if (profileJson['kg'] != null) {
        existing.calorieGoal = (profileJson['kg'] as num).toDouble();
      }
      if (profileJson['pg'] != null) {
        existing.proteinGoal = (profileJson['pg'] as num).toDouble();
      }
      if (profileJson['cg'] != null) {
        existing.carbGoal = (profileJson['cg'] as num).toDouble();
      }
      if (profileJson['fg'] != null) {
        existing.fatGoal = (profileJson['fg'] as num).toDouble();
      }
      if (profileJson['cu'] != null) {
        existing.cuisinePreference = profileJson['cu'] as String;
      }
      if (profileJson['td'] != null) {
        existing.tdee = (profileJson['td'] as num).toDouble();
      }
      if (profileJson['bm'] != null) {
        existing.customBmr = (profileJson['bm'] as num).toDouble();
      }
      if (profileJson['bb'] != null) {
        existing.breakfastBudget = (profileJson['bb'] as num).toDouble();
      }
      if (profileJson['lb'] != null) {
        existing.lunchBudget = (profileJson['lb'] as num).toDouble();
      }
      if (profileJson['db'] != null) {
        existing.dinnerBudget = (profileJson['db'] as num).toDouble();
      }
      if (profileJson['sb'] != null) {
        existing.snackBudget = (profileJson['sb'] as num).toDouble();
      }

      existing.onboardingComplete = true;
      existing.updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.userProfiles.put(existing);
      });

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

    // Optional fields — only include if non-null to save bytes
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

    // AR Scale data — valuable for AI training datasets
    if (e.referenceConfidence != null) map['rcf'] = _round(e.referenceConfidence!);
    if (e.plateDiameterCm != null) map['pd'] = _round(e.plateDiameterCm!);
    if (e.estimatedVolumeMl != null) map['ev'] = _round(e.estimatedVolumeMl!);
    if (e.arLabelsJson != null) map['alj'] = e.arLabelsJson;
    if (e.arImageWidth != null) map['aiw'] = _round(e.arImageWidth!);
    if (e.arImageHeight != null) map['aih'] = _round(e.arImageHeight!);
    if (e.arPixelPerCm != null) map['apc'] = _round(e.arPixelPerCm!);

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
      return FoodEntry()
        ..foodName = j['fn'] as String
        ..foodNameEn = j['fe'] as String?
        ..timestamp = DateTime.fromMillisecondsSinceEpoch(j['ts'] as int)
        ..mealType = MealType.values[j['mt'] as int]
        ..servingSize = (j['ss'] as num).toDouble()
        ..servingUnit = j['su'] as String
        ..servingGrams = (j['sg'] as num?)?.toDouble()
        ..calories = (j['k'] as num).toDouble()
        ..protein = (j['p'] as num).toDouble()
        ..carbs = (j['c'] as num).toDouble()
        ..fat = (j['f'] as num).toDouble()
        ..baseCalories = (j['bk'] as num).toDouble()
        ..baseProtein = (j['bp'] as num).toDouble()
        ..baseCarbs = (j['bc'] as num).toDouble()
        ..baseFat = (j['bf'] as num).toDouble()
        ..fiber = (j['fi'] as num?)?.toDouble()
        ..sugar = (j['su2'] as num?)?.toDouble()
        ..sodium = (j['so'] as num?)?.toDouble()
        ..cholesterol = (j['ch'] as num?)?.toDouble()
        ..saturatedFat = (j['sf'] as num?)?.toDouble()
        ..transFat = (j['tf'] as num?)?.toDouble()
        ..unsaturatedFat = (j['uf'] as num?)?.toDouble()
        ..monounsaturatedFat = (j['mf'] as num?)?.toDouble()
        ..polyunsaturatedFat = (j['pf'] as num?)?.toDouble()
        ..potassium = (j['po'] as num?)?.toDouble()
        ..source = DataSource.values[j['src'] as int]
        ..searchMode = FoodSearchMode.values[j['sm'] as int? ?? 0]
        ..aiConfidence = (j['ac'] as num?)?.toDouble()
        ..isVerified = j['v'] as bool? ?? false
        ..notes = j['n'] as String?
        ..ingredientsJson = j['ij'] as String?
        ..thumbnailUrl = j['tu'] as String?
        ..referenceObjectUsed = j['ro'] as String?
        ..isCalibrated = j['cal'] as bool? ?? false
        ..referenceConfidence = (j['rcf'] as num?)?.toDouble()
        ..plateDiameterCm = (j['pd'] as num?)?.toDouble()
        ..estimatedVolumeMl = (j['ev'] as num?)?.toDouble()
        ..arLabelsJson = j['alj'] as String?
        ..arImageWidth = (j['aiw'] as num?)?.toDouble()
        ..arImageHeight = (j['aih'] as num?)?.toDouble()
        ..arPixelPerCm = (j['apc'] as num?)?.toDouble()
        ..isSynced = true
        ..imagePath = null
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(j['ca'] as int);
    } catch (e) {
      debugPrint('[DataSync] Error expanding entry: $e');
      return null;
    }
  }

  static MyMeal? _expandMeal(Map<String, dynamic> j) {
    try {
      return MyMeal()
        ..name = j['n'] as String
        ..nameEn = j['ne'] as String?
        ..totalCalories = (j['k'] as num).toDouble()
        ..totalProtein = (j['p'] as num).toDouble()
        ..totalCarbs = (j['c'] as num).toDouble()
        ..totalFat = (j['f'] as num).toDouble()
        ..baseServingDescription = j['bs'] as String
        ..source = j['src'] as String
        ..usageCount = j['uc'] as int? ?? 0
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(j['ca'] as int);
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
    final isar = DatabaseService.isar;
    return isar.foodEntrys
        .filter()
        .isDeletedEqualTo(false)
        .isSyncedEqualTo(false)
        .count();
  }

  /// Get estimated payload size in bytes (for debugging).
  static Future<int> estimatePayloadSize() async {
    final payload = await buildSyncPayload();
    return utf8.encode(jsonEncode(payload)).length;
  }
}
