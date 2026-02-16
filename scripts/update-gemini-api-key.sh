#!/bin/bash

# =============================================================================
# Update Gemini API Key in Google Cloud Secret Manager
# =============================================================================
# Project: miro-d6856
# Purpose: Revoke old API key and update with new one securely
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="miro-d6856"
SECRET_NAME="GEMINI_API_KEY"
REGION="us-central1"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Update Gemini API Key${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# =============================================================================
# Step 1: Verify gcloud authentication
# =============================================================================
echo -e "${YELLOW}[1/6] Checking authentication...${NC}"
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
    echo -e "${RED}❌ Not authenticated. Please run: gcloud auth login${NC}"
    exit 1
fi

CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
echo -e "${GREEN}✅ Authenticated as: ${CURRENT_ACCOUNT}${NC}"
echo ""

# =============================================================================
# Step 2: Set project
# =============================================================================
echo -e "${YELLOW}[2/6] Setting project...${NC}"
gcloud config set project ${PROJECT_ID}
echo -e "${GREEN}✅ Project set to: ${PROJECT_ID}${NC}"
echo ""

# =============================================================================
# Step 3: Check if secret exists
# =============================================================================
echo -e "${YELLOW}[3/6] Checking if secret exists...${NC}"
if gcloud secrets describe ${SECRET_NAME} --project=${PROJECT_ID} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Secret '${SECRET_NAME}' exists${NC}"
    SECRET_EXISTS=true
else
    echo -e "${YELLOW}⚠️  Secret '${SECRET_NAME}' does not exist. Will create new one.${NC}"
    SECRET_EXISTS=false
fi
echo ""

# =============================================================================
# Step 4: Get new API key
# =============================================================================
echo -e "${YELLOW}[4/6] Enter new Gemini API key${NC}"
echo -e "${BLUE}ℹ️  Get your API key from: https://aistudio.google.com/app/apikey${NC}"
echo -e "${BLUE}ℹ️  Format should be: AIzaSy... (39 characters)${NC}"
echo ""
echo -n "Paste your new Gemini API key: "
read -s NEW_API_KEY
echo ""

# Validate API key format
if [[ ! $NEW_API_KEY =~ ^AIza[a-zA-Z0-9_-]{35}$ ]]; then
    echo -e "${RED}❌ Invalid API key format. Should start with 'AIza' and be 39 characters total.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API key format validated${NC}"
echo ""

# =============================================================================
# Step 5: Update or create secret
# =============================================================================
echo -e "${YELLOW}[5/6] Updating secret...${NC}"

if [ "$SECRET_EXISTS" = true ]; then
    # Add new version to existing secret
    echo "$NEW_API_KEY" | gcloud secrets versions add ${SECRET_NAME} \
        --project=${PROJECT_ID} \
        --data-file=-
    echo -e "${GREEN}✅ New version added to secret '${SECRET_NAME}'${NC}"
else
    # Create new secret
    echo "$NEW_API_KEY" | gcloud secrets create ${SECRET_NAME} \
        --project=${PROJECT_ID} \
        --replication-policy="automatic" \
        --data-file=-
    echo -e "${GREEN}✅ Secret '${SECRET_NAME}' created${NC}"
fi
echo ""

# =============================================================================
# Step 6: Grant access to Cloud Functions service account
# =============================================================================
echo -e "${YELLOW}[6/6] Granting access to service account...${NC}"

# Get project number
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Grant access
gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
    --project=${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor" \
    > /dev/null 2>&1

echo -e "${GREEN}✅ Access granted to: ${SERVICE_ACCOUNT}${NC}"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Success!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Secret Details:${NC}"
echo "  Name:    ${SECRET_NAME}"
echo "  Project: ${PROJECT_ID}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Redeploy your Cloud Functions:"
echo "     ${BLUE}firebase deploy --only functions${NC}"
echo ""
echo "  2. Or if using gcloud:"
echo "     ${BLUE}gcloud functions deploy analyzeFood --region=${REGION}${NC}"
echo ""
echo "  3. Test the new API key:"
echo "     ${BLUE}curl https://${REGION}-${PROJECT_ID}.cloudfunctions.net/analyzeFood${NC}"
echo ""
echo -e "${RED}⚠️  Important: Revoke the old API key at:${NC}"
echo -e "${RED}   https://aistudio.google.com/app/apikey${NC}"
echo ""

# =============================================================================
# Cleanup
# =============================================================================
unset NEW_API_KEY

echo -e "${GREEN}Done! 🎉${NC}"
