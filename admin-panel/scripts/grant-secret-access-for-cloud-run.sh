#!/usr/bin/env bash
# ให้ Cloud Run (default compute SA) อ่าน Secret Manager — รันครั้งเดียวหลังสร้าง secret
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-miro-d6856}"
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
RUNTIME_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

SECRETS=(
  firebase-client-email
  firebase-private-key
  nextauth-secret
  google-client-id
  google-client-secret
  allowed-admin-emails
  nextauth-url
)

echo "Project: $PROJECT_ID"
echo "Runtime SA: $RUNTIME_SA"
echo ""

for s in "${SECRETS[@]}"; do
  if ! gcloud secrets describe "$s" --project="$PROJECT_ID" &>/dev/null; then
    echo "⚠️  Skip (not found): $s"
    continue
  fi
  echo "→ Binding secretAccessor on $s"
  # รันซ้ำได้ — ถ้ามี binding อยู่แล้วอาจ error แต่ไม่เป็นไร
  gcloud secrets add-iam-policy-binding "$s" \
    --project="$PROJECT_ID" \
    --member="serviceAccount:${RUNTIME_SA}" \
    --role="roles/secretmanager.secretAccessor" \
    --quiet || true
done

echo ""
echo "✅ Done. Cloud Run service account can read these secrets."
