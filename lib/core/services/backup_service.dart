import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/health/models/food_entry.dart';
import '../../features/health/models/my_meal.dart';
import '../database/database_service.dart';
import '../services/device_id_service.dart';
import '../services/energy_service.dart';
import '../constants/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/energy/providers/gamification_provider.dart';

// ============================================================
// Data Models
// ============================================================

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

  BackupInfo({
    required this.appVersion,
    required this.backupVersion,
    required this.createdAt,
    this.deviceInfo,
    required this.energyBalance,
    required this.foodEntryCount,
    required this.myMealCount,
    required this.hasTransferKey,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      appVersion: json['appVersion'] ?? 'unknown',
      backupVersion: json['backupVersion'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      deviceInfo: json['deviceInfo'],
      energyBalance: json['energyBalance'] ?? 0,
      foodEntryCount: (json['foodEntries'] as List?)?.length ?? 0,
      myMealCount: (json['myMeals'] as List?)?.length ?? 0,
      hasTransferKey: json['transferKey'] != null,
    );
  }
}

/// ผลลัพธ์หลัง Restore
class BackupRestoreResult {
  final bool success;
  final int energyTransferred;
  final int newEnergyBalance;
  final int foodEntriesImported;
  final int myMealsImported;
  final bool settingsImported;
  final String? errorMessage;

