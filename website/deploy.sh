#!/bin/bash
set -e

echo "=== MiRO Website — Build & Deploy ==="

cd "$(dirname "$0")"

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
<html><head><meta http-equiv="refresh" content="0;url=/miro/"><script>location.replace("/miro/")</script></head><body>Redirecting to <a href="/miro/">MiRO</a>...</body></html>
EOF

echo "4. Deploying to Firebase Hosting..."
cd ..
/opt/homebrew/bin/firebase deploy --only hosting

echo ""
echo "=== Deploy complete! ==="
echo "Website: https://www.tnbgrp.com/miro/"
echo "Support: https://www.tnbgrp.com/miro/support/"
echo "Privacy: https://www.tnbgrp.com/miro/privacy/"
echo "Terms:   https://www.tnbgrp.com/miro/terms/"
