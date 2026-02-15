# 05: Terms of Service Update

> ⏱ **เวลา:** 1 ชั่วโมง  
> 🎯 **เป้าหมาย:** อัปเดต Terms of Service เพื่อครอบคลุมระบบ Backup & Transfer

---

## 📂 ไฟล์ที่จะแก้ไข

```
lib/
└── features/
    └── profile/
        └── presentation/
            └── terms_screen.dart  ← แก้ไขไฟล์นี้

docs/
└── terms-of-service.html  ← แก้ไขไฟล์นี้ (ถ้ามี)
```

---

## ส่วนที่ 1: แก้ไข `terms_screen.dart`

### 1.1 เปิดไฟล์ `lib/features/profile/presentation/terms_screen.dart`

### 1.2 ค้นหา Section "User Data and Responsibilities"

มักจะอยู่ประมาณบรรทัด 100-200

### 1.3 แก้ไข Section นี้

**ข้อความเดิม:**
```
User Data and Responsibilities:
• The app does not provide cloud backup — uninstalling the app will delete local food data
• Energy balance is preserved across reinstalls (linked to your device)
• We recommend regularly exporting your data (when feature is available)
```

**แทนที่ด้วย:**
```
User Data and Responsibilities:
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

---

### 1.4 เพิ่ม Section ใหม่ "Backup & Transfer Terms"

**หาตำแหน่งที่เหมาะสม** (หลังจาก "User Data and Responsibilities")

**เพิ่มข้อความนี้:**
```dart
// ใน terms_screen.dart

_buildSectionTitle('Backup & Transfer'),
_buildSectionContent(
  'Backup & Transfer:\n\n'
  '• Backup files contain your food history, settings, and a Transfer Key\n'
  '• Transfer Keys are valid for 30 days from creation\n'
  '• Each Transfer Key can only be used once\n'
  '• Using a Transfer Key transfers ALL Energy from the source device to the destination device '
  '(source device Energy becomes 0)\n'
  '• Only one active Transfer Key can exist per device — creating a new backup invalidates the previous key\n'
  '• We are not responsible for unauthorized use of your backup file or Transfer Key\n'
  '• Keep your backup file secure — anyone with the file can redeem your Energy',
),
```

---

### 1.5 ตัวอย่างโค้ดเต็ม (ส่วน Backup & Transfer)

```dart
// ภายใน _buildTermsContent() method

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // ... sections อื่น ๆ ...
    
    // User Data and Responsibilities (แก้ไขแล้ว)
    _buildSectionTitle('User Data and Responsibilities'),
    _buildSectionContent(
      'User Data and Responsibilities:\n\n'
      '• Food data is stored locally on your device\n'
      '• Energy balance is stored on our server, linked to your device identifier\n'
      '• You can backup your data (Energy + Food History) using the Backup feature in Settings\n'
      '• The backup file contains a one-time Transfer Key for moving Energy to a new device\n'
      '• Photos are NOT included in backup files — they are stored on your device only\n'
      '• If your photos are backed up via Google Photos or similar services, they may appear '
      'automatically on your new device, but this is not guaranteed\n'
      '• We are NOT responsible for data loss due to:\n'
      '  - Failure to create a backup before switching devices\n'
      '  - Lost or shared backup files\n'
      '  - Expired Transfer Keys (valid for 30 days)\n'
      '• Transfer Keys are single-use: once redeemed, the key becomes invalid\n'
      '• Creating a new backup invalidates any previous unused Transfer Key',
    ),
    
    const SizedBox(height: 24),
    
    // Backup & Transfer (ใหม่)
    _buildSectionTitle('Backup & Transfer'),
    _buildSectionContent(
      'Backup & Transfer:\n\n'
      '• Backup files contain your food history, settings, and a Transfer Key\n'
      '• Transfer Keys are valid for 30 days from creation\n'
      '• Each Transfer Key can only be used once\n'
      '• Using a Transfer Key transfers ALL Energy from the source device to the destination device '
      '(source device Energy becomes 0)\n'
      '• Only one active Transfer Key can exist per device — creating a new backup invalidates the previous key\n'
      '• We are not responsible for unauthorized use of your backup file or Transfer Key\n'
      '• Keep your backup file secure — anyone with the file can redeem your Energy',
    ),
    
    const SizedBox(height: 24),
    
    // ... sections อื่น ๆ ...
  ],
)
```

---

## ส่วนที่ 2: แก้ไข `terms-of-service.html` (ถ้ามี)

### 2.1 เปิดไฟล์ `docs/terms-of-service.html`

ถ้าโปรเจกต์มี HTML version ของ ToS (สำหรับ host บน GitHub Pages หรือ website)

### 2.2 ค้นหา Section "User Data and Responsibilities"

### 2.3 แก้ไขเหมือนกับใน `terms_screen.dart`

**ตัวอย่าง HTML:**

```html
<section>
  <h2>User Data and Responsibilities</h2>
  <ul>
    <li>Food data is stored locally on your device</li>
    <li>Energy balance is stored on our server, linked to your device identifier</li>
    <li>You can backup your data (Energy + Food History) using the Backup feature in Settings</li>
    <li>The backup file contains a one-time Transfer Key for moving Energy to a new device</li>
    <li>Photos are NOT included in backup files — they are stored on your device only</li>
    <li>If your photos are backed up via Google Photos or similar services, they may appear automatically on your new device, but this is not guaranteed</li>
    <li>We are NOT responsible for data loss due to:
      <ul>
        <li>Failure to create a backup before switching devices</li>
        <li>Lost or shared backup files</li>
        <li>Expired Transfer Keys (valid for 30 days)</li>
      </ul>
    </li>
    <li>Transfer Keys are single-use: once redeemed, the key becomes invalid</li>
    <li>Creating a new backup invalidates any previous unused Transfer Key</li>
  </ul>
