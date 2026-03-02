import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide JsonKey, Column;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../database/database_service.dart';
import '../database/model_extensions.dart';
import '../services/device_id_service.dart';
import '../services/energy_service.dart';

// ============================================================
// Data Models
// ============================================================

/// ประเภทไฟล์ Backup
enum BackupFileType {
  data,    // ข้อมูลอาหาร + meals (restore ได้เรื่อยๆ)
  energy,  // Transfer key + energy (ใช้ได้ครั้งเดียว, ห้ามเครื่องเดียวกัน)
  legacy,  // ไฟล์เก่าที่รวมทั้งสองอย่าง (backward compatible)
}

/// ข้อมูลที่แสดงใน Preview ก่อน Restore
class BackupInfo {
  final String appVersion;
  final int backupVersion;
  final DateTime createdAt;
  final String? deviceInfo;
  final int energyBalance;
  final int foodEntryCount;
  final int myMealCount;
  final bool hasTransferKey;
  final BackupFileType fileType;

  BackupInfo({
    required this.appVersion,
    required this.backupVersion,
    required this.createdAt,
    this.deviceInfo,
    required this.energyBalance,
    required this.foodEntryCount,
    required this.myMealCount,
    required this.hasTransferKey,
    required this.fileType,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    final type = _detectFileType(json);
    return BackupInfo(
      appVersion: json['appVersion'] ?? 'unknown',
      backupVersion: json['backupVersion'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      deviceInfo: json['deviceInfo'],
      energyBalance: json['energyBalance'] ?? 0,
      foodEntryCount: (json['foodEntries'] as List?)?.length ?? 0,
      myMealCount: (json['myMeals'] as List?)?.length ?? 0,
      hasTransferKey: json['transferKey'] != null,
      fileType: type,
    );
  }

  static BackupFileType _detectFileType(Map<String, dynamic> json) {
    final declaredType = json['backupType'] as String?;
    if (declaredType == 'data') return BackupFileType.data;
    if (declaredType == 'energy') return BackupFileType.energy;
    return BackupFileType.legacy;
  }
}

/// ผลลัพธ์ของ createBackup — มี 2 ไฟล์
class BackupFiles {
  final File dataFile;
  final File energyFile;

  BackupFiles({required this.dataFile, required this.energyFile});
}

/// ผลลัพธ์หลัง Restore
class BackupRestoreResult {
  final bool success;
  final int energyTransferred;
  final int newEnergyBalance;
  final int foodEntriesImported;
  final int myMealsImported;
  final bool settingsImported;
  final BackupFileType fileType;
  final String? errorMessage;

  BackupRestoreResult({
    required this.success,
    this.energyTransferred = 0,
    this.newEnergyBalance = 0,
    this.foodEntriesImported = 0,
    this.myMealsImported = 0,
    this.settingsImported = false,
    this.fileType = BackupFileType.legacy,
    this.errorMessage,
  });
}

// ============================================================
// Main Service
// ============================================================

class BackupService {
  // Singleton pattern
  BackupService._();
  static final BackupService instance = BackupService._();

  /// App version (อัปเดตตาม pubspec.yaml)
  static const String _appVersion = '1.1.3';
  static const int _backupVersion = 2;

  // ============================================================
  // 1. CREATE BACKUP
  // ============================================================

  /// สร้างไฟล์ Backup (2 ไฟล์: data + energy)
  static Future<BackupFiles> createBackup() async {
    try {
      debugPrint('[Backup] Starting backup...');
      
      final deviceId = await DeviceIdService.getDeviceId();
      debugPrint('[Backup] Device ID: $deviceId');

      debugPrint('[Backup] Calling generateTransferKey...');
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('generateTransferKey');
      
      final result = await callable.call({
        'deviceId': deviceId,
      });

      final transferKey = result.data['transferKey'] as String;
      final energyBalance = result.data['energyBalance'] as int;
      debugPrint('[Backup] Transfer Key generated, Energy: $energyBalance');

      debugPrint('[Backup] Loading local data...');

      final foodEntries = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
          .get();

      final myMeals = await DatabaseService.db.select(DatabaseService.db.myMeals).get();
      debugPrint('[Backup] Loaded ${foodEntries.length} food entries, ${myMeals.length} meals');

      final deviceInfo = await _getDeviceInfo();
      final energyService = EnergyService(DatabaseService.db);
      final miroId = await energyService.getMiroId();

      final now = DateTime.now();
      final dateStr = _formatDateForFilename(now);
      final createdAt = now.toUtc().toIso8601String();
      final directory = await getApplicationDocumentsDirectory();

      // ──────────────────────────────────────────────
      // 5A. สร้าง DATA FILE (restore ได้เรื่อยๆ)
      // ──────────────────────────────────────────────
      final dataBackup = {
        'backupType': 'data',
        'appVersion': _appVersion,
        'backupVersion': _backupVersion,
        'createdAt': createdAt,
        'deviceInfo': deviceInfo,
        'miroId': miroId,
        'foodEntries': foodEntries.map((entry) => {
          'foodName': entry.foodName,
          'foodNameEn': entry.foodNameEn,
          'timestamp': entry.timestamp.toUtc().toIso8601String(),
          'mealType': entry.mealType.name,
          'servingSize': entry.servingSize,
          'servingUnit': entry.servingUnit,
          'servingGrams': entry.servingGrams,
          'calories': entry.calories,
          'protein': entry.protein,
          'carbs': entry.carbs,
          'fat': entry.fat,
          'baseCalories': entry.baseCalories,
          'baseProtein': entry.baseProtein,
          'baseCarbs': entry.baseCarbs,
          'baseFat': entry.baseFat,
          'fiber': entry.fiber,
          'sugar': entry.sugar,
          'sodium': entry.sodium,
          'cholesterol': entry.cholesterol,
          'saturatedFat': entry.saturatedFat,
          'source': entry.source.name,
          'aiConfidence': entry.aiConfidence,
          'isVerified': entry.isVerified,
          'notes': entry.notes,
          'photoFileName': entry.imagePath?.split('/').last,
          'ingredientsJson': entry.ingredientsJson,
          'createdAt': entry.createdAt.toUtc().toIso8601String(),
          // Scene context
          if (entry.sceneContext != null) 'sceneContextJson': entry.sceneContext,
          // Group data
          if (entry.groupId != null) 'groupId': entry.groupId,
          if (entry.groupSource != null) 'groupSource': entry.groupSource,
          if (entry.groupOrder != null) 'groupOrder': entry.groupOrder,
          if (entry.isGroupOriginal) 'isGroupOriginal': true,
          // User input & correction tracking
          if (entry.userInputText != null) 'userInputText': entry.userInputText,
          if (entry.originalFoodName != null) 'originalFoodName': entry.originalFoodName,
          if (entry.originalCalories != null) 'originalCalories': entry.originalCalories,
          if (entry.originalProtein != null) 'originalProtein': entry.originalProtein,
          if (entry.originalCarbs != null) 'originalCarbs': entry.originalCarbs,
          if (entry.originalFat != null) 'originalFat': entry.originalFat,
          if (entry.originalIngredientsJson != null) 'originalIngredientsJson': entry.originalIngredientsJson,
          if (entry.editCount > 0) 'editCount': entry.editCount,
          if (entry.isUserCorrected) 'isUserCorrected': true,
          // Brand / product data
          if (entry.brandName != null) 'brandName': entry.brandName,
          if (entry.productName != null) 'productName': entry.productName,
          if (entry.productBarcode != null) 'productBarcode': entry.productBarcode,
          'searchMode': entry.searchMode.name,
        }).toList(),
        'myMeals': myMeals.map((meal) => {
          'name': meal.name,
          'nameEn': meal.nameEn,
          'totalCalories': meal.totalCalories,
          'totalProtein': meal.totalProtein,
          'totalCarbs': meal.totalCarbs,
          'totalFat': meal.totalFat,
          'baseServingDescription': meal.baseServingDescription,
          'source': meal.source,
          'usageCount': meal.usageCount,
          'createdAt': meal.createdAt.toUtc().toIso8601String(),
        }).toList(),
      };

      final dataFile = File('${directory.path}/miro_data_$dateStr.json');
      await dataFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(dataBackup),
      );
      debugPrint('[Backup] Data file created: ${dataFile.path}');

      // ──────────────────────────────────────────────
      // 5B. สร้าง ENERGY FILE (ใช้ได้ครั้งเดียว)
      // ──────────────────────────────────────────────
      final energyBackup = {
        'backupType': 'energy',
        'appVersion': _appVersion,
        'backupVersion': _backupVersion,
        'createdAt': createdAt,
        'deviceInfo': deviceInfo,
        'transferKey': transferKey,
        'energyBalance': energyBalance,
      };

      final energyFile = File('${directory.path}/miro_energy_$dateStr.json');
      await energyFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(energyBackup),
      );
      debugPrint('[Backup] Energy file created: ${energyFile.path}');

      return BackupFiles(dataFile: dataFile, energyFile: energyFile);

    } catch (e) {
      debugPrint('[Backup] Error: $e');
      
      String errorMessage = 'Failed to create backup: ';
      
      if (e.toString().contains('Rate limit exceeded')) {
        errorMessage += 'You have created too many backups. Please try again later (max 5 per hour).';
      } else if (e.toString().contains('Device not found')) {
        errorMessage += 'Device not registered. Please try using the app first.';
      } else if (e.toString().contains('network') || 
                 e.toString().contains('internet') ||
                 e.toString().contains('No host specified')) {
        errorMessage += 'No internet connection. Please check your connection and try again.';
      } else {
        errorMessage += e.toString();
      }
      
      throw Exception(errorMessage);
    }
  }

