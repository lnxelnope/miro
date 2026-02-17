# Subscription System - Testing Guide

## ✅ Implementation Complete

**Status:** Ready for Testing  
**Date:** 2026-02-17

---

## 📦 Files Created

### Models
- ✅ `lib/features/subscription/models/subscription_status.dart`
- ✅ `lib/features/subscription/models/subscription_data.dart`
- ✅ `lib/features/subscription/models/subscription_plan.dart`

### Services
- ✅ `lib/features/subscription/services/subscription_service.dart`
- ✅ `lib/core/ai/subscription_aware_gemini_service.dart`

### Providers
- ✅ `lib/features/subscription/providers/subscription_provider.dart`

### UI
- ✅ `lib/features/subscription/presentation/subscription_screen.dart`
- ✅ `lib/features/subscription/widgets/subscriber_badge.dart`

### Backend
- ✅ `verifySubscription` function deployed
- ✅ `handleRTDN` function deployed
- ✅ RTDN Pub/Sub configured

### Configuration
- ✅ `pubspec.yaml` - added `cloud_firestore: ^5.6.12`
- ✅ `functions/.env` - added Google Play License Key
- ✅ `.gitignore` updated

---

## 🧪 Testing Checklist

### 1. Pre-Testing Setup

**Google Play Console:**
- [ ] Add test account to License Testing
  - Go to: Settings → License Testing
  - Add your Gmail account
  - Save changes

**Flutter App:**
```bash
# Build & install on device
flutter build apk --release
flutter install
```

### 2. UI Testing (Without Purchase)

- [ ] Open app
- [ ] Navigate to Subscription Screen
- [ ] Check if Energy Pass plan displays correctly
- [ ] Check if benefits list shows
- [ ] Check if price displays (should be ฿149/month)
- [ ] Check "Subscribe Now" button appears

### 3. Subscription Status Check

**Test: Empty subscription (not subscribed)**
```dart
// Should show "Not Subscribed" status
// Should NOT show subscriber badge
// Should require energy for AI analysis
```

### 4. Purchase Flow Testing

**Test: Initiate purchase**
- [ ] Tap "Subscribe Now"
- [ ] Google Play payment sheet appears
- [ ] Select test payment method
- [ ] Complete payment
- [ ] Check loading indicator
- [ ] Check success/error message

**Expected Result:**
- ✅ Purchase initiates without errors
- ✅ Google Play shows test purchase (fake payment)
- ✅ App receives purchase confirmation
- ✅ `verifySubscription` function is called
- ✅ Firestore updated with subscription data

### 5. Backend Verification

**Check Firebase Logs:**
```bash
# View verifySubscription logs
firebase functions:log --only verifySubscription --lines 50

# Should see:
# - "💎 Verifying subscription for device-xxx"
# - "📦 Google Play response: ..."
# - "✅ Subscription verified: active"
```

**Check Firestore:**
```
users/{deviceId}/subscription:
{
  status: "active",
  productId: "energy_pass_monthly",
  purchaseToken: "...",
  startDate: Timestamp,
  expiryDate: Timestamp,
  autoRenewing: true,
  lastVerifiedAt: Timestamp
}
```

### 6. Subscription Features Testing

**Test: Unlimited AI Analysis**
- [ ] Complete subscription
- [ ] Try AI food analysis
- [ ] Check energy balance (should NOT decrease)
- [ ] Check logs show "Subscriber - no energy consumed"

**Test: Double Rewards**
- [ ] Check daily streak rewards
- [ ] Verify rewards are doubled (future feature)

**Test: Exclusive Badge**
- [ ] Check if PRO badge appears
- [ ] Badge should show in profile/header

### 7. RTDN Testing

**Test: Manual notification**
```bash
# Send test notification from Google Play Console
# Monetization setup → Real-time developer notifications
# Click "Send test notification"

# Check Firebase Logs:
firebase functions:log --only handleRTDN --lines 50
```

**Expected:**
- ✅ Test notification received
- ✅ Function processes without errors

### 8. Subscription Management

**Test: Active subscription screen**
- [ ] Open Subscription Screen (as subscriber)
- [ ] Should show "Energy Pass Active"
- [ ] Should display status, renewal date, price
- [ ] Should list benefits with checkmarks
- [ ] "Manage Subscription" button visible

**Test: Cancel subscription** (via Google Play)
- [ ] Open Google Play → Subscriptions
- [ ] Cancel MIRO subscription
- [ ] Wait for RTDN (or refresh app)
- [ ] Status should update to "cancelled"
- [ ] Still have access until expiry date

### 9. Error Handling

**Test: No internet**
- [ ] Disable network
- [ ] Try to subscribe
- [ ] Should show error message

**Test: Insufficient permissions**
- [ ] Check error messages are user-friendly

**Test: Already subscribed**
- [ ] Try to subscribe again
- [ ] Should handle gracefully

---

## 🐛 Common Issues & Solutions

### Issue: "In-app purchases not available"
**Solution:**
- Check if app is signed with release key
- Verify Google Play Console setup
- Ensure test account is added

### Issue: "Product not found"
**Solution:**
- Wait 2-4 hours after creating product
- Check product ID matches: `energy_pass_monthly`
- Verify product status is "Active"

### Issue: "Purchase verification failed"
**Solution:**
- Check Firebase Functions logs
- Verify `GOOGLE_SERVICE_ACCOUNT_JSON` secret
- Check service account permissions

### Issue: "RTDN not working"
**Solution:**
- Verify Pub/Sub topic created
- Check IAM permissions for Google Play
- Confirm webhook URL in Play Console

---

## 📊 Success Criteria

All tests pass:
- ✅ UI displays correctly
- ✅ Purchase flow works
- ✅ Backend verifies purchase
- ✅ Firestore updates
- ✅ Unlimited AI works
- ✅ Badge displays
- ✅ RTDN receives notifications
- ✅ Error handling works

---

## 🚀 Next Steps

After testing:
1. Monitor Firebase logs for errors
2. Check Firestore for correct data
3. Test on multiple devices
4. Verify Google Play Console analytics
5. Release to production when ready

---

## 📝 Notes

- Test with real Google Play account (not emulator)
- Use test payment methods (no real charges)
- RTDN may take a few minutes to trigger
- Check logs frequently during testing

---

**Testing by:** [Your Name]  
**Date:** [Test Date]  
**Version:** 1.1.3+27  
**Status:** [ ] Pass / [ ] Fail
