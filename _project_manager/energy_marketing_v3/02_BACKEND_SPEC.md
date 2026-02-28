# Backend Spec — Firebase Functions

> **สำหรับ:** Junior Developer  
> **Stack:** Firebase Functions (TypeScript)  
> **อ้างอิง:** `_project_manager/ENERGY_MARKETING_BLUEPRINT.md`

---

## #1 — แก้ Bug: Offer ซื้อซ้ำได้ไม่จำกัด 🔴 Critical

### ปัญหา
Promotion offers (Welcome Offer, Tier Upgrade) สามารถซื้อซ้ำได้เรื่อยๆ จนกว่าจะหมดเวลา

### แก้ไข

**ไฟล์:** `functions/src/energy/promotions.ts`, `functions/src/subscription/verifyPurchase.ts`

**Firestore schema เพิ่ม:**
```typescript
// users/{deviceId}
{
  offers: {
    firstPurchaseClaimed: boolean,    // $1 = 200E deal
    welcomeBonusClaimed: boolean,     // 40% bonus offer
    tierPromoClaimed: {               // per-tier promo
      bronze: boolean,
      silver: boolean,
      gold: boolean,
      diamond: boolean
    }
  }
}
```

**Logic:**
1. ก่อน process purchase → check flag ว่า offer นี้ claimed แล้วหรือยัง
2. ถ้า claimed แล้ว → reject purchase, return error
3. หลัง purchase สำเร็จ → set flag = true
4. ทำทั้ง backend (server-side validation) และ frontend (disable ปุ่ม)

**Test:**
- ซื้อ offer ครั้งแรก → สำเร็จ
- ซื้อ offer ครั้งที่ 2 → ถูก reject
- ลองจาก device อื่น same account → ถูก reject

---

## #2 — ปรับค่า Config

**ไฟล์:** `functions/src/energy/dailyCheckIn.ts`, `functions/src/energy/challenge.ts`

### Challenge Rewards
```typescript
// เดิม
const CHALLENGE_REWARD = 5;
// ใหม่
const CHALLENGE_REWARD = 3;
```

### Tier Upgrade Rewards
```typescript
// เดิม
const TIER_REWARDS = { bronze: 3, silver: 5, gold: 10, diamond: 15 };
// ใหม่
const TIER_REWARDS = { bronze: 5, silver: 10, gold: 15, diamond: 25 };
```

### ลบ Subscriber Double Quest
```typescript
// เดิม: subscriber ได้ 2x
// ใหม่: ทุกคนได้เท่ากัน ลบ multiplier ออก
```

---

## #3 — ลบ Features เก่า

### ลบ Random Daily Bonus
**ไฟล์:** `functions/src/energy/dailyCheckIn.ts`
- ลบ logic ที่ random 5% chance ให้ +5-10E

### ลบ First Empty Bonus
**ไฟล์:** `functions/src/energy/` (หา function ที่ให้ +50E ตอน energy หมดครั้งแรก)
- ลบ logic ทั้งหมด
- ลบ field `firstEmptyBonusClaimed` จาก user doc (optional, backward compat)

