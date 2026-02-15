# 02: Client Service (BackupService)

> ⏱ **เวลา:** 3-4 ชั่วโมง  
> 🎯 **เป้าหมาย:** สร้าง BackupService สำหรับ Backup/Restore ข้อมูล

---

## 📂 ไฟล์ที่จะสร้าง

```
lib/
└── core/
    └── services/
        └── backup_service.dart  ← สร้างใหม่
```

---

## ขั้นตอนที่ 1: ติดตั้ง Dependencies

### 1.1 เปิดไฟล์ `pubspec.yaml`

### 1.2 เพิ่ม dependencies เหล่านี้ (ถ้ายังไม่มี)

```yaml
dependencies:
  # ... dependencies อื่น ๆ ที่มีอยู่แล้ว ...
  
  # สำหรับเลือกไฟล์
  file_picker: ^8.0.0
  
  # สำหรับ share ไฟล์ (มีอยู่แล้ว แต่ตรวจสอบอีกครั้ง)
  share_plus: ^12.0.1
  
  # สำหรับเข้าถึง path (มีอยู่แล้ว)
  path_provider: ^2.1.1
```

### 1.3 รัน Flutter Pub Get

```bash
flutter pub get
```

---

## ขั้นตอนที่ 2: สร้างไฟล์ `backup_service.dart`

### 2.1 สร้างไฟล์ใหม่

```bash
# Windows (PowerShell)
New-Item -Path "lib\core\services\backup_service.dart" -ItemType File -Force

# macOS/Linux
mkdir -p lib/core/services
touch lib/core/services/backup_service.dart
```

### 2.2 เปิดไฟล์ `lib/core/services/backup_service.dart`

### 2.3 คัดลอกโค้ดนี้ทั้งหมด

```dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../features/food/data/models/food_entry.dart';
import '../../features/food/data/models/my_meal.dart';
import '../database/isar_service.dart';
import '../utils/device_id.dart';

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
  static const int _backupVersion = 1;

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
      // 1. Get Device ID
      final deviceId = await DeviceId.getDeviceId();

      // 2. เรียก Cloud Function: generateTransferKey
      final result = await FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('generateTransferKey').call({
        'deviceId': deviceId,
      });

      final transferKey = result.data['transferKey'] as String;
      final energyBalance = result.data['energyBalance'] as int;

      // 3. ดึงข้อมูลจาก Isar
      final isar = IsarService.instance.isar;

      // Food Entries (เรียงจากใหม่ไปเก่า)
      final foodEntries = await isar.foodEntrys
          .where()
          .sortByTimestampDesc()
          .findAll();

      // My Meals
      final myMeals = await isar.myMeals.where().findAll();

      // 4. Get Device Info
      final deviceInfo = await _getDeviceInfo();

      // 5. สร้าง JSON
      final backupData = {
        'appVersion': _appVersion,
        'backupVersion': _backupVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'deviceInfo': deviceInfo,
        'transferKey': transferKey,
        'energyBalance': energyBalance,
        
        // Food Entries
        'foodEntries': foodEntries.map((entry) => {
          'foodName': entry.foodName,
          'foodNameEn': entry.foodNameEn,
          'timestamp': entry.timestamp.toUtc().toIso8601String(),
          'mealType': entry.mealType,
          'servingSize': entry.servingSize,
          'servingUnit': entry.servingUnit,
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
          'source': entry.source,
          'aiConfidence': entry.aiConfidence,
          'isVerified': entry.isVerified,
          'notes': entry.notes,
          'photoFileName': entry.photoPath != null 
              ? entry.photoPath!.split('/').last 
              : null,
          'ingredientsJson': entry.ingredientsJson,
          'createdAt': entry.createdAt?.toUtc().toIso8601String(),
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
          'createdAt': meal.createdAt?.toUtc().toIso8601String(),
        }).toList(),
      };

      // 6. บันทึกเป็นไฟล์
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final fileName = 'miro_backup_${_formatDateForFilename(DateTime.now())}.json';
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file;

    } catch (e) {
      throw Exception('Failed to create backup: $e');
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
      // 1. อ่านไฟล์
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 2. Get Device ID
      final newDeviceId = await DeviceId.getDeviceId();

      // 3. เรียก Cloud Function: redeemTransferKey
      final transferKey = jsonData['transferKey'] as String;
      
      final result = await FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('redeemTransferKey').call({
        'transferKey': transferKey,
        'newDeviceId': newDeviceId,
      });

      final energyTransferred = result.data['energyTransferred'] as int;
      final newBalance = result.data['newBalance'] as int;

      // 4. Import Food Entries
      final foodEntriesImported = await _importFoodEntries(
        jsonData['foodEntries'] as List<dynamic>,
      );

      // 5. Import My Meals
      final myMealsImported = await _importMyMeals(
        jsonData['myMeals'] as List<dynamic>,
      );

      // 6. Import Settings (if requested)
      bool settingsImported = false;
      if (importSettings && jsonData.containsKey('profile')) {
        await _importSettings(jsonData['profile'] as Map<String, dynamic>);
        settingsImported = true;
      }

      return BackupRestoreResult(
        success: true,
        energyTransferred: energyTransferred,
        newEnergyBalance: newBalance,
        foodEntriesImported: foodEntriesImported,
        myMealsImported: myMealsImported,
        settingsImported: settingsImported,
      );

    } catch (e) {
      return BackupRestoreResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // 3. IMPORT HELPERS
  // ============================================================

  /// Import Food Entries (Merge — ไม่ลบของเดิม)
  static Future<int> _importFoodEntries(List<dynamic> entries) async {
    if (entries.isEmpty) return 0;

    final isar = IsarService.instance.isar;
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
          ..mealType = entryJson['mealType']
          ..servingSize = (entryJson['servingSize'] as num).toDouble()
          ..servingUnit = entryJson['servingUnit']
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
          ..source = entryJson['source']
          ..aiConfidence = (entryJson['aiConfidence'] as num?)?.toDouble()
          ..isVerified = entryJson['isVerified'] ?? false
          ..notes = entryJson['notes']
          ..photoPath = null // รูปไม่ import
          ..ingredientsJson = entryJson['ingredientsJson']
          ..createdAt = entryJson['createdAt'] != null 
              ? DateTime.parse(entryJson['createdAt']) 
              : null;

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

    final isar = IsarService.instance.isar;
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
          ..baseServingDescription = mealJson['baseServingDescription']
          ..source = mealJson['source']
          ..usageCount = mealJson['usageCount'] ?? 0
          ..createdAt = mealJson['createdAt'] != null 
              ? DateTime.parse(mealJson['createdAt']) 
              : null;

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
```

### 2.4 บันทึกไฟล์

---

## ขั้นตอนที่ 3: ตรวจสอบ Import Statements

### 3.1 ตรวจสอบว่าไฟล์เหล่านี้มีอยู่

- `../../features/food/data/models/food_entry.dart`
- `../../features/food/data/models/my_meal.dart`
- `../database/isar_service.dart`
- `../utils/device_id.dart`

### 3.2 ถ้าไฟล์ไหนไม่มี → แก้ path ให้ตรงกับโครงสร้างจริง

ตัวอย่าง:
```dart
// ถ้า FoodEntry อยู่ที่อื่น
import 'package:your_app_name/models/food_entry.dart';
```

---

## ขั้นตอนที่ 4: ทดสอบ BackupService

### 4.1 สร้างไฟล์ทดสอบ `test_backup_service.dart`

