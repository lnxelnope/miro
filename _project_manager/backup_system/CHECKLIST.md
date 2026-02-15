# Checklist: Backup & Transfer System

> 📋 **ใช้ Checklist นี้ตรวจสอบว่าระบบพร้อม Deploy หรือยัง**

---

## 🎯 การใช้งาน

- ✅ = เสร็จแล้ว
- ⏳ = กำลังทำ
- ❌ = ยังไม่ได้ทำ

---

## Phase 1: Backend (Cloud Functions)

### Files Created/Modified
- [ ] `functions/src/transferKey.ts` สร้างแล้ว
- [ ] `functions/src/index.ts` แก้ไข (export functions)
- [ ] `functions/firestore.indexes.json` อัปเดตแล้ว (ถ้าจำเป็น)
- [ ] `firestore.rules` เพิ่ม rules สำหรับ `transfer_keys`

### Build & Deploy
- [ ] `npm run build` ผ่าน (ไม่มี TypeScript errors)
- [ ] `firebase deploy --only functions` สำเร็จ
- [ ] `firebase deploy --only firestore:rules` สำเร็จ

### Testing: generateTransferKey
- [ ] เรียกด้วย deviceId ปกติ → ได้ Transfer Key กลับมา
- [ ] Key มี format: `MIRO-XXXX-XXXX-XXXX`
- [ ] สร้าง key ซ้ำ → key เก่า expire
- [ ] Rate limit ทำงาน (สร้าง 6 ครั้ง/ชม. → error)
- [ ] ไม่ส่ง deviceId → error: "deviceId is required"

### Testing: redeemTransferKey
- [ ] Redeem key ปกติ → Energy ถูกโอน
- [ ] Energy เครื่องเก่า = 0
- [ ] Energy เครื่องใหม่ = Energy เครื่องเก่า (REPLACE)
- [ ] Key ใช้แล้ว → error: "already redeemed"
- [ ] Key หมดอายุ → error: "expired"
- [ ] Transfer ให้เครื่องเดิม → error: "Cannot transfer to same device"
- [ ] Key format ผิด → error: "Invalid transfer key format"

---

## Phase 2: Client Service

### Files Created
- [ ] `lib/core/services/backup_service.dart` สร้างแล้ว

### Dependencies
- [ ] `file_picker: ^8.0.0` ติดตั้งแล้ว
- [ ] `share_plus` มีอยู่แล้ว (ตรวจสอบ)
- [ ] `path_provider` มีอยู่แล้ว (ตรวจสอบ)
- [ ] `flutter pub get` รันแล้ว

### Testing: createBackup()
- [ ] เรียก `createBackup()` → ได้ไฟล์ `.json`
- [ ] ไฟล์มี `transferKey`
- [ ] ไฟล์มี `energyBalance`
- [ ] ไฟล์มี `foodEntries` (array)
- [ ] ไฟล์มี `myMeals` (array)
- [ ] `photoFileName` มีแค่ชื่อไฟล์ (ไม่มี full path)
- [ ] JSON format ถูกต้อง (parse ได้)

### Testing: shareBackupFile()
- [ ] เรียก `shareBackupFile(file)` → Share Sheet เปิด
- [ ] ส่งไฟล์ผ่าน Google Drive ได้
- [ ] ส่งไฟล์ผ่าน Line / Email ได้

### Testing: pickBackupFile()
- [ ] เรียก `pickBackupFile()` → File Picker เปิด
- [ ] เลือกไฟล์ `.json` → return File
- [ ] กด Cancel → return null (ไม่ crash)

### Testing: validateBackupFile()
- [ ] Validate ไฟล์ถูกต้อง → return BackupInfo
- [ ] Validate ไฟล์เสียหาย → throw error
- [ ] Validate ไฟล์ไม่มี `transferKey` → throw error

