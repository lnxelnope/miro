# Migration & Rollout Plan - Energy Marketing V3

## 🎯 Overview

เอกสารนี้อธิบาย strategy สำหรับ deploy Energy Marketing V3 อย่างปลอดภัย พร้อม rollback plan

---

## 📋 Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`flutter test`, `npm test`)
- [ ] No linter warnings (`flutter analyze`, `npm run lint`)
- [ ] Code reviewed and approved
- [ ] Documentation updated

### Database
- [ ] Firestore indexes created
- [ ] Security rules deployed
- [ ] Migration script tested in emulator
- [ ] Backup created

### Backend
- [ ] Cloud Functions deployed to staging
- [ ] API endpoints tested
- [ ] Firebase App Check enabled
- [ ] Secrets stored in Secret Manager

### Frontend
- [ ] Feature flags configured (Remote Config)
- [ ] Localization complete (EN + TH)
- [ ] APK/IPA built and tested
- [ ] Crash reporting enabled (Firebase Crashlytics)

### Monitoring
- [ ] Firebase Performance Monitoring enabled
- [ ] Custom traces added for critical flows
- [ ] Alerts configured (error rate, latency)
- [ ] Dashboard ready (Firebase Console)

---

## 🚀 Deployment Timeline

### Phase 0: Preparation (Day 0)

**Goal:** Prepare infrastructure

**Tasks:**
1. Create database backup
   ```bash
   gcloud firestore export gs://miro-backups/backup-$(date +%Y%m%d)
   ```

2. Deploy Firestore indexes
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. Deploy security rules
   ```bash
   firebase deploy --only firestore:rules
   ```

4. Test migration script in emulator
   ```bash
   firebase emulators:start --only firestore
   npm run migrate:v3 verify 100
   ```

**Success Criteria:**
- ✅ Backup created
- ✅ Indexes deployed
- ✅ Security rules deployed
- ✅ Migration script tested

---

### Phase 1: Backend Deployment (Day 1-2)

**Goal:** Deploy backend without breaking existing clients

**Tasks:**
1. Deploy new Cloud Functions (backward compatible)
   ```bash
   firebase deploy --only functions:getActiveOffersEndpoint
   firebase deploy --only functions:claimDailyEnergy
   firebase deploy --only functions:verifyRewardedAd
   firebase deploy --only functions:dismissOfferEndpoint
   ```

2. Run migration script
   ```bash
   npm run migrate:v3 migrate
   ```

3. Verify migration
   ```bash
   npm run migrate:v3 verify 50
   ```

4. Test endpoints manually
   ```bash
   curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint \
     -H "Content-Type: application/json" \
     -d '{"deviceId": "test-device-123"}'
   ```

**Success Criteria:**
- ✅ All users migrated successfully
- ✅ No errors in migration logs
- ✅ API endpoints return correct data
- ✅ Old clients still working (backward compatibility)

**Rollback Plan:**
- If migration fails: Fix script, rollback users, try again
- If endpoints broken: Redeploy previous version

---

### Phase 2: Feature Flag Setup (Day 3)

**Goal:** Prepare for staged rollout

**Tasks:**
1. Set up Remote Config in Firebase Console
   ```json
   {
     "quest_bar_enabled": {
       "defaultValue": false,
       "conditionalValues": [
         {
           "condition": "10% rollout",
           "value": true
         }
       ]
     }
   }
   ```

2. Update Flutter app to check feature flag
   ```dart
   final remoteConfig = FirebaseRemoteConfig.instance;
   await remoteConfig.fetchAndActivate();
   
   final questBarEnabled = remoteConfig.getBool('quest_bar_enabled');
   ```

3. Test feature flag locally
   ```bash
   # Force enable
   await remoteConfig.setConfigSettings(RemoteConfigSettings(
     fetchTimeout: Duration(seconds: 10),
     minimumFetchInterval: Duration.zero,
   ));
   ```

**Success Criteria:**
- ✅ Feature flag configured
- ✅ App respects flag (show/hide Quest Bar)
- ✅ Can toggle flag without redeploying

---

### Phase 3: 10% Rollout (Day 4-6)

**Goal:** Test with real users, monitor metrics

**Tasks:**
1. Enable Quest Bar for 10% of users
   - Go to Firebase Console → Remote Config
   - Update `quest_bar_enabled` condition to "10% rollout"
   - Publish changes

2. Monitor key metrics (24-48 hours)
   - Crash rate: < 0.5%
   - API latency (p95): < 500ms
   - Quest Bar load time: < 300ms
   - Conversion rate ($1 offer): > 5%
   - User feedback: Check Play Store / App Store reviews

