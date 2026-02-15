# ✅ Testing Checklist - Backup & Transfer System

> 📋 **ใช้ Checklist นี้ทดสอบระบบก่อน Deploy**

---

## 🎯 Quick Test (5 นาที)

### Basic Flow Test
- [ ] เปิดแอป → Profile Screen
- [ ] เห็นปุ่ม "Backup Data" และ "Restore from Backup"
- [ ] กด "Backup Data" → เห็น Loading → Share Sheet เปิด
- [ ] กด "Restore from Backup" → File Picker เปิด

---

## 📋 Detailed Testing Checklist

### 1. Backend Functions (Cloud Functions)

#### `generateTransferKey`
- [ ] สร้าง key ปกติ → ได้ `{ success: true, transferKey: "MIRO-..." }`
- [ ] ไม่ส่ง deviceId → Error: "deviceId is required"
- [ ] สร้าง key ซ้ำ → key เก่า expire, key ใหม่ active
- [ ] Rate limit: สร้าง 6 ครั้ง/ชม. → ครั้งที่ 6: Error

**วิธีทดสอบ:**
```dart
// ใน Flutter app หรือ Firebase Console
final result = await FirebaseFunctions.instanceFor(
  region: 'asia-southeast1',
).httpsCallable('generateTransferKey').call({
  'deviceId': 'test-device-001',
});
print(result.data);
```

#### `redeemTransferKey`
- [ ] Redeem key ปกติ → Energy โอนสำเร็จ
- [ ] Key ไม่มีอยู่ → Error: "Transfer key not found"
- [ ] Key ใช้แล้ว → Error: "already redeemed"
- [ ] Key หมดอายุ → Error: "expired"
- [ ] Transfer ให้เครื่องเดิม → Error: "Cannot transfer to same device"
- [ ] Format ผิด → Error: "Invalid transfer key format"

---

### 2. Backup Service

#### `createBackup()`
- [ ] ได้ไฟล์ `.json`
- [ ] ไฟล์มี `transferKey` (format: `MIRO-XXXX-XXXX-XXXX`)
- [ ] ไฟล์มี `energyBalance` (เป็นตัวเลข)
- [ ] ไฟล์มี `foodEntries` (array)
- [ ] ไฟล์มี `myMeals` (array)
- [ ] `photoFileName` มีแค่ชื่อไฟล์ (ไม่มี path เต็ม)
- [ ] JSON format ถูกต้อง (parse ได้)

**ตรวจสอบไฟล์:**
```dart
final file = await BackupService.createBackup();
final jsonString = await file.readAsString();
final jsonData = jsonDecode(jsonString);
print('Transfer Key: ${jsonData['transferKey']}');
print('Energy: ${jsonData['energyBalance']}');
print('Food Entries: ${jsonData['foodEntries'].length}');
```

#### `validateBackupFile()`
- [ ] Validate ไฟล์ถูกต้อง → ได้ `BackupInfo`
- [ ] Validate ไฟล์เสียหาย → throw error
- [ ] Validate ไฟล์ไม่มี `transferKey` → throw error
- [ ] Validate ไฟล์ version ใหม่กว่า app → error

#### `restoreFromBackup()`
- [ ] Restore สำเร็จ → `success = true`
- [ ] Food Entries ถูก import (merge ไม่ลบของเดิม)
- [ ] Duplicate entries ถูก skip
- [ ] My Meals ถูก import
- [ ] Energy ถูกโอนมา (ตรวจสอบจาก Firebase Console)

---

### 3. UI Flow

#### Backup Flow
- [ ] กด "Backup Data" → แสดง Loading
- [ ] สร้าง Backup สำเร็จ → Share Sheet เปิด
- [ ] แสดง Success Dialog พร้อม Warning:
  - [ ] "Photos are NOT included"
  - [ ] "Transfer Key expires in 30 days"
  - [ ] "Key can only be used once"

#### Restore Flow
- [ ] กด "Restore from Backup" → File Picker เปิด
- [ ] เลือกไฟล์ → แสดง Preview Dialog:
  - [ ] Device info
  - [ ] Energy balance
  - [ ] จำนวน Food entries
  - [ ] จำนวน My Meals
- [ ] แสดง Warning:
  - [ ] "Energy will be REPLACED"
  - [ ] "Photos NOT included"