</section>

<section>
  <h2>Backup & Transfer</h2>
  <ul>
    <li>Backup files contain your food history, settings, and a Transfer Key</li>
    <li>Transfer Keys are valid for 30 days from creation</li>
    <li>Each Transfer Key can only be used once</li>
    <li>Using a Transfer Key transfers ALL Energy from the source device to the destination device (source device Energy becomes 0)</li>
    <li>Only one active Transfer Key can exist per device — creating a new backup invalidates the previous key</li>
    <li>We are not responsible for unauthorized use of your backup file or Transfer Key</li>
    <li>Keep your backup file secure — anyone with the file can redeem your Energy</li>
  </ul>
</section>
```

---

## ส่วนที่ 3: Privacy Policy (ถ้าจำเป็น)

### 3.1 ตรวจสอบว่าต้องแก้ไข Privacy Policy หรือไม่

**ถามตัวเอง:**
- เราเก็บข้อมูลเพิ่มเติมหรือไม่? → **ไม่** (Transfer Key เก็บแค่ใน Firestore ชั่วคราว)
- เราส่งข้อมูลไปที่อื่นหรือไม่? → **ไม่** (ผู้ใช้ควบคุมไฟล์ backup เอง)
- มีการเปลี่ยนแปลงเรื่อง Data Storage หรือไม่? → **ไม่** (ยังเหมือนเดิม)

**สรุป:** ส่วนใหญ่**ไม่ต้องแก้ไข** Privacy Policy

ถ้าต้องการแก้ไข → เพิ่ม section นี้:

```
Data Export and Portability:
• You can export your data at any time using the Backup feature
• Backup files are stored on your device and under your control
• We do not automatically upload or store backup files on our servers
• Transfer Keys are stored temporarily (30 days) to facilitate device transfers
```

---

## ส่วนที่ 4: อัปเดต Version Number

### 4.1 เปิดไฟล์ `terms_screen.dart`

### 4.2 ค้นหา Version Number (ถ้ามี)

มักอยู่ด้านล่างของ Terms

**ตัวอย่าง:**
```dart
Text(
  'Last updated: January 15, 2026',
  style: TextStyle(fontSize: 12, color: Colors.grey),
),
```

### 4.3 อัปเดตวันที่

```dart
Text(
  'Last updated: February 15, 2026',  // อัปเดตเป็นวันที่ปัจจุบัน
  style: TextStyle(fontSize: 12, color: Colors.grey),
),
```

---

## ส่วนที่ 5: ทดสอบ

### 5.1 รัน App

```bash
flutter run
```

### 5.2 ไปที่ Profile → Terms of Service

### 5.3 ตรวจสอบ

- [ ] Section "User Data and Responsibilities" แสดงข้อความใหม่
- [ ] Section "Backup & Transfer" แสดงครบถ้วน
- [ ] ข้อความไม่เกิน Screen (scroll ได้)
- [ ] Font size อ่านง่าย
- [ ] ไม่มี Typo

---

## ส่วนที่ 6: Deploy (ถ้ามี Web Version)

### 6.1 ถ้ามี `docs/terms-of-service.html`

```bash
# Commit + Push
git add docs/terms-of-service.html
git commit -m "docs: update ToS for Backup & Transfer feature"
git push
```

### 6.2 ถ้าใช้ GitHub Pages

1. ไปที่ Repository Settings → Pages
2. ตรวจสอบว่า Deploy สำเร็จ
3. เปิด URL: `https://your-username.github.io/your-repo/terms-of-service.html`
4. ตรวจสอบว่าข้อความอัปเดตแล้ว

---

## ✅ Checklist

- [ ] แก้ไข `terms_screen.dart` → Section "User Data and Responsibilities"
- [ ] เพิ่ม Section "Backup & Transfer" ใน `terms_screen.dart`
- [ ] อัปเดตวันที่ "Last updated"
- [ ] ทดสอบ: เปิด Terms of Service ใน App → แสดงถูกต้อง
- [ ] ถ้ามี HTML version → แก้ไข `docs/terms-of-service.html`
- [ ] ถ้าใช้ GitHub Pages → Deploy แล้ว
- [ ] ตรวจสอบ Privacy Policy (ถ้าจำเป็น)

---

## 🎉 สำเร็จ!

Terms of Service อัปเดตเรียบร้อยแล้ว! ตอนนี้:
- ✅ ผู้ใช้รับทราบเรื่อง Transfer Key
- ✅ ผู้ใช้รับทราบว่ารูปภาพไม่รวมใน Backup
- ✅ ผู้ใช้รับทราบเรื่องความรับผิดชอบ (Data Loss)
- ✅ มีข้อความกฎหมายที่ครบถ้วน

➡️ **[ไปที่ Phase 6: Error Handling](./06_ERROR_HANDLING.md)**

---

## 🆘 หากมีปัญหา

### ไม่รู้ว่าจะเขียนยังไง
- ใช้ข้อความในคู่มือนี้ได้เลย (คัดลอกได้)
- ปรับให้เหมาะกับแอปของคุณ

### ต้องการ Legal Review
- ให้ทนายความตรวจสอบก่อน Deploy
- แนบคู่มือนี้ให้ทนายอ่าน

### มีคำถามเรื่อง Privacy Policy
- ใช้ตารางใน Section 3.1 ตัดสินใจ
- สอบถาม Data Protection Officer (ถ้ามี)

---

*Next: [06_ERROR_HANDLING.md](./06_ERROR_HANDLING.md)*