```dart
import 'package:flutter/material.dart';
import 'package:your_app_name/core/services/backup_service.dart';

class TestBackupScreen extends StatefulWidget {
  @override
  State<TestBackupScreen> createState() => _TestBackupScreenState();
}

class _TestBackupScreenState extends State<TestBackupScreen> {
  String _status = 'Ready';

  Future<void> _testCreateBackup() async {
    setState(() => _status = 'Creating backup...');
    
    try {
      final file = await BackupService.createBackup();
      setState(() => _status = 'Backup created: ${file.path}');
      
      // Share ไฟล์
      await BackupService.shareBackupFile(file);
      
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _testRestoreBackup() async {
    setState(() => _status = 'Picking file...');
    
    try {
      // เลือกไฟล์
      final file = await BackupService.pickBackupFile();
      
      if (file == null) {
        setState(() => _status = 'No file selected');
        return;
      }
      
      // Validate ไฟล์
      setState(() => _status = 'Validating file...');
      final info = await BackupService.validateBackupFile(file);
      
      if (info == null) {
        setState(() => _status = 'Invalid backup file');
        return;
      }
      
      setState(() => _status = 'Preview: Energy: ${info.energyBalance}, Foods: ${info.foodEntryCount}');
      
      // Restore
      setState(() => _status = 'Restoring...');
      final result = await BackupService.restoreFromBackup(file);
      
      if (result.success) {
        setState(() => _status = 'Success! Energy: ${result.newEnergyBalance}, Foods: ${result.foodEntriesImported}');
      } else {
        setState(() => _status = 'Error: ${result.errorMessage}');
      }
      
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Backup Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testCreateBackup,
              child: Text('Test Create Backup'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testRestoreBackup,
              child: Text('Test Restore Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.2 รัน Test

```bash
flutter run
```

ไปที่ TestBackupScreen แล้วทดสอบ:
1. กด "Test Create Backup" → ควรได้ไฟล์ `.json`
2. เปิดไฟล์ → ตรวจสอบว่ามี `transferKey`, `foodEntries`, `myMeals`
3. กด "Test Restore Backup" → เลือกไฟล์ → ควร import สำเร็จ

---

## ขั้นตอนที่ 5: แก้ไข Import Settings (Optional)

### 5.1 ถ้าใช้ Riverpod → แก้ `_importSettings`

```dart
static Future<void> _importSettings(Map<String, dynamic> profile) async {
  // ตัวอย่างสำหรับ Riverpod
  final container = ProviderContainer();
  
  final profileNotifier = container.read(profileProvider.notifier);
  
  profileNotifier.updateProfile(
    name: profile['name'],
    age: profile['age'],
    weight: profile['weight'],
    // ... อื่น ๆ
  );
}
```

### 5.2 ถ้าใช้ SharedPreferences

```dart
import 'package:shared_preferences/shared_preferences.dart';

static Future<void> _importSettings(Map<String, dynamic> profile) async {
  final prefs = await SharedPreferences.getInstance();
  
  await prefs.setString('name', profile['name']);
  await prefs.setInt('age', profile['age']);
  await prefs.setDouble('weight', profile['weight']);
  // ... อื่น ๆ
}
```

---

## ✅ Checklist สำหรับ Phase นี้

- [ ] `backup_service.dart` สร้างแล้ว
- [ ] Dependencies ติดตั้งแล้ว (`file_picker`, `share_plus`)
- [ ] ทดสอบ `createBackup()` → ได้ไฟล์ .json
- [ ] ทดสอบ `shareBackupFile()` → Share Sheet เปิดได้
- [ ] ทดสอบ `pickBackupFile()` → เลือกไฟล์ได้
- [ ] ทดสอบ `validateBackupFile()` → ได้ BackupInfo
- [ ] ทดสอบ `restoreFromBackup()` → Import สำเร็จ
- [ ] ไม่มี Compilation Errors

---

## 🎉 สำเร็จ!

BackupService เสร็จแล้ว! ตอนนี้มี:
- ✅ สร้าง Backup ได้ (พร้อม Transfer Key)
- ✅ Share ไฟล์ได้
- ✅ เลือกไฟล์ Backup ได้
- ✅ Validate ไฟล์ได้
- ✅ Restore ได้ (Energy + Food + My Meals)

➡️ **[ไปที่ Phase 3: UI Implementation](./03_UI_IMPLEMENTATION.md)**

---

## 🆘 หากมีปัญหา

### Import Error
```bash
# รัน pub get อีกครั้ง
flutter pub get

# Clean + Get
flutter clean
flutter pub get
```

### File Picker ไม่ทำงาน
1. ตรวจสอบ permissions (Android: `AndroidManifest.xml`)
2. ดู logs: `flutter logs`

### Isar Error
```bash
# Build Isar models ใหม่
flutter pub run build_runner build --delete-conflicting-outputs
```

---

*Next: [03_UI_IMPLEMENTATION.md](./03_UI_IMPLEMENTATION.md)*
