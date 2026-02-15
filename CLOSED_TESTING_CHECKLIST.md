# 🧪 Closed Testing Checklist — Version 1.0.3 (Build 21)

> **สำหรับการทดสอบปิด (Closed Testing) ใน Google Play Console**

---

## ✅ Pre-Upload Checklist

### 1. Version & Build Number
- [x] Updated `pubspec.yaml` to `1.0.3+21`
- [ ] Verify version shows correctly in app (About screen)
- [ ] Update CHANGELOG.md with changes in this version

### 2. Code Quality
- [ ] All linter errors fixed
- [ ] No debug print statements in production code
- [ ] Remove unnecessary TODO comments
- [ ] All features tested on physical device

### 3. Energy System
- [x] Backend (Firebase Cloud Functions) deployed and working
- [x] Energy purchases working (test with Google Play sandbox)
- [x] Welcome Offer (24-hour) working correctly
- [ ] Test Energy deduction (1 Energy per AI analysis)
- [ ] Test Energy persistence across app reinstalls
- [ ] Verify Energy balance syncs correctly

### 4. AI Features
- [ ] Image analysis working (via Firebase backend)
- [ ] Text analysis working
- [ ] Barcode scanner working
- [ ] Nutrition label scanner working
- [ ] Loading messages showing correctly (English, technical)
- [ ] Error handling working (429 errors, no energy, etc.)
- [ ] Confirmation dialogs for re-analysis working

### 5. In-App Purchases
- [ ] All 8 SKUs created in Google Play Console:
  - Regular: `energy_100`, `energy_500`, `energy_1000`, `energy_3000`
  - Welcome: `energy_welcome_100`, `energy_welcome_500`, `energy_welcome_1000`, `energy_welcome_3000`
- [ ] Prices set correctly (see IAP_SETUP_COMPLETE_GUIDE.md)
- [ ] Test purchase flow in sandbox mode
- [ ] Verify receipts validated correctly

### 6. Beta Testing Features
- [x] Beta Feedback button still present (keep for closed testing)
- [x] Beta testers list configured in `beta_testers.dart`
- [ ] Test beta tester gets 1000 Energy welcome gift
- [ ] Force Pro mode is **DISABLED** (should be off for testing IAP)

### 7. Legal & Compliance
- [x] Privacy Policy updated (English, no BYOK)
- [x] Terms of Service updated (Energy terms included)
- [ ] Privacy Policy accessible in app (Profile → Privacy Policy)
- [ ] Terms of Service accessible in app (Profile → Terms of Service)

### 8. UI/UX Polish
- [ ] No overflow errors (RenderFlex)
- [ ] All text in English
- [ ] Energy badge showing correctly
- [ ] Welcome Offer notification working
- [ ] No double-tap issues on AI analysis

---

## 📦 Build & Upload Steps

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
```

### Step 2: Build Release AAB
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### Step 3: Verify AAB
- [ ] Check file size (should be < 50 MB)
- [ ] Version code is 21
- [ ] Version name is 1.0.3

### Step 4: Upload to Play Console
1. Go to: **Google Play Console → Release → Closed Testing**
2. Create new release
3. Upload `app-release.aab`
4. Fill release notes (see template below)
5. Review and rollout

---

## 📝 Release Notes Template

```
Version 1.0.3 (Build 21) - Closed Testing

🎯 What to Test:
- Energy System: Purchase Energy packages and use AI analysis
- Welcome Offer: Check if 40% off appears after 10 AI uses
- AI Analysis: Test with food photos, text, barcodes, and nutrition labels
- Re-analysis: Verify confirmation dialog when analyzing same food again
- Energy Balance: Check if Energy persists after app restart

🐛 Fixes:
- Fixed double-tap issue when analyzing food
- Fixed app crash after AI analysis completes
- Fixed RenderFlex overflow on timeline cards
- Improved error handling for API rate limits (429)

🎨 UI Improvements:
- Changed AI loading messages to technical English
- Added verified badge for analyzed food entries
- Better Energy Store UI

📌 Known Issues:
- [List any known bugs that testers should be aware of]

💬 Feedback:
- Use the blue feedback button (bottom right) to report issues
- Or email: support@mirocal.app
```

---

## 🧪 Testing Instructions for Testers

Share this with your testers:

### What to Test

1. **Energy Purchase Flow**
   - Buy an Energy package
   - Verify Energy balance updates
   - Try using Energy for AI analysis

2. **Welcome Offer**
   - Use AI analysis 10 times
   - Check if "40% OFF" notification appears
   - Verify offer expires after 24 hours

3. **AI Analysis**
   - Take photo of food → Analyze
   - Enter food name → Analyze
   - Scan barcode → Analyze
   - Scan nutrition label → Analyze
   - Try re-analyzing same food (should ask confirmation)

4. **App Stability**
   - Use app for multiple days
   - Close and reopen app (Energy should persist)
   - Test with poor internet connection
   - Test with no internet (should show appropriate errors)

### How to Report Issues

- Click blue feedback button (bottom right corner)
- Or email: support@mirocal.app
- Include:
  - Device model
  - Android version
  - Screenshots if possible
  - Steps to reproduce the bug

---

## 🔍 Post-Upload Verification

After upload:
- [ ] Release is published to Closed Testing track
- [ ] Testers added to closed testing list
- [ ] Testers received invitation email
- [ ] Test app download and installation
- [ ] Monitor crash reports in Play Console
- [ ] Monitor feedback from testers

---

## 📊 Metrics to Monitor

During closed testing:
- Crash-free rate (target: > 99%)
- ANRs (target: < 0.5%)
- Energy purchase conversion rate
- AI analysis success rate
- Average Energy usage per user
- Feedback sentiment

---

## ⚠️ Before Moving to Production

Before promoting to Production (Public Release):
- [ ] All critical bugs fixed
- [ ] Crash-free rate > 99%
- [ ] At least 20 testers tested the app
- [ ] Positive feedback from majority of testers
- [ ] All checklists in PRE_LAUNCH_CHECKLIST.md completed
- [ ] Remove Beta Feedback button
- [ ] Final testing on 5+ different devices

---

## 🚀 Ready to Deploy?

Once this checklist is complete:
```bash
# 1. Build release
flutter build appbundle --release

# 2. Upload to Play Console → Closed Testing

# 3. Send invitation to testers

# 4. Monitor and gather feedback

# 5. Fix bugs → Repeat
```

---

**Last Updated:** February 13, 2026  
**Version:** 1.0.3 (Build 21)
