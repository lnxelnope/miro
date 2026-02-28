# 📚 Phase 4 & 5 - Quick Reference for Junior Developer

**Created:** 2026-02-17  
**Status:** ✅ READY FOR IMPLEMENTATION

---

## 🎯 Overview

Phase 4 และ 5 เป็น features สุดท้ายของ Monetization System:

**Phase 4:** Referral System + Comeback Bonus  
**Phase 5:** Subscription (Energy Pass)

---

## 📋 Phase 4: Referral System

### Task 1: Referral Backend (6-8 hours) ✅ READY

**เอกสาร:** `phase_4/TASK_1_REFERRAL_BACKEND.md`

**สิ่งที่ต้องทำ:**
1. ✅ Review existing functions (มีอยู่แล้ว!)
   - `submitReferralCode.ts`
   - `checkReferralProgress.ts`
2. Integrate `checkReferralProgress` ใน `analyzeFood.ts`
3. สร้าง `expireReferrals` cron job
4. สร้าง `resetReferralQuota` cron job
5. Deploy functions
6. Deploy Firestore indexes
7. Test full flow

**Backend พร้อมใช้แล้ว 90%!** แค่ต้อง integrate และสร้าง cron jobs

---

### Task 2: Referral UI (4-6 hours) ✅ READY

**เอกสาร:** `phase_4/TASK_2_REFERRAL_FLUTTER.md`

**สิ่งที่ต้องทำ:**
1. สร้าง `ReferralScreen` - หน้า invite friends
2. สร้าง `ReferralService` - API calls
3. สร้าง `ReferralProvider` - State management
4. เพิ่ม Share functionality
5. Test ทุก flow

**Features:**
- แสดง MiRO ID (= referral code)
- Copy & Share code
- Form ใส่ referral code
- แสดง quota (X/2 this month)

---

## 📋 Phase 5: Subscription

### Task 1: Subscription Backend (8-10 hours) ✅ READY

**เอกสาร:** `phase_5/TASK_1_SUBSCRIPTION_BACKEND.md`

**สิ่งที่ต้องทำ:**
1. Setup Google Play Developer API
2. Create subscription product (Energy Pass)
3. Implement `verifySubscription` function
4. Implement `handleRTDN` webhook
5. Update `analyzeFood` for unlimited AI
6. Deploy functions
7. Test purchase & RTDN

**ยากกว่า Referral หน่อย** เพราะต้อง setup Google Play API

---

### Task 2: Subscription UI (6-8 hours) ✅ READY

**เอกสาร:** `phase_5/TASK_2_SUBSCRIPTION_FLUTTER.md`

**สิ่งที่ต้องทำ:**
1. Add `in_app_purchase` dependency
2. Configure Android (build.gradle, manifest)
3. สร้าง `SubscriptionService`
4. สร้าง `SubscriptionProvider`
5. สร้าง `SubscriptionScreen`
6. Test purchase flow

**Features:**
- Subscription offer screen
- Active subscription screen
- Purchase button
- Status management

---

## 🗓️ Recommended Timeline

### Week 1: Phase 4
```
Day 1-2:  Task 1 - Referral Backend
Day 3-4:  Task 2 - Referral UI
Day 5:    Testing & Bug fixes
```

### Week 2-3: Phase 5
```
Day 1-2:  Task 1 - Subscription Backend (setup + implement)
Day 3:    Task 1 - Deploy & test
Day 4-5:  Task 2 - Subscription UI
Day 6:    Testing & Bug fixes
```

**Total:** ~30-40 hours

---

## 📁 File Structure

```
_project_manager/monetization_upgrade/
│
├── phase_4/
│   ├── README.md                      ← Phase overview
│   ├── TASK_1_REFERRAL_BACKEND.md    ← Step-by-step ✅
│   └── TASK_2_REFERRAL_FLUTTER.md    ← Step-by-step ✅
│
├── phase_5/
│   ├── README.md                          ← Phase overview
│   ├── TASK_1_SUBSCRIPTION_BACKEND.md    ← Step-by-step ✅
│   └── TASK_2_SUBSCRIPTION_FLUTTER.md    ← Step-by-step ✅
│
└── STATUS.md                          ← Overall progress
```

