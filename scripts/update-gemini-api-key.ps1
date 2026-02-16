# =============================================================================
# Update Gemini API Key in Google Cloud Secret Manager (PowerShell)
# =============================================================================
# Project: miro-d6856
# Purpose: Revoke old API key and update with new one securely
# =============================================================================

$ErrorActionPreference = "Stop"

# Configuration
$PROJECT_ID = "miro-d6856"
$SECRET_NAME = "GEMINI_API_KEY"
$REGION = "us-central1"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Blue "========================================"
Write-ColorOutput Blue "Update Gemini API Key"
Write-ColorOutput Blue "========================================"
Write-Output ""

# =============================================================================
# Step 1: Verify gcloud authentication
# =============================================================================
Write-ColorOutput Yellow "[1/6] Checking authentication..."
try {
    $currentAccount = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null | Select-Object -First 1
    if ([string]::IsNullOrEmpty($currentAccount)) {
        throw "Not authenticated"
    }
    Write-ColorOutput Green "✅ Authenticated as: $currentAccount"
    Write-Output ""
} catch {
    Write-ColorOutput Red "❌ Not authenticated. Please run: gcloud auth login"
    exit 1
}

# =============================================================================
# Step 2: Set project
# =============================================================================
Write-ColorOutput Yellow "[2/6] Setting project..."
gcloud config set project $PROJECT_ID | Out-Null
Write-ColorOutput Green "✅ Project set to: $PROJECT_ID"
Write-Output ""

# =============================================================================
# Step 3: Check if secret exists
# =============================================================================
Write-ColorOutput Yellow "[3/6] Checking if secret exists..."
try {
    gcloud secrets describe $SECRET_NAME --project=$PROJECT_ID 2>$null | Out-Null
    Write-ColorOutput Green "✅ Secret '$SECRET_NAME' exists"
    $secretExists = $true
} catch {
    Write-ColorOutput Yellow "⚠️  Secret '$SECRET_NAME' does not exist. Will create new one."
    $secretExists = $false
}
Write-Output ""

# =============================================================================
# Step 4: Get new API key
# =============================================================================
Write-ColorOutput Yellow "[4/6] Enter new Gemini API key"
Write-ColorOutput Blue "ℹ️  Get your API key from: https://aistudio.google.com/app/apikey"
Write-ColorOutput Blue "ℹ️  Format should be: AIzaSy... (39 characters)"
Write-Output ""

$secureKey = Read-Host "Paste your new Gemini API key" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
$newApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

# Validate API key format
if ($newApiKey -notmatch '^AIza[a-zA-Z0-9_-]{35}$') {
    Write-ColorOutput Red "❌ Invalid API key format. Should start with 'AIza' and be 39 characters total."
    exit 1
}

Write-ColorOutput Green "✅ API key format validated"
Write-Output ""

# =============================================================================
# Step 5: Update or create secret
# =============================================================================
Write-ColorOutput Yellow "[5/6] Updating secret..."

# Save API key to temp file
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $newApiKey -NoNewline

try {
    if ($secretExists) {
        # Add new version to existing secret
        gcloud secrets versions add $SECRET_NAME `
            --project=$PROJECT_ID `
            --data-file=$tempFile | Out-Null
        Write-ColorOutput Green "✅ New version added to secret '$SECRET_NAME'"
    } else {
        # Create new secret
        gcloud secrets create $SECRET_NAME `
            --project=$PROJECT_ID `
            --replication-policy="automatic" `
            --data-file=$tempFile | Out-Null
        Write-ColorOutput Green "✅ Secret '$SECRET_NAME' created"
    }
} finally {
    # Clean up temp file
    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name newApiKey -ErrorAction SilentlyContinue
}
Write-Output ""

# =============================================================================
# Step 6: Grant access to Cloud Functions service account
# =============================================================================
Write-ColorOutput Yellow "[6/6] Granting access to service account..."

# Get project number
$projectNumber = gcloud projects describe $PROJECT_ID --format="value(projectNumber)"
$serviceAccount = "$projectNumber-compute@developer.gserviceaccount.com"

# Grant access
gcloud secrets add-iam-policy-binding $SECRET_NAME `
    --project=$PROJECT_ID `
    --member="serviceAccount:$serviceAccount" `
    --role="roles/secretmanager.secretAccessor" | Out-Null

Write-ColorOutput Green "✅ Access granted to: $serviceAccount"
Write-Output ""

# =============================================================================
# Summary
# =============================================================================
Write-ColorOutput Green "========================================"
Write-ColorOutput Green "✅ Success!"
Write-ColorOutput Green "========================================"
Write-Output ""
Write-ColorOutput Blue "Secret Details:"
Write-Output "  Name:    $SECRET_NAME"
Write-Output "  Project: $PROJECT_ID"
Write-Output ""
Write-ColorOutput Yellow "Next Steps:"
Write-Output "  1. Redeploy your Cloud Functions:"
Write-ColorOutput Blue "     firebase deploy --only functions"
Write-Output ""
Write-Output "  2. Or if using gcloud:"
Write-ColorOutput Blue "     gcloud functions deploy analyzeFood --region=$REGION"
Write-Output ""
Write-Output "  3. Test the new API key:"
Write-ColorOutput Blue "     curl https://$REGION-$PROJECT_ID.cloudfunctions.net/analyzeFood"
Write-Output ""
Write-ColorOutput Red "⚠️  Important: Revoke the old API key at:"
Write-ColorOutput Red "   https://aistudio.google.com/app/apikey"
Write-Output ""

Write-ColorOutput Green "Done! 🎉"