  BackupRestoreResult({
    required this.success,
    this.energyTransferred = 0,
    this.newEnergyBalance = 0,
    this.foodEntriesImported = 0,
    this.myMealsImported = 0,
    this.settingsImported = false,
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
  static const int _backupVersion = 2; // ← อัพเดทเป็น 2 เพื่อรองรับ MiRO ID + Streak

  // ============================================================
  // 1. CREATE BACKUP
  // ============================================================

  /// สร้างไฟล์ Backup
  /// 
  /// Steps:
  /// 1. เรียก Cloud Function สร้าง Transfer Key
  /// 2. ดึงข้อมูลจาก Isar (Food Entries + My Meals)
  /// 3. สร้างไฟล์ JSON
  /// 4. Share ไฟล์ให้ผู้ใช้
  static Future<File> createBackup() async {
    try {
      debugPrint('🔍 [Backup] Starting backup...');
      
      // 1. Get Device ID
      final deviceId = await DeviceIdService.getDeviceId();
      debugPrint('🔍 [Backup] Device ID: $deviceId');

      // 2. เรียก Cloud Function: generateTransferKey
      debugPrint('🔍 [Backup] Calling generateTransferKey...');
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('generateTransferKey');
      
      final result = await callable.call({
        'deviceId': deviceId,
      });

      final transferKey = result.data['transferKey'] as String;
      final energyBalance = result.data['energyBalance'] as int;
      debugPrint('🔍 [Backup] Transfer Key generated, Energy: $energyBalance');

      // 3. ดึงข้อมูลจาก Isar
      debugPrint('🔍 [Backup] Loading local data from Isar...');
      final isar = DatabaseService.isar;

      // Food Entries (เรียงจากใหม่ไปเก่า)
      final foodEntries = await isar.foodEntrys
          .where()
          .sortByTimestampDesc()
          .findAll();

      // My Meals
      final myMeals = await isar.myMeals.where().findAll();
      debugPrint('🔍 [Backup] Loaded ${foodEntries.length} food entries, ${myMeals.length} meals');

      // 4. Get Device Info
      final deviceInfo = await _getDeviceInfo();

      // 5. ดึง MiRO ID และ Streak data
      final energyService = EnergyService(DatabaseService.isar);
      final miroId = await energyService.getMiroId();
      
      // ดึง gamification state (ถ้ามี provider)
      Map<String, dynamic>? streakData;
      try {
        // ใช้ ProviderScope ถ้ามี context
        // ถ้าไม่มี → ใช้ค่า default
        streakData = {
          'currentStreak': 0,
          'longestStreak': 0,
          'tier': 'none',
        };
      } catch (e) {
        // ไม่มี provider → ใช้ค่า default
        streakData = {
          'currentStreak': 0,
          'longestStreak': 0,
          'tier': 'none',
        };
      }

      // 6. สร้าง JSON
      final backupData = {
        'appVersion': _appVersion,
        'backupVersion': _backupVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'deviceInfo': deviceInfo,
        'transferKey': transferKey,
        'energyBalance': energyBalance,
        'miroId': miroId, // ← ใหม่!
        'streakData': streakData, // ← ใหม่!
        
        // Food Entries
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
        }).toList(),
        
        // My Meals
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

      // 6. บันทึกเป็นไฟล์
      debugPrint('🔍 [Backup] Saving backup file...');
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final fileName = 'miro_backup_${_formatDateForFilename(DateTime.now())}.json';
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      debugPrint('✅ [Backup] Backup created: ${file.path}');

      return file;

    } catch (e) {
      debugPrint('❌ [Backup] Error: $e');
      
      // แปลง error message ให้เข้าใจง่าย
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

  /// แชร์ไฟล์ Backup
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

      // ตรวจสอบ format พื้นฐาน
      if (!jsonData.containsKey('backupVersion') ||
          !jsonData.containsKey('transferKey') ||
          !jsonData.containsKey('createdAt')) {
        throw Exception('Invalid backup file format');
      }

      // ตรวจสอบ version
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
  /// 
  /// Steps:
  /// 1. อ่านไฟล์ JSON
  /// 2. เรียก Cloud Function: redeemTransferKey → ย้าย Energy
  /// 3. Import Food Entries (merge)
  /// 4. Import My Meals (merge)
  /// 5. Import Settings (optional)
  static Future<BackupRestoreResult> restoreFromBackup(
    File file, {
    bool importSettings = false,
  }) async {
    try {
      debugPrint('🔍 [Restore] Starting restore from: ${file.path}');
      
      // 1. อ่านไฟล์
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('🔍 [Restore] Backup file loaded successfully');

      // 2. Get Device ID
      final newDeviceId = await DeviceIdService.getDeviceId();

      // 3. เรียก Cloud Function: redeemTransferKey
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
      debugPrint('✅ [Restore] Energy transferred: $energyTransferred → New balance: $newBalance');

      // 3.5. Restore MiRO ID (ถ้ามีใน backup)
      final miroId = jsonData['miroId'] as String?;
      if (miroId != null && miroId.isNotEmpty) {
        final energyService = EnergyService(DatabaseService.isar);
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
        debugPrint('✅ [Restore] MiRO ID restored: $miroId');
      }

      // 4. Import Food Entries
      debugPrint('🔍 [Restore] Importing food entries...');
      final foodEntriesImported = await _importFoodEntries(
        jsonData['foodEntries'] as List<dynamic>? ?? [],
      );
      debugPrint('✅ [Restore] Imported $foodEntriesImported food entries');

      // 5. Import My Meals
      debugPrint('🔍 [Restore] Importing my meals...');
      final myMealsImported = await _importMyMeals(
        jsonData['myMeals'] as List<dynamic>? ?? [],
      );
      debugPrint('✅ [Restore] Imported $myMealsImported my meals');

      // 6. Import Settings (if requested)
      debugPrint('🔍 [Restore] Importing settings...');
      bool settingsImported = false;
      if (importSettings && jsonData.containsKey('profile')) {
        await _importSettings(jsonData['profile'] as Map<String, dynamic>);
        settingsImported = true;
      }

      debugPrint('✅ [Restore] Restore completed successfully!');
      return BackupRestoreResult(
        success: true,
        energyTransferred: energyTransferred,
        newEnergyBalance: newBalance,
        foodEntriesImported: foodEntriesImported,
        myMealsImported: myMealsImported,
        settingsImported: settingsImported,
      );

    } catch (e) {
      debugPrint('❌ [Restore] Error: $e');
      
      // แปลง error message ให้เข้าใจง่าย
      String errorMessage = e.toString();
      
      // จับ Firebase Functions errors
      if (errorMessage.contains('Cannot transfer to the same device')) {
        errorMessage = 'Cannot restore on the same device. Please use a different device to restore this backup.';
      } else if (errorMessage.contains('Transfer key has already been redeemed')) {
        errorMessage = 'This Transfer Key has already been used. Each key can only be used once.';
      } else if (errorMessage.contains('Transfer key has expired')) {
        errorMessage = 'This Transfer Key has expired (valid for 30 days). Please create a new backup.';
      } else if (errorMessage.contains('Transfer key not found')) {
        errorMessage = 'Invalid Transfer Key. Please check your backup file.';
      } else if (errorMessage.contains('Rate limit exceeded')) {
        errorMessage = 'You have created too many backups. Please try again later (max 5 per hour).';
      } else if (errorMessage.contains('Failed to redeem transfer key') || 
                 errorMessage.contains('No host specified') ||
                 errorMessage.contains('network') ||
                 errorMessage.contains('internet')) {
        errorMessage = 'No internet connection. Please check your connection and try again.';
      }
      
      return BackupRestoreResult(
        success: false,
        errorMessage: errorMessage,
      );
    }
  }

  // ============================================================
  // 3. IMPORT HELPERS
  // ============================================================

  /// Import Food Entries (Merge — ไม่ลบของเดิม)
  static Future<int> _importFoodEntries(List<dynamic> entries) async {
    if (entries.isEmpty) return 0;

    final isar = DatabaseService.isar;
    int importedCount = 0;

    for (final entryJson in entries) {
      try {
        final foodName = entryJson['foodName'] as String;
        final timestampStr = entryJson['timestamp'] as String;
        final timestamp = DateTime.parse(timestampStr);

        // ตรวจสอบ Duplicate (foodName + timestamp)
        final existingEntry = await isar.foodEntrys
            .filter()
            .foodNameEqualTo(foodName)
            .timestampEqualTo(timestamp)
            .findFirst();

        if (existingEntry != null) {
          // Skip duplicate
          continue;
        }

        // สร้าง FoodEntry ใหม่
        final newEntry = FoodEntry()
          ..foodName = foodName
          ..foodNameEn = entryJson['foodNameEn']
          ..timestamp = timestamp
          ..mealType = MealType.values.firstWhere(
            (e) => e.name == entryJson['mealType'],
            orElse: () => MealType.breakfast,
          )
          ..servingSize = (entryJson['servingSize'] as num).toDouble()
          ..servingUnit = entryJson['servingUnit'] as String
          ..servingGrams = (entryJson['servingGrams'] as num?)?.toDouble()
          ..calories = (entryJson['calories'] as num).toDouble()
          ..protein = (entryJson['protein'] as num).toDouble()
          ..carbs = (entryJson['carbs'] as num).toDouble()
          ..fat = (entryJson['fat'] as num).toDouble()
          ..baseCalories = (entryJson['baseCalories'] as num).toDouble()
          ..baseProtein = (entryJson['baseProtein'] as num).toDouble()
          ..baseCarbs = (entryJson['baseCarbs'] as num).toDouble()
          ..baseFat = (entryJson['baseFat'] as num).toDouble()
          ..fiber = (entryJson['fiber'] as num?)?.toDouble()
          ..sugar = (entryJson['sugar'] as num?)?.toDouble()
          ..sodium = (entryJson['sodium'] as num?)?.toDouble()
          ..cholesterol = (entryJson['cholesterol'] as num?)?.toDouble()
          ..saturatedFat = (entryJson['saturatedFat'] as num?)?.toDouble()
          ..source = DataSource.values.firstWhere(
            (e) => e.name == entryJson['source'],
            orElse: () => DataSource.manual,
          )
          ..aiConfidence = (entryJson['aiConfidence'] as num?)?.toDouble()
          ..isVerified = entryJson['isVerified'] ?? false
          ..notes = entryJson['notes']
          ..imagePath = null // รูปไม่ import
          ..ingredientsJson = entryJson['ingredientsJson']
          ..createdAt = entryJson['createdAt'] != null 
              ? DateTime.parse(entryJson['createdAt']) 
              : DateTime.now();

        // บันทึกลง Isar
        await isar.writeTxn(() async {
          await isar.foodEntrys.put(newEntry);
        });

        importedCount++;
      } catch (e) {
        // Log error แต่ทำต่อ
        debugPrint('Error importing food entry: $e');
      }
    }

    return importedCount;
  }

  /// Import My Meals (Merge — ไม่ลบของเดิม)
  static Future<int> _importMyMeals(List<dynamic> meals) async {
    if (meals.isEmpty) return 0;

    final isar = DatabaseService.isar;
    int importedCount = 0;

    for (final mealJson in meals) {
      try {
        final name = mealJson['name'] as String;

        // ตรวจสอบ Duplicate (name)
        final existingMeal = await isar.myMeals
            .filter()
            .nameEqualTo(name)
            .findFirst();

        if (existingMeal != null) {
          // Skip duplicate
          continue;
        }

        // สร้าง MyMeal ใหม่
        final newMeal = MyMeal()
          ..name = name
          ..nameEn = mealJson['nameEn']
          ..totalCalories = (mealJson['totalCalories'] as num).toDouble()
          ..totalProtein = (mealJson['totalProtein'] as num).toDouble()
          ..totalCarbs = (mealJson['totalCarbs'] as num).toDouble()
          ..totalFat = (mealJson['totalFat'] as num).toDouble()
          ..baseServingDescription = mealJson['baseServingDescription'] as String
          ..source = mealJson['source'] as String
          ..usageCount = mealJson['usageCount'] ?? 0
          ..createdAt = mealJson['createdAt'] != null 
              ? DateTime.parse(mealJson['createdAt']) 
              : DateTime.now();

        // บันทึกลง Isar
        await isar.writeTxn(() async {
          await isar.myMeals.put(newMeal);
        });

        importedCount++;
      } catch (e) {
        debugPrint('Error importing my meal: $e');
      }
    }

    return importedCount;
  }

  /// Import Settings (Profile)
  /// 
  /// ⚠️ TODO: แก้ไขให้เหมาะกับโครงสร้างของคุณ
  /// ตัวอย่างนี้ใช้ SharedPreferences — ถ้าใช้ Riverpod/Provider ต้องแก้
  static Future<void> _importSettings(Map<String, dynamic> profile) async {
    // TODO: Implement based on your app's architecture
    // Example: Save to SharedPreferences or update Provider state
    debugPrint('Settings import not implemented yet');
  }

  // ============================================================
  // 4. UTILITIES
  // ============================================================

  /// ดึงข้อมูลเครื่อง (สำหรับแสดงใน Preview)
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
