# Subscription Backend Setup - Completed ✅

## 📝 Status

### Google Play Console
- [x] Product ID: `energy_pass_monthly` (149 THB/month)
- [x] Status: Active
- [x] Auto-renewing subscription

### Firebase Functions
- [x] Deploy `verifySubscription`: https://verifysubscription-lkfwupvm7a-uc.a.run.app
- [x] Deploy `handleRTDN`: https://handlertdn-lkfwupvm7a-uc.a.run.app
- [x] Secret: `GOOGLE_SERVICE_ACCOUNT_JSON` (version 2)

### Environment Variables
- [x] `.env` file created with `GOOGLE_PLAY_LICENSE_KEY`
- [x] `.gitignore` updated to exclude secrets

---

## 🔧 Next Steps: Setup RTDN

### 1. Configure RTDN in Google Play Console

**Location:** Google Play Console → Monetization setup → Real-time developer notifications

**Or direct URL:** 
https://play.google.com/console/developers/{YOUR_DEVELOPER_ID}/app/{YOUR_APP_ID}/monetization-setup

**Settings:**
- Topic name: `projects/miro-d6856/topics/play-rtdn`
- Enable real-time developer notifications: ✅

### 2. Create Pub/Sub Topic (if not exists)

```bash
gcloud pubsub topics create play-rtdn --project=miro-d6856
```

### 3. Grant permissions to Google Play

```bash
gcloud pubsub topics add-iam-policy-binding play-rtdn \
  --project=miro-d6856 \
  --member=serviceAccount:google-play-developer-notifications@system.gserviceaccount.com \
  --role=roles/pubsub.publisher
```

### 4. Link Pub/Sub to Cloud Function

Already configured in `handleRTDN` function - it will automatically receive Pub/Sub messages.

---

## 🧪 Testing

### Test verifySubscription

```bash
curl -X POST https://verifysubscription-lkfwupvm7a-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test-device-123",
    "purchaseToken": "test-token",
    "productId": "energy_pass_monthly"
  }'
```

### Test with real purchase (from Flutter app)

1. User taps "Subscribe" in app
2. Complete payment in Google Play
3. App calls `verifySubscription` with real purchase token
4. Backend verifies with Google Play API
5. User gets subscription benefits

---

## 📊 Monitor

- Firebase Console: https://console.firebase.google.com/project/miro-d6856/functions
- Cloud Logging: https://console.cloud.google.com/logs
- Firestore: Check `users/{deviceId}/subscription` field

---

## 🎯 Subscription Benefits (when active)

- ✅ Unlimited AI analysis (no energy cost)
- ✅ Double streak rewards
- ✅ Exclusive badge
- ✅ Priority support

Implemented in Flutter app by checking `user.subscription.status === 'active'`
