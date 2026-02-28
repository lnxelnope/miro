# MiRO Admin Panel - Google Cloud Platform Deployment

## 🚀 Deploy to Google Cloud Run

เนื่องจาก MiRO ใช้ Firebase อยู่แล้ว การ deploy ไป GCP จะทำให้:
- ✅ อยู่ใน project เดียวกัน (`miro-d6856`)
- ✅ ดูแลรักษาง่าย centralized management
- ✅ มี Google Analytics & Monitoring ในตัว
- ✅ ใช้ Service Account เดียวกัน
- ✅ แชร์ IAM permissions

---

## 📋 Prerequisites

1. Google Cloud SDK (gcloud CLI)
2. Docker (สำหรับ build container)
3. Firebase Service Account Key
4. Admin credentials

---

## 🛠️ Step 1: ติดตั้ง Google Cloud SDK

### Windows:
```powershell
# Download และติดตั้งจาก:
# https://cloud.google.com/sdk/docs/install

# หรือใช้ PowerShell:
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
```

### Verify installation:
```bash
gcloud --version
```

---

## 🔐 Step 2: Login และตั้งค่า Project

```bash
# Login
gcloud auth login

# Set project เป็น miro-d6856
gcloud config set project miro-d6856

# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

---

## 📦 Step 3: สร้าง Dockerfile

ไฟล์นี้อยู่ที่ `admin-panel/Dockerfile` แล้ว (จะสร้างให้ในขั้นตอนถัดไป)

---

## 🏗️ Step 4: สร้าง Production Build Configuration

### Create `.env.production` (สำหรับ build time)
```env
# ไม่ต้องใส่ sensitive data ที่นี่
NODE_ENV=production
NEXT_PUBLIC_APP_NAME=MiRO Admin Panel
```

### Environment Variables จะถูกตั้งผ่าน Cloud Run Secrets

---

## 🚀 Step 5: Deploy to Cloud Run

### Option A: Deploy แบบ One-Command (Recommended)

```bash
cd admin-panel

gcloud run deploy miro-admin-panel \
  --source . \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 10 \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --set-env-vars "NODE_ENV=production" \
  --set-secrets "FIREBASE_PROJECT_ID=firebase-project-id:latest" \
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest" \
  --set-secrets "FIREBASE_PRIVATE_KEY=firebase-private-key:latest" \
  --set-secrets "ADMIN_USERNAME=admin-username:latest" \
  --set-secrets "ADMIN_PASSWORD=admin-password:latest" \
  --set-secrets "JWT_SECRET=jwt-secret:latest"
```

**หมายเหตุ:** ต้องสร้าง Secrets ใน Secret Manager ก่อน (ดู Step 6)

### Option B: Deploy แบบ Manual (2 Steps)

#### 1. Build Container
```bash
cd admin-panel

# Build with Cloud Build
gcloud builds submit --tag gcr.io/miro-d6856/admin-panel
```

#### 2. Deploy to Cloud Run
```bash
gcloud run deploy miro-admin-panel \
  --image gcr.io/miro-d6856/admin-panel \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 10 \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --update-env-vars NODE_ENV=production \
  --update-secrets=FIREBASE_PROJECT_ID=firebase-project-id:latest \
  --update-secrets=FIREBASE_CLIENT_EMAIL=firebase-client-email:latest \
  --update-secrets=FIREBASE_PRIVATE_KEY=firebase-private-key:latest \
  --update-secrets=ADMIN_USERNAME=admin-username:latest \
  --update-secrets=ADMIN_PASSWORD=admin-password:latest \
  --update-secrets=JWT_SECRET=jwt-secret:latest
```

---

## 🔒 Step 6: Setup Secret Manager

### Create Secrets (ทำครั้งเดียว)

```bash
# 1. Firebase Project ID
echo -n "miro-d6856" | gcloud secrets create firebase-project-id --data-file=-

# 2. Firebase Client Email
echo -n "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com" | \
  gcloud secrets create firebase-client-email --data-file=-

# 3. Firebase Private Key (copy จาก .env.local)
cat <<'EOF' | gcloud secrets create firebase-private-key --data-file=-
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDULxN3KREL1tCF
... (rest of your private key) ...
-----END PRIVATE KEY-----
EOF

# 4. Admin Username
echo -n "lnxelnope" | gcloud secrets create admin-username --data-file=-

# 5. Admin Password (ควรเปลี่ยนเป็นรหัสผ่านที่แข็งแรง)
echo -n "6six6yesonly" | gcloud secrets create admin-password --data-file=-

# 6. JWT Secret (generate random string)
openssl rand -base64 32 | gcloud secrets create jwt-secret --data-file=-
```

### Grant Access to Cloud Run Service Account
```bash
# Get project number
PROJECT_NUMBER=$(gcloud projects describe miro-d6856 --format="value(projectNumber)")

# Grant secret accessor role
gcloud secrets add-iam-policy-binding firebase-project-id \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding firebase-client-email \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding firebase-private-key \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding admin-username \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding admin-password \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding jwt-secret \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

---

## 📊 Step 7: Setup Monitoring & Analytics

