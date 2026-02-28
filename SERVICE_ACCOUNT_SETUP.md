# 🔐 Service Account Setup for Google Play API

## สถานการณ์
Error: `insufficient permissions to perform the requested operation`

## สาเหตุ
Service Account ยังไม่ได้ permissions ใน Google Play Console

---

## ✅ วิธีแก้ (เลือก 1 วิธี)

### Option 1: ใช้ Firebase Admin SDK (แนะนำ!)

#### Step 1: หา Service Account Email

1. ไปที่: https://console.firebase.google.com/project/miro-d6856/settings/serviceaccounts
2. จะเห็น email แบบนี้:
   ```
   firebase-adminsdk-xxxxx@miro-d6856.iam.gserviceaccount.com
   ```
3. **Copy email นี้ไว้**

#### Step 2: เพิ่มใน Google Play Console

1. ไปที่: https://play.google.com/console
2. เลือกแอป **MiRO** (com.tanabun.miro)
3. เมนูซ้าย → **Setup** → **API access**
4. หาส่วน **Service accounts**
5. คลิก **"Link existing service account"**
6. Paste email ที่ copy ไว้
7. คลิก **"Link"**

#### Step 3: Grant Permissions

1. คลิกที่ service account ที่เพิ่งเพิ่ม
2. คลิก **"Grant access"** หรือ **"Manage permissions"**
3. เลือก **App permissions**
4. เลือกแอป: **MiRO**
5. Check permissions เหล่านี้:
   - ✅ **View financial data**
   - ✅ **Manage orders and subscriptions**
   - หรือ ✅ **Admin (all permissions)** ถ้าต้องการครบ
6. คลิก **"Apply"** → **"Save"**

#### Step 4: รอและทดสอบ

- รอ **5-10 นาที** ให้ permissions มีผล
- ลองซื้อ subscription อีกครั้ง
- ถ้ายังไม่ได้ รอ 30 นาที แล้วลองใหม่

---

### Option 2: สร้าง Service Account ใหม่

#### Step 1: สร้างใน Google Cloud Console

1. ไปที่: https://console.cloud.google.com/iam-admin/serviceaccounts?project=miro-d6856
2. คลิก **"Create Service Account"**
3. ตั้งชื่อ: `google-play-api`
4. Description: `For Google Play API access`
5. คลิก **"Create and continue"**

#### Step 2: Grant Role (ใน GCP)

1. เลือก Role: **Service Account User**
2. คลิก **"Continue"**
3. คลิก **"Done"**

#### Step 3: สร้าง Key

1. คลิกที่ service account ที่สร้าง
2. Tab **"Keys"**
3. คลิก **"Add Key"** → **"Create new key"**
4. เลือก **JSON**
5. คลิก **"Create"**
6. ไฟล์ JSON จะถูก download

#### Step 4: เพิ่มใน Firebase Secrets

```bash
cd c:\aiprogram\miro

# อ่านไฟล์ JSON
Get-Content "C:\Users\ASUS\Downloads\miro-d6856-xxx.json" | Set-Clipboard

# เพิ่มเป็น Secret
firebase functions:secrets:set GOOGLE_SERVICE_ACCOUNT_JSON
# Paste JSON ที่ copy ไว้ แล้วกด Ctrl+Z แล้ว Enter
```

#### Step 5: เพิ่มใน Google Play Console

ทำตาม **Option 1 Step 2-4** โดยใช้ email ของ service account ใหม่

#### Step 6: อัปเดตโค้ด (ถ้าใช้ JSON file)

```typescript
// functions/src/subscription/verifySubscription.ts

// เปลี่ยนจาก:
const serviceAccountPath = path.join(__dirname, '..', 'secrets', 'google-play-service-account.json');

// เป็น:
const serviceAccountJson = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
const serviceAccount = JSON.parse(serviceAccountJson || '{}');
```

แล้ว deploy ใหม่:
```bash
cd functions
npm run build
cd ..
firebase deploy --only functions:verifySubscription
```

---

## 🧪 ทดสอบ

### วิธี 1: ผ่านแอป
1. เปิดแอป MiRO
2. ไปหน้า Energy Store
3. กดซื้อ Energy Pass
4. ดู Firebase Console → Functions logs
5. ถ้าสำเร็จ จะเห็น: `✅ [Subscription] Verified`

### วิธี 2: ผ่าน curl (ถ้ามี test token)
```bash
curl -X POST https://verifysubscription-lkfwupvm7a-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "YOUR_DEVICE_ID",
    "purchaseToken": "TEST_TOKEN",
    "productId": "energy_pass_monthly"
  }'
```

---

## ❓ Troubleshooting

### Error: "insufficient permissions"
- ✅ เช็คว่า service account ถูก link ใน Play Console แล้ว
- ✅ เช็คว่า grant permissions แล้ว (View financial data + Manage subscriptions)
- ✅ รอ 10-30 นาที ให้ permissions มีผล
- ✅ ลอง revoke แล้ว grant ใหม่

### Error: "invalid credentials"
- ✅ เช็คว่า service account JSON ถูกต้อง
- ✅ เช็คว่า secret ใน Firebase ถูกต้อง
- ✅ ลอง generate key ใหม่

### Error: "purchase not found"
- ✅ เช็คว่า package name ตรงกับที่ตั้งใน Play Console
- ✅ เช็คว่า product ID ถูกต้อง: `energy_pass_monthly`
- ✅ เช็คว่าเป็น purchase token จริง (ไม่ใช่ test token)

---

## 📞 Links

- Firebase Console: https://console.firebase.google.com/project/miro-d6856
- Google Cloud Console: https://console.cloud.google.com/iam-admin/serviceaccounts?project=miro-d6856
- Play Console: https://play.google.com/console
- Function URL: https://verifysubscription-lkfwupvm7a-uc.a.run.app

---

## ✅ Checklist

- [ ] Service account created
- [ ] Service account linked to Play Console
- [ ] Permissions granted (View financial + Manage subscriptions)
- [ ] Wait 10-30 minutes
- [ ] Test purchase
- [ ] Check Firebase logs
- [ ] Verify subscription in Firestore

---

สำเร็จแล้ว! 🎉
