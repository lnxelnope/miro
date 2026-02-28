import 'dart:io';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import '../constants/enums.dart' as app_enums;
import '../utils/logger.dart';

class HealthSyncService {
  static final Health _health = Health();
  static bool _configured = false;

  static const _readTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];
  static const _writeTypes = [HealthDataType.NUTRITION];

  static void _ensureConfigured() {
    if (!_configured) {
      Health().configure();
      _configured = true;
    }
  }

  /// iOS always has HealthKit. Android needs Health Connect installed.
  static Future<bool> isAvailable() async {
    if (Platform.isIOS) return true;
    if (!Platform.isAndroid) return false;
    try {
      _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      AppLogger.warn('Health Connect availability check failed', e);
      return false;
    }
  }

  /// Request Read + Write permissions in one go.
  static Future<bool> requestPermissions() async {
    try {
      _ensureConfigured();

      final types = [..._readTypes, ..._writeTypes];
      final permissions = [
        ..._readTypes.map((_) => HealthDataAccess.READ),
        ..._writeTypes.map((_) => HealthDataAccess.WRITE),
      ];

      AppLogger.info('[Health] Requesting permissions for: '
          '${types.map((t) => t.name).join(", ")}');
      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      AppLogger.info('[Health] requestAuthorization result: $granted '
          '(iOS always returns true even if denied)');
      return granted;
    } catch (e) {
      AppLogger.error('[Health] Permission request failed', e);
      return false;
    }
  }

  /// Check if we already have permissions.
  static Future<bool> hasPermissions() async {
    try {
      _ensureConfigured();
      final types = [..._readTypes, ..._writeTypes];
      final permissions = [
        ..._readTypes.map((_) => HealthDataAccess.READ),
        ..._writeTypes.map((_) => HealthDataAccess.WRITE),
      ];
      return await _health.hasPermissions(types, permissions: permissions) ??
          false;
    } catch (e) {
      return false;
    }
  }

  /// Get today's **bonus** active energy (kcal) — the amount that justifies
  /// eating more than the base calorie goal.
  ///
  /// **iOS** — HealthKit provides `ACTIVE_ENERGY_BURNED` which already
  /// excludes BMR, so we use it directly as the bonus.
  ///
  /// **Android** — Health Connect only reliably gives
  /// `TOTAL_CALORIES_BURNED` (BMR + active).  We subtract the user's
  /// full-day BMR so only genuine surplus counts:
  ///   • TBC ≤ BMR → Bonus = 0
  ///   • TBC > BMR → Bonus = TBC − BMR
  static Future<double> getTodayActiveEnergy({double bmr = 1500}) async {
    final safeBmr = (bmr.isNaN || bmr.isInfinite || bmr <= 0) ? 1500.0 : bmr;
    try {
      _ensureConfigured();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      AppLogger.info('[Health] ── getTodayActiveEnergy START ──');
      AppLogger.info('[Health] now=$now  startOfDay=$startOfDay');
      AppLogger.info('[Health] Platform: ${Platform.isIOS ? "iOS" : "Android"}');

      // Try fetching each type separately for better debugging
      AppLogger.info('[Health] ── Fetch ACTIVE_ENERGY_BURNED ──');
      List<HealthDataPoint> activeData = [];
      try {
        activeData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          startTime: startOfDay,
          endTime: now,
        );
        AppLogger.info('[Health] ACTIVE_ENERGY raw points: ${activeData.length}');
      } catch (e) {
        AppLogger.error('[Health] ACTIVE_ENERGY fetch error', e);
      }

      AppLogger.info('[Health] ── Fetch TOTAL_CALORIES_BURNED ──');
      List<HealthDataPoint> totalData = [];
      try {
        totalData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.TOTAL_CALORIES_BURNED],
          startTime: startOfDay,
          endTime: now,
        );
        AppLogger.info('[Health] TOTAL_CALORIES raw points: ${totalData.length}');
      } catch (e) {
        AppLogger.error('[Health] TOTAL_CALORIES fetch error', e);
      }

      // Also try 24h window as debug fallback
      if (activeData.isEmpty && totalData.isEmpty) {
        AppLogger.info('[Health] ── No data from today, trying 24h window ──');
        final yesterday = now.subtract(const Duration(hours: 24));
        try {
          activeData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.ACTIVE_ENERGY_BURNED],
            startTime: yesterday,
            endTime: now,
          );
          AppLogger.info('[Health] 24h ACTIVE_ENERGY points: ${activeData.length}');
          totalData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.TOTAL_CALORIES_BURNED],
            startTime: yesterday,
            endTime: now,
          );
          AppLogger.info('[Health] 24h TOTAL_CALORIES points: ${totalData.length}');
        } catch (e) {
          AppLogger.error('[Health] 24h fallback fetch error', e);
        }
      }

      final allData = [...activeData, ...totalData];
      final uniqueData = Health().removeDuplicates(allData);
      AppLogger.info('[Health] Combined unique points: ${uniqueData.length}');

      // Log each data point for debugging
      for (final point in uniqueData) {
        AppLogger.info('[Health] Point: type=${point.type.name}, '
            'value=${point.value}, '
            'unit=${point.unit}, '
            'dateFrom=${point.dateFrom}, '
            'dateTo=${point.dateTo}, '
            'source=${point.sourceName}');
      }

      double active = 0;
      double total = 0;

      for (final point in uniqueData) {
        if (point.value is NumericHealthValue) {
          final val =
              (point.value as NumericHealthValue).numericValue.toDouble();
          if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            active += val;
          } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            total += val;
          }
        }
      }

      double result;
      if (Platform.isIOS && active > 0) {
        result = active;
      } else if (total > 0) {
        result = (total - safeBmr).clamp(0.0, double.infinity);
      } else if (active > 0) {
        result = active;
      } else {
        result = 0;
      }

      AppLogger.info('[Health] ── RESULT ──  '
          'active=$active, total=$total, bmr=$safeBmr, '
          'bonus=${result.toInt()} kcal');
      return result;
    } catch (e) {
      AppLogger.error('Failed to get active energy', e);
      return 0;
    }
  }

  /// Write a food entry to Health App via writeMeal.
  /// Returns a sync key (timestamp-based) on success, null on failure.
  static Future<String?> writeFoodEntry({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime timestamp,
    app_enums.MealType? mealType,
    double? fiber,
    double? sugar,
    double? sodium,
    double? cholesterol,
    double? saturatedFat,
    double? transFat,
    double? unsaturatedFat,
    double? monounsaturatedFat,
    double? polyunsaturatedFat,
    double? potassium,
  }) async {
    try {
      _ensureConfigured();

      final startTime = timestamp;
      final endTime = timestamp.add(const Duration(minutes: 1));

      final success = await _health.writeMeal(
        startTime: startTime,
        endTime: endTime,
        caloriesConsumed: calories,
        protein: protein,
        carbohydrates: carbs,
        fatTotal: fat,
        name: name,
        mealType: _mapMealType(mealType),
        fiber: fiber,
        sugar: sugar,
        sodium: sodium,
        cholesterol: cholesterol,
        fatSaturated: saturatedFat,
        fatTransMonoenoic: transFat,
        fatUnsaturated: unsaturatedFat,
        fatMonounsaturated: monounsaturatedFat,
        fatPolyunsaturated: polyunsaturatedFat,
        potassium: potassium,
      );

      if (!success) {
        AppLogger.warn('writeMeal returned false for "$name"');
        return null;
      }

      final syncKey = '${startTime.millisecondsSinceEpoch}';
      AppLogger.info(
          'Wrote food to Health: "$name" $calories kcal (key=$syncKey)');
      return syncKey;
    } catch (e) {
      AppLogger.error('Failed to write food entry to Health', e);
      return null;
    }
  }

  /// Delete a previously synced food entry from Health App.
  static Future<bool> deleteFoodEntry({
    required String healthSyncKey,
  }) async {
    try {
      _ensureConfigured();

      final startMs = int.tryParse(healthSyncKey);
      if (startMs == null) return false;

      final startTime = DateTime.fromMillisecondsSinceEpoch(startMs);
      final endTime = startTime.add(const Duration(minutes: 1));

      final success = await _health.delete(
        type: HealthDataType.NUTRITION,
        startTime: startTime,
        endTime: endTime,
      );

      AppLogger.info(
          'Deleted food from Health: key=$healthSyncKey success=$success');
      return success;
    } catch (e) {
      AppLogger.error('Failed to delete food from Health', e);
      return false;
    }
  }

  /// Update = delete old + write new.
  static Future<String?> updateFoodEntry({
    required String? oldHealthSyncKey,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime timestamp,
    app_enums.MealType? mealType,
    double? fiber,
    double? sugar,
    double? sodium,
    double? cholesterol,
    double? saturatedFat,
    double? transFat,
    double? unsaturatedFat,
    double? monounsaturatedFat,
    double? polyunsaturatedFat,
    double? potassium,
  }) async {
    if (oldHealthSyncKey != null && oldHealthSyncKey.isNotEmpty) {
      await deleteFoodEntry(healthSyncKey: oldHealthSyncKey);
    }

    return writeFoodEntry(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      timestamp: timestamp,
      mealType: mealType,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      cholesterol: cholesterol,
      saturatedFat: saturatedFat,
      transFat: transFat,
      unsaturatedFat: unsaturatedFat,
      monounsaturatedFat: monounsaturatedFat,
      polyunsaturatedFat: polyunsaturatedFat,
      potassium: potassium,
    );
  }

  /// Open device health-data settings so user can grant permissions manually.
  /// Android: re-request via Health Connect dialog (always re-shows).
  /// iOS: open app settings where user can toggle Health access.
  static Future<void> openDeviceSettings() async {
    if (Platform.isAndroid) {
      await requestPermissions();
    } else {
      await openAppSettings();
    }
  }

  static MealType _mapMealType(app_enums.MealType? type) {
    switch (type) {
      case app_enums.MealType.breakfast:
        return MealType.BREAKFAST;
      case app_enums.MealType.lunch:
        return MealType.LUNCH;
      case app_enums.MealType.dinner:
        return MealType.DINNER;
      case app_enums.MealType.snack:
        return MealType.SNACK;
      default:
        return MealType.UNKNOWN;
    }
  }
}
