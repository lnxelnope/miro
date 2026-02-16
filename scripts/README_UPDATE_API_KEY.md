# 🔄 Update Gemini API Key Scripts

สคริปต์สำหรับอัพเดท Gemini API Key ลง Google Cloud Secret Manager อย่างปลอดภัย

---

## 📋 Prerequisites

ติดตั้ง Google Cloud SDK:

### Windows
```powershell
# ดาวน์โหลดและติดตั้ง
# https://cloud.google.com/sdk/docs/install

# หรือใช้ Chocolatey
choco install gcloudsdk
```

### macOS
```bash
brew install google-cloud-sdk
```

### Linux
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

---

## 🔐 Authentication

Login ก่อนใช้งาน:

```bash
gcloud auth login
```

---

## 🚀 Usage

### Windows (PowerShell)

```powershell
cd c:\aiprogram\miro
.\scripts\update-gemini-api-key.ps1
```

### macOS / Linux (Bash)

```bash
cd /path/to/miro
chmod +x scripts/update-gemini-api-key.sh
./scripts/update-gemini-api-key.sh
```

---

## 📝 Step-by-Step Guide

### 1. เตรียม API Key ใหม่

1. ไปที่ [Google AI Studio](https://aistudio.google.com/app/apikey)
2. สร้าง API Key ใหม่
3. คัดลอก key (รูปแบบ: `AIzaSy...` ยาว 39 ตัวอักษร)
4. **ยังไม่ต้องลบ key เก่า** (รอจน deploy เสร็จก่อน)

### 2. รันสคริปต์

#### PowerShell (Windows):
```powershell
.\scripts\update-gemini-api-key.ps1
```

สคริปต์จะถาม:
```
Paste your new Gemini API key: [พิมพ์ key ตรงนี้]
```

#### Bash (Mac/Linux):
```bash
./scripts/update-gemini-api-key.sh
```

### 3. Deploy Cloud Functions

หลังจากอัพเดท secret แล้ว:

#### ถ้าใช้ Firebase:
```bash
firebase deploy --only functions
```

#### ถ้าใช้ gcloud:
```bash
gcloud functions deploy analyzeFood \
  --region=us-central1 \
  --trigger-http \
  --allow-unauthenticated
```

### 4. Test API Key ใหม่

```bash
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -H "x-energy-token: YOUR_TOKEN" \
  -H "x-device-id: test-device" \
  -d '{"type":"text","prompt":"Analyze: Apple"}'
```

ถ้าได้ response ปกติ = สำเร็จ!

### 5. Revoke API Key เก่า

เมื่อ test แล้วใช้งานได้:
1. กลับไปที่ [Google AI Studio](https://aistudio.google.com/app/apikey)
2. หา key เก่า (ที่เคย expose)
3. กด **Delete** หรือ **Revoke**
4. ยืนยันการลบ

---

## 🔍 Verify Secret

ตรวจสอบว่า secret ถูกตั้งค่าแล้ว:

```bash
# List all secrets
gcloud secrets list --project=miro-d6856

# View secret metadata (ไม่แสดงค่าจริง)
gcloud secrets describe GEMINI_API_KEY --project=miro-d6856

# View secret versions
gcloud secrets versions list GEMINI_API_KEY --project=miro-d6856
```

---

## 🛠️ สคริปต์ทำอะไรบ้าง?

### ขั้นตอนที่ 1: Authentication Check
- ตรวจสอบว่าคุณ login gcloud แล้ว
- แสดง account ที่ใช้งานอยู่

### ขั้นตอนที่ 2: Set Project
- ตั้งค่า project เป็น `miro-d6856`

### ขั้นตอนที่ 3: Check Secret
- ตรวจสอบว่า secret `GEMINI_API_KEY` มีอยู่แล้วหรือยัง

### ขั้นตอนที่ 4: Validate API Key
- รับ input API key จากคุณ (แบบ secure)
- ตรวจสอบ format: `AIza[a-zA-Z0-9_-]{35}`
- ยาวต้อง 39 ตัวอักษรพอดี

### ขั้นตอนที่ 5: Update Secret
- ถ้ามี secret อยู่แล้ว → สร้าง version ใหม่
- ถ้าไม่มี → สร้าง secret ใหม่
- ตั้ง replication policy เป็น automatic

### ขั้นตอนที่ 6: Grant Access
- ให้สิทธิ์ Cloud Functions service account
- Role: `roles/secretmanager.secretAccessor`
- Account: `{PROJECT_NUMBER}-compute@developer.gserviceaccount.com`

---

## ⚠️ Troubleshooting

### Error: "Not authenticated"
```bash
gcloud auth login
```

### Error: "Permission denied"
ต้องมีสิทธิ์:
- `roles/secretmanager.admin` (สำหรับสร้าง/อัพเดท secrets)
- `roles/iam.securityAdmin` (สำหรับให้สิทธิ์ service account)

ตรวจสอบสิทธิ์:
```bash
gcloud projects get-iam-policy miro-d6856 \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"
```

### Error: "Secret already exists"
ใช้ version ใหม่แทน:
```bash
echo "YOUR_NEW_KEY" | gcloud secrets versions add GEMINI_API_KEY \
  --project=miro-d6856 \
  --data-file=-
```

### Error: "Invalid API key format"
- ตรวจสอบว่า key ขึ้นต้นด้วย `AIza`
- ยาว 39 ตัวอักษรพอดี
- ไม่มีช่องว่างหรือ newline

---

## 🔒 Security Notes

### ✅ สคริปต์ปลอดภัยเพราะ:
1. **Input แบบ secure** - ไม่แสดง key ตอนพิมพ์
2. **ไม่ log ลง console** - ไม่มี echo/print key
3. **Clear จาก memory** - unset variable หลังใช้
4. **ใช้ temp file** - ลบทิ้งทันทีหลังใช้
5. **Validate format** - ตรวจสอบ pattern ก่อนบันทึก

### ⚠️ อย่าทำ:
- ❌ อย่า copy-paste key ลง chat/email
- ❌ อย่า screenshot ตอนพิมพ์ key
- ❌ อย่า commit script ที่มี key hardcode
- ❌ อย่าเปิด screen share ตอนรัน script

---

## 📚 Manual Commands

ถ้าไม่ต้องการใช้ script สามารถรันเองได้:

### Create Secret
```bash
echo "YOUR_NEW_API_KEY" | gcloud secrets create GEMINI_API_KEY \
  --project=miro-d6856 \
  --replication-policy="automatic" \
  --data-file=-
```

### Add New Version
```bash
echo "YOUR_NEW_API_KEY" | gcloud secrets versions add GEMINI_API_KEY \
  --project=miro-d6856 \
  --data-file=-
```

### Grant Access
```bash
PROJECT_NUMBER=$(gcloud projects describe miro-d6856 --format="value(projectNumber)")

gcloud secrets add-iam-policy-binding GEMINI_API_KEY \
  --project=miro-d6856 \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

---

## 📞 Support

หากมีปัญหา:
1. ตรวจสอบ [SECURITY_AUDIT_REPORT.md](../SECURITY_AUDIT_REPORT.md)
2. ดู gcloud logs: `gcloud functions logs read analyzeFood`
3. ตรวจสอบ IAM permissions: `gcloud projects get-iam-policy miro-d6856`

---

**เวอร์ชัน:** 1.0  
**อัพเดทล่าสุด:** 16 กุมภาพันธ์ 2026
