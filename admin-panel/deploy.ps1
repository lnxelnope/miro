# Deploy Admin Panel to Google Cloud Run (PowerShell)
# Usage: .\deploy.ps1

$ErrorActionPreference = "Stop"

$PROJECT_ID = "miro-d6856"
$REGION = "asia-southeast1"
$SERVICE_NAME = "admin-panel"
$IMAGE_NAME = "gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

Write-Host "Starting deployment of ${SERVICE_NAME}..."

# Check if gcloud is installed
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: gcloud CLI is not installed. Please install it first."
    exit 1
}

# Check if docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed. Please install it first."
    exit 1
}

# Set the project
Write-Host "Setting GCP project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Enable required APIs
Write-Host "Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build the Docker image
Write-Host "Building Docker image..."
docker build -t ${IMAGE_NAME}:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed!"
    exit 1
}

# Push the image to Container Registry
Write-Host "Pushing image to Container Registry..."
docker push ${IMAGE_NAME}:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker push failed!"
    exit 1
}

# Deploy to Cloud Run
Write-Host "Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} `
  --image ${IMAGE_NAME}:latest `
  --platform managed `
  --region ${REGION} `
  --allow-unauthenticated `
  --memory 512Mi `
  --cpu 1 `
  --max-instances 10 `
  --min-instances 0 `
  --timeout 300 `
  --set-env-vars "FIREBASE_PROJECT_ID=${PROJECT_ID},NODE_ENV=production" `
  --set-secrets "FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Deployment failed!"
    exit 1
}

Write-Host ""
Write-Host "Deployment complete!"
Write-Host "Service URL:"
$url = gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)'
Write-Host $url
