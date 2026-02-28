# Quick Start: Testing Subscription

## 🚀 Build & Run

```bash
# 1. Build release APK
cd c:\aiprogram\miro
flutter build apk --release

# 2. Install on device  
flutter install

# 3. Open app and test!
```

## 🧪 Test Flow

### Step 1: Navigate to Subscription
**Option A - From Energy Store:**
1. Open app
2. Tap on Energy icon (⚡) in bottom navigation
3. See "⚡ Energy Pass" card at the top
4. Tap the card

**Option B - From Profile:**
1. Open app
2. Tap on Profile icon in bottom navigation
3. Scroll to "Account" section
4. Tap "Energy Pass" (💎 icon)

### Step 2: View Subscription Screen
- See Energy Pass plan (฿149/month)
- See benefits:
  - ✨ Unlimited AI Analysis
  - 🎁 Double Streak Rewards
  - 👑 Exclusive Badge
  - 📱 Priority Support

### Step 3: Test Purchase (Optional)
**Prerequisites:**
- Real Android device
- Google Play test account added

**Steps:**
1. Tap "Subscribe Now"
2. Google Play payment sheet opens
3. Select test payment
4. Complete purchase
5. Wait for verification
6. Check subscription activates

## ✅ What to Check

### UI Check (Quick)
- [ ] Energy Pass card shows in Energy Store
- [ ] Card is tappable and navigates correctly
- [ ] Subscription Screen displays properly
- [ ] Benefits list is clear
- [ ] Price shows correctly (฿149/month)
- [ ] Subscribe button is visible

### Backend Check (After Purchase)
- [ ] Firebase logs show verification
- [ ] Firestore has subscription data
- [ ] Energy doesn't decrease for AI analysis
- [ ] PRO badge appears (if implemented)

## 🐛 Common Issues

### "Screen not found"
- Make sure you saved all files
- Try: `flutter clean && flutter pub get`

### "Can't navigate"
- Check imports in energy_store_screen.dart
- Check imports in profile_screen.dart

### "Build failed"
- Run: `flutter analyze`
- Fix any import errors

## 📱 Expected Behavior

### Before Subscribe
- Energy Store shows Energy Pass CTA
- Profile shows "Unlimited AI + Double rewards"
- AI analysis costs 1 energy

### After Subscribe
- Subscription Screen shows "Energy Pass Active"
- Status: Active, Renewal date shown
- AI analysis costs 0 energy (unlimited)
- PRO badge visible

## 🎯 Success!

If you can:
1. ✅ See Energy Pass card in Energy Store
2. ✅ Navigate to Subscription Screen
3. ✅ View plan details and benefits
4. ✅ See "Subscribe Now" button

**Then navigation is working perfectly!** 🎉

For full testing with real purchase, see `TESTING_GUIDE.md`
