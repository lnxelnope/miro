# Phase 5: Subscription + Events

**เป้าหมาย:** Energy Pass Subscription  
**ระยะเวลา:** 2-3 สัปดาห์  
**สถานะ:** 📝 READY FOR IMPLEMENTATION

---

## 📋 Task List

| Task | ชื่อ | เอกสาร | สถานะ | ระยะเวลา |
|------|------|--------|-------|---------|
| 1 | Subscription Backend | TASK_1_SUBSCRIPTION_BACKEND.md | ✅ READY | 8-10 ชม. |
| 2 | Subscription UI | TASK_2_SUBSCRIPTION_FLUTTER.md | ✅ READY | 6-8 ชม. |
| 3 | Admin Analytics | (TODO) | ⏳ Pending | 6-8 ชม. |
| 4 | iOS IAP (Optional) | (TODO) | ⏳ Pending | 6-8 ชม. |
| 5 | Testing | (See each task doc) | ⏳ Pending | 4 ชม. |

**Total Estimated Time:** 30-38 hours

---

## 🎯 Key Features

### ✅ Energy Pass (149 THB/month) - READY

**Benefits:**
- ✓ Unlimited AI analysis (no energy cost)
- ✓ Double streak rewards
- ✓ Exclusive badge
- ✓ Priority support (optional)

**Technical:**
- Google Play Billing v6+
- Server-side receipt verification
- RTDN (Real-time Developer Notifications)
- Subscription lifecycle management

**Backend Status:**
- ⚠️ มี draft functions แต่ต้องแก้ไขใหม่
- ⚠️ ต้อง setup Google Play Developer API
- ⚠️ ต้อง create subscription product
- ⚠️ ต้อง implement RTDN webhook

**Flutter Status:**
- ❌ ยังไม่มี UI
- ❌ ยังไม่มี billing integration

---

### ⏳ Seasonal Events (FUTURE)
- Songkran Event (April)
- New Year Event (Dec-Jan)
- Custom Events

### ⏳ Social Features (FUTURE)
- Share meals to social
- Leaderboard (optional)
- Friend system (optional)

### ⏳ Energy Expiry (OPTIONAL)
- Energy หมดอายุหลัง 90 วัน
- Purchased energy ไม่หมดอายุ

---

## 🚀 Quick Start for Junior

### Step 1: เริ่มจาก Task 1 (Backend)
```bash
# อ่านเอกสาร
cat phase_5/TASK_1_SUBSCRIPTION_BACKEND.md

# Follow step-by-step:
# 1. Setup Google Play Developer API
# 2. Create subscription product
# 3. Implement verifySubscription
# 4. Implement RTDN handler
# 5. Deploy
```

### Step 2: ทำ Task 2 (Flutter UI)
```bash
cat phase_5/TASK_2_SUBSCRIPTION_FLUTTER.md

# Follow step-by-step:
# 1. Add dependencies
# 2. Configure Android
# 3. Create service & providers
# 4. Create UI
# 5. Test purchase flow
```

### Step 3: Test ทั้งหมด
- Purchase flow
- Receipt verification
- RTDN notifications
- Subscription status sync
- Unlimited AI working

---

## 📁 Files Structure

```
phase_5/
├── README.md                          ← This file
├── TASK_1_SUBSCRIPTION_BACKEND.md    ← Backend ✅
├── TASK_2_SUBSCRIPTION_FLUTTER.md    ← Flutter UI ✅
├── TASK_3_ADMIN_ANALYTICS.md         ← TODO
└── TASK_4_IOS_IAP.md                 ← TODO (Optional)
```

---

## ✅ Success Criteria

**Subscription System:**
- [ ] User ซื้อ subscription ผ่าน Google Play สำเร็จ
- [ ] Server verify receipt ถูกต้อง
- [ ] Subscription status sync realtime
- [ ] Unlimited AI ทำงาน (ไม่ deduct energy)
- [ ] Double rewards ทำงาน
- [ ] Badge แสดงใน app
- [ ] RTDN handle renewal/cancellation/expiry
- [ ] Admin panel แสดง metrics

---

## 🔗 Related Documentation

- [Phase 1 README](../phase_1/README.md)
- [Phase 2 README](../phase_2/README.md)
- [Phase 3 README](../phase_3/README.md)
- [Phase 4 README](../phase_4/README.md)
- [Overall STATUS](../STATUS.md)

---

## 💡 Important Notes

### Google Play Billing
- ต้อง setup service account ใน Google Cloud
- ต้อง link กับ Play Console
- ต้อง create subscription product ใน Play Console
- ต้อง test กับ real Google Play account

### RTDN (Real-time Developer Notifications)
- ต้อง setup Cloud Pub/Sub topic
- ต้อง configure ใน Play Console
- Webhook จะถูกเรียกเมื่อ subscription status เปลี่ยน
- Handle: renewal, cancellation, expiry, pause, restart

### Testing
- ใช้ Google Play test accounts
- ใช้ test purchase tokens
- Monitor logs ใน Firebase Functions
- Test ทุก notification types
