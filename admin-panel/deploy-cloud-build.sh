#!/usr/bin/env bash
# Deploy โดยให้ Google Cloud Build สร้าง image จาก source (ไม่ต้องมี Docker บนเครื่อง)
# Usage: from admin-panel/: ./deploy-cloud-build.sh
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-miro-d6856}"
REGION="${GCP_REGION:-asia-southeast1}"
SERVICE_NAME="${CLOUD_RUN_SERVICE:-admin-panel}"

SECRETS_ARG="FIREBASE_CLIENT_EMAIL=firebase-client-email:latest,FIREBASE_PRIVATE_KEY=firebase-private-key:latest,AUTH_SECRET=nextauth-secret:latest,GOOGLE_CLIENT_ID=google-client-id:latest,GOOGLE_CLIENT_SECRET=google-client-secret:latest,ALLOWED_ADMIN_EMAILS=allowed-admin-emails:latest,NEXTAUTH_URL=nextauth-url:latest"

REQUIRED_SECRETS=(
  firebase-client-email
  firebase-private-key
  nextauth-secret
  google-client-id
  google-client-secret
  allowed-admin-emails
  nextauth-url
)

echo "🚀 Cloud Build deploy ${SERVICE_NAME} → ${REGION} (project ${PROJECT_ID})"
echo "   (ไม่ใช้ Docker บน Mac — build บน GCP)"

if ! command -v gcloud &>/dev/null; then
  echo "❌ gcloud CLI not found"
  exit 1
fi

gcloud config set project "${PROJECT_ID}"

echo "🔧 Enabling APIs..."
gcloud services enable cloudbuild.googleapis.com run.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com translate.googleapis.com --quiet

echo "🔒 Checking Secret Manager secrets..."
MISSING_ANY=0
for s in "${REQUIRED_SECRETS[@]}"; do
  if ! gcloud secrets describe "$s" --project="$PROJECT_ID" &>/dev/null; then
    echo "   ❌ missing: $s"
    MISSING_ANY=1
  fi
done
if [ "$MISSING_ANY" -ne 0 ]; then
  echo "Create missing secrets — see CLOUD_RUN.md"
  exit 1
fi

echo "🔑 Ensuring Cloud Run runtime SA can read secrets..."
if [ -x scripts/grant-secret-access-for-cloud-run.sh ]; then
  ./scripts/grant-secret-access-for-cloud-run.sh || true
fi

# สคริปต์เก่าผูก FIREBASE_PROJECT_ID จาก Secret Manager — GCP ไม่ให้เปลี่ยนเป็นค่า literal ใน deploy เดียวกัน
# ต้อง update ถอด secret ก่อน แล้วค่อย deploy รอบถัดไป (ดู SO #75725564)
if gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --project "${PROJECT_ID}" &>/dev/null; then
  echo "🔧 Unbind legacy secret env FIREBASE_PROJECT_ID (if present)..."
  gcloud run services update "${SERVICE_NAME}" \
    --region "${REGION}" \
    --project "${PROJECT_ID}" \
    --remove-secrets=FIREBASE_PROJECT_ID \
    --quiet 2>/dev/null || true
fi

echo "🏗️  Building on Cloud Build & deploying (อาจใช้เวลา 5–15 นาที)..."
gcloud run deploy "${SERVICE_NAME}" \
  --source . \
  --platform managed \
  --region "${REGION}" \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --min-instances 0 \
  --timeout 300 \
  --set-env-vars "FIREBASE_PROJECT_ID=${PROJECT_ID},NODE_ENV=production" \
  --set-secrets "${SECRETS_ARG}"

echo ""
echo "✅ Done."
echo "🌐 URL:"
gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --format 'value(status.url)'
