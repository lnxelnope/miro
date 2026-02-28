# MiRO Admin Panel - Quick Deploy Script for GCP
# Run this script to deploy to Google Cloud Run

Write-Host "[*] MiRO Admin Panel - GCP Deployment" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Check if gcloud is installed
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Error: Google Cloud SDK not found" -ForegroundColor Red
    Write-Host "   Please install from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "[+] Google Cloud SDK found`n" -ForegroundColor Green

# Set project
$PROJECT_ID = "miro-d6856"
Write-Host "[*] Setting project: $PROJECT_ID" -ForegroundColor Cyan
gcloud config set project $PROJECT_ID

# Enable required APIs
Write-Host "`n[*] Enabling required APIs..." -ForegroundColor Cyan
gcloud services enable run.googleapis.com --quiet
gcloud services enable containerregistry.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
gcloud services enable secretmanager.googleapis.com --quiet

Write-Host "[+] APIs enabled`n" -ForegroundColor Green

# Build and Deploy
Write-Host "[*] Building and deploying to Cloud Run..." -ForegroundColor Cyan
Write-Host "   This may take 5-10 minutes...`n" -ForegroundColor Yellow

gcloud run deploy admin-panel `
    --source . `
    --platform managed `
    --region asia-southeast1 `
    --allow-unauthenticated `
    --min-instances 0 `
    --max-instances 10 `
    --memory 512Mi `
    --cpu 1 `
    --timeout 300 `
    --set-env-vars "NODE_ENV=production" `
    --set-secrets "FIREBASE_PROJECT_ID=firebase-project-id:latest,FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,NEXTAUTH_URL=nextauth-url:latest,NEXTAUTH_SECRET=nextauth-secret:latest,GOOGLE_CLIENT_ID=google-client-id:latest,GOOGLE_CLIENT_SECRET=google-client-secret:latest,ALLOWED_ADMIN_EMAILS=allowed-admin-emails:latest"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[+] Deployment successful!`n" -ForegroundColor Green
    
    # Get service URL
    $serviceUrl = gcloud run services describe admin-panel --region asia-southeast1 --format "value(status.url)"
    
    Write-Host "[+] Admin Panel URL: $serviceUrl" -ForegroundColor Cyan
    Write-Host "`n[*] View Monitoring: https://console.cloud.google.com/run/detail/asia-southeast1/admin-panel" -ForegroundColor Cyan
    Write-Host "[*] View Logs: https://console.cloud.google.com/run/detail/asia-southeast1/admin-panel/logs" -ForegroundColor Cyan
    
    Write-Host "`n[+] Done!`n" -ForegroundColor Green
} else {
    Write-Host "`n[!] Deployment failed!`n" -ForegroundColor Red
    Write-Host "[!] Check logs at: https://console.cloud.google.com/cloud-build/builds" -ForegroundColor Yellow
}