### Testing: restoreFromBackup()
- [ ] Restore สำเร็จ → return `BackupRestoreResult` (success = true)
- [ ] Food Entries ถูก import (merge)
- [ ] Duplicate entries ถูก skip
- [ ] My Meals ถูก import
- [ ] Energy ถูกโอนมา (ตรวจสอบจาก Firebase Console)
- [ ] Transfer Key ใช้แล้ว → error

---

## Phase 3: UI Implementation

### Files Modified
- [ ] `lib/features/profile/presentation/profile_screen.dart` แก้ไขแล้ว

### UI Elements
- [ ] ปุ่ม "Backup Data" แสดงใน Profile Screen
- [ ] ปุ่ม "Restore from Backup" แสดงใน Profile Screen
- [ ] Icon และ Subtitle ถูกต้อง

### Testing: Backup Flow
- [ ] กด "Backup Data" → แสดง Loading
- [ ] สร้าง Backup สำเร็จ → Share Sheet เปิด
- [ ] แสดง Success Dialog พร้อม Warning:
  - [ ] "Photos are NOT included"
  - [ ] "Transfer Key expires in 30 days"
  - [ ] "Key can only be used once"

### Testing: Restore Flow
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

### Testing: Error Cases
- [ ] ไฟล์เสียหาย → Error Dialog: "Invalid backup file"
- [ ] ไม่มี Internet (Backup) → Error Dialog: "No internet connection"
- [ ] ไม่มี Internet (Restore) → Error Dialog: "Failed to redeem"
- [ ] Transfer Key หมดอายุ → Error Dialog: "Transfer key expired"
- [ ] Transfer Key ใช้แล้ว → Error Dialog: "already redeemed"
- [ ] กด Cancel ที่ File Picker → ไม่มี Dialog (ไม่ crash)

---

## Phase 4: Testing (E2E)

### E2E Test 1: Backup → Restore (2 Devices)
- [ ] เครื่อง A: สร้าง Backup (Energy: 550, Foods: 10)
- [ ] เครื่อง B: Restore จากไฟล์
- [ ] เครื่อง B: Energy = 550 ✅
- [ ] เครื่อง B: Foods = 10 ✅
- [ ] เครื่อง A: Energy = 0 ✅

### E2E Test 2: Restore บนเครื่องที่มีข้อมูล
- [ ] เครื่อง B: Energy = 100, Foods = 5
- [ ] Restore: Energy from backup = 550, Foods = 10
- [ ] เครื่อง B (หลัง Restore): Energy = 550 ✅ (REPLACE)
- [ ] เครื่อง B (หลัง Restore): Foods = 15 ✅ (MERGE)

### E2E Test 3: สร้าง Backup ซ้ำ
- [ ] สร้าง Backup ครั้งแรก → Key A
- [ ] สร้าง Backup ครั้งที่สอง → Key B
- [ ] ลองใช้ Key A → Error: "expired" ✅

### Edge Cases
- [ ] Backup เมื่อ Energy = 0 → ยังสร้างได้ (export food data)
- [ ] Restore ไฟล์ว่าง (0 foods) → ยังทำงานได้
- [ ] Restore รายการที่มีรูป → แสดง placeholder (ไม่ crash)
- [ ] Restore ซ้ำด้วยไฟล์เดิม → Duplicate entries ถูก skip

---

## Phase 5: Terms of Service

### Files Modified
- [ ] `lib/features/profile/presentation/terms_screen.dart` แก้ไขแล้ว
- [ ] `docs/terms-of-service.html` แก้ไขแล้ว (ถ้ามี)

### Content Updated
- [ ] Section "User Data and Responsibilities" อัปเดตแล้ว:
  - [ ] กล่าวถึง Backup feature
  - [ ] กล่าวถึง Transfer Key
  - [ ] กล่าวถึง Photos ไม่รวมใน Backup
  - [ ] กล่าวถึงความรับผิดชอบ (Data Loss)
