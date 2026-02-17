# Phase 2: Challenges & Milestones

**เป้าหมาย:** Weekly Challenges, Milestone Rewards, Bonus Energy, Random Bonus  
**ระยะเวลา:** 2 สัปดาห์ (14 วัน)  
**ต้องทำ Phase 1 เสร็จก่อน:** ✅

---

## 📋 Task List (ทำตามลำดับ)

| Task | ชื่อ | ไฟล์ที่ต้องทำ | ระยะเวลา | สถานะ |
|------|------|--------------|---------|-------|
| 1 | Weekly Challenges (Backend) | `TASK_1_WEEKLY_CHALLENGES.md` | 2 วัน | ⬜ |
| 2 | Milestone Rewards (Backend) | `TASK_2_MILESTONES.md` | 2 วัน | ⬜ |
| 3 | Bonus Energy System | `TASK_3_BONUS_ENERGY.md` | 1 วัน | ⬜ |
| 4 | Random Daily Bonus | `TASK_4_RANDOM_BONUS.md` | 1 วัน | ⬜ |
| 5 | Cron Jobs | `TASK_5_CRON.md` | 1 วัน | ⬜ |
| 6 | Flutter Client Updates | `TASK_6_FLUTTER.md` | 3 วัน | ⬜ |
| 7 | Testing & Verification | `TASK_7_TESTING.md` | 2 วัน | ⬜ |

---

## 🎯 Deliverables ของ Phase 2

### Backend
- ✅ `completeChallenge` — Claim weekly challenges
- ✅ `claimMilestone` — Claim milestones
- ✅ `analyzeFood` (แก้ไข) — Track challenge progress
- ✅ `verifyPurchase` (แก้ไข) — Bonus Energy
- ✅ `dailyCheckIn` (แก้ไข) — Random Bonus
- ✅ `resetWeeklyChallenges` — Cron job

### Firestore
- ✅ `users.challenges.weekly` — Challenge progress
- ✅ `users.milestones` — Milestone flags
- ✅ `config/rewards` — อัพเดท config

### Flutter
- ✅ Weekly Challenge Card UI
- ✅ Milestone Progress Card UI
- ✅ Random Bonus Animation
- ✅ Bonus Energy Badge (Store)

---

## 📝 วิธีใช้คู่มือนี้

1. **ทำ Phase 1 ให้เสร็จก่อน** — Phase 2 ต้องใช้ระบบจาก Phase 1
2. **เปิดไฟล์ TASK_X** — มีขั้นตอนละเอียด
3. **ทำตามลำดับ** — Task 1 → 2 → ... → 7
4. **Test ทุก task** — ต้อง test ให้ผ่านก่อนไปต่อ

---

## ✅ เมื่อทำเสร็จ Phase 2

```bash
□ Log 7 meals → challenge สำเร็จ → claim 5 Energy
□ Use AI 3 times → challenge สำเร็จ → claim 5 Energy
□ totalSpent ≥ 500 → claim 15 Energy
□ totalSpent ≥ 1000 → claim 30 Energy
□ Gold tier ซื้อ 100 → ได้ 120 (+20% bonus)
□ Diamond tier ซื้อ 100 → ได้ 130 (+30% bonus)
□ Random bonus ~5% chance → ได้ 5-10 Energy
□ Weekly challenges reset ทุกวันจันทร์
```

→ ไป **Phase 3** ได้เลย! 🎉
