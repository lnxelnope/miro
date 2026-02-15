# Feature Plan: Backup & Transfer (Energy + Food Data)

> **Goal:** ให้ผู้ใช้สามารถ Backup ข้อมูล (Energy + Food History) เป็นไฟล์เดียว แล้วนำไป Restore ที่เครื่องใหม่ได้  
> **Scope:** Cloud Functions, BackupService, Profile Screen, Terms of Service  
> **Breaking Change:** ไม่มี (เพิ่ม feature ใหม่ ไม่กระทบ flow เดิม)  
> **Philosophy:** ไม่ต้อง login — ผู้ใช้ควบคุมข้อมูลเอง ผ่านไฟล์ Backup

---

## 1. Overview

### ปัญหาเดิม
- **Energy หายเมื่อเปลี่ยนเครื่อง** — balance ผูกกับ `deviceId` (ANDROID_ID) ซึ่งเปลี่ยนเมื่อย้ายเครื่อง
- **Food History หายเมื่อ clear data** — ข้อมูลอาหารเก็บใน Isar database บนเครื่อง ไม่มี cloud backup
- **ไม่มี Export/Import** — ถูก comment ไว้ตั้งแต่ v1.0 (`profile_screen.dart` line 107-118)
- **ไม่มี Restore Purchase button** — Google Play policy แนะนำให้มี

### Solution
สร้างระบบ **Backup & Restore** แบบไฟล์เดียว:
1. ผู้ใช้กด **"Backup Data"** → ได้ไฟล์ `.json` ที่มี **Transfer Key** (สำหรับย้าย Energy) + **Food History** + **Settings** รวมกัน
2. ผู้ใช้เอาไฟล์ไปเก็บที่ไหนก็ได้ (Google Drive, Line, Email)
3. เครื่องใหม่: กด **"Restore from Backup"** → เลือกไฟล์ → Energy กลับมา + ข้อมูลอาหารกลับมา

### Design Principles
- **No login required** — ยึด philosophy เดิมของแอป
- **Single file** — ไม่ต้องจำหลาย key หรือหลาย flow
- **Transfer Key from Server** — ป้องกันการ forge/ปลอมแปลง
- **รูปภาพไม่รวม** — รูปเก็บบนเครื่อง แจ้งผู้ใช้ชัดเจน (อาจกลับมาเองผ่าน Google Photos)

---

## 2. User Flow

### 2.1 Backup (เครื่องเก่า)

```
User กด "Backup Data" (Profile > Data section)
    ↓
App เรียก Cloud Function: generateTransferKey(deviceId)
    ↓
Server: สร้าง key, ล็อค energy balance, บันทึกใน Firestore
    ↓ return { transferKey, energyBalance }
App: รวม transferKey + foodHistory + settings → สร้างไฟล์ .json
    ↓
App: เปิด Share Sheet ให้ user เลือกที่เก็บ (Google Drive, etc.)
    ↓
แสดง popup: "Backup สำเร็จ! เก็บไฟล์นี้ไว้ใช้ตอนเปลี่ยนเครื่อง"
```

### 2.2 Restore (เครื่องใหม่)

```
User กด "Restore from Backup" (Profile > Data section)
    ↓
เลือกไฟล์ backup (.json)
    ↓
App อ่านไฟล์ → ตรวจ format/version
    ↓
แสดง Preview:
  "Backup จาก: Samsung Galaxy S24 (15 ก.พ. 2026)"
  "Energy ใน backup: 550"
  "อาหาร: 234 รายการ"
  "My Meals: 12 รายการ"
    ↓
แสดง Warning (ถ้ามี energy อยู่แล้ว):
  ⚠️ "Energy ปัจจุบันบนเครื่องนี้ (100) จะถูกแทนที่ด้วย Energy จาก backup (550)"
  "หากคุณซื้อ Energy ใหม่ไว้แล้วบนเครื่องนี้ Energy นั้นจะหายไป"
    ↓
User กด Confirm
    ↓
App เรียก Cloud Function: redeemTransferKey(transferKey, newDeviceId)
    ↓
Server: validate key → SET energy เครื่องใหม่ = energy เครื่องเก่า → เครื่องเก่า = 0 → mark key used
    ↓ return { success, newBalance }
App: import food entries ลง Isar (merge กับข้อมูลที่มีอยู่)
App: import settings (ถ้า user ยืนยัน)
    ↓
แสดง summary: "Restore สำเร็จ! Energy: 550 | อาหาร: 234 รายการ"
```

