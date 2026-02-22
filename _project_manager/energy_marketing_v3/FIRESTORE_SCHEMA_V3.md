# Firestore Schema V3 — Energy Marketing Update

> **Version:** 3.0  
> **Date:** 20 ก.พ. 2026  
> **ผู้เขียน:** Senior Developer  
> **อ้างอิง:** `_project_manager/energy_marketing_v3/`

---

## Collection: `users/{deviceId}`

### Field ทั้งหมด

```
users/{deviceId}
├── (Existing — ไม่แตะ)
│   ├── balance             : number          — Energy ปัจจุบัน
│   ├── totalEarned         : number          — Energy ที่ได้รับทั้งหมด
│   ├── totalPurchased      : number          — Energy ที่ซื้อมาทั้งหมด
│   ├── miroId              : string          — Display ID (MIRO-XXXX)
│   ├── tier                : string          — 'none'|'bronze'|'silver'|'gold'|'diamond'
│   ├── highestTier         : string          — Tier สูงสุดที่เคยได้
│   ├── currentStreak       : number          — Streak วันปัจจุบัน
│   ├── longestStreak       : number          — Streak ยาวสุด
│   ├── lastCheckInDate     : string          — 'YYYY-MM-DD' (เดิมใช้ชื่อนี้)
│   ├── bonusRate           : number          — Tier bonus rate (0.10/0.20)
│   ├── fcmToken            : string|null     — FCM token สำหรับ Push Notification
│   ├── referralCode        : string          — รหัสชวนเพื่อน
│   ├── referredBy          : string|null     — deviceId ของผู้ชวน
│   ├── createdAt           : Timestamp
│   └── lastUpdated         : Timestamp
│
├── (Existing promotions — ยังคงไว้ backward compat)
│   └── promotions
│       ├── welcomeOfferClaimed     : boolean    — V2 flag (ไม่ใช้แล้ว)
│       ├── welcomeBackClaimed      : boolean
│       ├── tierPromoClaimed        : map<string,boolean>
│       ├── tierPromoAt             : map<string,Timestamp>
│       └── tierRewardClaimed       : map<string,boolean>
│
├── (NEW V3) offers                            — Offer system ใหม่
│   ├── firstPurchaseClaimed    : boolean      — $1 = 200E deal ใช้ไปแล้ว
│   ├── firstPurchaseAvailable  : boolean      — flag ว่ามี offer อยู่ (ต้องแสดง)
│   ├── firstPurchaseExpiry     : Timestamp|null — หมดอายุ (4hr จาก trigger)
│   ├── firstPurchaseClaimedAt  : Timestamp|null
│   │
│   ├── welcomeBonusClaimed     : boolean      — 40% bonus (หลัง $1 deal) ใช้ไปแล้ว
│   ├── welcomeBonusAvailable   : boolean      — flag (24hr หลัง $1 deal)
│   ├── welcomeBonusExpiry      : Timestamp|null
│   └── welcomeBonusClaimedAt   : Timestamp|null
│
├── (NEW V3) milestones                        — 10-step milestone system
│   ├── totalSpent          : number           — Energy ที่ใช้สะสม (เพิ่มทุกครั้งที่ analyze)
│   ├── claimedMilestones   : string[]         — ['milestone_10','milestone_25',...]
│   └── nextMilestoneIndex  : number           — index ใน MILESTONES array (0-9)
│
├── (NEW V3) adViews                           — Rewarded Ads quota
│   ├── date                : string           — 'YYYY-MM-DD' (วันที่นับ)
│   └── count               : number           — ดูไปแล้ว (0-3 ต่อวัน)
│
├── (NEW V3) dailyClaim                        — Manual daily claim
│   └── lastClaimDate       : string           — 'YYYY-MM-DD'
│
├── (NEW V3) notifications                     — Push notification tracking
│   ├── offerExpirySent     : map<string,boolean>  — {'first_purchase': true}
│   └── lastStreakReminder   : string          — 'YYYY-MM-DD'
│
├── (NEW V3) subscription                      — Subscription (updated schema)
│   ├── status              : string           — 'active'|'expired'|'cancelled'|'grace_period'
│   ├── productId           : string           — 'miro_normal_subscription'
│   ├── basePlanId          : string           — 'energy-pass-monthly'|'weekly'|'yearly'
│   ├── offerId             : string|null      — 'first-month-free'|'winback-3usd'|null
│   ├── purchaseToken       : string
│   ├── startDate           : Timestamp
│   ├── expiryDate          : Timestamp
│   ├── autoRenewing        : boolean
│   └── lastVerifiedAt      : Timestamp
│
├── (NEW V3) winbackOfferAvailable : boolean   — Ex-subscriber winback flag
└── (NEW V3) winbackOfferExpiry    : Timestamp|null
```

---

## Design Decisions

### 1. Offer ID Format
**เลือก: Predictable key ใน user doc (ไม่ใช้ random UUID)**

เหตุผล: Offer มีจำนวนน้อย (< 10 ประเภท) ทำให้ store เป็น field ใน user doc ได้เลย  
ไม่ต้อง query sub-collection → เร็วกว่า, ถูกกว่า  
ถ้าอนาคตต้องการ dynamic offers → เปลี่ยนเป็น sub-collection ได้

