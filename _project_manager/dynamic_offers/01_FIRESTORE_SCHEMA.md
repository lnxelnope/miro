# Firestore Schema — Dynamic Offer System

> **สำหรับ:** Junior Developer  
> **อ้างอิง:** `_project_manager/dynamic_offers/00_README.md`

---

## Collection ใหม่: `offer_templates/{templateId}`

```typescript
offer_templates/{templateId}
├── id                   : string          — auto-generated document ID
├── slug                 : string          — unique key เช่น 'starter_deal', 'tier_up_bonus'
│                                            ใช้เป็น identifier ที่อ่านง่าย (ห้ามซ้ำ)
│
├── ─── Trigger ───
├── triggerEvent         : string          — enum ค่าที่รองรับ:
│                                            'first_energy_use'
│                                            'energy_use_milestone'
│                                            'tier_up'
│                                            'first_app_open'
│                                            'meals_logged_milestone'
│                                            'first_purchase_complete'
│
├── triggerCondition     : map             — เงื่อนไขเพิ่มเติม (optional)
│   ├── minTotalSpent?   : number          — สำหรับ energy_use_milestone (เช่น 10)
│   ├── tier?            : string          — สำหรับ tier_up (เช่น 'bronze')
│   │                                        ถ้าไม่ระบุ = ทุก tier
│   ├── minMealsLogged?  : number          — สำหรับ meals_logged_milestone (เช่น 100)
│   └── afterProductId?  : string          — สำหรับ first_purchase_complete
│                                            (เช่น 'energy_first_purchase_200')
│
├── ─── Content (i18n) ───
├── title                : map
│   ├── en               : string          — "⚡ Starter Deal"
│   └── th               : string          — "⚡ ดีลสตาร์ทเตอร์"
│
├── description          : map
│   ├── en               : string          — "200 Energy for just $1!"
│   └── th               : string          — "200 Energy แค่ $1!"
│
├── ctaText              : map
│   ├── en               : string          — "Buy Now"
│   └── th               : string          — "ซื้อเลย"
│
├── icon                 : string          — emoji: "⚡", "🎁", "🌟", "💝"
│
├── ─── Reward ───
├── rewardType           : string          — enum ค่าที่รองรับ:
│                                            'special_product'    — สินค้าพิเศษ (ผูก IAP product)
│                                            'bonus_rate'         — โบนัส % เพิ่มเมื่อซื้อ package
│                                            'free_energy'        — ได้ energy ฟรี (claim ได้เลย)
│                                            'subscription_deal'  — ส่วนลด subscription
│
├── rewardConfig         : map             — config ตาม rewardType:
│   │
│   │  ── ถ้า rewardType == 'special_product':
│   ├── productId        : string          — Google Play product ID (เช่น 'energy_first_purchase_200')
│   ├── energyAmount     : number          — Energy ที่ได้ (เช่น 200)
│   └── displayPrice     : string          — ราคาแสดง (เช่น '$1.00')
│   │
│   │  ── ถ้า rewardType == 'bonus_rate':
│   └── bonusRate        : number          — อัตราโบนัส (เช่น 0.4 = 40%)
│   │
│   │  ── ถ้า rewardType == 'free_energy':
│   └── amount           : number          — Energy ฟรี (เช่น 50)
│   │
│   │  ── ถ้า rewardType == 'subscription_deal':
│   ├── productId        : string          — 'miro_normal_subscription'
│   ├── basePlanId       : string          — 'energy-pass-monthly'
│   └── offerId          : string          — Google Play offer ID (เช่น 'winback-3usd')
│
├── ─── Duration & Limits ───
├── expiresAfterHours    : number | null   — หมดอายุหลังจาก activate กี่ชม.
│                                            null = ไม่มีวันหมด
│                                            4 = 4 ชั่วโมง (เช่น $1 deal)
│                                            24 = 24 ชั่วโมง (เช่น 40% bonus)
│
├── priority             : number          — ลำดับแสดง (ยิ่งน้อย = สำคัญกว่า)
│                                            1 = แสดงก่อนสุด
│
├── maxClaimsPerUser     : number          — จำนวนครั้งที่ซื้อ/claim ได้ต่อ user
│                                            1 = one-time (ส่วนใหญ่จะเป็น 1)
│
├── ─── Admin Control ───
├── isActive             : boolean         — Admin เปิด/ปิด offer ได้
│                                            false = ไม่ trigger ให้ user ใหม่
│                                            user ที่ activate แล้วยังเห็นอยู่จนหมดอายุ
│
├── createdAt            : Timestamp       — สร้างเมื่อ
└── updatedAt            : Timestamp       — แก้ไขล่าสุด
```