### Enable Cloud Monitoring
```bash
gcloud services enable monitoring.googleapis.com
gcloud services enable logging.googleapis.com
```

### View Logs
```bash
# Real-time logs
gcloud run services logs tail miro-admin-panel --region=asia-southeast1

# View in Console
# https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel/logs
```

### Monitoring Dashboard
Access at: https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel/metrics

Metrics available:
- Request count
- Request latency
- Memory utilization
- CPU utilization
- Error rate
- Container instance count

---

## 🌐 Step 8: Custom Domain (Optional)

### Map custom domain to Cloud Run

```bash
# Add domain mapping
gcloud run domain-mappings create \
  --service miro-admin-panel \
  --domain admin.yourdomain.com \
  --region asia-southeast1
```

จากนั้น add DNS records ตามที่ GCP แจ้ง

---

## 🔄 Step 9: CI/CD with Cloud Build

### Create `cloudbuild.yaml`

```yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/miro-d6856/admin-panel', '.']
  
  # Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/miro-d6856/admin-panel']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'miro-admin-panel'
      - '--image'
      - 'gcr.io/miro-d6856/admin-panel'
      - '--region'
      - 'asia-southeast1'
      - '--platform'
      - 'managed'

images:
  - 'gcr.io/miro-d6856/admin-panel'
```

### Trigger build from Git
```bash
gcloud builds submit --config cloudbuild.yaml
```

---

## ✅ Verify Deployment

1. Get service URL:
```bash
gcloud run services describe miro-admin-panel \
  --region asia-southeast1 \
  --format 'value(status.url)'
```

2. Open URL in browser
3. Test login with admin credentials
4. Verify all features work

---

## 🔧 Update & Redeploy

### Update code and redeploy:
```bash
cd admin-panel
gcloud run deploy miro-admin-panel --source .
```

### Update secrets:
```bash
# Update admin password
echo -n "new-password" | \
  gcloud secrets versions add admin-password --data-file=-

# Redeploy automatically picks up latest secret version
```

---

## 💰 Cost Optimization

Cloud Run Pricing (ณ 2026):
- **Free Tier:** 2 million requests/month
- **Pay per use:** ไม่มี traffic = ไม่เสียเงิน
- **Min instances = 0:** ประหยัดสุด

Recommended settings:
```bash
--min-instances 0          # Scale to zero when idle
--max-instances 10         # Prevent runaway costs
--memory 512Mi             # Enough for Next.js
--cpu 1                    # 1 vCPU
--timeout 300              # 5 minutes max
```

---

## 📊 Access Control & Security

### Restrict access by IP (Optional)
```bash
# Create VPC Connector first
gcloud compute networks vpc-access connectors create miro-connector \
  --region asia-southeast1 \
  --range 10.8.0.0/28

# Update service to use connector
gcloud run services update miro-admin-panel \
  --vpc-connector miro-connector \
  --region asia-southeast1
```

### Enable Cloud Armor (DDoS protection)
```bash
gcloud compute security-policies create admin-panel-policy
gcloud compute security-policies rules create 1000 \
  --security-policy admin-panel-policy \
  --expression "origin.region_code == 'TH'" \
  --action "allow"
```

---

## 🐛 Troubleshooting

### View detailed logs:
```bash
gcloud run services logs read miro-admin-panel \
  --region asia-southeast1 \
  --limit 50
```

### Debug container locally:
```bash
docker build -t admin-panel .
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e FIREBASE_PROJECT_ID=miro-d6856 \
  admin-panel
```

### Common Issues:

**Error: Secret not found**
- Solution: สร้าง secrets ใน Secret Manager ก่อน (Step 6)

**Error: Permission denied**
- Solution: Grant IAM roles to service account

**Error: Build failed**
- Solution: Check `Dockerfile` และ dependencies

---

## 🔗 Useful GCP Console Links

- **Cloud Run Dashboard:** https://console.cloud.google.com/run
- **Secret Manager:** https://console.cloud.google.com/security/secret-manager
- **Container Registry:** https://console.cloud.google.com/gcr
- **Cloud Build History:** https://console.cloud.google.com/cloud-build
- **Monitoring:** https://console.cloud.google.com/monitoring
- **Logs Explorer:** https://console.cloud.google.com/logs

---

## 📈 Monitoring & Alerts

### Create Alert for Errors
```bash
# In GCP Console:
# Monitoring → Alerting → Create Policy
# Metric: Cloud Run → Request count (filtered by response code 5xx)
# Threshold: > 10 errors in 5 minutes
# Notification: Email
```

### Cost Budget Alert
```bash
# Billing → Budgets & alerts
# Set budget: 1,000 THB/month
# Alert at: 50%, 80%, 100%
```

---

## 🎯 Next Steps

1. ✅ Deploy to Cloud Run
2. ✅ Setup monitoring & alerts
3. ✅ Configure custom domain (optional)
4. ✅ Setup CI/CD with Cloud Build
5. ✅ Test all features in production
6. ✅ Monitor logs and metrics

---

**Last Updated:** 2026-02-18  
**Version:** 1.0.0  
**Platform:** Google Cloud Run  
**Region:** asia-southeast1 (Singapore)