---

## 3. Backup File Format

ไฟล์ชื่อ: `miro_backup_YYYY-MM-DD.json`

```json
{
  "appVersion": "1.1.3",
  "backupVersion": 1,
  "createdAt": "2026-02-15T10:30:00Z",
  "deviceInfo": "Samsung Galaxy S24",

  "transferKey": "MIRO-A3F9-K7X2-P8M1",

  "energyBalance": 550,

  "profile": {
    "name": "John",
    "gender": "male",
    "age": 30,
    "weight": 75.0,
    "height": 175.0,
    "targetWeight": 70.0,
    "activityLevel": "moderate",
    "calorieGoal": 2000,
    "proteinGoal": 120,
    "carbGoal": 250,
    "fatGoal": 65,
    "cuisinePreference": "thai"
  },

  "foodEntries": [
    {
      "foodName": "ข้าวผัดกะเพรา",
      "foodNameEn": "Basil Fried Rice",
      "timestamp": "2026-02-14T12:30:00Z",
      "mealType": "lunch",
      "servingSize": 1.0,
      "servingUnit": "plate",
      "calories": 450,
      "protein": 25,
      "carbs": 55,
      "fat": 12,
      "baseCalories": 450,
      "baseProtein": 25,
      "baseCarbs": 55,
      "baseFat": 12,
      "fiber": 3,
      "sugar": 5,
      "sodium": 800,
      "source": "camera",
      "aiConfidence": 0.85,
      "isVerified": true,
      "notes": null,
      "photoFileName": "IMG_20260214_123000.jpg",
      "ingredientsJson": "[{\"name\":\"ข้าว\",\"calories\":200}]",
      "createdAt": "2026-02-14T12:31:00Z"
    }
  ],

  "myMeals": [
    {
      "name": "ข้าวผัดกะเพราหมูสับ",
      "nameEn": "Basil Pork Fried Rice",
      "totalCalories": 450,
      "totalProtein": 25,
      "totalCarbs": 55,
      "totalFat": 12,
      "baseServingDescription": "1 plate",
      "source": "gemini",
      "usageCount": 5,
      "createdAt": "2026-02-10T08:00:00Z"
    }
  ]
}
```

### หมายเหตุ
- **`transferKey`** สร้างจาก server เท่านั้น — ใช้ได้ครั้งเดียว หมดอายุ 30 วัน
- **`photoFileName`** เก็บแค่ชื่อไฟล์ (ไม่เก็บ full path) เพื่อ reference — ตัวรูปไม่อยู่ในไฟล์ backup
- **`energyBalance`** เป็น snapshot ตอนสร้าง backup (สำหรับแสดงใน UI เท่านั้น ค่าจริงอยู่ที่ server)
- ไม่รวม `id` ของ Isar (จะสร้างใหม่ตอน import)

---

## 4. Architecture

### 4.1 Firestore Collection ใหม่: `transfer_keys`

```
transfer_keys/{keyId}
├── transferKey: "MIRO-A3F9-K7X2-P8M1"     // key ที่ผู้ใช้ได้รับ
├── sourceDeviceId: "abc123..."              // deviceId ที่สร้าง key
├── energyBalance: 550                       // energy ที่จะย้าย (snapshot ตอนสร้าง)
├── status: "active" | "redeemed" | "expired"
├── createdAt: Timestamp
├── expiresAt: Timestamp                     // createdAt + 30 days
├── redeemedAt: Timestamp | null
├── redeemedByDeviceId: string | null        // deviceId ที่ใช้ key
└── previousKeyId: string | null             // key ก่อนหน้า (ถูก expire แล้ว)
```

### 4.2 Cloud Functions ใหม่ (2 functions)

#### `generateTransferKey`
```
POST /generateTransferKey
Body: { deviceId: string }
Response: { 
  success: true, 
  transferKey: "MIRO-A3F9-K7X2-P8M1",
  energyBalance: 550 
}

Logic:
1. Validate deviceId
2. ดึง energy balance ปัจจุบัน
3. ถ้ามี active key เดิม → expire ทันที (สร้างได้แค่ 1 active key)
4. Generate key: "MIRO-" + 12 ตัวอักษร random (A-Z, 0-9, ไม่รวมตัวที่สับสน: 0/O, 1/I/L)
5. บันทึกลง transfer_keys collection
6. Return key + balance
```

