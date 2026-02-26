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

      return await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
    } catch (e) {
      AppLogger.error('Health permission request failed', e);
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

  /// Get today's estimated active energy (kcal).
  ///
  /// Strategy:
  /// 1. If ACTIVE_ENERGY_BURNED data exists → use it directly.
  /// 2. Otherwise fall back to TOTAL_CALORIES_BURNED minus BMR prorated
  ///    to the current time of day: `max(0, TCB - BMR × hoursElapsed / 24)`.
  static Future<double> getTodayActiveEnergy({double bmr = 1500}) async {
    final safeBmr = (bmr.isNaN || bmr.isInfinite || bmr <= 0) ? 1500.0 : bmr;
    try {
      _ensureConfigured();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        types: _readTypes,
        startTime: startOfDay,
        endTime: now,
      );

      final uniqueData = Health().removeDuplicates(data);

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
      if (active > 0) {
        result = active;
      } else if (total > 0) {
        final hoursElapsed =
            now.difference(startOfDay).inMinutes / 60.0;
        final bmrSoFar = safeBmr * hoursElapsed / 24.0;
        result = (total - bmrSoFar).clamp(0.0, double.infinity);
      } else {
        result = 0;
      }

      AppLogger.info(
          'Energy today — active: $active, total: $total, bmr: $safeBmr, result: ${result.toInt()} kcal');
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
