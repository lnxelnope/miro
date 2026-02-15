# Backup & Transfer System - v1.1.3

## 🎉 New Features

### Backup & Transfer System
- ✅ สร้าง Backup ไฟล์ JSON (Energy + Food History + My Meals)
- ✅ Transfer Key สำหรับย้าย Energy ไปเครื่องใหม่
- ✅ Restore จากไฟล์ Backup (merge food data, replace energy)
- ✅ Share ไฟล์ Backup ผ่าน Google Drive / Line / Email

### Backend (Cloud Functions)
- ✅ `generateTransferKey` - สร้าง Transfer Key (30 วันอายุ, single-use)
- ✅ `redeemTransferKey` - ใช้ Transfer Key ย้าย Energy
- ✅ Rate limiting (5 keys/hour per device)
- ✅ Automatic invalidation (key เก่าถูก expire เมื่อสร้างใหม่)

### Client (Flutter)
- ✅ `BackupService` - service สำหรับจัดการ backup/restore
- ✅ UI ใน Profile Screen (Backup Data / Restore from Backup)
- ✅ Preview Dialog แสดงข้อมูล backup ก่อน restore
- ✅ User-friendly error messages
- ✅ Logging สำหรับ debugging

### Security & Rules
- ✅ Firestore Rules ป้องกัน direct access ของ `transfer_keys`
- ✅ Firestore Composite Indexes สำหรับ queries
- ✅ Transfer Key validation (format, expiry, usage)

### Documentation
- ✅ อัปเดต Terms of Service (Backup & Transfer section)
- ✅ คู่มือครบถ้วน 6 phases ใน `_project_manager/backup_system/`

## 🐛 Bug Fixes
- ✅ แก้ไข Energy badge font size (16 → 18)
- ✅ ลบกรอบสีเขียวออกจาก Energy badge

## 📝 Changed Files

### Backend
- `functions/src/transferKey.ts` (new)
- `functions/src/index.ts`
- `firestore.indexes.json`
- `firestore.rules`

### Client
- `lib/core/services/backup_service.dart` (new)
- `lib/features/profile/presentation/profile_screen.dart`
- `lib/features/profile/presentation/terms_screen.dart`
- `lib/features/energy/widgets/energy_badge_riverpod.dart`
- `pubspec.yaml` (added: cloud_functions, file_picker)

### Documentation
- `docs/PLAN_backup_transfer.md` (new)
- `_project_manager/backup_system/` (new directory)

## ⚠️ Important Notes

### For Users
- Photos are NOT included in backup files
- Transfer Keys expire after 30 days
- Each Transfer Key can only be used once
- Energy is REPLACED (not added) when restoring
- Food data is MERGED when restoring

### For Developers
- Must deploy Cloud Functions before testing
- Must deploy Firestore indexes and rules
- Google Play API must be enabled for purchase verification

## 🚀 Deployment Checklist

- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Deploy Firestore Rules: `firebase deploy --only firestore:rules`
- [ ] Deploy Firestore Indexes: `firebase deploy --only firestore:indexes`
- [ ] Build Flutter App: `flutter build apk --release`
- [ ] Test on real devices (backup → restore flow)

---

**Version:** 1.1.3  
**Date:** February 15, 2026  
**Estimated Development Time:** 15-20 hours