#### `redeemTransferKey`
```
POST /redeemTransferKey
Body: { transferKey: string, newDeviceId: string }
Response: { 
  success: true, 
  energyTransferred: 550,
  previousBalance: 100,     // energy ที่เครื่องใหม่มีอยู่เดิม (สำหรับ logging)
  newBalance: 550            // energy หลัง restore (= energy จากเครื่องเก่า)
}

Logic:
1. ค้นหา key ใน transfer_keys collection
2. Validate: status == "active", ยังไม่หมดอายุ
3. ดึง energy balance จาก sourceDeviceId
4. Atomic transaction:
   a. SET energy ของ sourceDeviceId เป็น 0
   b. SET energy ของ newDeviceId = sourceBalance (REPLACE ไม่ใช่ ADD)
   c. Mark key: status = "redeemed", redeemedAt, redeemedByDeviceId
5. Return success + new balance

Error cases:
- Key ไม่พบ → 404
- Key หมดอายุ → 410 "Transfer key expired"
- Key ใช้แล้ว → 409 "Transfer key already redeemed"
- sourceDeviceId == newDeviceId → 400 "Cannot transfer to same device"
```

### 4.3 Flow Diagram

```
┌──────────────┐                    ┌──────────────┐
│  เครื่องเก่า   │                    │   Firebase    │
│  (Device A)  │                    │   Server      │
└──────┬───────┘                    └──────┬───────┘
       │                                    │
       │  POST /generateTransferKey         │
       │  { deviceId: "A" }                 │
       │ ──────────────────────────────────> │
       │                                    │ ● สร้าง key
       │                                    │ ● expire key เก่า (ถ้ามี)
       │  { key: "MIRO-...", balance: 550 } │
       │ <────────────────────────────────── │
       │                                    │
       │  สร้างไฟล์ .json                     │
       │  (key + food + settings)           │
       │  ──> Share ไป Google Drive          │
       │                                    │
       ▼                                    │
                                            │
┌──────────────┐                            │
│  เครื่องใหม่   │                            │
│  (Device B)  │                            │
└──────┬───────┘                            │
       │                                    │
       │  เลือกไฟล์ .json                     │
       │                                    │
       │  POST /redeemTransferKey           │
       │  { key: "MIRO-...", deviceId: "B" }│
       │ ──────────────────────────────────> │
       │                                    │ ● validate key
       │                                    │ ● Device A energy → 0
       │                                    │ ● Device B energy = 550 (REPLACE)
       │                                    │ ● mark key "redeemed"
       │  { success, newBalance: 550 }      │
       │ <────────────────────────────────── │
       │                                    │
       │  Import food entries ลง Isar       │
       │  Import settings (optional)        │
       ▼                                    ▼
```

---

## 5. Files to Create / Change

### 5.1 NEW: Cloud Function `generateTransferKey` — `functions/src/transferKey.ts`

สร้างไฟล์ใหม่ที่รวมทั้ง `generateTransferKey` และ `redeemTransferKey`

**Key generation algorithm:**
```typescript
// ตัวอักษรที่ใช้ (ไม่รวมตัวที่สับสน: 0/O, 1/I/L)
const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

function generateKey(): string {
  const segments = [];
  for (let i = 0; i < 3; i++) {
    let segment = '';
    for (let j = 0; j < 4; j++) {
      segment += CHARSET[Math.floor(Math.random() * CHARSET.length)];
    }
    segments.push(segment);
  }
  return `MIRO-${segments.join('-')}`;
  // ผลลัพธ์: "MIRO-A3F9-K7X2-P8M1"
}
```

**Security:**
- Key ใช้ได้ครั้งเดียว
- หมดอายุ 30 วัน
- สร้างใหม่ได้ (key เก่า expire ทันที)
- Validate format ก่อน query Firestore (ป้องกัน brute force)
- Rate limit: 5 requests / device / hour

### 5.2 UPDATE: `functions/src/index.ts`

เพิ่ม export:
```typescript
export { generateTransferKey, redeemTransferKey } from './transferKey';
```

