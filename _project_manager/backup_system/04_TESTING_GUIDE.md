# 04: Testing Guide

> ⏱ **เวลา:** 2-3 ชั่วโมง  
> 🎯 **เป้าหมาย:** ทดสอบระบบ Backup & Restore แบบครบถ้วน

---

## 📋 Overview

การทดสอบแบ่งเป็น 4 ส่วน:
1. **Unit Tests** — ทดสอบ Backend Functions
2. **Integration Tests** — ทดสอบ Service Layer
3. **E2E Tests** — ทดสอบ User Flow ทั้งหมด
4. **Edge Cases** — ทดสอบกรณีพิเศษ

---

## ส่วนที่ 1: Unit Tests (Backend)

### 1.1 ทดสอบ `generateTransferKey`

#### เครื่องมือ: Firebase Emulator หรือ Postman

#### Test Cases

| # | Test Case | Input | Expected Output |
|---|-----------|-------|-----------------|
| 1 | สร้าง key ปกติ | `deviceId: "test-001"` | `{ success: true, transferKey: "MIRO-...", energyBalance: ... }` |
| 2 | Device ไม่มีอยู่ | `deviceId: "nonexistent"` | Error: "Device not found" |
| 3 | ไม่ส่ง deviceId | `{}` | Error: "deviceId is required" |
| 4 | สร้าง key ซ้ำ | `deviceId: "test-001"` (ครั้งที่ 2) | Success + key เก่า expire |
| 5 | Rate limit | สร้าง 6 ครั้งภายใน 1 ชม. | ครั้งที่ 6: Error: "Rate limit exceeded" |

#### วิธีทดสอบ (ด้วย Flutter)

```dart
Future<void> testGenerateKey() async {
  try {
    final result = await FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).httpsCallable('generateTransferKey').call({
      'deviceId': 'test-device-001',
    });

    print('✅ Test 1 Passed: ${result.data}');
    assert(result.data['success'] == true);
    assert(result.data['transferKey'].toString().startsWith('MIRO-'));
    
  } catch (e) {
    print('❌ Test 1 Failed: $e');
  }
}
```

---

### 1.2 ทดสอบ `redeemTransferKey`

#### Test Cases

| # | Test Case | Input | Expected Output |
|---|-----------|-------|-----------------|
| 1 | Redeem key ปกติ | Valid key + new deviceId | `{ success: true, energyTransferred: ..., newBalance: ... }` |
| 2 | Key ไม่มีอยู่ | `transferKey: "MIRO-FAKE-KEY1-TEST"` | Error: "Transfer key not found" |
| 3 | Key หมดอายุ | Key ที่เก็บไว้นานกว่า 30 วัน | Error: "Transfer key has expired" |
| 4 | Key ใช้แล้ว | Key เดิมที่ redeem ไปแล้ว | Error: "already redeemed" |
| 5 | Transfer ให้เครื่องเดิม | sourceDeviceId == newDeviceId | Error: "Cannot transfer to same device" |
| 6 | Format ผิด | `transferKey: "INVALID"` | Error: "Invalid transfer key format" |

#### วิธีทดสอบ

```dart
Future<void> testRedeemKey(String transferKey) async {
  try {
    final result = await FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).httpsCallable('redeemTransferKey').call({
      'transferKey': transferKey,
      'newDeviceId': 'test-device-002', // เครื่องใหม่
    });

    print('✅ Test Passed: ${result.data}');
    assert(result.data['success'] == true);
    assert(result.data['newBalance'] > 0);
    
  } catch (e) {
    print('❌ Test Failed: $e');
  }
}
```

---

## ส่วนที่ 2: Integration Tests (Service)

### 2.1 ทดสอบ `BackupService.createBackup()`

#### Checklist

- [ ] ได้ไฟล์ `.json`
- [ ] ไฟล์มี `transferKey`
- [ ] ไฟล์มี `foodEntries` (ถ้ามีข้อมูล)
- [ ] ไฟล์มี `myMeals` (ถ้ามีข้อมูล)
- [ ] ไฟล์มี `energyBalance`
- [ ] `photoFileName` มีแค่ชื่อไฟล์ (ไม่มี path เต็ม)
- [ ] JSON format ถูกต้อง (parse ได้)

#### วิธีทดสอบ