3. Check logs for errors
   ```bash
   gcloud logging read "resource.type=cloud_function AND severity>=ERROR" --limit 100
   ```

4. Firebase Performance Monitoring
   - Go to Firebase Console → Performance
   - Check custom traces:
     - `quest_bar_load`
     - `claim_daily_energy`
     - `get_active_offers`

**Success Criteria:**
- ✅ Crash rate < 0.5%
- ✅ No critical errors in logs
- ✅ Conversion rate > 5%
- ✅ Positive user feedback

**Rollback Plan:**
- If crash rate > 0.5%: Disable feature flag immediately
- If conversion < 3%: Investigate UX issues
- If performance issues: Optimize (Phase 9)

---

### Phase 4: 50% Rollout (Day 7-9)

**Goal:** Scale up, monitor stability

**Tasks:**
1. Increase rollout to 50%
   ```json
   {
     "quest_bar_enabled": {
       "conditionalValues": [
         {
           "condition": "50% rollout",
           "value": true
         }
       ]
     }
   }
   ```

2. Monitor same metrics as Phase 3

3. Check Firestore usage
   - Go to Firebase Console → Firestore → Usage
   - Reads/day: Should not increase > 30%
   - Writes/day: Should be stable

4. Check Cloud Functions costs
   - Go to Google Cloud Console → Billing
   - Verify min instances cost (~$12/month)

**Success Criteria:**
- ✅ Same success criteria as Phase 3
- ✅ Firestore usage under control
- ✅ Costs within budget

**Rollback Plan:**
- Same as Phase 3

---

### Phase 5: 100% Rollout (Day 10+)

**Goal:** Full launch

**Tasks:**
1. Enable Quest Bar for all users
   ```json
   {
     "quest_bar_enabled": {
       "defaultValue": true
     }
   }
   ```

2. Monitor for 3-5 days

3. Announce on social media / in-app notification
   ```dart
   // Show in-app announcement
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: Text('🎉 New Feature!'),
       content: Text('Check out the Quest Bar for daily rewards and special offers!'),
     ),
   );
   ```

4. Update App Store / Play Store description
   - Mention Quest Bar in "What's New"

**Success Criteria:**
- ✅ All users have access
- ✅ No performance degradation
- ✅ Positive feedback

---

## 🔄 Rollback Procedures

### Option A: Feature Flag Rollback (Recommended)

**When to use:** Minor issues, want to disable feature without full rollback

**Steps:**
1. Disable feature flag
   ```json
   { "quest_bar_enabled": { "defaultValue": false } }
   ```

2. Publish changes (takes effect immediately)

3. Verify Quest Bar hidden in app

**Pros:** Fast (< 5 minutes), no code deployment
**Cons:** Backend changes remain

---

### Option B: Database Rollback

**When to use:** Data corruption or migration errors

**Steps:**
1. Stop all Cloud Functions
   ```bash
   firebase functions:delete getActiveOffersEndpoint
   # ... delete other functions
   ```

2. Restore database from backup
   ```bash
   gcloud firestore import gs://miro-backups/backup-20260220
   ```

3. Run rollback script
   ```bash
   npm run rollback:v3 --confirm rollback
   ```

4. Verify rollback
   ```bash
   npm run rollback:v3 --confirm verify 50
   ```

5. Redeploy old Cloud Functions
   ```bash
   git checkout v2.0
   firebase deploy --only functions
   ```

**Pros:** Full rollback, clean state
**Cons:** Slow (30-60 minutes), potential data loss (transactions during rollback window)

---

### Option C: App Version Rollback

**When to use:** Critical client-side bugs

**Steps:**
1. Disable Quest Bar via feature flag (immediate)
   ```json
   { "quest_bar_enabled": { "defaultValue": false } }
   ```

2. Publish previous app version to stores
   - Play Store: Rollback to previous release
   - App Store: Submit expedited review with bug fix

3. Force update users
   ```dart
   // Check app version on startup
   if (currentVersion < minSupportedVersion) {
     showForceUpdateDialog();
   }
   ```

**Pros:** Fixes client bugs
**Cons:** Slow (24-48 hours for review), users must update

---

## 📊 Monitoring Dashboard

### Key Metrics to Track

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Crash rate | < 0.5% | > 1% |
| API latency (p95) | < 500ms | > 1000ms |
| Quest Bar load time | < 300ms | > 500ms |
| Conversion rate ($1 offer) | > 5% | < 3% |
| Daily active users | Stable | -10% from baseline |
| Revenue | Increase | -5% from baseline |

