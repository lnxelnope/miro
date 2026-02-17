#!/bin/bash

# Setup Secrets in Google Secret Manager for Admin Panel
# Usage: ./setup-secrets.sh

set -e

PROJECT_ID="miro-d6856"

echo "🔐 Setting up secrets for ${PROJECT_ID}..."

# Set the project
gcloud config set project ${PROJECT_ID}

# Enable Secret Manager API
echo "🔧 Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com

# Read values from .env.local (if exists)
if [ -f .env.local ]; then
    echo "📖 Reading values from .env.local..."
    source .env.local
else
    echo "⚠️  .env.local not found. Please provide values manually."
    read -p "Firebase Client Email: " FIREBASE_CLIENT_EMAIL
    read -sp "Firebase Private Key (paste and press Enter): " FIREBASE_PRIVATE_KEY
    echo
    read -p "Admin Username: " ADMIN_USERNAME
    read -sp "Admin Password: " ADMIN_PASSWORD
    echo
    read -sp "JWT Secret: " JWT_SECRET
    echo
fi

# Create or update secrets
echo "🔐 Creating/updating secrets..."

# Firebase Client Email
if [ -n "$FIREBASE_CLIENT_EMAIL" ]; then
    echo -n "$FIREBASE_CLIENT_EMAIL" | \
        gcloud secrets create firebase-client-email --data-file=- 2>/dev/null || \
        echo -n "$FIREBASE_CLIENT_EMAIL" | \
        gcloud secrets versions add firebase-client-email --data-file=-
    echo "✅ firebase-client-email secret created/updated"
fi

# Firebase Private Key
if [ -n "$FIREBASE_PRIVATE_KEY" ]; then
    # Remove quotes if present
    FIREBASE_PRIVATE_KEY=$(echo "$FIREBASE_PRIVATE_KEY" | sed 's/^"//;s/"$//')
    echo -n "$FIREBASE_PRIVATE_KEY" | \
        gcloud secrets create firebase-private-key --data-file=- 2>/dev/null || \
        echo -n "$FIREBASE_PRIVATE_KEY" | \
        gcloud secrets versions add firebase-private-key --data-file=-
    echo "✅ firebase-private-key secret created/updated"
fi

# Admin Username
if [ -n "$ADMIN_USERNAME" ]; then
    echo -n "$ADMIN_USERNAME" | \
        gcloud secrets create admin-username --data-file=- 2>/dev/null || \
        echo -n "$ADMIN_USERNAME" | \
        gcloud secrets versions add admin-username --data-file=-
    echo "✅ admin-username secret created/updated"
fi

# Admin Password
if [ -n "$ADMIN_PASSWORD" ]; then
    echo -n "$ADMIN_PASSWORD" | \
        gcloud secrets create admin-password --data-file=- 2>/dev/null || \
        echo -n "$ADMIN_PASSWORD" | \
        gcloud secrets versions add admin-password --data-file=-
    echo "✅ admin-password secret created/updated"
fi

# JWT Secret
if [ -n "$JWT_SECRET" ]; then
    echo -n "$JWT_SECRET" | \
        gcloud secrets create jwt-secret --data-file=- 2>/dev/null || \
        echo -n "$JWT_SECRET" | \
        gcloud secrets versions add jwt-secret --data-file=-
    echo "✅ jwt-secret secret created/updated"
fi

# Grant Cloud Run service account access to secrets
echo "🔑 Granting Cloud Run service account access to secrets..."

# Get Cloud Run service account
SERVICE_ACCOUNT="${PROJECT_ID}@appspot.gserviceaccount.com"

# Grant secret accessor role
for secret in firebase-client-email firebase-private-key admin-username admin-password jwt-secret; do
    gcloud secrets add-iam-policy-binding $secret \
        --member="serviceAccount:${SERVICE_ACCOUNT}" \
        --role="roles/secretmanager.secretAccessor" \
        --quiet || echo "⚠️  Failed to grant access to $secret (may already have access)"
done

echo "✅ Secrets setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run ./deploy.sh to deploy the admin panel"
echo "2. Or use: gcloud builds submit --config cloudbuild.yaml"
