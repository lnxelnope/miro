# Setup Google OAuth for MiRO Admin Panel

## 🔐 Create Google OAuth Credentials

### Step 1: Go to Google Cloud Console
https://console.cloud.google.com/apis/credentials?project=miro-d6856

### Step 2: Create OAuth 2.0 Client ID

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**

2. **Application type:** Web application

3. **Name:** MiRO Admin Panel

4. **Authorized JavaScript origins:**
   - http://localhost:3000
   - https://admin-panel-65396857547.asia-southeast1.run.app

5. **Authorized redirect URIs:**
   - http://localhost:3000/api/auth/callback/google
   - https://admin-panel-65396857547.asia-southeast1.run.app/api/auth/callback/google

6. Click **CREATE**

7. Copy:
   - **Client ID**
   - **Client Secret**

---

## 🔧 Step 3: Add Secrets to GCP Secret Manager

```powershell
# 1. NEXTAUTH_SECRET (generate random)
$bytes = New-Object byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes) | gcloud secrets create nextauth-secret --data-file=-

# 2. Google Client ID (paste ที่ได้จาก Google Console)
Write-Output "YOUR_GOOGLE_CLIENT_ID" | gcloud secrets create google-client-id --data-file=-

# 3. Google Client Secret (paste ที่ได้จาก Google Console)
Write-Output "YOUR_GOOGLE_CLIENT_SECRET" | gcloud secrets create google-client-secret --data-file=-

# 4. Allowed Admin Emails
Write-Output "lnxelnope@gmail.com" | gcloud secrets create allowed-admin-emails --data-file=-

# 5. NextAuth URL (production)
Write-Output "https://admin-panel-65396857547.asia-southeast1.run.app" | gcloud secrets create nextauth-url --data-file=-
```

---

## 🔑 Step 4: Grant Secret Access

```powershell
$secrets = @("nextauth-secret", "google-client-id", "google-client-secret", "allowed-admin-emails", "nextauth-url")
foreach ($secret in $secrets) {
  gcloud secrets add-iam-policy-binding $secret `
    --member="serviceAccount:65396857547-compute@developer.gserviceaccount.com" `
    --role="roles/secretmanager.secretAccessor"
}
```

---

## 🚀 Step 5: Update Cloud Run Service

```powershell
cd admin-panel

gcloud run services update admin-panel `
  --region asia-southeast1 `
  --update-secrets="NEXTAUTH_URL=nextauth-url:latest,NEXTAUTH_SECRET=nextauth-secret:latest,GOOGLE_CLIENT_ID=google-client-id:latest,GOOGLE_CLIENT_SECRET=google-client-secret:latest,ALLOWED_ADMIN_EMAILS=allowed-admin-emails:latest"
```

---

## 🎯 Step 6: Deploy

```powershell
gcloud run deploy admin-panel --source . --region asia-southeast1
```

---

## ✅ Done!

Access: https://admin-panel-65396857547.asia-southeast1.run.app

You'll see **"Sign in with Google"** button

Only **lnxelnope@gmail.com** can login (you can add more emails later)

---

## 👥 Add More Admins Later

```powershell
# Add more emails (comma-separated)
Write-Output "lnxelnope@gmail.com,admin2@gmail.com,admin3@gmail.com" | `
  gcloud secrets versions add allowed-admin-emails --data-file=-

# Redeploy
gcloud run services update admin-panel --region asia-southeast1
```
