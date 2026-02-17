# Phase 4: Referral + Comeback

**เป้าหมาย:** Referral System, Comeback Bonus  
**ระยะเวลา:** 2 สัปดาห์  
**สถานะ:** 📝 READY FOR IMPLEMENTATION

---

## 📋 Task List

| Task | ชื่อ | เอกสาร | สถานะ | ระยะเวลา |
|------|------|--------|-------|---------|
| 1 | Referral Backend | TASK_1_REFERRAL_BACKEND.md | ✅ READY | 6-8 ชม. |
| 2 | Referral UI (Flutter) | TASK_2_REFERRAL_FLUTTER.md | ✅ READY | 4-6 ชม. |
| 3 | Comeback Bonus | (TODO) | ⏳ Pending | 4-6 ชม. |
| 4 | Admin: Referral Analytics | (TODO) | ⏳ Pending | 4 ชม. |
| 5 | Testing | (See each task doc) | ⏳ Pending | 2 ชม. |

**Total Estimated Time:** 20-26 hours

---

## 🎯 Key Features

### ✅ Referral System (READY)
- **Referrer reward:** 15 Energy per friend
- **Referee reward:** 5 Energy bonus (instant)
- **Limit:** 2 referrals/month
- **Condition:** Friend ต้องใช้ AI 3 ครั้งภายใน 7 วัน
- **Code:** MiRO ID = Referral Code
- **Anti-fraud:** IP check + device fingerprint

**Backend Status:**
- ✅ `submitReferralCode.ts` - Deploy แล้ว
- ✅ `checkReferralProgress.ts` - Deploy แล้ว
- ⚠️ ต้อง integrate กับ `analyzeFood.ts`
- ⚠️ ต้องสร้าง cron jobs (expire, reset quota)

**Flutter Status:**
- ❌ ยังไม่มี UI
- ❌ ยังไม่มี service/provider

---

### ⏳ Comeback Bonus (PENDING)
| หายไป | Reward |
|-------|--------|
| 3-7 วัน | 3 Energy |
| 7-14 วัน | 5 Energy |
| 14-30 วัน | 10 Energy |
| 30+ วัน | 15 Energy |

**Frequency:** ได้แค่ 1 ครั้ง/60 วัน

---

## 🚀 Quick Start for Junior

### Step 1: เริ่มจาก Task 1
```bash
# อ่านเอกสาร
cat phase_4/TASK_1_REFERRAL_BACKEND.md

# Follow step-by-step instructions
```

### Step 2: ทำ Task 2
```bash
cat phase_4/TASK_2_REFERRAL_FLUTTER.md
```

### Step 3: Test ทั้งหมด
- Referral flow ครบ
- Edge cases
- Anti-fraud

---

## 📁 Files Structure

```
phase_4/
├── README.md                      ← This file
├── TASK_1_REFERRAL_BACKEND.md    ← Backend implementation ✅
├── TASK_2_REFERRAL_FLUTTER.md    ← Flutter UI ✅
├── TASK_3_COMEBACK.md            ← TODO
└── TASK_4_ADMIN_ANALYTICS.md     ← TODO
```

---

## ✅ Success Criteria

**Referral System:**
- [ ] User A share code → User B submit → B ได้ +5 Energy
- [ ] User B ใช้ AI 3 ครั้ง → User A ได้ +15 Energy
- [ ] Quota 2/month enforced
- [ ] Anti-fraud working
- [ ] Cron jobs ทำงานถูกต้อง

**Comeback Bonus:**
- [ ] Comeback bonus ถูกต้องตาม tier
- [ ] Dialog แสดงถูกต้อง
- [ ] ได้แค่ 1 ครั้ง/60 วัน

---

## 🔗 Related Documentation

- [Phase 1 README](../phase_1/README.md)
- [Phase 2 README](../phase_2/README.md)
- [Phase 3 README](../phase_3/README.md)
- [Overall STATUS](../STATUS.md)
