# Deploy Admin Panel → Google Cloud Run

โปรเจกต์: **`miro-d6856`** · Service: **`admin-panel`** · Region: **`asia-southeast1`**

แอปใช้ **Auth.js + Google OAuth** + **Firebase Admin** + **Cloud Translation API** — ไม่ใช้ `ADMIN_USERNAME` / `JWT_SECRET` แบบเก่าแล้ว

---

## ครั้งแรก: สร้าง Secret Manager

ล็อกอินและตั้งโปรเจกต์:

```bash
gcloud auth login
gcloud config set project miro-d6856
gcloud services enable secretmanager.googleapis.com run.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com translate.googleapis.com
```

สร้าง secret (แก้ค่าตามของจริง):

```bash
# 1) Session signing (openssl rand -base64 32)
openssl rand -base64 32 | gcloud secrets create nextauth-secret --data-file=-

# 2–3) Google OAuth (Web client จาก Google Cloud Console)
echo -n 'YOUR_GOOGLE_CLIENT_ID' | gcloud secrets create google-client-id --data-file=-
echo -n 'YOUR_GOOGLE_CLIENT_SECRET' | gcloud secrets create google-client-secret --data-file=-

# 4) อีเมล admin คั่นด้วย comma
echo -n 'you@gmail.com' | gcloud secrets create allowed-admin-emails --data-file=-

# 5) URL จริงของ Cloud Run (ไม่มี slash ท้ายหรือมีก็ได้ ให้ตรงกับที่เปิดในเบราว์เซอร์)
echo -n 'https://admin-panel-XXXX.asia-southeast1.run.app' | gcloud secrets create nextauth-url --data-file=-

# 6–7) Firebase Admin (จาก service account JSON — เดียวกับ Firestore)
echo -n 'firebase-adminsdk-xxxxx@miro-d6856.iam.gserviceaccount.com' | gcloud secrets create firebase-client-email --data-file=-
# private_key จาก JSON (ทั้งบล็อก PEM รวม \n)
jq -r '.private_key' serviceAccountKey.json | gcloud secrets create firebase-private-key --data-file=-
```

ถ้า secret มีอยู่แล้ว ใช้เวอร์ชันใหม่แทน:

```bash
echo -n 'new-value' | gcloud secrets versions add nextauth-url --data-file=-
```

---

## ให้ Cloud Run อ่าน secret ได้

```bash
chmod +x scripts/grant-secret-access-for-cloud-run.sh
./scripts/grant-secret-access-for-cloud-run.sh
```

---

## Google OAuth — Redirect URI

ใน [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=miro-d6856) ใส่ **Authorized redirect URI**:

`https://<YOUR-CLOUD-RUN-HOST>/api/auth/callback/google`

---

## Cloud Translation

- เปิด [Cloud Translation API](https://console.cloud.google.com/apis/library/translate.googleapis.com?project=miro-d6856)
- IAM → service account `firebase-adminsdk-...` → role **Cloud Translation API User** (`roles/cloudtranslate.user`)

---

## Deploy

จากโฟลเดอร์ `admin-panel/`:

### แบบมี Docker บนเครื่อง (build local → push GCR)

```bash
chmod +x deploy.sh deploy-cloud-build.sh scripts/grant-secret-access-for-cloud-run.sh
./deploy.sh
```

ต้องติดตั้ง [Docker Desktop](https://www.docker.com/products/docker-desktop/) แล้วเปิดแอปให้สถานะ Running

### แบบไม่มี Docker (แนะนำถ้ายังไม่ติดตั้ง Docker)

ให้ GCP build ให้บน Cloud Build:

```bash
./deploy-cloud-build.sh
```

ใช้ `Dockerfile` ในโฟลเดอร์เดียวกัน — อาจใช้เวลา 5–15 นาทีครั้งแรก

---

## หลัง deploy ครั้งแรก

ถ้าสร้าง `nextauth-url` ก่อนมี URL จริง ให้อัปเดต secret เป็น URL ที่ `gcloud run services describe` แสดง แล้ว deploy ใหม่

## Error: FIREBASE_PROJECT_ID “different type”

ถ้าเคย deploy แบบผูก `FIREBASE_PROJECT_ID` เป็น **secret** สคริปต์จะรัน `gcloud run services update … --remove-secrets=FIREBASE_PROJECT_ID` ก่อน deploy อัตโนมัติ  
ถ้ายังติด รันด้วยมือแล้วค่อย `./deploy-cloud-build.sh` อีกครั้ง:

```bash
gcloud run services update admin-panel --region asia-southeast1 --project miro-d6856 --remove-secrets=FIREBASE_PROJECT_ID
```
