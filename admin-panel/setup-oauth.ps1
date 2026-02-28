# MiRO Admin Panel - Setup Google OAuth Secrets
# Run this ONCE before deploying

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " MiRO Admin Panel - OAuth Setup Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$PROJECT_ID = "miro-d6856"
gcloud config set project $PROJECT_ID

# ============================================================
# STEP 1: User must create OAuth credentials manually first
# ============================================================

Write-Host "[!] BEFORE running this script, you must:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Go to: https://console.cloud.google.com/apis/credentials?project=miro-d6856" -ForegroundColor White
Write-Host "   2. Click '+ CREATE CREDENTIALS' -> 'OAuth client ID'" -ForegroundColor White
Write-Host "   3. Application type: 'Web application'" -ForegroundColor White
Write-Host "   4. Name: 'MiRO Admin Panel'" -ForegroundColor White
Write-Host "   5. Authorized JavaScript origins:" -ForegroundColor White
Write-Host "      - http://localhost:3000" -ForegroundColor Green
Write-Host "      - https://admin-panel-65396857547.asia-southeast1.run.app" -ForegroundColor Green
Write-Host "   6. Authorized redirect URIs:" -ForegroundColor White
Write-Host "      - http://localhost:3000/api/auth/callback/google" -ForegroundColor Green
Write-Host "      - https://admin-panel-65396857547.asia-southeast1.run.app/api/auth/callback/google" -ForegroundColor Green
Write-Host "   7. Click CREATE and copy Client ID + Client Secret" -ForegroundColor White
Write-Host ""

# Also check OAuth consent screen
Write-Host "[!] If you haven't set up OAuth Consent Screen:" -ForegroundColor Yellow
Write-Host "   1. Go to: https://console.cloud.google.com/apis/credentials/consent?project=miro-d6856" -ForegroundColor White
Write-Host "   2. User Type: External (or Internal if Workspace)" -ForegroundColor White
Write-Host "   3. App name: 'MiRO Admin Panel'" -ForegroundColor White
Write-Host "   4. Support email: lnxelnope@gmail.com" -ForegroundColor White
Write-Host "   5. Add scope: email, profile, openid" -ForegroundColor White
Write-Host "   6. Test users: lnxelnope@gmail.com" -ForegroundColor White
Write-Host ""

$proceed = Read-Host "Have you created the OAuth credentials? (y/n)"
if ($proceed -ne "y") {
    Write-Host "`n[!] Please create OAuth credentials first, then run this script again." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# STEP 2: Get Client ID and Secret from user
# ============================================================

$GOOGLE_CLIENT_ID = Read-Host "`nEnter Google Client ID"
$GOOGLE_CLIENT_SECRET = Read-Host "Enter Google Client Secret"

if ([string]::IsNullOrWhiteSpace($GOOGLE_CLIENT_ID) -or [string]::IsNullOrWhiteSpace($GOOGLE_CLIENT_SECRET)) {
    Write-Host "[!] Client ID and Secret cannot be empty!" -ForegroundColor Red
    exit 1
}

# ============================================================
# STEP 3: Generate NEXTAUTH_SECRET
# ============================================================

$bytes = New-Object byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$NEXTAUTH_SECRET = [Convert]::ToBase64String($bytes)

Write-Host "`n[*] Generated NEXTAUTH_SECRET: $NEXTAUTH_SECRET" -ForegroundColor Cyan

# ============================================================
# STEP 4: Create or update secrets in Secret Manager
# ============================================================

Write-Host "`n[*] Creating secrets in Secret Manager..." -ForegroundColor Cyan

$NEXTAUTH_URL = "https://admin-panel-65396857547.asia-southeast1.run.app"
$ALLOWED_EMAILS = "lnxelnope@gmail.com"

# Helper function: create or update secret
function Set-GcpSecret {
    param($Name, $Value)
    
    $exists = gcloud secrets describe $Name --project=$PROJECT_ID 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Updating secret: $Name" -ForegroundColor Yellow
        $Value | gcloud secrets versions add $Name --data-file=- --project=$PROJECT_ID
    } else {
        Write-Host "   Creating secret: $Name" -ForegroundColor Green
        $Value | gcloud secrets create $Name --data-file=- --project=$PROJECT_ID
    }
}

Set-GcpSecret "google-client-id" $GOOGLE_CLIENT_ID
Set-GcpSecret "google-client-secret" $GOOGLE_CLIENT_SECRET
Set-GcpSecret "nextauth-secret" $NEXTAUTH_SECRET
Set-GcpSecret "nextauth-url" $NEXTAUTH_URL
Set-GcpSecret "allowed-admin-emails" $ALLOWED_EMAILS

# Ensure Firebase secrets exist too
$existingFirebase = gcloud secrets describe firebase-project-id --project=$PROJECT_ID 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[*] Creating Firebase secrets..." -ForegroundColor Cyan
    Set-GcpSecret "firebase-project-id" "miro-d6856"
    Set-GcpSecret "firebase-client-email" "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com"
    Write-Host "[!] You also need to create 'firebase-private-key' secret manually!" -ForegroundColor Yellow
    Write-Host "   Copy from admin-panel/.env.local" -ForegroundColor Yellow
}

# ============================================================
# STEP 5: Grant access to Cloud Run service account
# ============================================================

Write-Host "`n[*] Granting secret access to Cloud Run..." -ForegroundColor Cyan

$PROJECT_NUMBER = (gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
$SA = "${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

$secrets = @("google-client-id", "google-client-secret", "nextauth-secret", "nextauth-url", "allowed-admin-emails", "firebase-project-id", "firebase-client-email", "firebase-private-key")

foreach ($secret in $secrets) {
    gcloud secrets add-iam-policy-binding $secret `
        --member="serviceAccount:$SA" `
        --role="roles/secretmanager.secretAccessor" `
        --project=$PROJECT_ID --quiet 2>$null
    Write-Host "   Granted access: $secret" -ForegroundColor Green
}

# ============================================================
# DONE
# ============================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Deploy the admin panel:" -ForegroundColor Cyan
Write-Host "   cd admin-panel" -ForegroundColor White
Write-Host "   .\deploy-gcp.ps1" -ForegroundColor White
Write-Host ""