  /// แชร์ไฟล์ Backup (single file — backward compatible)
  static Future<void> shareBackupFile(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: 'Miro Backup',
        text: 'Backup your Energy + Food History. Keep this file safe!',
      );
    } catch (e) {
      throw Exception('Failed to share backup file: $e');
    }
  }

  /// แชร์ 2 ไฟล์ Backup พร้อมกัน (data + energy)
  static Future<void> shareBackupFiles(File dataFile, File energyFile) async {
    try {
      await Share.shareXFiles(
        [XFile(dataFile.path), XFile(energyFile.path)],
        subject: 'Miro Backup',
        text: 'Data file: restore your food history anytime.\n'
            'Energy file: transfer your energy to another device (one-time use).',
      );
    } catch (e) {
      throw Exception('Failed to share backup files: $e');
    }
  }

  /// บันทึกไฟล์ Backup ไปยังโฟลเดอร์ที่ผู้ใช้เลือก (SAF)
  static Future<String?> saveToUserDirectory(File backupFile) async {
    try {
      final bytes = await backupFile.readAsBytes();
      final fileName = backupFile.path.split(Platform.pathSeparator).last;

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputPath != null) {
        final savedFile = File(outputPath);
        if (!await savedFile.exists()) {
          await backupFile.copy(outputPath);
        }
        debugPrint('[Backup] Saved to user directory: $outputPath');
        return outputPath;
      }

      return null;
    } catch (e) {
      debugPrint('[Backup] Save to directory error: $e');
      throw Exception('Failed to save backup file: $e');
    }
  }

  // ============================================================
  // 2. RESTORE FROM BACKUP
  // ============================================================

  /// เลือกไฟล์ Backup
  static Future<File?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick backup file: $e');
    }
  }

  /// Validate ไฟล์ Backup และ Return ข้อมูล Preview
  static Future<BackupInfo?> validateBackupFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!jsonData.containsKey('backupVersion') ||
          !jsonData.containsKey('createdAt')) {
        throw Exception('Invalid backup file format');
      }

      final backupType = jsonData['backupType'] as String?;

      if (backupType != 'data' && !jsonData.containsKey('transferKey')) {
        throw Exception('Invalid backup file format');
      }

      final backupVersion = jsonData['backupVersion'] as int;
      if (backupVersion > _backupVersion) {
        throw Exception(
          'Backup file is from a newer app version. Please update the app.',
        );
      }

      return BackupInfo.fromJson(jsonData);
    } catch (e) {
      throw Exception('Invalid backup file: $e');
    }
  }

  /// Restore จากไฟล์ Backup
  static Future<BackupRestoreResult> restoreFromBackup(
    File file, {
    bool importSettings = false,
  }) async {
    try {
      debugPrint('[Restore] Starting restore from: ${file.path}');
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('[Restore] Backup file loaded successfully');

      final backupType = jsonData['backupType'] as String?;
      
      if (backupType == 'data') {
        return _restoreDataFile(jsonData, importSettings: importSettings);
      } else if (backupType == 'energy') {
        return _restoreEnergyFile(jsonData);
      } else {
        return _restoreLegacyFile(jsonData, importSettings: importSettings);
      }
    } catch (e) {
      debugPrint('[Restore] Error: $e');
      return BackupRestoreResult(
        success: false,
        errorMessage: _humanizeError(e.toString()),
      );
    }
  }

  /// Restore DATA file — food entries + meals
  static Future<BackupRestoreResult> _restoreDataFile(
    Map<String, dynamic> jsonData, {
    bool importSettings = false,
  }) async {
    debugPrint('[Restore] Type: DATA (no transfer key needed)');

    await _restoreMiroId(jsonData);

    final foodEntriesImported = await _importFoodEntries(
      jsonData['foodEntries'] as List<dynamic>? ?? [],
    );
    debugPrint('[Restore] Imported $foodEntriesImported food entries');

    final myMealsImported = await _importMyMeals(
      jsonData['myMeals'] as List<dynamic>? ?? [],
    );
    debugPrint('[Restore] Imported $myMealsImported my meals');

    bool settingsImported = false;
    if (importSettings && jsonData.containsKey('profile')) {
      await _importSettings(jsonData['profile'] as Map<String, dynamic>);
      settingsImported = true;
    }

    debugPrint('[Restore] Data restore completed!');
    return BackupRestoreResult(
      success: true,
      foodEntriesImported: foodEntriesImported,
      myMealsImported: myMealsImported,
      settingsImported: settingsImported,
      fileType: BackupFileType.data,
    );
  }

  /// Restore ENERGY file — transfer key + energy
  static Future<BackupRestoreResult> _restoreEnergyFile(
    Map<String, dynamic> jsonData,
  ) async {
    debugPrint('[Restore] Type: ENERGY (transfer key required)');

    try {
      final newDeviceId = await DeviceIdService.getDeviceId();
      final transferKey = jsonData['transferKey'] as String;
      
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('redeemTransferKey');
      
      final result = await callable.call({
        'transferKey': transferKey,
        'newDeviceId': newDeviceId,
      });

      final energyTransferred = result.data['energyTransferred'] as int;
      final newBalance = result.data['newBalance'] as int;
      debugPrint('[Restore] Energy transferred: $energyTransferred → New balance: $newBalance');

      return BackupRestoreResult(
        success: true,
        energyTransferred: energyTransferred,
        newEnergyBalance: newBalance,
        fileType: BackupFileType.energy,
      );
    } catch (e) {
      return BackupRestoreResult(
        success: false,
        errorMessage: _humanizeError(e.toString()),
        fileType: BackupFileType.energy,
      );
    }
  }

  /// Restore LEGACY file — ทำทั้ง energy + data (backward compatible)
  static Future<BackupRestoreResult> _restoreLegacyFile(
    Map<String, dynamic> jsonData, {
    bool importSettings = false,
  }) async {
    debugPrint('[Restore] Type: LEGACY (combined file)');

    final newDeviceId = await DeviceIdService.getDeviceId();
    final transferKey = jsonData['transferKey'] as String;
    
    final callable = FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).httpsCallable('redeemTransferKey');
    
    final result = await callable.call({
      'transferKey': transferKey,
      'newDeviceId': newDeviceId,
    });

    final energyTransferred = result.data['energyTransferred'] as int;
    final newBalance = result.data['newBalance'] as int;
    debugPrint('[Restore] Energy transferred: $energyTransferred → New balance: $newBalance');

    await _restoreMiroId(jsonData);

    final foodEntriesImported = await _importFoodEntries(
      jsonData['foodEntries'] as List<dynamic>? ?? [],
    );
    debugPrint('[Restore] Imported $foodEntriesImported food entries');

    final myMealsImported = await _importMyMeals(
      jsonData['myMeals'] as List<dynamic>? ?? [],
    );
    debugPrint('[Restore] Imported $myMealsImported my meals');

    bool settingsImported = false;
    if (importSettings && jsonData.containsKey('profile')) {
      await _importSettings(jsonData['profile'] as Map<String, dynamic>);
      settingsImported = true;
    }

    debugPrint('[Restore] Legacy restore completed!');
    return BackupRestoreResult(
      success: true,
      energyTransferred: energyTransferred,
      newEnergyBalance: newBalance,
      foodEntriesImported: foodEntriesImported,
      myMealsImported: myMealsImported,
      settingsImported: settingsImported,
      fileType: BackupFileType.legacy,
    );
  }

  /// Restore MiRO ID จาก backup data (ถ้ามี)
  static Future<void> _restoreMiroId(Map<String, dynamic> jsonData) async {
    final miroId = jsonData['miroId'] as String?;
    if (miroId != null && miroId.isNotEmpty) {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
      await storage.write(key: 'miro_id', value: miroId);
      debugPrint('[Restore] MiRO ID restored: $miroId');
    }
  }

  /// แปลง error message ให้เข้าใจง่าย
  static String _humanizeError(String errorMessage) {
    if (errorMessage.contains('Cannot transfer to the same device')) {
      return 'Cannot restore on the same device. Please use a different device to restore this backup.';
    } else if (errorMessage.contains('Transfer key has already been redeemed')) {
      return 'This Transfer Key has already been used. Each key can only be used once.';
    } else if (errorMessage.contains('Transfer key has expired')) {
      return 'This Transfer Key has expired (valid for 30 days). Please create a new backup.';
    } else if (errorMessage.contains('Transfer key not found')) {
      return 'Invalid Transfer Key. Please check your backup file.';
    } else if (errorMessage.contains('Rate limit exceeded')) {
      return 'You have created too many backups. Please try again later (max 5 per hour).';
    } else if (errorMessage.contains('Failed to redeem transfer key') || 
               errorMessage.contains('No host specified') ||
               errorMessage.contains('network') ||
               errorMessage.contains('internet')) {
      return 'No internet connection. Please check your connection and try again.';
    }
    return errorMessage;
  }

  // ============================================================
  // 3. IMPORT HELPERS
  // ============================================================

  /// Import Food Entries (Merge — ไม่ลบของเดิม)
  static Future<int> _importFoodEntries(List<dynamic> entries) async {
    if (entries.isEmpty) return 0;

    int importedCount = 0;
    int failedCount = 0;

    for (var i = 0; i < entries.length; i++) {
      final entryJson = entries[i];
      try {
        final foodName = entryJson['foodName'] as String?;
        final timestampStr = entryJson['timestamp'] as String?;
        if (foodName == null || foodName.isEmpty || timestampStr == null) {
          debugPrint('[Restore] Skip entry $i: missing foodName or timestamp');
          failedCount++;
          continue;
        }
        final timestamp = DateTime.parse(timestampStr);

        final existingEntry = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
          ..where((tbl) =>
              tbl.foodName.equals(foodName) &
              tbl.timestamp.equals(timestamp))
          ..limit(1))
            .getSingleOrNull();

        if (existingEntry != null) continue;

        final now = DateTime.now();
        final newEntry = FoodEntry(
          id: 0,
          foodName: foodName,
          foodNameEn: entryJson['foodNameEn'] as String?,
          timestamp: timestamp,
          mealType: MealType.values.firstWhere(
            (e) => e.name == (entryJson['mealType'] as String?),
            orElse: () => MealType.breakfast,
          ),
          servingSize: ((entryJson['servingSize'] as num?) ?? 1).toDouble(),
          servingUnit: entryJson['servingUnit'] as String? ?? 'serving',
          servingGrams: (entryJson['servingGrams'] as num?)?.toDouble(),
          calories: ((entryJson['calories'] as num?) ?? 0).toDouble(),
          protein: ((entryJson['protein'] as num?) ?? 0).toDouble(),
          carbs: ((entryJson['carbs'] as num?) ?? 0).toDouble(),
          fat: ((entryJson['fat'] as num?) ?? 0).toDouble(),
          baseCalories: ((entryJson['baseCalories'] as num?) ?? 0).toDouble(),
          baseProtein: ((entryJson['baseProtein'] as num?) ?? 0).toDouble(),
          baseCarbs: ((entryJson['baseCarbs'] as num?) ?? 0).toDouble(),
          baseFat: ((entryJson['baseFat'] as num?) ?? 0).toDouble(),
          fiber: (entryJson['fiber'] as num?)?.toDouble(),
          sugar: (entryJson['sugar'] as num?)?.toDouble(),
          sodium: (entryJson['sodium'] as num?)?.toDouble(),
          cholesterol: (entryJson['cholesterol'] as num?)?.toDouble(),
          saturatedFat: (entryJson['saturatedFat'] as num?)?.toDouble(),
          source: DataSource.values.firstWhere(
            (e) => e.name == entryJson['source'],
            orElse: () => DataSource.manual,
          ),
          aiConfidence: (entryJson['aiConfidence'] as num?)?.toDouble(),
          isVerified: entryJson['isVerified'] ?? false,
          isDeleted: false,
          notes: entryJson['notes'] as String?,
          ingredientsJson: entryJson['ingredientsJson'] as String?,
          searchMode: entryJson['searchMode'] != null
              ? FoodSearchMode.values.firstWhere(
                  (e) => e.name == entryJson['searchMode'],
                  orElse: () => FoodSearchMode.normal,
                )
              : FoodSearchMode.normal,
          sceneContext: entryJson['sceneContextJson'] as String?,
          groupId: entryJson['groupId'] as String?,
          groupSource: entryJson['groupSource'] as String?,
          groupOrder: entryJson['groupOrder'] as int?,
          isGroupOriginal: entryJson['isGroupOriginal'] as bool? ?? false,
          userInputText: entryJson['userInputText'] as String?,
          originalFoodName: entryJson['originalFoodName'] as String?,
          originalCalories: (entryJson['originalCalories'] as num?)?.toDouble(),
          originalProtein: (entryJson['originalProtein'] as num?)?.toDouble(),
          originalCarbs: (entryJson['originalCarbs'] as num?)?.toDouble(),
          originalFat: (entryJson['originalFat'] as num?)?.toDouble(),
          originalIngredientsJson: entryJson['originalIngredientsJson'] as String?,
          editCount: entryJson['editCount'] as int? ?? 0,
          isUserCorrected: entryJson['isUserCorrected'] as bool? ?? false,
          brandName: entryJson['brandName'] as String?,
          productName: entryJson['productName'] as String?,
          productBarcode: entryJson['productBarcode'] as String?,
          isSynced: false,
          isCalibrated: false,
          imagePath: null,
          createdAt: entryJson['createdAt'] != null
              ? DateTime.parse(entryJson['createdAt'])
              : now,
          updatedAt: now,
        );

        await DatabaseService.db
            .into(DatabaseService.db.foodEntries)
            .insertOnConflictUpdate(newEntry);

        importedCount++;
      } catch (e) {
        failedCount++;
        debugPrint('[Restore] Error importing food entry $i: $e');
      }
    }

    if (failedCount > 0) {
      debugPrint('[Restore] Failed to import $failedCount of ${entries.length} entries');
    }
    return importedCount;
  }

  /// Import My Meals (Merge — ไม่ลบของเดิม)
  static Future<int> _importMyMeals(List<dynamic> meals) async {
    if (meals.isEmpty) return 0;

    int importedCount = 0;

    for (final mealJson in meals) {
      try {
        final name = mealJson['name'] as String;

        final existingMeal = await (DatabaseService.db.select(DatabaseService.db.myMeals)
          ..where((tbl) => tbl.name.equals(name))
          ..limit(1))
            .getSingleOrNull();

        if (existingMeal != null) continue;

        final now = DateTime.now();
        final newMeal = MyMeal(
          id: 0,
          name: name,
          nameEn: mealJson['nameEn'] as String?,
          totalCalories: ((mealJson['totalCalories'] as num?) ?? 0).toDouble(),
          totalProtein: ((mealJson['totalProtein'] as num?) ?? 0).toDouble(),
          totalCarbs: ((mealJson['totalCarbs'] as num?) ?? 0).toDouble(),
          totalFat: ((mealJson['totalFat'] as num?) ?? 0).toDouble(),
          baseServingDescription: mealJson['baseServingDescription'] as String? ?? '',
          source: mealJson['source'] as String? ?? 'manual',
          usageCount: mealJson['usageCount'] ?? 0,
          createdAt: mealJson['createdAt'] != null
              ? DateTime.parse(mealJson['createdAt'])
              : now,
          updatedAt: now,
        );

        await DatabaseService.db
            .into(DatabaseService.db.myMeals)
            .insertOnConflictUpdate(newMeal);

        importedCount++;
      } catch (e) {
        debugPrint('Error importing my meal: $e');
      }
    }

    return importedCount;
  }

  /// Import Settings (Profile)
  static Future<void> _importSettings(Map<String, dynamic> profile) async {
    debugPrint('Settings import not implemented yet');
  }

  // ============================================================
  // 4. UTILITIES
  // ============================================================

  /// ดึงข้อมูลเครื่อง
  static Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.systemVersion})';
      }
      
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Format วันที่สำหรับชื่อไฟล์
  static String _formatDateForFilename(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