```dart
Future<void> testCreateBackup() async {
  try {
    // สร้าง backup
    final file = await BackupService.createBackup();
    
    print('✅ File created: ${file.path}');
    
    // อ่านไฟล์
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);
    
    // ตรวจสอบ fields
    assert(jsonData['transferKey'] != null, 'transferKey missing');
    assert(jsonData['energyBalance'] != null, 'energyBalance missing');
    assert(jsonData['foodEntries'] is List, 'foodEntries not a list');
    
    print('✅ All checks passed');
    
  } catch (e) {
    print('❌ Test Failed: $e');
  }
}
```

---

### 2.2 ทดสอบ `BackupService.restoreFromBackup()`

#### Checklist

- [ ] Food Entries ถูก import (merge ไม่ลบของเดิม)
- [ ] My Meals ถูก import
- [ ] Duplicate entries ถูก skip
- [ ] Energy ถูกโอนมา (ตรวจสอบจาก Firebase Console)
- [ ] Return `BackupRestoreResult` ที่ถูกต้อง

#### วิธีทดสอบ

```dart
Future<void> testRestore(File backupFile) async {
  try {
    // ดึงจำนวน food entries ก่อน restore
    final isar = IsarService.instance.isar;
    final countBefore = await isar.foodEntrys.count();
    
    // Restore
    final result = await BackupService.restoreFromBackup(backupFile);
    
    assert(result.success, 'Restore failed: ${result.errorMessage}');
    
    // ดึงจำนวนหลัง restore
    final countAfter = await isar.foodEntrys.count();
    
    print('✅ Before: $countBefore, After: $countAfter');
    print('✅ Imported: ${result.foodEntriesImported}');
    
    assert(countAfter >= countBefore, 'Food entries decreased!');
    
  } catch (e) {
    print('❌ Test Failed: $e');
  }
}
```

---

## ส่วนที่ 3: E2E Tests (User Flow)

### 3.1 Flow: Backup บนเครื่อง A → Restore บนเครื่อง B

#### ขั้นตอน

1. **เครื่อง A (หรือ Emulator 1)**
   - เปิดแอป
   - เพิ่มข้อมูลอาหาร 5-10 รายการ
   - ไปที่ Profile → กด "Backup Data"
   - Share ไฟล์ไปที่ Google Drive / Email
   - **เช็ค Energy Balance ก่อน backup** (เช่น 550)

2. **เครื่อง B (หรือ Emulator 2)**
   - ติดตั้งแอปใหม่
   - ไปที่ Profile → กด "Restore from Backup"
   - เลือกไฟล์ backup จากเครื่อง A
   - ตรวจสอบ Preview Dialog:
     - Energy: 550 ✅
     - Food entries: 10 ✅
   - กด "Restore"
   - ตรวจสอบผลลัพธ์:
     - Energy = 550 ✅
     - Food entries มี 10 รายการ ✅

3. **กลับไปเครื่อง A**
   - Refresh แอป
   - Energy ควรเป็น 0 ✅

---

### 3.2 Flow: Restore บนเครื่องที่มีข้อมูลอยู่แล้ว

#### ขั้นตอน

1. เครื่อง B มีข้อมูลอยู่แล้ว:
   - Energy: 100
   - Food entries: 5 รายการ

2. Restore ด้วยไฟล์ backup:
   - Energy from backup: 550
   - Food entries from backup: 10 รายการ

3. ผลลัพธ์ที่คาดหวัง:
   - Energy: **550** (ถูกแทนที่ ❗)
   - Food entries: **15 รายการ** (5 เดิม + 10 ใหม่ = merge ✅)
   - Duplicate entries: ถูก skip ✅

---

### 3.3 Flow: สร้าง Backup ซ้ำ

#### ขั้นตอน

1. สร้าง Backup ครั้งแรก → ได้ key: `MIRO-AAA1-BBB2-CCC3`
2. สร้าง Backup อีกครั้ง → ได้ key ใหม่: `MIRO-DDD4-EEE5-FFF6`
3. ลองใช้ key เก่า (`MIRO-AAA1-BBB2-CCC3`) → ควรได้ Error: "expired" ✅

---

## ส่วนที่ 4: Edge Cases

### 4.1 ไฟล์เสียหาย / Format ผิด

#### Test Cases

| Test Case | วิธีทดสอบ | Expected |
|-----------|-----------|----------|
| ไฟล์ไม่ใช่ JSON | เลือกไฟล์ `.txt` | Error: "Invalid backup file" |
| JSON ไม่มี `transferKey` | แก้ไขไฟล์ลบ field `transferKey` | Error: "Invalid backup file format" |
| JSON เสียหาย | แก้ไขให้ syntax ผิด | Error: "Invalid backup file" |
| ไฟล์ว่าง | สร้างไฟล์ `.json` ว่าง | Error: "Invalid backup file" |

