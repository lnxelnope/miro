# 03: UI Implementation

> ⏱ **เวลา:** 2-3 ชั่วโมง  
> 🎯 **เป้าหมาย:** เพิ่มปุ่ม Backup/Restore ใน Profile Screen พร้อม UI Flow ที่สมบูรณ์

---

## 📂 ไฟล์ที่จะแก้ไข

```
lib/
└── features/
    └── profile/
        └── presentation/
            └── profile_screen.dart  ← แก้ไขไฟล์นี้
```

---

## ขั้นตอนที่ 1: เพิ่มปุ่ม Backup/Restore ใน Profile Screen

### 1.1 เปิดไฟล์ `lib/features/profile/presentation/profile_screen.dart`

### 1.2 ค้นหาบรรทัดที่มี Comment นี้ (ประมาณบรรทัด 105-125)

```dart
// ===== ซ่อน Export/Import สำหรับ v1.0 =====
// _buildSettingCard(... 'Export Data' ...),
// _buildSettingCard(... 'Import Data' ...),
// ===== จบซ่อน v1.0 =====
```

### 1.3 **ลบ** Comment ทั้งหมดข้างบน และแทนที่ด้วยโค้ดนี้

```dart
// ===== Backup & Restore (v1.1.3+) =====
_buildSettingCard(
  context: context,
  title: 'Backup Data',
  subtitle: 'Energy + Food History → save as file',
  leading: const Icon(Icons.backup, color: Colors.blue),
  onTap: () => _handleBackup(context),
),
_buildSettingCard(
  context: context,
  title: 'Restore from Backup',
  subtitle: 'Import data from backup file',
  leading: const Icon(Icons.restore, color: Colors.green),
  onTap: () => _handleRestore(context),
),
// ===== End Backup & Restore =====
```

### 1.4 เพิ่ม Import ที่ด้านบนของไฟล์

```dart
import 'package:flutter/material.dart';
import 'dart:io';

// ... imports อื่น ๆ ที่มีอยู่แล้ว ...

import '../../../core/services/backup_service.dart';
```

---

## ขั้นตอนที่ 2: เพิ่ม Handler Methods

### 2.1 เลื่อนไปด้านล่างของ `_ProfileScreenState` class

### 2.2 เพิ่ม Methods เหล่านี้ (ก่อน closing brace `}` ของ class)

```dart
// ============================================================
// BACKUP & RESTORE HANDLERS
// ============================================================

/// Handle Backup Flow
Future<void> _handleBackup(BuildContext context) async {
  // แสดง Loading Dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // สร้าง Backup
    final file = await BackupService.createBackup();

    // ปิด Loading
    if (context.mounted) Navigator.pop(context);

    // Share ไฟล์
    await BackupService.shareBackupFile(file);

    // แสดง Success Dialog
    if (context.mounted) {
      _showBackupSuccessDialog(context, file);
    }
  } catch (e) {
    // ปิด Loading
    if (context.mounted) Navigator.pop(context);

    // แสดง Error
    if (context.mounted) {
      _showErrorDialog(
        context,
        'Backup Failed',
        'Failed to create backup: ${e.toString()}',
      );
    }
  }
}

/// Handle Restore Flow
Future<void> _handleRestore(BuildContext context) async {
  try {
    // 1. เลือกไฟล์
    final file = await BackupService.pickBackupFile();

    if (file == null) {
      // ผู้ใช้ยกเลิก
      return;
    }

    // 2. Validate ไฟล์
    BackupInfo? info;
    try {
      info = await BackupService.validateBackupFile(file);
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Invalid Backup File',
          'This file is not a valid Miro backup file.\n\n${e.toString()}',
        );
      }
      return;
    }

    if (info == null) return;

    // 3. แสดง Preview + Confirmation
    if (context.mounted) {
      final confirmed = await _showRestoreConfirmationDialog(context, info);

      if (confirmed != true) return;
    }

    // 4. แสดง Loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 5. Restore
    final result = await BackupService.restoreFromBackup(file);

    // 6. ปิด Loading
    if (context.mounted) Navigator.pop(context);

    // 7. แสดงผลลัพธ์
    if (context.mounted) {
      if (result.success) {
        _showRestoreSuccessDialog(context, result);
      } else {
        _showErrorDialog(
          context,
          'Restore Failed',
          result.errorMessage ?? 'Unknown error',
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      _showErrorDialog(
        context,
        'Error',
        'Failed to restore backup: ${e.toString()}',
      );
    }
  }
}

// ============================================================
// DIALOGS
// ============================================================

/// Success Dialog หลัง Backup
void _showBackupSuccessDialog(BuildContext context, File file) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Backup Created!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your backup file has been created successfully.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            '⚠️ Important:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Save this file in a safe place (Google Drive, etc.)\n'
            '• Photos are NOT included in the backup\n'
            '• Transfer Key expires in 30 days\n'
            '• Key can only be used once',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              file.path.split('/').last,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Confirmation Dialog ก่อน Restore
Future<bool?> _showRestoreConfirmationDialog(
  BuildContext context,
  BackupInfo info,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restore Backup?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Info
            _buildInfoRow('Backup from:', info.deviceInfo ?? 'Unknown device'),
            _buildInfoRow(
              'Date:',
              _formatDate(info.createdAt),
            ),
            _buildInfoRow('Energy:', '${info.energyBalance}'),
            _buildInfoRow('Food entries:', '${info.foodEntryCount}'),
            _buildInfoRow('My Meals:', '${info.myMealCount}'),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Current Energy on this device will be REPLACED with Energy from backup (${info.energyBalance})\n'
                    '• Food entries will be MERGED (not replaced)\n'
                    '• Photos are NOT included in backup\n'
                    '• Transfer Key will be used (cannot be reused)',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

/// Success Dialog หลัง Restore
void _showRestoreSuccessDialog(
  BuildContext context,
  BackupRestoreResult result,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Restore Complete!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your data has been restored successfully.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('New Energy Balance:', '${result.newEnergyBalance}'),
          _buildInfoRow('Food Entries Imported:', '${result.foodEntriesImported}'),
          _buildInfoRow('My Meals Imported:', '${result.myMealsImported}'),
          const SizedBox(height: 16),
          const Text(
            '✨ Your app will refresh to show the restored data.',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Refresh app state (reload providers, etc.)
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Error Dialog
void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ============================================================
// HELPER WIDGETS
// ============================================================

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
```