### 5.3 NEW: Client Service `lib/core/services/backup_service.dart`

```dart
class BackupService {
  /// สร้าง Backup file
  /// 1. เรียก server สร้าง Transfer Key
  /// 2. ดึง food entries + my meals + profile จาก Isar
  /// 3. รวมเป็น JSON file
  /// 4. Return File path
  static Future<File> createBackup() async { ... }

  /// Restore จาก Backup file
  /// 1. อ่านไฟล์ JSON
  /// 2. Validate format + version
  /// 3. เรียก server redeem Transfer Key → ย้าย energy
  /// 4. Import food entries ลง Isar (merge)
  /// 5. Import settings (optional)
  static Future<BackupRestoreResult> restoreFromBackup(File file) async { ... }
  
  /// Validate backup file format
  static Future<BackupInfo?> validateBackupFile(File file) async { ... }
}

class BackupRestoreResult {
  final bool success;
  final int energyTransferred;
  final int newEnergyBalance;
  final int foodEntriesImported;
  final int myMealsImported;
  final bool settingsImported;
  final String? errorMessage;
}

class BackupInfo {
  final String appVersion;
  final int backupVersion;
  final DateTime createdAt;
  final String? deviceInfo;
  final int energyBalance;
  final int foodEntryCount;
  final int myMealCount;
  final bool hasTransferKey;
}
```

### 5.4 UPDATE: `lib/features/profile/presentation/profile_screen.dart`

**Action:** Uncomment + แก้ไข Data section (line 105-125)

เปลี่ยนจาก:
```dart
// ===== ซ่อน Export/Import สำหรับ v1.0 =====
// _buildSettingCard(... 'Export Data' ...),
// _buildSettingCard(... 'Import Data' ...),
// ===== จบซ่อน v1.0 =====
```

เป็น:
```dart
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
```

### 5.5 NEW: Backup UI Screens (optional — อาจทำเป็น Dialog ก็ได้)


- Backup: กด → loading → share sheet → done popup
- Restore: กด → file picker → preview summary → confirm → loading → done popup


### 5.6 UPDATE: `lib/features/profile/presentation/terms_screen.dart`

**Action:** เพิ่ม/แก้ไข section ต่อไปนี้

#### แก้ section "User Data and Responsibilities":
```
เดิม:
• The app does not provide cloud backup — uninstalling the app will delete local food data
• Energy balance is preserved across reinstalls (linked to your device)
• We recommend regularly exporting your data (when feature is available)

ใหม่:
• Food data is stored locally on your device
• Energy balance is stored on our server, linked to your device identifier
• You can backup your data (Energy + Food History) using the Backup feature in Settings
• The backup file contains a one-time Transfer Key for moving Energy to a new device
• Photos are NOT included in backup files — they are stored on your device only
• If your photos are backed up via Google Photos or similar services, they may appear 
  automatically on your new device, but this is not guaranteed
• We are NOT responsible for data loss due to:
  - Failure to create a backup before switching devices
  - Lost or shared backup files
  - Expired Transfer Keys (valid for 30 days)
• Transfer Keys are single-use: once redeemed, the key becomes invalid
• Creating a new backup invalidates any previous unused Transfer Key
```

#### เพิ่ม section ใหม่ "Backup & Transfer Terms":
```
Backup & Transfer:
• Backup files contain your food history, settings, and a Transfer Key
• Transfer Keys are valid for 30 days from creation
• Each Transfer Key can only be used once
• Using a Transfer Key transfers ALL Energy from the source device to the destination device
  (source device Energy becomes 0)
• Only one active Transfer Key can exist per device — creating a new backup invalidates the previous key
• We are not responsible for unauthorized use of your backup file or Transfer Key
• Keep your backup file secure — anyone with the file can redeem your Energy
```

---

## 6. Import Strategy: Merge vs Replace

เมื่อ Restore บนเครื่องที่มีข้อมูลอยู่แล้ว:

### Food Entries: **Merge (เพิ่ม ไม่ลบ)**
- Import เข้าเป็น entries ใหม่ (Isar auto-increment ID)
- ตรวจ duplicate โดยเทียบ `foodName + timestamp` — ถ้าตรงกัน → skip
- ถ้าไม่ตรง → เพิ่มเข้าไป

