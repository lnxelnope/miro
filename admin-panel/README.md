# MiRO Admin Panel - Quick Start Guide

## 🚀 Deploy to Google Cloud Run (Recommended)

### ⚡ Quick Deploy (One Command)

#### Windows (PowerShell):
```powershell
cd admin-panel
.\deploy-gcp.ps1
```

#### Linux/Mac (Bash):
```bash
cd admin-panel
chmod +x deploy-gcp.sh
./deploy-gcp.sh
```

---

## 📋 What the script does:

1. ✅ Checks if Google Cloud SDK is installed
2. ✅ Sets project to `miro-d6856`
3. ✅ Enables required APIs
4. ✅ Guides you to create secrets (if not exist)
5. ✅ Builds and deploys to Cloud Run
6. ✅ Shows you the deployed URL

---

## 🔐 First Time Setup (Do Once)

### 1. Install Google Cloud SDK

**Windows:**
```powershell
# Download from: https://cloud.google.com/sdk/docs/install
# Or run:
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
```

**Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

**Mac:**
```bash
brew install google-cloud-sdk
```

### 2. Login to Google Cloud
```bash
gcloud auth login
```

### 3. Create Secrets (First deployment only)

```bash
# 1. Firebase Project ID
echo -n "miro-d6856" | gcloud secrets create firebase-project-id --data-file=-

# 2. Firebase Client Email
echo -n "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com" | \
  gcloud secrets create firebase-client-email --data-file=-

# 3. Firebase Private Key
cat serviceAccountKey.json | jq -r .private_key | \
  gcloud secrets create firebase-private-key --data-file=-

# 4. Admin Username
echo -n "lnxelnope" | gcloud secrets create admin-username --data-file=-

# 5. Admin Password (change to strong password!)
echo -n "your-strong-password-here" | \
  gcloud secrets create admin-password --data-file=-

# 6. JWT Secret (random)
openssl rand -base64 32 | gcloud secrets create jwt-secret --data-file=-
```

### 4. Run Deploy Script
```powershell
# Windows
.\deploy-gcp.ps1

# Linux/Mac
./deploy-gcp.sh
```

---

## 🔄 Update & Redeploy

To update after code changes:
```bash
cd admin-panel
gcloud run deploy miro-admin-panel --source .
```

Or simply run the deploy script again:
```powershell
.\deploy-gcp.ps1
```

---

## 📊 Access Admin Panel

After deployment, you'll get a URL like:
```
https://miro-admin-panel-xxxxxxxx-as.a.run.app
```

### Features Available:
- ✅ **Dashboard** - Metrics & Analytics
- ✅ **User Management** - Search, Top-up, Ban/Unban, Reset Streak
- ✅ **Subscription Management** - Cancel, Extend, Activate
- ✅ **Config Management** - Promotions, Rewards, Challenges
- ✅ **Fraud Alerts** - Monitor suspicious activities
- ✅ **Notifications** - Send push notifications

---

## 🔍 Monitoring & Logs

### View Logs:
```bash
gcloud run services logs tail miro-admin-panel --region=asia-southeast1
```

### Console Links:
- **Monitoring:** https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel/metrics
- **Logs:** https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel/logs
- **Secret Manager:** https://console.cloud.google.com/security/secret-manager

---

## 💰 Cost (Very Low!)

- **Free Tier:** 2 million requests/month
- **Min instances:** 0 (pay only when used)
- **Estimated cost:** < 50 THB/month for typical admin usage

---

## 🔒 Security

- ✅ Secrets stored in Google Secret Manager
- ✅ No credentials in code or environment files
- ✅ HTTPS by default
- ✅ JWT authentication
- ✅ Service Account isolation

---

## 📚 Documentation

- **Full GCP Guide:** [DEPLOYMENT_GCP.md](./DEPLOYMENT_GCP.md)
- **Vercel Alternative:** [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 🆘 Need Help?

### Common Issues:

**"gcloud: command not found"**
- Install Google Cloud SDK (see step 1)

**"Secret not found"**
- Create secrets first (see step 3)

**"Permission denied"**
- Run `gcloud auth login`
- Make sure you have Owner or Editor role in project

**"Build failed"**
- Check logs: `gcloud builds list --limit=5`

---

## ✨ Quick Commands Cheat Sheet

```bash
# Deploy
gcloud run deploy miro-admin-panel --source .

# View logs
gcloud run services logs tail miro-admin-panel --region=asia-southeast1

# Get URL
gcloud run services describe miro-admin-panel --region=asia-southeast1 --format='value(status.url)'

# Update secret
echo -n "new-value" | gcloud secrets versions add secret-name --data-file=-

# Delete service
gcloud run services delete miro-admin-panel --region=asia-southeast1
```

---

**Ready to deploy? Run `.\deploy-gcp.ps1` now! 🚀**