### 2. Expiry Storage
**เลือก: เก็บเป็น Timestamp (ไม่ใช้ duration)**

เหตุผล: Firestore รองรับ range query บน Timestamp ได้โดยตรง  
→ scheduled job หา users ที่ offer ใกล้หมดได้ง่าย  
→ `.where('offers.firstPurchaseExpiry', '<=', oneHourFromNow)`

### 3. Notification Tracking
**เลือก: เก็บใน user doc (ไม่ใช้ separate collection)**

เหตุผล: Offer ประเภทน้อย → field จำนวนน้อย → ไม่กินพื้นที่มาก  
ถ้า user มี offer > 20 ประเภท → ย้ายไป sub-collection

### 4. totalSpent vs totalPurchased
- `totalSpent` (milestones.totalSpent) = Energy ที่ **ใช้** ไป (deducted ใน analyzeFood)  
- `totalPurchased` = Energy ที่ **ซื้อ** มา (เพิ่มใน verifyPurchase)  
ทั้งสองไม่ใช่ตัวเดียวกัน

---

## Collection: `purchase_records/{purchaseHash}`

```
purchase_records/{sha256(purchaseToken)}
├── deviceId            : string
├── productId           : string
├── energyAmount        : number    — รวม bonus แล้ว
├── baseEnergy          : number
├── bonusEnergy         : number
├── bonusRate           : number
├── purchaseTokenPreview: string    — 20 chars แรก (security)
├── orderId             : string
├── purchaseTimeMillis  : string
├── verifiedAt          : Timestamp
└── status              : 'verified'
```

---

## Collection: `transactions/{auto-id}`

```
transactions/{auto-id}
├── deviceId        : string
├── miroId          : string
├── type            : string    — ดูรายการด้านล่าง
├── amount          : number    — บวก = ได้รับ, ลบ = ใช้
├── balanceAfter    : number
├── description     : string
├── metadata        : map       — ข้อมูลเพิ่มเติมตาม type
└── createdAt       : Timestamp
```

### Transaction Types (V3 เพิ่มมา)

| type | ความหมาย |
|------|----------|
| `purchase` | ซื้อ Energy package |
| `daily_checkin` | Daily check-in reward |
| `milestone_cashback` | Milestone reward (V3 — 10 ขั้น) |
| `ad_reward` | ดู Rewarded Ad (amount = 0, แต่ log ไว้) |
| `referral_reward` | Referral two-way reward |
| `daily_claim` | Manual daily claim (V3) |
| `tier_upgrade_reward` | Tier upgrade bonus energy |
| `welcome_offer_bonus` | (V2 — deprecated) |

---

## Migration Plan

### Existing Users → V3 Fields

เนื่องจาก Firestore เป็น schemaless การเพิ่ม field ใหม่จะ **ไม่กระทบ existing users**  
Function ทุกตัวใช้ `|| default` เมื่ออ่าน field ที่ไม่มี

#### Field Defaults ที่ต้อง handle ใน code:

```typescript
// ตัวอย่างใน milestoneV2.ts
const milestones = user.milestones || {
  totalSpent: user.totalSpent || 0,  // migrate จาก root field เก่า (ถ้ามี)
  claimedMilestones: [],
  nextMilestoneIndex: 0,
};

// ตัวอย่างใน offersV2.ts
const offers = user.offers || {
  firstPurchaseClaimed: false,
  firstPurchaseAvailable: false,
  firstPurchaseExpiry: null,
  welcomeBonusClaimed: false,
  welcomeBonusAvailable: false,
  welcomeBonusExpiry: null,
};

// ตัวอย่างใน adViews
const adViews = user.adViews || { date: '', count: 0 };

// ตัวอย่างใน dailyClaim
const lastClaimDate = user.dailyClaim?.lastClaimDate || user.lastCheckInDate || '';
```

#### Milestone Migration Strategy:
- ผู้ใช้เก่าที่มี `totalSpent` อยู่แล้ว → `milestones.totalSpent = totalSpent`  
- คำนวณ `claimedMilestones` และ `nextMilestoneIndex` จาก `totalSpent` ด้วย `computeMilestoneState()`  
- **ไม่ให้** retroactive rewards (milestone ที่ผ่านมาแล้วก่อน V3 = claimed โดยอัตโนมัติ)

#### Daily Claim Migration:
- `lastCheckInDate` (เดิม) → ยังอ่านได้ใน `dailyClaim.lastClaimDate` fallback  
- Function ใหม่จะเขียนลงทั้ง `lastCheckInDate` (backward compat) และ `dailyClaim.lastClaimDate`

---

## Firestore Indexes ที่ต้องสร้าง

สร้างใน `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "offers.firstPurchaseAvailable", "order": "ASCENDING" },
        { "fieldPath": "offers.firstPurchaseExpiry", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "subscription.status", "order": "ASCENDING" },
        { "fieldPath": "subscription.expiryDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "dailyClaim.lastClaimDate", "order": "ASCENDING" },
        { "fieldPath": "currentStreak", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "deviceId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```
