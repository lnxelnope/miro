# 06: Error Handling Guide

> 🎯 **เป้าหมาย:** จัดการ Error ทุกกรณีให้แสดงข้อความที่เข้าใจง่าย

---

## 📋 Overview

เอกสารนี้รวบรวม Error Cases ทั้งหมดที่อาจเกิดขึ้น พร้อมวิธีแก้ไข

---

## ส่วนที่ 1: Backend Errors (Cloud Functions)

### 1.1 TypeScript Build Errors

#### ❌ Error: `Cannot find module 'firebase-functions'`

**สาเหตุ:** ไม่ได้ติดตั้ง dependencies

**วิธีแก้:**
```bash
cd functions
npm install
```

---

#### ❌ Error: `Property 'balance' does not exist on type 'DocumentData'`

**สาเหตุ:** TypeScript ไม่รู้จัก field ใน Firestore

**วิธีแก้:**
```typescript
// แทนที่
const energyBalance = energyDoc.data().balance;

// ด้วย
const energyBalance = energyDoc.data()?.balance || 0;
```

---

### 1.2 Cloud Functions Runtime Errors

#### ❌ Error: `HttpsError: invalid-argument, deviceId is required`

**สาเหตุ:** ไม่ส่ง `deviceId` ใน request

**วิธีแก้ (Client):**
```dart
// ตรวจสอบว่ามีการส่ง deviceId
final result = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
    .httpsCallable('generateTransferKey')
    .call({
  'deviceId': deviceId,  // ต้องมี!
});
```

---

#### ❌ Error: `HttpsError: not-found, Device not found in energy collection`

**สาเหตุ:** Device ไม่มีข้อมูลใน Firestore collection `energy`

**วิธีแก้:**
1. ตรวจสอบว่า `deviceId` ถูกต้อง
2. ตรวจสอบว่ามี document ใน `energy/{deviceId}`
3. ถ้าไม่มี → สร้าง document ก่อน:
   ```typescript
   await admin.firestore().collection('energy').doc(deviceId).set({
     balance: 100, // Welcome bonus
     createdAt: admin.firestore.FieldValue.serverTimestamp(),
   });
   ```

---

#### ❌ Error: `HttpsError: resource-exhausted, Rate limit exceeded`

**สาเหตุ:** สร้าง Transfer Key มากกว่า 5 ครั้ง/ชั่วโมง

**วิธีแก้:**
- รอ 1 ชั่วโมง
- หรือแก้ไข `RATE_LIMIT_PER_HOUR` ใน `transferKey.ts` (สำหรับ testing)

---

#### ❌ Error: `HttpsError: already-exists, Transfer key has already been redeemed`

**สาเหตุ:** ใช้ Transfer Key ที่ใช้ไปแล้ว

**วิธีแก้:**
- สร้าง Backup ใหม่ → ได้ Transfer Key ใหม่

---

#### ❌ Error: `HttpsError: failed-precondition, Transfer key has expired`

**สาเหตุ:** Transfer Key หมดอายุ (30 วัน)

**วิธีแก้:**
- สร้าง Backup ใหม่ → ได้ Transfer Key ใหม่

---

### 1.3 Firestore Permission Errors

#### ❌ Error: `FirebaseError: Missing or insufficient permissions`

**สาเหตุ:** Firestore Rules ไม่ถูกต้อง

**วิธีแก้:**
```javascript
// firestore.rules
match /transfer_keys/{keyId} {
  allow read, write: if false;  // Client ไม่สามารถเข้าถึงโดยตรง
}

match /energy/{deviceId} {
  allow read: if request.auth != null || true;  // อนุญาตอ่านได้
  allow write: if false;  // เขียนผ่าน Cloud Functions เท่านั้น
}
```

---

## ส่วนที่ 2: Client Errors (Flutter)

### 2.1 BackupService Errors

#### ❌ Error: `Exception: Failed to create backup: type 'Null' is not a subtype of type 'String'`

**สาเหตุ:** Field ใน FoodEntry เป็น null

**วิธีแก้:**
```dart
// ใน _importFoodEntries()
'photoFileName': entryJson['photoFileName'] ?? '',  // เพิ่ม ?? ''
'notes': entryJson['notes'] ?? '',
'ingredientsJson': entryJson['ingredientsJson'] ?? '[]',
```

---

#### ❌ Error: `FileSystemException: Cannot open file, path = '...'`

**สาเหตุ:** ไม่มี permission เข้าถึงไฟล์

**วิธีแก้ (Android):**

1. เปิด `android/app/src/main/AndroidManifest.xml`
2. เพิ่ม permissions:
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   ```

---

#### ❌ Error: `PlatformException(read_external_storage_denied, ...)`

**สาเหตุ:** ผู้ใช้ปฏิเสธ permission

**วิธีแก้:**
```dart
// ขอ permission ก่อนเปิด File Picker
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestStoragePermission() async {
  final status = await Permission.storage.request();
  return status.isGranted;
}

