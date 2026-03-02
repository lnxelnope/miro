import 'package:drift/drift.dart';

import '../database/database_service.dart';
import '../database/model_extensions.dart';
import 'health_sync_service.dart';
import '../utils/logger.dart';

/// Snapshots daily energy balance every time a food entry is saved.
///
/// Stores only derived values (netEnergy) — never raw Health Connect data.
/// This avoids violating Apple HealthKit / Google Health Connect policies
/// while still capturing valuable energy balance data.
class DailySummaryService {
  /// Update today's DailySummary. Called on every food add/update/delete.
  static Future<void> snapshotToday() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayEnd = today.add(const Duration(days: 1));

      final entries = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
        ..where((tbl) =>
            tbl.isDeleted.equals(false) &
            tbl.timestamp.isBiggerOrEqualValue(today) &
            tbl.timestamp.isSmallerThanValue(todayEnd)))
          .get();

      double totalCal = 0, totalProt = 0, totalCarb = 0, totalFat = 0;
      int corrections = 0;
      for (final e in entries) {
        totalCal += e.calories;
        totalProt += e.protein;
        totalCarb += e.carbs;
        totalFat += e.fat;
        if (e.isUserCorrected) corrections++;
      }

      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
        ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      final tdee = (profile?.tdee ?? 0) > 0
          ? profile!.tdee
          : profile?.calorieGoal.toDouble() ?? 2000;
      final goal = profile?.calorieGoal.toDouble() ?? 2000;
      final bmr = profile?.safeBmr ?? 1500;

      double activeBurn = 0;
      if (profile?.isHealthConnectConnected == true) {
        try {
          activeBurn = await HealthSyncService.getTodayActiveEnergy(bmr: bmr);
          if (activeBurn.isNaN || activeBurn.isInfinite) activeBurn = 0;
        } catch (_) {}
      }

      final netEnergy = totalCal - tdee - activeBurn;

      final deficit = tdee - bmr;
      String zone;
      if (netEnergy > 0) {
        zone = 'surplus';
      } else if (netEnergy >= -deficit * 0.3) {
        zone = 'maintain';
      } else if (netEnergy >= -deficit * 0.8) {
        zone = 'sweet_spot';
      } else if (netEnergy >= -bmr) {
        zone = 'careful';
      } else {
        zone = 'danger';
      }

      // Check if a summary for today already exists
      final existing = await (DatabaseService.db.select(DatabaseService.db.dailySummaries)
        ..where((tbl) => tbl.date.equals(today)))
          .getSingleOrNull();

      final summary = existing ?? DailySummary(
        id: 0,
        date: today,
        caloriesEaten: 0,
        proteinEaten: 0,
        carbsEaten: 0,
        fatEaten: 0,
        tdee: 0,
        netEnergy: 0,
        deficitZone: 'maintain',
        entryCount: 0,
        correctionCount: 0,
        calorieGoal: 0,
        createdAt: now,
        updatedAt: now,
      );

      summary.caloriesEaten = totalCal;
      summary.proteinEaten = totalProt;
      summary.carbsEaten = totalCarb;
      summary.fatEaten = totalFat;
      summary.tdee = tdee;
      summary.netEnergy = netEnergy;
      summary.deficitZone = zone;
      summary.entryCount = entries.length;
      summary.correctionCount = corrections;
      summary.calorieGoal = goal;
      summary.updatedAt = DateTime.now();

      await DatabaseService.db
          .into(DatabaseService.db.dailySummaries)
          .insertOnConflictUpdate(summary);

      AppLogger.info(
        '[DailySummary] ${today.toIso8601String().substring(0, 10)}: '
        'eaten=${totalCal.toInt()}, tdee=${tdee.toInt()}, '
        'net=${netEnergy.toInt()}, zone=$zone, entries=${entries.length}',
      );
    } catch (e) {
      AppLogger.warn('[DailySummary] Snapshot failed (non-fatal)', e);
    }
  }
}
