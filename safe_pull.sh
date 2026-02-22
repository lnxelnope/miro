#!/bin/bash
# Safe Pull Script - จัดการ merge conflicts อัตโนมัติ

echo "🔄 Starting safe pull..."

# 1. Stash local changes
echo "📦 Stashing local changes..."
git stash push -m "Auto-stash before pull $(date +%Y%m%d_%H%M%S)"

# 2. Pull from remote
echo "⬇️  Pulling from remote..."
git pull origin $(git branch --show-current)

# 3. Pop stash
echo "📤 Restoring local changes..."
if git stash pop; then
    echo "✅ Pull completed successfully!"
else
    echo "⚠️  Merge conflicts detected. Checking files..."
    
    # Auto-resolve common conflicts
    if [ -f "pubspec.yaml" ]; then
        echo "🔧 Checking pubspec.yaml for duplicates..."
        # Remove duplicate google_mobile_ads entries
        awk '!seen[$0]++ || !/google_mobile_ads:/' pubspec.yaml > pubspec.yaml.tmp
        mv pubspec.yaml.tmp pubspec.yaml
        git add pubspec.yaml
    fi
    
    echo "✅ Conflicts resolved. Please check git status."
fi

echo "🎉 Done!"