// ใช้งาน
final hasPermission = await _requestStoragePermission();
if (!hasPermission) {
  _showErrorDialog(context, 'Permission Required', 
    'Please grant storage permission to pick backup files');
  return;
}
```

---

### 2.2 Isar Database Errors

#### ❌ Error: `IsarError: Cannot write to database, transaction already closed`

**สาเหตุ:** เรียก `writeTxn` ซ้อนกัน

**วิธีแก้:**
```dart
// ❌ ผิด
await isar.writeTxn(() async {
  await isar.writeTxn(() async {  // ซ้อนกัน!
    await isar.foodEntrys.put(entry);
  });
});

// ✅ ถูก
await isar.writeTxn(() async {
  await isar.foodEntrys.put(entry);
});
```

---

#### ❌ Error: `Late initialization error: Field 'isar' has not been initialized`

**สาเหตุ:** `IsarService` ยังไม่ได้ initialize

**วิธีแก้:**
```dart
// ใน main.dart
await IsarService.instance.initialize();  // เรียกก่อนใช้งาน

// หรือเช็คก่อนใช้
if (!IsarService.instance.isInitialized) {
  await IsarService.instance.initialize();
}
```

---

### 2.3 Firebase Functions Errors

#### ❌ Error: `FirebaseFunctionsException: [DEADLINE_EXCEEDED] Deadline exceeded`

**สาเหตุ:** Cloud Function ทำงานนานเกินไป (default timeout: 60s)

**วิธีแก้:**

1. เพิ่ม timeout ใน Cloud Function:
   ```typescript
   export const generateTransferKey = functions
     .runWith({ timeoutSeconds: 120 })  // เพิ่มเป็น 120s
     .region('asia-southeast1')
     .https.onCall(async (data, context) => { ... });
   ```

2. เพิ่ม timeout ใน Client:
   ```dart
   final result = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
       .httpsCallable('generateTransferKey')
       .call(
         { 'deviceId': deviceId },
         HttpsCallableOptions(timeout: const Duration(seconds: 120)),
       );
   ```

---

#### ❌ Error: `FirebaseFunctionsException: [UNAUTHENTICATED] The request does not have valid authentication`

**สาเหตุ:** Cloud Function ต้องการ authentication แต่ไม่ได้ login

**วิธีแก้:**

1. ถ้าไม่ต้องการ authentication → ลบ check นี้ออก:
   ```typescript
   // ลบออก
   if (!context.auth) {
     throw new functions.https.HttpsError('unauthenticated', '...');
   }
   ```

2. ถ้าต้องการ authentication → ให้ผู้ใช้ login ก่อน

---

### 2.4 File Picker Errors

#### ❌ Error: `PlatformException(file_picker, User cancelled file picking)`

**สาเหตุ:** ผู้ใช้กด Cancel

**วิธีแก้:**
```dart
final file = await BackupService.pickBackupFile();

if (file == null) {
  // ผู้ใช้ยกเลิก → ไม่ต้องทำอะไร
  return;
}
```

---

#### ❌ Error: `file_picker: No implementation found`

**สาเหตุ:** ไม่ได้เพิ่ม dependency

**วิธีแก้:**
```bash
flutter pub add file_picker
flutter pub get
```

---

## ส่วนที่ 3: Network Errors

### 3.1 No Internet Connection

#### ❌ Error: `SocketException: Failed host lookup`

**สาเหตุ:** ไม่มี Internet

**วิธีแก้ (แสดง Error Message ที่เข้าใจง่าย):**
```dart
try {
  final result = await BackupService.createBackup();
} catch (e) {
  if (e.toString().contains('SocketException') || 
      e.toString().contains('Failed host lookup')) {
    _showErrorDialog(
      context,
      'No Internet Connection',
      'Please check your internet connection and try again.',
    );
  } else {
    _showErrorDialog(context, 'Error', e.toString());
  }
}
```

---

### 3.2 Server Error (500)

#### ❌ Error: `HttpsError: internal, Internal server error`

**สาเหตุ:** Cloud Function crash

**วิธีแก้:**
1. เช็ค Firebase Console → Functions → Logs
2. อ่าน Error Message
3. แก้ไขตาม Error

---

## ส่วนที่ 4: JSON Format Errors

### 4.1 Invalid JSON

#### ❌ Error: `FormatException: Unexpected character`

**สาเหตุ:** ไฟล์ JSON เสียหาย

**วิธีแก้:**
```dart
try {
  final jsonString = await file.readAsString();
  final jsonData = jsonDecode(jsonString);
} catch (e) {
  if (e is FormatException) {
    _showErrorDialog(
      context,
      'Invalid Backup File',
      'The file is corrupted or not a valid JSON file.',
    );
  }
  return;
}
```

---

### 4.2 Missing Required Fields

#### ❌ Error: `type 'Null' is not a subtype of type 'String' in type cast`

**สาเหตุ:** ไฟล์ backup ไม่มี field ที่จำเป็น

**วิธีแก้:**
```dart
// ใน validateBackupFile()
if (!jsonData.containsKey('backupVersion') ||
    !jsonData.containsKey('transferKey') ||
    !jsonData.containsKey('createdAt')) {
  throw Exception('Invalid backup file format: missing required fields');
}
```

---

## ส่วนที่ 5: UI Errors

### 5.1 Dialog Not Showing

#### ❌ Error: `Null check operator used on a null value`

**สาเหตุ:** Context ถูก dispose แล้ว

**วิธีแก้:**
```dart
// ❌ ผิด
Navigator.pop(context);
_showSuccessDialog(context);