### Firebase Console Views

1. **Crashlytics**
   - Monitor crash-free users percentage
   - Check for new crash types

2. **Performance Monitoring**
   - Custom traces:
     - `quest_bar_load`
     - `claim_daily_energy`
     - `get_active_offers`
   - Network requests:
     - `getActiveOffersEndpoint`
     - `claimDailyEnergy`

3. **Analytics**
   - Custom events:
     - `quest_bar_loaded`
     - `offer_dismissed`
     - `daily_energy_claimed`
     - `offer_converted`

4. **Firestore Usage**
   - Reads/day
   - Writes/day
   - Storage

5. **Cloud Functions Logs**
   - Error logs
   - Latency distribution
   - Invocations/minute

---

## 🧪 Testing Checklist

### Pre-Deployment Testing

- [ ] Unit tests: 100% pass
- [ ] Integration tests: 100% pass
- [ ] Manual testing:
  - [ ] Quest Bar displays correctly
  - [ ] Countdown timer accurate
  - [ ] Swipe to dismiss works
  - [ ] Claim button works
  - [ ] Multiple offers prioritized correctly
  - [ ] Streak mode displays when no offers
- [ ] Offline mode: App doesn't crash
- [ ] Different screen sizes: UI adapts
- [ ] Localization: EN + TH both work

### Post-Deployment Testing (Production)

- [ ] Smoke test (10 test accounts)
- [ ] Check API responses
- [ ] Verify metrics in dashboard
- [ ] Monitor logs for errors
- [ ] Check user feedback (reviews, support tickets)

---

## 📞 Incident Response

### If Critical Issue Detected

1. **Immediate (0-5 min):**
   - Disable feature flag: `quest_bar_enabled = false`
   - Notify team in Slack/Discord

2. **Investigation (5-30 min):**
   - Check Firebase Crashlytics for errors
   - Check Cloud Functions logs
   - Reproduce issue locally

3. **Fix (30 min - 2 hours):**
   - Patch bug
   - Test fix locally
   - Deploy to staging
   - Test in staging

4. **Deploy Fix (2-4 hours):**
   - Deploy to production
   - Re-enable feature flag (10% → 50% → 100%)
   - Monitor closely

5. **Post-Mortem (1 day later):**
   - Document issue and fix
   - Update runbook
   - Add tests to prevent regression

---

## 📝 Runbook Commands

### Quick Reference

```bash
# Backup database
gcloud firestore export gs://miro-backups/backup-$(date +%Y%m%d)

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy security rules
firebase deploy --only firestore:rules

# Deploy Cloud Functions
firebase deploy --only functions

# Run migration
npm run migrate:v3 migrate

# Verify migration
npm run migrate:v3 verify 50

# Rollback
npm run rollback:v3 --confirm rollback

# Check logs
gcloud logging read "resource.type=cloud_function AND severity>=ERROR" --limit 100

# Monitor Firestore usage
gcloud firestore indexes list
```

---

## ✅ Final Checklist

Before going to 100% rollout, ensure:

- [ ] 10% rollout successful (no critical issues)
- [ ] 50% rollout successful (metrics stable)
- [ ] All monitoring dashboards set up
- [ ] Team trained on rollback procedures
- [ ] Support team briefed on new feature
- [ ] Announcement materials ready
- [ ] Backup created
- [ ] Rollback plan tested

---

## 🎉 Success Criteria

V3 is considered successful if:

1. **Technical:**
   - Crash rate < 0.5%
   - API latency < 500ms (p95)
   - Quest Bar load time < 300ms
   - No data loss

2. **Business:**
   - Conversion rate > 5% ($1 offer)
   - Revenue increase > 10%
   - User engagement increase > 15%

3. **User Satisfaction:**
   - Positive reviews (> 80%)
   - Low support tickets (< 5% increase)
   - NPS score stable or improved

---

## 📅 Estimated Timeline

| Phase | Duration | Total |
|-------|----------|-------|
| Preparation | 1 day | Day 0 |
| Backend Deploy | 2 days | Day 1-2 |
| Feature Flag Setup | 1 day | Day 3 |
| 10% Rollout + Monitor | 3 days | Day 4-6 |
| 50% Rollout + Monitor | 3 days | Day 7-9 |
| 100% Rollout | 1 day | Day 10 |
| Post-Launch Monitor | 3-5 days | Day 11-15 |
| **Total** | **~15 days** | |

**Conservative estimate:** 2-3 weeks including buffer time
