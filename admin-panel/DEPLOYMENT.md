# Admin Panel Deployment Guide

## Prerequisites

1. **Google Cloud SDK** installed and configured
2. **Docker** installed
3. **GCP Project**: `miro-d6856`
4. **Required APIs enabled**:
   - Cloud Build API
   - Cloud Run API
   - Container Registry API

## Setup Secrets in Secret Manager

Before deploying, you need to create secrets in Google Secret Manager:

```bash
# Set your project
gcloud config set project miro-d6856

# Create secrets (replace values with actual secrets)
echo -n "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com" | \
  gcloud secrets create firebase-admin-key --data-file=-

echo -n "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----" | \
  gcloud secrets create firebase-admin-key --data-file=-

echo -n "your-admin-username" | \
  gcloud secrets create admin-credentials --data-file=-

echo -n "your-admin-password" | \
  gcloud secrets create admin-credentials --data-file=-

echo -n "your-jwt-secret-key" | \
  gcloud secrets create jwt-secret --data-file=-
```

**Note**: For `firebase-admin-key`, you need to create a secret with multiple versions:
- Version 1: `FIREBASE_CLIENT_EMAIL`
- Version 2: `FIREBASE_PRIVATE_KEY`

Or create separate secrets:
```bash
# Client Email
echo -n "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com" | \
  gcloud secrets create firebase-client-email --data-file=-

# Private Key
echo -n "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----" | \
  gcloud secrets create firebase-private-key --data-file=-
```

## Deployment Methods

### Method 1: Using Deployment Scripts (Recommended)

**Windows (PowerShell):**
```powershell
cd admin-panel
.\setup-secrets.ps1  # First time only
.\deploy.ps1
```

**Linux/Mac (Bash):**
```bash
cd admin-panel
chmod +x setup-secrets.sh deploy.sh
./setup-secrets.sh  # First time only
./deploy.sh
```

### Method 2: Using Cloud Build

```bash
cd admin-panel
gcloud builds submit --config cloudbuild.yaml
```

### Method 3: Manual Deployment

**Windows (PowerShell):**
```powershell
# 1. Build Docker image
docker build -t gcr.io/miro-d6856/admin-panel:latest .

# 2. Push to Container Registry
docker push gcr.io/miro-d6856/admin-panel:latest

# 3. Deploy to Cloud Run
gcloud run deploy admin-panel `
  --image gcr.io/miro-d6856/admin-panel:latest `
  --platform managed `
  --region asia-southeast1 `
  --allow-unauthenticated `
  --memory 512Mi `
  --cpu 1 `
  --max-instances 10 `
  --set-env-vars "FIREBASE_PROJECT_ID=miro-d6856,NODE_ENV=production" `
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"
```

**Linux/Mac (Bash):**
```bash
# 1. Build Docker image
docker build -t gcr.io/miro-d6856/admin-panel:latest .

# 2. Push to Container Registry
docker push gcr.io/miro-d6856/admin-panel:latest

# 3. Deploy to Cloud Run
gcloud run deploy admin-panel \
  --image gcr.io/miro-d6856/admin-panel:latest \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars "FIREBASE_PROJECT_ID=miro-d6856,NODE_ENV=production" \
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"
```

## Environment Variables

The following environment variables are set during deployment:

- `FIREBASE_PROJECT_ID`: Set to `miro-d6856`
- `NODE_ENV`: Set to `production`

## Secrets

The following secrets are mounted from Secret Manager:

- `FIREBASE_CLIENT_EMAIL`: Firebase Admin SDK client email
- `FIREBASE_PRIVATE_KEY`: Firebase Admin SDK private key
- `ADMIN_USERNAME`: Admin panel username
- `ADMIN_PASSWORD`: Admin panel password
- `JWT_SECRET`: JWT secret for authentication

## Updating Secrets

To update a secret:

```bash
# Update secret value
echo -n "new-value" | gcloud secrets versions add SECRET_NAME --data-file=-

# The latest version will be used automatically
```

## Troubleshooting

### Build fails

1. Check Docker is running: `docker ps`
2. Check you're logged in to GCP: `gcloud auth login`
3. Configure Docker for GCR: `gcloud auth configure-docker`

### Deployment fails

1. Check Cloud Run API is enabled: `gcloud services enable run.googleapis.com`
2. Check you have permissions: `gcloud projects get-iam-policy miro-d6856`
3. Check logs: `gcloud run services logs read admin-panel --region asia-southeast1`

### Service won't start

1. Check environment variables are set correctly
2. Check secrets are accessible
3. Check service account has necessary permissions

## Post-Deployment

After deployment:

1. **Get the service URL**:
   ```bash
   gcloud run services describe admin-panel --region asia-southeast1 --format 'value(status.url)'
   ```

2. **Test the deployment**:
   - Visit the URL in your browser
   - Try logging in with admin credentials
   - Test all features

3. **Set up custom domain** (optional):
   ```bash
   gcloud run domain-mappings create \
     --service admin-panel \
     --domain admin.miro-app.com \
     --region asia-southeast1
   ```

## Monitoring

View logs:
```bash
gcloud run services logs read admin-panel --region asia-southeast1 --limit 50
```

View metrics:
- Go to Cloud Console → Cloud Run → admin-panel
- Check "Metrics" tab

## Rollback

To rollback to a previous version:

```bash
gcloud run services update-traffic admin-panel \
  --region asia-southeast1 \
  --to-revisions REVISION_NAME=100
```