- [ ] กด "Restore" → แสดง Loading
- [ ] Restore สำเร็จ → แสดง Success Dialog:
  - [ ] New Energy Balance
  - [ ] จำนวน Food Entries Imported
  - [ ] จำนวน My Meals Imported

---

### 4. E2E Tests

#### Test 1: Backup → Restore (2 Devices)
**เครื่อง A:**
- [ ] เพิ่มข้อมูลอาหาร 5-10 รายการ
- [ ] เช็ค Energy Balance (เช่น 550)
- [ ] สร้าง Backup → Share ไฟล์

**เครื่อง B:**
- [ ] Restore จากไฟล์
- [ ] Preview แสดง Energy: 550 ✅
- [ ] Preview แสดง Foods: 10 ✅
- [ ] Restore สำเร็จ
- [ ] Energy = 550 ✅
- [ ] Foods = 10 ✅

**กลับไปเครื่อง A:**
- [ ] Refresh แอป
- [ ] Energy = 0 ✅

#### Test 2: Restore บนเครื่องที่มีข้อมูล
**ก่อน Restore:**
- [ ] Energy: 100
- [ ] Foods: 5 รายการ

**Restore จาก Backup:**
- [ ] Energy from backup: 550
- [ ] Foods from backup: 10 รายการ

**หลัง Restore:**
- [ ] Energy: **550** ✅ (REPLACE)
- [ ] Foods: **15** ✅ (5 + 10 = MERGE)

#### Test 3: สร้าง Backup ซ้ำ
- [ ] สร้าง Backup ครั้งแรก → Key A
- [ ] สร้าง Backup ครั้งที่สอง → Key B
- [ ] ลองใช้ Key A → Error: "expired" ✅

---

### 5. Error Cases

#### File Errors
- [ ] ไฟล์เสียหาย → Error: "Invalid backup file"
- [ ] เลือกไฟล์ `.txt` → Error: "Invalid backup file"
- [ ] JSON ไม่มี `transferKey` → Error: "Invalid backup file format"
- [ ] กด Cancel ที่ File Picker → ไม่มี Dialog (ไม่ crash)

#### Network Errors
- [ ] ไม่มี Internet (Backup) → Error: "Failed to create backup"
- [ ] ไม่มี Internet (Restore) → Error: "Failed to redeem transfer key"

#### Transfer Key Errors
- [ ] Transfer Key หมดอายุ → Error: "Transfer key expired"
- [ ] Transfer Key ใช้แล้ว → Error: "already redeemed"
- [ ] Transfer Key ไม่มีอยู่ → Error: "Transfer key not found"

---

### 6. Edge Cases

- [ ] Backup เมื่อ Energy = 0 → ยังสร้างได้ (export food data)
- [ ] Restore ไฟล์ว่าง (0 foods) → ยังทำงานได้
- [ ] Restore รายการที่มีรูป → แสดง placeholder (ไม่ crash)
- [ ] Restore ซ้ำด้วยไฟล์เดิม → Duplicate entries ถูก skip
- [ ] Backup รายการที่มีรูป → Backup มีแค่ `photoFileName` (ไม่มีรูปจริง)

---

## 🎯 Test Results Summary

### Backend Functions
- [ ] `generateTransferKey`: ✅ / ❌
- [ ] `redeemTransferKey`: ✅ / ❌

### Service Layer
- [ ] `createBackup()`: ✅ / ❌
- [ ] `restoreFromBackup()`: ✅ / ❌
- [ ] `validateBackupFile()`: ✅ / ❌

### UI Flow
- [ ] Backup Flow: ✅ / ❌
- [ ] Restore Flow: ✅ / ❌
- [ ] Error Handling: ✅ / ❌

### E2E Tests
- [ ] Test 1 (2 Devices): ✅ / ❌
- [ ] Test 2 (Merge): ✅ / ❌
- [ ] Test 3 (Duplicate Key): ✅ / ❌

---

## 📝 Notes

**วันที่ทดสอบ:** _______________

**ผู้ทดสอบ:** _______________

**Issues Found:**
1. 
2. 
3. 

---

## ✅ Ready to Deploy?

ถ้าทุกข้อ ✅ แล้ว → **พร้อม Deploy!**

➡️ ไปที่ Phase 5: Terms Update
