# Task 6: Backup System Update

**ระยะเวลา:** 1 วัน  
**Complexity:** 🟢 Easy  
**ต้องรู้:** Dart, JSON, File I/O

---

## 🎯 สิ่งที่ต้องทำ

อัพเดท Backup/Restore เพื่อรองรับ MiRO ID + Streak data

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 6.1: แก้ไข createBackup

**ที่อยู่:** `lib/core/services/backup_service.dart`

**เพิ่ม MiRO ID + Streak:**

```dart
Future<File> createBackup() async {
  // ... code เดิม ...

  final miroId = await energyService.getMiroId();
  final gamification = ref.read(gamificationProvider);

  final backupData = {
    'version': 2,  // ← ใหม่! (เดิมไม่มี version)
    'miroId': miroId,  // ← ใหม่!
    'transferKey': transferKey,
    'energyBalance': balance,
    'streakData': {  // ← ใหม่!
      'currentStreak': gamification.currentStreak,
      'longestStreak': gamification.longestStreak,
      'tier': gamification.tier,
    },
    'foodEntries': [...],
    'myMeals': [...],
    // ... ข้อมูลอื่นๆ
  };

  // ... save to file ...
}
```

---

### Step 6.2: แก้ไข restoreFromBackup

**ที่อยู่:** `lib/core/services/backup_service.dart`

**Cache MiRO ID ใหม่:**

```dart
Future<void> restoreFromBackup(File file) async {
  final backupData = jsonDecode(await file.readAsString());

  // ... redeem transfer key ...

  // Restore MiRO ID
  final miroId = backupData['miroId'] as String?;
  if (miroId != null) {
    await _storage.write(key: 'miro_id', value: miroId);
  }

  // ... restore food entries, meals, etc. ...
}
```

---

### Step 6.3: แก้ไข transferKey.ts (Backend)

**ที่อยู่:** `functions/src/transferKey.ts`

**Transfer MiRO ID:**

```typescript
// หลัง transfer energy สำเร็จ:

const sourceUser = await db.collection('users').doc(sourceDeviceId).get();
const sourceMiroId = sourceUser.data()?.miroId;

if (sourceMiroId) {
  // ผูก MiRO ID กับ device ใหม่
  await db.collection('users').doc(newDeviceId).set({
    miroId: sourceMiroId,
    deviceId: newDeviceId,
    currentStreak: sourceUser.data()?.currentStreak || 0,
    longestStreak: sourceUser.data()?.longestStreak || 0,
    tier: sourceUser.data()?.tier || 'none',
    tierUnlockedAt: sourceUser.data()?.tierUnlockedAt || {},
    // ... copy ข้อมูลอื่นๆ
  }, { merge: true });

  // Unlink MiRO ID จาก device เก่า
  await db.collection('users').doc(sourceDeviceId).update({
    miroId: `TRANSFERRED:${sourceMiroId}`,
    transferredTo: newDeviceId,
    transferredAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

---

### Step 6.4: เพิ่มคำเตือน Anonymous

**ที่อยู่:** `lib/features/profile/presentation/profile_screen.dart`

**เพิ่ม warning banner:**

```dart
Container(
  color: Colors.orange,
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text(
        '⚠️ MIRO ใช้ระบบ Anonymous',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text(
        'ถ้าเปลี่ยนเครื่องหรือลบแอปโดยไม่ Backup → ข้อมูลหายถาวร!',
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 8),
      ElevatedButton(
        child: Text('Backup ตอนนี้'),
        onPressed: () => _createBackup(),
      ),
    ],
  ),
)
```

---

## ✅ Checklist

```
□ แก้ไข createBackup (เพิ่ม miroId + streakData)
□ แก้ไข restoreFromBackup (cache MiRO ID ใหม่)
□ แก้ไข transferKey.ts (transfer MiRO ID)
□ Deploy transferKey function
□ เพิ่มคำเตือน Anonymous ใน Profile
□ Test: Backup → ไฟล์มี miroId
□ Test: Restore → MiRO ID ย้ายมา
□ Test: Restore backup เก่า → ยังทำงานได้
```

---

## ⏭️ Next Task

เมื่อทำ Task 6 เสร็จ → ไป **TASK_7_TESTING.md**