---

### 4.2 Network Issues

#### Test Cases

| Test Case | วิธีทดสอบ | Expected |
|-----------|-----------|----------|
| ไม่มี Internet (Backup) | ปิด WiFi → กด Backup | Error: "Failed to generate transfer key" |
| ไม่มี Internet (Restore) | ปิด WiFi → กด Restore | Error: "Failed to redeem transfer key" |
| Network ช้ามาก | จำลองด้วย Network Throttling | แสดง Loading นานขึ้น แต่สำเร็จ |

---

### 4.3 Permission Issues

#### Test Cases (Android)

| Test Case | วิธีทดสอบ | Expected |
|-----------|-----------|----------|
| ไม่อนุญาต Storage | ปฏิเสธ permission → กด Restore | Error: "Permission denied" |
| File Picker ปิด | เปิด File Picker แล้วกด Back | ไม่มี Dialog (ยกเลิก) |

---

### 4.4 Photos (Special Case)

#### Test Cases

| Test Case | วิธีทดสอบ | Expected |
|-----------|-----------|----------|
| Backup รายการที่มีรูป | Food entry ที่มี `photoPath` | Backup มีแค่ `photoFileName` (ไม่มีรูปจริง) |
| Restore รายการที่มีรูป | Import entry ที่มี `photoFileName` | ไม่ crash, แสดง placeholder icon |

---

## ✅ Master Checklist

### Backend

- [ ] `generateTransferKey`: สร้าง key สำเร็จ
- [ ] `generateTransferKey`: Rate limit ทำงาน
- [ ] `generateTransferKey`: Expire key เก่าเมื่อสร้างใหม่
- [ ] `redeemTransferKey`: โอน energy สำเร็จ
- [ ] `redeemTransferKey`: Key ใช้แล้ว → error
- [ ] `redeemTransferKey`: Key หมดอายุ → error
- [ ] `redeemTransferKey`: Transfer ให้เครื่องเดิม → error

### Service

- [ ] `createBackup()`: ได้ไฟล์ .json
- [ ] `createBackup()`: JSON format ถูกต้อง
- [ ] `shareBackupFile()`: Share Sheet เปิดได้
- [ ] `validateBackupFile()`: Validate ถูกต้อง
- [ ] `restoreFromBackup()`: Import food entries สำเร็จ
- [ ] `restoreFromBackup()`: Duplicate check ทำงาน
- [ ] `restoreFromBackup()`: Energy โอนมาถูกต้อง

### UI

- [ ] ปุ่ม Backup/Restore แสดงใน Profile
- [ ] Backup: Loading → Share → Success Dialog
- [ ] Restore: File Picker → Preview → Confirm → Loading → Success
- [ ] Preview Dialog: แสดงข้อมูลถูกต้อง
- [ ] Warning: แจ้งว่า Energy จะถูกแทนที่
- [ ] Error Dialogs: แสดงข้อความที่เข้าใจง่าย

### Edge Cases

- [ ] ไฟล์เสียหาย → error ที่ชัดเจน
- [ ] ไม่มี Internet → error ที่ชัดเจน
- [ ] Transfer Key หมดอายุ → error ที่ชัดเจน
- [ ] Transfer Key ใช้แล้ว → error ที่ชัดเจน
- [ ] Restore ซ้ำ → Duplicate skip
- [ ] Photos ไม่รวมใน Backup
- [ ] Restore รายการที่มีรูป → ไม่ crash

---

## 🎉 สำเร็จ!

ถ้าผ่านทุก Test Case → ระบบพร้อม Deploy!

➡️ **[ไปที่ Phase 5: Terms Update](./05_TERMS_UPDATE.md)**

---

## 🆘 หากมีปัญหา

### Test ไม่ผ่าน
1. อ่าน Error Message ให้ละเอียด
2. เช็คใน `06_ERROR_HANDLING.md`
3. ตรวจสอบ Firebase Console → Functions → Logs

### E2E Test ทำยาก
- ใช้ 2 Emulators (Android Studio)
- หรือใช้ 1 Emulator + 1 เครื่องจริง

### Debug Tips
```dart
// เพิ่ม print ใน BackupService
print('🔍 Creating backup for device: $deviceId');
print('🔍 Transfer Key: $transferKey');
print('🔍 Food Entries: ${foodEntries.length}');
```

---

*Next: [05_TERMS_UPDATE.md](./05_TERMS_UPDATE.md)*
