#!/bin/bash

# MiRO Admin Panel - Quick Deploy Script for GCP (Bash version)
# Run this script to deploy to Google Cloud Run

echo "🚀 MiRO Admin Panel - GCP Deployment"
echo "===================================="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: Google Cloud SDK not found"
    echo "   Please install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "✅ Google Cloud SDK found"
echo ""

# Set project
PROJECT_ID="miro-d6856"
echo "📦 Setting project: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ""
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com --quiet
gcloud services enable containerregistry.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
gcloud services enable secretmanager.googleapis.com --quiet

echo "✅ APIs enabled"
echo ""

# Ask if secrets are already created
echo "🔒 Secrets Setup"
read -p "Have you already created secrets in Secret Manager? (y/n): " secrets_exist

if [ "$secrets_exist" != "y" ]; then
    echo ""
    echo "⚠️  You need to create secrets first!"
    echo "   Run these commands:"
    echo ""
    
    echo "# 1. Firebase Project ID"
    echo 'echo -n "miro-d6856" | gcloud secrets create firebase-project-id --data-file=-'
    
    echo ""
    echo "# 2. Firebase Client Email"
    echo 'echo -n "firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com" | gcloud secrets create firebase-client-email --data-file=-'
    
    echo ""
    echo "# 3. Firebase Private Key (copy from serviceAccountKey.json)"
    echo 'cat serviceAccountKey.json | jq -r .private_key | gcloud secrets create firebase-private-key --data-file=-'
    
    echo ""
    echo "# 4. Admin Username"
    echo 'echo -n "lnxelnope" | gcloud secrets create admin-username --data-file=-'
    
    echo ""
    echo "# 5. Admin Password"
    echo 'echo -n "your-strong-password" | gcloud secrets create admin-password --data-file=-'
    
    echo ""
    echo "# 6. JWT Secret"
    echo 'openssl rand -base64 32 | gcloud secrets create jwt-secret --data-file=-'
    
    echo ""
    echo ""
    echo "After creating secrets, run this script again."
    echo ""
    exit 0
fi

# Build and Deploy
echo ""
echo "🏗️  Building and deploying to Cloud Run..."
echo "   This may take 5-10 minutes..."
echo ""

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
    --set-secrets "FIREBASE_PROJECT_ID=firebase-project-id:latest,FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,ADMIN_USERNAME=admin-username:latest,ADMIN_PASSWORD=admin-password:latest,JWT_SECRET=jwt-secret:latest"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe miro-admin-panel \
        --region asia-southeast1 \
        --format 'value(status.url)')
    
    echo "🌐 Admin Panel URL: $SERVICE_URL"
    echo ""
    echo "📊 View Monitoring: https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel"
    echo "📋 View Logs: https://console.cloud.google.com/run/detail/asia-southeast1/miro-admin-panel/logs"
    
    # Open in browser
    echo ""
    read -p "Open Admin Panel in browser? (y/n): " open_browser
    if [ "$open_browser" = "y" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$SERVICE_URL"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$SERVICE_URL"
        fi
    fi
else
    echo ""
    echo "❌ Deployment failed!"
    echo ""
    echo "Check logs at: https://console.cloud.google.com/cloud-build/builds"
fi

echo ""
echo "✨ Done!"
echo ""