- [ ] Section "Backup & Transfer" เพิ่มแล้ว:
  - [ ] Transfer Key valid 30 days
  - [ ] Single-use only
  - [ ] Energy REPLACE ไม่ ADD
  - [ ] Keep file secure
- [ ] "Last updated" date อัปเดตแล้ว

### Testing
- [ ] เปิด Terms of Service ใน App → แสดงข้อความใหม่
- [ ] ข้อความไม่เกิน Screen (scroll ได้)
- [ ] ไม่มี Typo

---

## Phase 6: Error Handling

### User-Friendly Error Messages
- [ ] No Internet → "No internet connection. Please check..."
- [ ] Permission Denied → "Permission denied. Please grant..."
- [ ] Transfer Key Expired → "Transfer Key has expired. Please create new..."
- [ ] Transfer Key Used → "Transfer Key already used. Please create new..."
- [ ] Invalid File → "Invalid backup file. Please select a valid..."

### Context Safety
- [ ] ทุก `showDialog` เช็ค `context.mounted` ก่อน
- [ ] ทุก `Navigator.pop` เช็ค `context.mounted` ก่อน

### Logging
- [ ] Backend: มี `console.error` ใน catch block
- [ ] Client: มี `debugPrint` สำหรับ Debug
- [ ] Firebase Console → Functions → Logs มี log ที่เป็นประโยชน์

---

## Final Checks

### Code Quality
- [ ] ไม่มี Compilation Errors
- [ ] ไม่มี Warnings ที่สำคัญ
- [ ] ไม่มี TODO comments ที่ค้างอยู่
- [ ] Code มี Comments ที่เหมาะสม

### Performance
- [ ] Backup ไม่ใช้เวลานานเกินไป (< 10 วินาที)
- [ ] Restore ไม่ใช้เวลานานเกินไป (< 20 วินาที)
- [ ] ไฟล์ Backup ไม่ใหญ่เกินไป (< 5 MB)

### Security
- [ ] Transfer Key สร้างจาก Server เท่านั้น
- [ ] Firestore Rules ป้องกัน direct access
- [ ] Rate Limit ทำงาน
- [ ] Key format validation ทำงาน

### UX
- [ ] Loading indicators แสดงทุกครั้งที่รอ
- [ ] Success/Error messages ชัดเจน
- [ ] Warning messages แสดงก่อนทำสิ่งที่อันตราย
- [ ] User ไม่งง (มีคำแนะนำชัดเจน)

---

## 🚀 Ready to Deploy?

ถ้าทุกข้อ ✅ แล้ว → **พร้อม Deploy!**

### Pre-Deployment
- [ ] Commit all changes: `git add .`
- [ ] `git commit -m "feat: add Backup & Transfer system"`
- [ ] `git push`
- [ ] Create Git Tag: `git tag v1.1.3`
- [ ] Push Tag: `git push --tags`

### Deployment
- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Deploy Firestore Rules: `firebase deploy --only firestore:rules`
- [ ] Build Flutter App: `flutter build apk --release`
- [ ] Test Release Build บนเครื่องจริง
- [ ] Upload to Play Store / App Store

### Post-Deployment
- [ ] ทดสอบ Production → Backup สำเร็จ
- [ ] ทดสอบ Production → Restore สำเร็จ
- [ ] Monitor Firebase Console → Functions Logs (24 hours)
- [ ] Monitor User Feedback
- [ ] อัปเดต CHANGELOG.md

---

## 📊 Statistics

- **Total Files Modified:** ~6 files
- **Total Lines of Code:** ~1,500 lines
- **Estimated Time:** 15-20 hours
- **Test Cases:** 50+ test cases

---

## 🎉 Congratulations!

คุณพัฒนาระบบ Backup & Transfer สำเร็จแล้ว! 🚀

---

*สร้างจาก: `docs/PLAN_backup_transfer.md`*  
*เวอร์ชัน: 1.0*  
*อัปเดตล่าสุด: 15 ก.พ. 2026*