### My Meals: **Merge (เพิ่ม ไม่ลบ)**
- ตรวจ duplicate โดยเทียบ `name` — ถ้าชื่อเดียวกัน → skip (เก็บตัวเดิม)
- ถ้าไม่ซ้ำ → เพิ่มเข้าไป

### Profile/Settings: **ถาม User**
- แสดง dialog: "ต้องการ overwrite settings ด้วยหรือไม่?"
- ถ้า Yes → overwrite profile (goals, cuisine, etc.)
- ถ้า No → ใช้ settings เดิม

### Energy: **Replace (ทับ)**
- Server จะ **แทนที่** energy ของเครื่องใหม่ด้วย energy จากเครื่องเก่า
- เช่น เครื่องเก่ามี 550, เครื่องใหม่มี 100 → หลัง restore เครื่องใหม่ = 550, เครื่องเก่า = 0
- **ทำไมไม่ Add?** เพราะเป็นช่องโหว่ให้สร้าง energy เพิ่มได้ (เช่น ซื้อเครื่องใหม่ → welcome gift 100 → restore +550 = 650 ทั้งที่ควรได้ 550)
- **ต้องเตือนผู้ใช้ก่อน confirm restore:**
  > "Energy ปัจจุบันบนเครื่องนี้ (100) จะถูกแทนที่ด้วย Energy จาก backup (550)
  > หากคุณซื้อ Energy ใหม่ไว้แล้วบนเครื่องนี้ Energy นั้นจะหายไป"

---

## 7. Photo Handling

### ปัญหา
- รูปภาพเก็บบนเครื่อง (`/storage/emulated/0/...`)
- รวมรูปในไฟล์ backup จะทำให้ไฟล์ใหญ่มาก (100MB+)
- Path ของรูปเปลี่ยนเมื่อย้ายเครื่อง

### แนวทาง
1. **ไม่รวมรูปในไฟล์ backup** — เก็บแค่ `photoFileName` (ชื่อไฟล์)
2. **แจ้งผู้ใช้ชัดเจน** ทั้งตอน Backup และ Restore:
   - Backup: "Photos are stored on your device and NOT included in this backup"
   - Restore: "Photos are not included. If you use Google Photos, they may sync automatically."
3. **UI ตอนแสดง food entry ที่ไม่มีรูป:** แสดง placeholder icon แทน (ไม่ crash)
4. **อนาคต (optional):** ลอง match `photoFileName` กับรูปบนเครื่องใหม่ (best-effort, ไม่ guarantee)

---

## 8. Security Considerations

| ภัยคุกคาม | การป้องกัน |
|---|---|
| ปลอม Transfer Key | Key สร้างจาก server เท่านั้น, format validation ก่อน query |
| Brute force key | Rate limit 5 req/device/hr, key space: 28^12 = ~1.2 x 10^17 |
| Share ไฟล์ให้คนอื่น | Key ใช้ได้ครั้งเดียว — ใครใช้ก่อนได้ก่อน |
| แก้ไข energyBalance ในไฟล์ | ค่า energy จริงอยู่ที่ server — ค่าในไฟล์เป็นแค่ display |
| แก้ไข food data ในไฟล์ | ไม่เป็นปัญหา — เป็นข้อมูลของผู้ใช้เอง |
| สร้าง key หลายอัน | สร้างใหม่ได้ แต่อันเก่า expire ทันที (แค่ 1 active key/device) |
| Key หมดอายุ | 30 วัน — พอดีกับการเปลี่ยนเครื่อง |
| ใช้ key กับเครื่องเดิม | ป้องกัน: sourceDeviceId != newDeviceId |

---

## 9. Dependencies ที่ต้องเพิ่ม

### Client (pubspec.yaml)
```yaml
# File picker (เลือกไฟล์ backup)
file_picker: ^8.0.0

# Share (share ไฟล์ backup)
share_plus: ^12.0.1        # มีอยู่แล้ว
```

### Backend (functions/package.json)
ไม่ต้องเพิ่ม — ใช้ `firebase-functions`, `firebase-admin`, `crypto` ที่มีอยู่แล้ว

---

## 10. Implementation Order

