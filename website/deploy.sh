#!/bin/bash
set -e

echo "=== ArCal Website — Build & Deploy ==="

cd "$(dirname "$0")"

if [ ! -f .env.local ] && [ -z "${NEXT_PUBLIC_GA_MEASUREMENT_ID:-}" ]; then
  echo "⚠️  Warning: GA4 tag disabled — create website/.env.local from .env.example"
  echo "   and set NEXT_PUBLIC_GA_MEASUREMENT_ID (GA4 → Data streams → Measurement ID)."
fi

echo "1. Installing dependencies..."
npm ci

echo "2. Building static site..."
npm run build

echo "3. Preparing deploy directory..."
rm -rf deploy
mkdir -p deploy/miro
cp -r out/* deploy/miro/

# Root redirect to /miro/ (fixes "Page Not Found" when visiting domain root)
cat > deploy/index.html << 'EOF'
<!DOCTYPE html>
<html><head><meta http-equiv="refresh" content="0;url=/miro/"><script>location.replace("/miro/")</script></head><body>Redirecting to <a href="/miro/">ArCal</a>...</body></html>
EOF

echo "4. Deploying to Firebase Hosting..."
cd ..
if command -v firebase >/dev/null 2>&1; then
  firebase deploy --only hosting
elif [ -x /opt/homebrew/bin/firebase ]; then
  /opt/homebrew/bin/firebase deploy --only hosting
else
  npx --yes firebase-tools deploy --only hosting
fi

echo ""
echo "=== Deploy complete! ==="
echo "Website: https://www.tnbgrp.com/miro/"
echo "Support: https://www.tnbgrp.com/miro/support/"
echo "Privacy: https://www.tnbgrp.com/miro/privacy/"
echo "Terms:   https://www.tnbgrp.com/miro/terms/"