### ลบ Welcome Offer +50E
**ไฟล์:** `functions/src/energy/promotions.ts`
- เปลี่ยนจากให้ +50E ฟรี → ไม่ให้ (milestone #1 ให้ +3E แทน)
- ยังคงมี 40% bonus offer แต่เป็น offer แยก (ดู #5)

---

## #4 — Milestone System ใหม่ (10 ขั้น)

**ไฟล์ใหม่:** `functions/src/energy/milestoneV2.ts`

### Milestone Table (Hardcoded Config)
```typescript
const MILESTONES = [
  { threshold: 10,    reward: 3,   label: 'milestone_10' },
  { threshold: 25,    reward: 5,   label: 'milestone_25' },
  { threshold: 50,    reward: 7,   label: 'milestone_50' },
  { threshold: 100,   reward: 10,  label: 'milestone_100' },
  { threshold: 250,   reward: 15,  label: 'milestone_250' },
  { threshold: 500,   reward: 20,  label: 'milestone_500' },
  { threshold: 1000,  reward: 30,  label: 'milestone_1000' },
  { threshold: 2500,  reward: 50,  label: 'milestone_2500' },
  { threshold: 5000,  reward: 65,  label: 'milestone_5000' },
  { threshold: 10000, reward: 100, label: 'milestone_10000' },
];
```

### Firestore Schema
```typescript
// users/{deviceId}
{
  milestones: {
    totalSpent: number,           // cumulative energy spent
    claimedMilestones: string[],  // ['milestone_10', 'milestone_25', ...]
    nextMilestoneIndex: number    // index ใน MILESTONES array
  }
}
```

### Logic (เรียกหลังทุก AI analysis)
```
1. totalSpent += 1
2. Check: totalSpent >= MILESTONES[nextMilestoneIndex].threshold?
3. ถ้าใช่:
   a. เพิ่ม balance += reward
   b. push label เข้า claimedMilestones
   c. nextMilestoneIndex++
   d. Log transaction (type: 'milestone_cashback')
   e. Return milestone info ให้ frontend แสดง animation
4. ถ้า milestone #1 (10E): → trigger $1 offer (ดู #5)
5. ถ้า milestone #3 (50E): → trigger sub upsell flag
```

### Migration
- ลบ milestone เก่า (500E, 1000E)
- Map ผู้ใช้เก่าที่ claimed milestone เก่าแล้ว → set claimedMilestones ตาม totalSpent ปัจจุบัน

---

## #5 — $1 = 200E Offer Flow

**ไฟล์:** `functions/src/energy/promotions.ts`, `functions/src/subscription/verifyPurchase.ts`

### Trigger
- เมื่อผู้ใช้ผ่าน Milestone #1 (totalSpent >= 10)
- Backend set flag: `offers.firstPurchaseAvailable: true`, `offers.firstPurchaseExpiry: now + 4hr`

### Verify Purchase
```
1. รับ purchase token จาก frontend
2. Check: offers.firstPurchaseClaimed == false
3. Check: now < offers.firstPurchaseExpiry
4. Verify purchase กับ Google Play API
5. เพิ่ม balance += 200
6. Set offers.firstPurchaseClaimed = true
7. Trigger: 40% Bonus Offer (offers.bonusOfferAvailable: true, expiry: now + 24hr)
8. Log transaction
```

### 40% Bonus Offer (ตามหลัง $1 deal)
- Trigger: หลังซื้อ $1 deal สำเร็จ
- ระยะเวลา: 24 ชม.
- ผล: ซื้อ Energy Package ใดก็ได้ → ได้ +40% bonus
- 1 ครั้ง/บัญชี

---

## #6 — Daily Claim (Manual)

**ไฟล์:** `functions/src/energy/dailyCheckIn.ts`

### เปลี่ยนจาก Auto → Manual
- **เดิม:** `analyzeFood` function เรียก `processCheckIn()` อัตโนมัติ
- **ใหม่:** สร้าง endpoint แยก `claimDailyEnergy` ที่ frontend ต้องเรียกเอง

### Endpoint: `claimDailyEnergy`
```
1. Check: วันนี้ claim แล้วหรือยัง? (lastClaimDate == today)
2. ถ้า claim แล้ว → return { alreadyClaimed: true }
3. ถ้ายังไม่ claim:
   a. เพิ่ม balance += dailyEnergy (ตาม tier)
   b. streak += 1
   c. เช็ค tier upgrade
   d. Set lastClaimDate = today
   e. Return {
        energyClaimed: number,
        newStreak: number,
        tierUpgraded: boolean,
        newTier: string,
        tierReward: number,
        activeOffers: Offer[]  // offers ที่ active อยู่
      }
```

### ไม่ต้องเปลี่ยน
- `analyzeFood` ยังคง deduct energy ตามเดิม
- แต่ **ลบ** auto check-in ออกจาก `analyzeFood`

---

## #7 — Rewarded Ads Verification

**ไฟล์ใหม่:** `functions/src/energy/rewardedAd.ts`

### Server-Side Verification (SSV)
Google AdMob ส่ง callback มาที่ server เมื่อ user ดู ad จบ

### Endpoint: `verifyRewardedAd`
```
1. รับ: SSV callback จาก AdMob (หรือ client-side token)
2. Verify: signature จาก AdMob
3. Check: วันนี้ดู ad ไปกี่ครั้งแล้ว? (adViews.today < 3)
4. ถ้า < 3:
   a. adViews.today += 1
   b. Return { adRewardGranted: true, remainingAds: 3 - adViews.today }
   c. ไม่เพิ่ม balance — frontend ให้ใช้ AI ฟรี 1 ครั้งทันที
5. ถ้า >= 3:
   a. Return { adRewardGranted: false, remainingAds: 0 }
```

### Firestore Schema
```typescript
// users/{deviceId}
{
  adViews: {
    date: string,  // 'YYYY-MM-DD'
    count: number  // 0-3
  }
}
```

### Anti-Fraud
- Server-side verification เท่านั้น (ไม่เชื่อ client)
- Rate limit: max 3/วัน/user
- Log ทุก ad view สำหรับ analytics

---

## #8 — Push Notification Triggers

**ไฟล์ใหม่:** `functions/src/notifications/pushTriggers.ts`

### 3 กรณี

#### 8.1 Offer ใกล้หมด
- **Trigger:** Scheduled function ทุก 15 นาที
- **เงื่อนไข:** user มี active offer ที่เหลือเวลา < 1 ชม. && ยังไม่ส่ง notification สำหรับ offer นี้
- **ข้อความ:** "⏰ โปรพิเศษกำลังจะหมด! เหลือเวลาอีก 1 ชั่วโมง"

#### 8.2 ลืม Login (3 ทุ่ม)
- **Trigger:** Scheduled function ทุกวัน 21:00 UTC+7
- **เงื่อนไข:** user มี streak > 0 && lastClaimDate != today
- **ข้อความ:** "ลืม log หรือเปล่า? Streak จะหาย! 🔥 Daily reward รอคุณอยู่"

#### 8.3 Tier Up
- **Trigger:** ใน `claimDailyEnergy` เมื่อ tierUpgraded == true
- **ข้อความ:** "🎉 ยินดีด้วย! คุณเลื่อนเป็น [Tier]! Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!"

### Firestore Schema เพิ่ม
```typescript
// users/{deviceId}
{
  fcmToken: string,
  notifications: {
    offerExpirySent: { [offerId: string]: boolean },
    lastStreakReminder: string  // 'YYYY-MM-DD'
  }
}
```

---

## #9 — Referral Two-Way

**ไฟล์:** `functions/src/referral/submitReferralCode.ts`, `checkReferralProgress.ts`

### เปลี่ยนจาก One-Way → Two-Way
- **เดิม:** เฉพาะผู้ชวนได้ reward
- **ใหม่:** ทั้งสองฝ่ายได้ +5E เมื่อเพื่อนใช้ Energy ครบ 10E

### Logic
```
checkReferralProgress:
1. เช็ค: เพื่อนที่ถูกชวน totalSpent >= 10?
2. ถ้าใช่ && ยังไม่ได้ reward:
   a. ผู้ชวน: balance += 5, log transaction
   b. เพื่อน: balance += 5, log transaction
   c. Set referralRewardClaimed = true (ทั้งสองฝ่าย)
```

---

## #10 — Winback Subscription Offer

**ไฟล์:** `functions/src/subscription/verifySubscription.ts`

### Logic
```
1. Scheduled function: ทุกวัน scan users ที่ subscription.status == 'expired'
2. เงื่อนไข: expiryDate + 7 วัน < now && ยังไม่เคยส่ง winback
3. Action:
   a. Set user flag: winbackOfferAvailable = true
   b. ส่ง Push Notification: "กลับมาใช้ MiRO! Energy Pass เดือนแรกแค่ $3"
   c. Frontend อ่าน flag แล้วแสดง offer
4. Offer: ใช้ Google Play Promotional Offer ID 'winback-3usd' (อยู่ใน Base Plan 'energy-pass-monthly')
```