### 2.3 บันทึกไฟล์

---

## ขั้นตอนที่ 3: ทดสอบ UI

### 3.1 รัน App

```bash
flutter run
```

### 3.2 ไปที่ Profile Screen

### 3.3 ทดสอบ Backup Flow

1. กดปุ่ม "Backup Data"
2. ควรเห็น Loading
3. ควรเห็น Share Sheet (เลือก Google Drive / Line / etc.)
4. ควรเห็น Success Dialog

### 3.4 ทดสอบ Restore Flow

1. กดปุ่ม "Restore from Backup"
2. เลือกไฟล์ `.json` ที่ backup ไว้
3. ควรเห็น Preview Dialog (แสดงข้อมูลจาก backup)
4. กด "Restore"
5. ควรเห็น Loading
6. ควรเห็น Success Dialog

---

## ขั้นตอนที่ 4: ปรับแต่ง UI (Optional)

### 4.1 เปลี่ยนสีปุ่ม

```dart
_buildSettingCard(
  // ...
  leading: const Icon(Icons.backup, color: Colors.purple), // เปลี่ยนสี
  // ...
),
```

### 4.2 เปลี่ยนข้อความ

```dart
subtitle: 'สำรองข้อมูล Energy + อาหาร', // แปลเป็นไทย
```

### 4.3 เพิ่ม Animation (Advanced)

```dart
// TODO: เพิ่ม Hero animation สำหรับ Dialog
```

---

## ขั้นตอนที่ 5: ทดสอบ Edge Cases

### 5.1 ทดสอบ Error Cases

| Test Case | วิธีทดสอบ | ผลลัพธ์ที่คาดหวัง |
|-----------|-----------|-------------------|
| ไฟล์เสียหาย | เลือกไฟล์ `.txt` แทน `.json` | Error: "Invalid backup file" |
| ไม่มี Internet (Backup) | ปิด WiFi/Data → กด Backup | Error: "Failed to create backup" |
| ไม่มี Internet (Restore) | ปิด WiFi/Data → กด Restore | Error: "Failed to redeem transfer key" |
| Transfer Key หมดอายุ | ใช้ไฟล์ backup ที่เก็บไว้นานกว่า 30 วัน | Error: "Transfer key has expired" |
| Transfer Key ใช้แล้ว | Restore ด้วยไฟล์เดิม 2 ครั้ง | ครั้งที่ 2: Error: "already redeemed" |
| ยกเลิกตอนเลือกไฟล์ | กด Cancel ที่ File Picker | ไม่มี Dialog (ไม่ crash) |

---

## ✅ Checklist สำหรับ Phase นี้

- [ ] ปุ่ม "Backup Data" แสดงใน Profile Screen
- [ ] ปุ่ม "Restore from Backup" แสดงใน Profile Screen
- [ ] กด Backup → เห็น Loading → Share Sheet → Success Dialog
- [ ] กด Restore → File Picker → Preview Dialog → Confirm → Loading → Success Dialog
- [ ] Preview Dialog แสดงข้อมูลถูกต้อง (Energy, จำนวน foods, วันที่)
- [ ] Warning Message แสดงชัดเจน (Energy จะถูกแทนที่)
- [ ] Success Dialog แสดงผลลัพธ์ถูกต้อง
- [ ] Error Cases ทั้งหมดแสดง Error Dialog ที่เหมาะสม
- [ ] ไม่มี Crash ในทุก Flow

---

## 🎉 สำเร็จ!

UI Implementation เสร็จแล้ว! ตอนนี้ผู้ใช้สามารถ:
- ✅ กด Backup → ได้ไฟล์
- ✅ Share ไฟล์ไปที่ต้องการ
- ✅ กด Restore → เลือกไฟล์ → เห็น Preview → Confirm → สำเร็จ
- ✅ เห็น Warning ที่ชัดเจนก่อน Restore
- ✅ เห็น Error Message ที่เข้าใจง่าย

➡️ **[ไปที่ Phase 4: Testing Guide](./04_TESTING_GUIDE.md)**

---

## 🆘 หากมีปัญหา

### ปุ่มไม่แสดง
1. ตรวจสอบว่าแก้ไขไฟล์ถูกต้อง (`profile_screen.dart`)
2. Hot Restart: `R` (ใน terminal)
3. ดู Error ใน Console

### Dialog ไม่แสดง
1. ตรวจสอบ `context.mounted` ก่อนเรียก `showDialog`
2. ดู Error: `Navigator operation requested with a context that does not include a Navigator`

### Share Sheet ไม่เปิด
1. ตรวจสอบ permissions (Android/iOS)
2. ทดสอบบนเครื่องจริง (Emulator อาจมีปัญหา)

---

*Next: [04_TESTING_GUIDE.md](./04_TESTING_GUIDE.md)*
