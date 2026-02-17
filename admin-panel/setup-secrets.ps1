# Setup Secrets in Google Secret Manager for Admin Panel (PowerShell)
# Usage: .\setup-secrets.ps1

$ErrorActionPreference = "Continue"

$PROJECT_ID = "miro-d6856"

Write-Host "Setting up secrets for $PROJECT_ID..."

# Set the project
Write-Host "Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable Secret Manager API
Write-Host "Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com

# Read values from .env.local (if exists)
$FIREBASE_CLIENT_EMAIL = ""
$FIREBASE_PRIVATE_KEY = ""
$ADMIN_USERNAME = ""
$ADMIN_PASSWORD = ""
$JWT_SECRET = ""

if (Test-Path ".env.local") {
    Write-Host "Reading values from .env.local..."
    Get-Content ".env.local" | ForEach-Object {
        if ($_ -match '^FIREBASE_CLIENT_EMAIL=(.*)$') {
            $FIREBASE_CLIENT_EMAIL = $matches[1].Trim().Trim('"')
        }
        elseif ($_ -match '^FIREBASE_PRIVATE_KEY=(.*)$') {
            $FIREBASE_PRIVATE_KEY = $matches[1].Trim().Trim('"')
        }
        elseif ($_ -match '^ADMIN_USERNAME=(.*)$') {
            $ADMIN_USERNAME = $matches[1].Trim().Trim('"')
        }
        elseif ($_ -match '^ADMIN_PASSWORD=(.*)$') {
            $ADMIN_PASSWORD = $matches[1].Trim().Trim('"')
        }
        elseif ($_ -match '^JWT_SECRET=(.*)$') {
            $JWT_SECRET = $matches[1].Trim().Trim('"')
        }
    }
}

if (-not $FIREBASE_CLIENT_EMAIL -or -not $FIREBASE_PRIVATE_KEY -or -not $ADMIN_USERNAME -or -not $ADMIN_PASSWORD -or -not $JWT_SECRET) {
    Write-Host "Some values are missing. Please provide them manually."
    
    if (-not $FIREBASE_CLIENT_EMAIL) {
        $FIREBASE_CLIENT_EMAIL = Read-Host "Firebase Client Email"
    }
    if (-not $FIREBASE_PRIVATE_KEY) {
        $FIREBASE_PRIVATE_KEY = Read-Host "Firebase Private Key"
    }
    if (-not $ADMIN_USERNAME) {
        $ADMIN_USERNAME = Read-Host "Admin Username"
    }
    if (-not $ADMIN_PASSWORD) {
        $ADMIN_PASSWORD = Read-Host "Admin Password"
    }
    if (-not $JWT_SECRET) {
        $JWT_SECRET = Read-Host "JWT Secret"
    }
}

# Create or update secrets
Write-Host "Creating/updating secrets..."

# Firebase Client Email
if ($FIREBASE_CLIENT_EMAIL) {
    Write-Host "Creating firebase-client-email..."
    $FIREBASE_CLIENT_EMAIL | gcloud secrets create firebase-client-email --data-file=- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Secret exists, updating..."
        $FIREBASE_CLIENT_EMAIL | gcloud secrets versions add firebase-client-email --data-file=-
    }
    Write-Host "Done: firebase-client-email"
}

# Firebase Private Key
if ($FIREBASE_PRIVATE_KEY) {
    Write-Host "Creating firebase-private-key..."
    $FIREBASE_PRIVATE_KEY | gcloud secrets create firebase-private-key --data-file=- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Secret exists, updating..."
        $FIREBASE_PRIVATE_KEY | gcloud secrets versions add firebase-private-key --data-file=-
    }
    Write-Host "Done: firebase-private-key"
}

# Admin Username
if ($ADMIN_USERNAME) {
    Write-Host "Creating admin-username..."
    $ADMIN_USERNAME | gcloud secrets create admin-username --data-file=- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Secret exists, updating..."
        $ADMIN_USERNAME | gcloud secrets versions add admin-username --data-file=-
    }
    Write-Host "Done: admin-username"
}

# Admin Password
if ($ADMIN_PASSWORD) {
    Write-Host "Creating admin-password..."
    $ADMIN_PASSWORD | gcloud secrets create admin-password --data-file=- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Secret exists, updating..."
        $ADMIN_PASSWORD | gcloud secrets versions add admin-password --data-file=-
    }
    Write-Host "Done: admin-password"
}

# JWT Secret
if ($JWT_SECRET) {
    Write-Host "Creating jwt-secret..."
    $JWT_SECRET | gcloud secrets create jwt-secret --data-file=- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Secret exists, updating..."
        $JWT_SECRET | gcloud secrets versions add jwt-secret --data-file=-
    }
    Write-Host "Done: jwt-secret"
}

# Grant Cloud Run service account access to secrets
Write-Host "Granting Cloud Run service account access to secrets..."

$SERVICE_ACCOUNT = "${PROJECT_ID}@appspot.gserviceaccount.com"

$secrets = @("firebase-client-email", "firebase-private-key", "admin-username", "admin-password", "jwt-secret")
foreach ($secret in $secrets) {
    Write-Host "Granting access to $secret..."
    gcloud secrets add-iam-policy-binding $secret --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/secretmanager.secretAccessor" --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Granted access to $secret"
    }
    else {
        Write-Host "Failed to grant access to $secret (may already have access)"
    }
}

Write-Host ""
Write-Host "Secrets setup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run .\deploy.ps1 to deploy the admin panel"
Write-Host "2. Or use: gcloud builds submit --config cloudbuild.yaml"