```
Phase 1: Backend (Cloud Functions)
  Step 1: สร้าง functions/src/transferKey.ts (generateTransferKey + redeemTransferKey)
  Step 2: เพิ่ม export ใน functions/src/index.ts
  Step 3: Deploy + ทดสอบด้วย curl/Postman
  Step 4: เพิ่ม Firestore rules สำหรับ transfer_keys collection

Phase 2: Client Service
  Step 5: สร้าง lib/core/services/backup_service.dart
  Step 6: เพิ่ม file_picker dependency
  Step 7: ทดสอบ createBackup() + restoreFromBackup() แบบ manual

Phase 3: UI
  Step 8: เพิ่มปุ่ม Backup/Restore ใน profile_screen.dart (Data section)
  Step 9: สร้าง Backup flow (loading → share sheet → success dialog)
  Step 10: สร้าง Restore flow (file picker → preview → confirm → loading → success)
  Step 11: ทดสอบ E2E: Backup เครื่อง A → Restore เครื่อง B

Phase 4: Legal & Polish
  Step 12: อัปเดต terms_screen.dart (ToS)
  Step 13: อัปเดต privacy_policy_screen.dart (ถ้าจำเป็น)
  Step 14: อัปเดต docs/terms-of-service.html + GitHub Pages version
  Step 15: ทดสอบ edge cases (key expired, key used, same device, no network)
```

---

## 11. Testing Checklist

### Backup Flow
- [ ] กด Backup → ได้ไฟล์ .json (มี transferKey, foodEntries, profile)
- [ ] ไฟล์มีขนาดเหมาะสม (ไม่มีรูปภาพ)
- [ ] Share sheet เปิดได้ → ส่งไฟล์ไป Google Drive / Line / Email ได้
- [ ] สร้าง Backup ซ้ำ → key เก่า expire, ได้ key ใหม่
- [ ] Balance 0 → ยังสร้าง Backup ได้ (food data ยัง export ได้)

### Restore Flow
- [ ] เลือกไฟล์ → แสดง preview (energy, จำนวน food entries, วันที่ backup)
- [ ] กด Confirm → energy เข้าเครื่องใหม่ (เพิ่มจากที่มีอยู่)
- [ ] เครื่องเก่า energy เป็น 0
- [ ] Food entries ถูก import (merge ไม่ลบของเดิม)
- [ ] Duplicate food entries ถูก skip
- [ ] My Meals ถูก import
- [ ] Profile settings: ถาม user ก่อน overwrite

### Transfer Key Validation
- [ ] Key หมดอายุ (30 วัน) → แสดง error ชัดเจน
- [ ] Key ใช้แล้ว → แสดง error ชัดเจน
- [ ] Key ไม่ถูกต้อง → แสดง error ชัดเจน
- [ ] ใช้ key กับเครื่องเดิม → แสดง error "Cannot transfer to same device"
- [ ] ไม่มี internet → แสดง error + แนะนำลองใหม่

### Edge Cases
- [ ] ไฟล์เสียหาย (corrupted JSON) → แสดง error ไม่ crash
- [ ] ไฟล์ version เก่ากว่าปัจจุบัน → handle migration หรือแจ้ง error
- [ ] ไฟล์ว่าง (0 food entries) → ยังทำงานได้ (แค่ transfer energy)
- [ ] Backup ขณะไม่มี internet → แจ้ง error (ต้องการ server สร้าง key)
- [ ] Restore food entry ที่มี photoFileName → แสดง placeholder ถ้าไม่เจอรูป
- [ ] Restore ซ้ำด้วยไฟล์เดิม → key ใช้แล้ว error, แต่ food entries ถูก merge อีกรอบ (duplicate check)

### Terms of Service
- [ ] ToS แสดงข้อความใหม่ถูกต้อง
- [ ] Privacy Policy ยังถูกต้อง (ถ้าแก้)

---



---

## 13. Estimated Effort

| Task | Effort | Priority |
|---|---|---|
| Cloud Functions (generateTransferKey + redeemTransferKey) | 3-4 hours | P0 |
| BackupService (create + restore) | 3-4 hours | P0 |
| UI: Backup/Restore buttons + dialogs | 2-3 hours | P0 |
| Food import logic (merge + duplicate check) | 2-3 hours | P0 |
| ToS update | 1 hour | P0 |
| Edge case handling + error UI | 2-3 hours | P1 |
| Testing (E2E with 2 devices) | 2-3 hours | P0 |
| **Total** | **~15-20 hours** | |