---

## User Document: `users/{deviceId}` — เปลี่ยน offers field

### ก่อน (V3 เดิม — hardcoded)
```typescript
{
  offers: {
    firstPurchaseAvailable: boolean,
    firstPurchaseClaimed: boolean,
    firstPurchaseExpiry: Timestamp | null,
    firstPurchaseClaimedAt: Timestamp | null,
    welcomeBonusAvailable: boolean,
    welcomeBonusClaimed: boolean,
    welcomeBonusExpiry: Timestamp | null,
    welcomeBonusClaimedAt: Timestamp | null,
    dismissed: string[],
  }
}
```

### หลัง (Dynamic — template-based)
```typescript
{
  offers: {
    active: {
      // key = templateId (document ID จาก offer_templates collection)
      [templateId: string]: {
        templateId: string,        // ซ้ำกับ key — เก็บไว้เพื่อความชัดเจน
        slug: string,              // slug จาก template ตอน activate
        activatedAt: Timestamp,    // เวลาที่ offer ถูก activate
        expiresAt: Timestamp | null, // เวลาหมดอายุ (null = ไม่หมด)
        claimed: boolean,          // ซื้อ/claim แล้วหรือยัง
        claimedAt: Timestamp | null, // เวลาที่ claim
        claimCount: number,        // จำนวนครั้งที่ claim (สำหรับ maxClaimsPerUser > 1)
      }
    },
    dismissed: string[],           // templateId[] ที่ user ปัดซ่อน (ถาวร)
  }
}
```

### ตัวอย่าง user doc หลังมี offer

```json
{
  "offers": {
    "active": {
      "abc123": {
        "templateId": "abc123",
        "slug": "starter_deal",
        "activatedAt": "2026-02-21T10:00:00Z",
        "expiresAt": "2026-02-21T14:00:00Z",
        "claimed": false,
        "claimedAt": null,
        "claimCount": 0
      },
      "def456": {
        "templateId": "def456",
        "slug": "first_open_welcome",
        "activatedAt": "2026-02-21T10:00:00Z",
        "expiresAt": null,
        "claimed": true,
        "claimedAt": "2026-02-21T10:05:00Z",
        "claimCount": 1
      }
    },
    "dismissed": ["ghi789"]
  }
}
```

---

## Field ใหม่ใน User Document

### `totalMealsLogged` (root level)

```typescript
{
  totalMealsLogged: number   // จำนวน meal ที่ log ทั้งหมด (increment ทุกครั้งที่ analyzeFood สำเร็จ)
                             // default: 0
}
```

> **สำคัญ:** field นี้ต้อง increment อยู่ใน transaction เดียวกับ balance deduction ใน `analyzeFood.ts` เพื่อความ atomic

---

## Firestore Indexes ที่ต้องเพิ่ม

เพิ่มใน `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "offer_templates",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "triggerEvent", "order": "ASCENDING" },
        { "fieldPath": "isActive", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "offer_templates",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "priority", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## Design Decisions

### 1. offer_templates เป็น top-level collection (ไม่ใช่ sub-collection)
- Admin Panel query ง่าย (`db.collection('offer_templates').get()`)
- ไม่ผูกกับ user คนใดคนหนึ่ง
- จำนวน template น้อย (< 50) → อ่านทั้งหมดได้เร็ว

### 2. User offers ใช้ map (ไม่ใช่ sub-collection)
- อ่าน user doc 1 ครั้ง = ได้ offers ทั้งหมด (ไม่ต้อง query เพิ่ม)
- จำนวน active offers ต่อ user น้อย (< 10)
- ถ้าอนาคตมี > 20 offers ต่อ user → ย้ายเป็น sub-collection

### 3. Slug field สำหรับ human-readable ID
- templateId เป็น auto-generated (ยาว, ไม่อ่านง่าย)
- slug เช่น `starter_deal`, `tier_up_bonus` ใช้ debug + display ง่ายกว่า
- Admin กำหนด slug ตอนสร้าง (ห้ามซ้ำ — validate ใน API)

### 4. i18n ใน template (ไม่ใช้ l10n file)
- Offer content เปลี่ยนบ่อย → admin แก้ได้เลยไม่ต้อง deploy app
- รองรับ en + th (เพิ่มภาษาได้โดยเพิ่ม key ใน map)
- Flutter อ่าน locale แล้วเลือก key ที่ตรง