---

## ✅ เอกสารที่พร้อมใช้งาน

| Phase | Task | เอกสาร | สถานะ |
|-------|------|--------|-------|
| 4 | Referral Backend | TASK_1_REFERRAL_BACKEND.md | ✅ |
| 4 | Referral UI | TASK_2_REFERRAL_FLUTTER.md | ✅ |
| 5 | Subscription Backend | TASK_1_SUBSCRIPTION_BACKEND.md | ✅ |
| 5 | Subscription UI | TASK_2_SUBSCRIPTION_FLUTTER.md | ✅ |

**ทุกไฟล์มี:**
- 📋 Table of Contents
- 🎯 Overview
- 📊 Requirements
- 🚀 Step-by-Step Implementation (copy-paste ได้!)
- 🧪 Testing instructions
- 🐛 Troubleshooting
- ✅ Completion Checklist

---

## 🚀 วิธีเริ่มต้น

### Step 1: เลือก Phase ที่จะทำ

```bash
# ถ้าจะทำ Phase 4:
cd _project_manager/monetization_upgrade/phase_4
cat README.md

# ถ้าจะทำ Phase 5:
cd _project_manager/monetization_upgrade/phase_5
cat README.md
```

### Step 2: อ่านเอกสาร Task

```bash
# Phase 4 Task 1:
cat TASK_1_REFERRAL_BACKEND.md

# Phase 4 Task 2:
cat TASK_2_REFERRAL_FLUTTER.md

# ... etc
```

### Step 3: ทำตาม Step-by-Step

เอกสารทุกไฟล์มี:
- Step 1, 2, 3, ... แบบละเอียด
- Code snippets ที่ copy-paste ได้เลย
- ตำแหน่งไฟล์ที่ต้องสร้าง/แก้ไข
- คำสั่ง bash ที่ต้องรัน

### Step 4: Test ตาม Checklist

ทุก task มี Testing section พร้อม:
- Test cases
- Expected results
- How to verify

### Step 5: Mark as Complete

เมื่อเสร็จแล้ว:
- เช็ค Completion Checklist
- Update STATUS.md
- Commit & Push

---

## 💡 Tips for Success

### 1. อ่านเอกสารทั้งหมดก่อนเริ่ม
- เข้าใจภาพรวมก่อน
- รู้ว่าแต่ละ step ทำอะไร

### 2. Follow Step-by-Step
- อย่าข้าม step
- Code ทุกบรรทัดมีเหตุผล

### 3. Test ทุก Step
- อย่ารอจน deploy แล้วค่อย test
- Test ทีละ feature

### 4. ถ้าติดปัญหา
- อ่าน Troubleshooting section
- Check logs ใน Firebase Console
- Google error message
- ถามผม (Senior)!

### 5. Document ถ้าเจอ Issues ใหม่
- เพิ่มใน Troubleshooting
- จะช่วย developer คนต่อไป

---

## 🎓 Learning Resources

### Google Play Billing (Phase 5)
- [Official Docs](https://developer.android.com/google/play/billing)
- [In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [RTDN Guide](https://developer.android.com/google/play/billing/rtdn-reference)

### Referral Systems Best Practices
- Keep it simple
- Anti-fraud is crucial
- Track everything

---

## 📞 Need Help?

ถ้าติดที่ไหน:
1. อ่าน Troubleshooting section ในเอกสาร
2. Check Firebase logs
3. ถามผม!

---

## 🎉 ขอให้โชคดีครับ!

Phase 4 และ 5 เป็น features สุดท้าย!  
หลังจากนี้ Monetization System จะเสร็จสมบูรณ์แล้ว 🚀

---

**Happy Coding! 💻**