# 🚀 Quick Start - Deploy Admin Panel

## ขั้นตอนการ Deploy

### 1. Setup Secrets (ทำครั้งแรกเท่านั้น)

**Windows (PowerShell):**
```powershell
cd admin-panel
.\setup-secrets.ps1
```

**Linux/Mac (Bash):**
```bash
cd admin-panel
chmod +x setup-secrets.sh
./setup-secrets.sh
```

หรือทำ manual:
```bash
# Set project
gcloud config set project miro-d6856

# Create secrets
echo -n "your-value" | gcloud secrets create SECRET_NAME --data-file=-

# Grant Cloud Run access
gcloud secrets add-iam-policy-binding SECRET_NAME \
  --member="serviceAccount:miro-d6856@appspot.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### 2. Deploy

**Windows (PowerShell):**
```powershell
.\deploy.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x deploy.sh
./deploy.sh
```

**วิธีที่ 2: ใช้ Cloud Build**
```bash
gcloud builds submit --config cloudbuild.yaml
```

**วิธีที่ 3: Manual**

**Windows (PowerShell):**
```powershell
# Build & Push
docker build -t gcr.io/miro-d6856/admin-panel:latest .
docker push gcr.io/miro-d6856/admin-panel:latest

# Deploy
gcloud run deploy admin-panel `
  --image gcr.io/miro-d6856/admin-panel:latest `
  --platform managed `
  --region asia-southeast1 `
  --allow-unauthenticated `
  --memory 512Mi `
  --set-env-vars "FIREBASE_PROJECT_ID=miro-d6856,NODE_ENV=production" `
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"
```

**Linux/Mac (Bash):**
```bash
# Build & Push
docker build -t gcr.io/miro-d6856/admin-panel:latest .
docker push gcr.io/miro-d6856/admin-panel:latest

# Deploy
gcloud run deploy admin-panel \
  --image gcr.io/miro-d6856/admin-panel:latest \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --set-env-vars "FIREBASE_PROJECT_ID=miro-d6856,NODE_ENV=production" \
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"
```

### 3. Get Service URL

```bash
gcloud run services describe admin-panel \
  --region asia-southeast1 \
  --format 'value(status.url)'
```

## Secrets ที่ต้องสร้าง

1. `firebase-client-email` - Firebase Admin SDK client email
2. `firebase-private-key` - Firebase Admin SDK private key
3. `admin-username` - Admin panel username
4. `admin-password` - Admin panel password
5. `jwt-secret` - JWT secret key

## Troubleshooting

**Build fails:**
- Check Docker is running: `docker ps`
- Login to GCP: `gcloud auth login`
- Configure Docker: `gcloud auth configure-docker`

**Deployment fails:**
- Enable APIs: `gcloud services enable run.googleapis.com cloudbuild.googleapis.com`
- Check permissions
- View logs: `gcloud run services logs read admin-panel --region asia-southeast1`

## ดูรายละเอียดเพิ่มเติม

ดูไฟล์ `DEPLOYMENT.md` สำหรับรายละเอียดเพิ่มเติม