// ✅ ถูก
if (context.mounted) Navigator.pop(context);
if (context.mounted) _showSuccessDialog(context);
```

---

### 5.2 Navigator Error

#### ❌ Error: `Navigator operation requested with a context that does not include a Navigator`

**สาเหตุ:** Context ไม่มี Navigator

**วิธีแก้:**
```dart
// ใช้ BuildContext จาก Scaffold
showDialog(
  context: context,  // ต้องเป็น context ที่อยู่ใน MaterialApp
  builder: (context) => AlertDialog(...),
);
```

---

## ส่วนที่ 6: Error Messages แบบ User-Friendly

### 6.1 Error Message Template

```dart
// สร้าง Helper Function
String getUserFriendlyError(dynamic error) {
  final errorString = error.toString().toLowerCase();
  
  if (errorString.contains('socket') || errorString.contains('network')) {
    return 'No internet connection. Please check your network and try again.';
  }
  
  if (errorString.contains('permission')) {
    return 'Permission denied. Please grant storage permission in Settings.';
  }
  
  if (errorString.contains('not found')) {
    return 'The requested data was not found.';
  }
  
  if (errorString.contains('expired')) {
    return 'Transfer Key has expired. Please create a new backup.';
  }
  
  if (errorString.contains('already')) {
    return 'Transfer Key has already been used. Please create a new backup.';
  }
  
  if (errorString.contains('same device')) {
    return 'Cannot transfer to the same device.';
  }
  
  // Default
  return 'An error occurred. Please try again later.';
}
```

### 6.2 ใช้งาน

```dart
try {
  final result = await BackupService.createBackup();
} catch (e) {
  _showErrorDialog(
    context,
    'Backup Failed',
    getUserFriendlyError(e),
  );
}
```

---

## ส่วนที่ 7: Logging & Debugging

### 7.1 เพิ่ม Logging

```dart
import 'package:flutter/foundation.dart';

class BackupService {
  static Future<File> createBackup() async {
    debugPrint('🔍 [Backup] Starting backup...');
    
    try {
      final deviceId = await DeviceId.getDeviceId();
      debugPrint('🔍 [Backup] Device ID: $deviceId');
      
      final result = await FirebaseFunctions...;
      debugPrint('🔍 [Backup] Transfer Key: ${result.data['transferKey']}');
      
      final file = ...;
      debugPrint('✅ [Backup] Backup created: ${file.path}');
      
      return file;
    } catch (e) {
      debugPrint('❌ [Backup] Error: $e');
      rethrow;
    }
  }
}
```

---

### 7.2 ดู Logs

```bash
# Flutter Logs
flutter logs

# Filter เฉพาะ Backup
flutter logs | grep "Backup"

# Firebase Functions Logs
firebase functions:log
```

---

## ✅ Checklist

- [ ] ทุก Error Case มี User-Friendly Message
- [ ] ทุก try-catch block มี error handling
- [ ] Dialog ทุกอันเช็ค `context.mounted`
- [ ] Backend Errors ถูก wrap ใน `HttpsError`
- [ ] Client Errors แสดง Dialog ที่เหมาะสม
- [ ] มี Logging สำหรับ Debug
- [ ] Permission Errors แสดงวิธีแก้ไข
- [ ] Network Errors แสดงข้อความที่ชัดเจน

---

## 🎉 สำเร็จ!

ตอนนี้ระบบมี Error Handling ที่ครบถ้วน:
- ✅ ทุก Error แสดงข้อความที่เข้าใจง่าย
- ✅ ไม่มี Crash
- ✅ มี Logging สำหรับ Debug
- ✅ ผู้ใช้รู้ว่าต้องทำอะไรต่อ

➡️ **[ดู Checklist สุดท้าย](./CHECKLIST.md)**

---

## 🆘 หากมีปัญหาอื่น ๆ

### ไม่รู้ว่า Error นี้คืออะไร
1. คัดลอก Error Message ทั้งหมด
2. ค้นหาใน Google: `flutter [error message]`
3. เช็ค Stack Overflow

### Error ที่ไม่มีในคู่มือ
1. เพิ่ม Logging (ดู Section 7.1)
2. ดู Firebase Console Logs
3. ดู Flutter Logs: `flutter logs`

---

*Next: [CHECKLIST.md](./CHECKLIST.md)*
