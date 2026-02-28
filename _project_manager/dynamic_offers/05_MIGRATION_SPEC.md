# Migration Spec — Hardcoded → Dynamic Offers

> **สำหรับ:** Junior Developer  
> **อ้างอิง:** `_project_manager/dynamic_offers/01_FIRESTORE_SCHEMA.md`

---

## #1 — Seed Script: สร้าง offer_templates จาก Hardcoded

**ไฟล์ใหม่:** `functions/src/scripts/seedOfferTemplates.ts`

### วิธีรัน

```bash
cd functions
npx ts-node src/scripts/seedOfferTemplates.ts
```

> **สำคัญ:** รัน 1 ครั้งเท่านั้น — script ต้องเช็คว่า slug ซ้ำไหมก่อนสร้าง

### Seed Data

สร้าง offer_templates 5 ตัวดังนี้:

#### Template 1: Starter Deal ($1 = 200E)

```typescript
{
  slug: "starter_deal",
  triggerEvent: "energy_use_milestone",
  triggerCondition: { minTotalSpent: 10 },
  title: { en: "⚡ Starter Deal", th: "⚡ ดีลสตาร์ทเตอร์" },
  description: {
    en: "Get 200 Energy for just $1! Limited time offer.",
    th: "รับ 200 Energy แค่ $1! ข้อเสนอจำกัดเวลา",
  },
  ctaText: { en: "Buy $1", th: "ซื้อ $1" },
  icon: "⚡",
  rewardType: "special_product",
  rewardConfig: {
    productId: "energy_first_purchase_200",
    energyAmount: 200,
    displayPrice: "$1.00",
  },
  expiresAfterHours: 4,
  priority: 1,
  maxClaimsPerUser: 1,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

#### Template 2: 40% Bonus (หลังซื้อ $1 deal)

```typescript
{
  slug: "bonus_40_after_purchase",
  triggerEvent: "first_purchase_complete",
  triggerCondition: { afterProductId: "energy_first_purchase_200" },
  title: { en: "🎁 40% Bonus", th: "🎁 โบนัส 40%" },
  description: {
    en: "Buy any Energy package and get +40% bonus!",
    th: "ซื้อแพ็กเกจ Energy ใดก็ได้ รับโบนัสเพิ่ม 40%!",
  },
  ctaText: { en: "View Packages", th: "ดูแพ็กเกจ" },
  icon: "🎁",
  rewardType: "bonus_rate",
  rewardConfig: { bonusRate: 0.4 },
  expiresAfterHours: 24,
  priority: 2,
  maxClaimsPerUser: 1,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

#### Template 3: Tier Up Bonus

```typescript
{
  slug: "tier_up_bonus",
  triggerEvent: "tier_up",
  triggerCondition: {},              // ทุก tier
  title: { en: "🌟 Tier Up Bonus!", th: "🌟 โบนัสเลื่อน Tier!" },
  description: {
    en: "Congratulations on your tier up! +20% bonus on your next purchase.",
    th: "ยินดีด้วยที่เลื่อน Tier! รับโบนัส 20% สำหรับการซื้อครั้งถัดไป",
  },
  ctaText: { en: "Buy Now", th: "ซื้อเลย" },
  icon: "🌟",
  rewardType: "bonus_rate",
  rewardConfig: { bonusRate: 0.2 },
  expiresAfterHours: 48,
  priority: 3,
  maxClaimsPerUser: 1,              // 1 ต่อ tier? หรือ 4 (ทุก tier)?
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

> **คำถามสำหรับ Senior:** maxClaimsPerUser ของ tier_up_bonus ควรเป็น 1 (ได้ครั้งเดียวตลอดชีวิต) หรือ 4 (ได้ทุกครั้งที่เลื่อน tier ใหม่)? ถ้า 4 → ต้องเพิ่ม logic ใน offerEngine ให้เช็ค `claimCount < maxClaimsPerUser` แทน `activeOffers[templateId] exists`

#### Template 4: Welcome Gift (เปิด App ครั้งแรก)

```typescript
{
  slug: "welcome_gift",
  triggerEvent: "first_app_open",
  triggerCondition: {},
  title: { en: "🎉 Welcome to MiRO!", th: "🎉 ยินดีต้อนรับสู่ MiRO!" },
  description: {
    en: "Start your health journey! Here's 5 free Energy.",
    th: "เริ่มต้นเส้นทางสุขภาพ! รับ 5 Energy ฟรี",
  },
  ctaText: { en: "Claim!", th: "รับเลย!" },
  icon: "🎉",
  rewardType: "free_energy",
  rewardConfig: { amount: 5 },
  expiresAfterHours: null,          // ไม่หมดอายุ
  priority: 1,
  maxClaimsPerUser: 1,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

#### Template 5: 100 Meals Milestone

```typescript
{
  slug: "meals_100_reward",
  triggerEvent: "meals_logged_milestone",
  triggerCondition: { minMealsLogged: 100 },
  title: { en: "💝 100 Meals Logged!", th: "💝 Log อาหารครบ 100 ครั้ง!" },
  description: {
    en: "Amazing dedication! Here's 25 free Energy as a reward.",
    th: "ยอดเยี่ยม! รับ 25 Energy ฟรีเป็นรางวัล",
  },
  ctaText: { en: "Claim Reward", th: "รับรางวัล" },
  icon: "💝",
  rewardType: "free_energy",
  rewardConfig: { amount: 25 },
  expiresAfterHours: 168,           // 7 days
  priority: 2,
  maxClaimsPerUser: 1,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

### Script Logic

```typescript
import * as admin from "firebase-admin";

// ─── Initialize with service account ───
const serviceAccount = require("../../serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const TEMPLATES = [
  // ... 5 templates ด้านบน
];

async function seed() {
  for (const template of TEMPLATES) {
    // Check ว่า slug ซ้ำไหม
    const existing = await db.collection("offer_templates")
      .where("slug", "==", template.slug)
      .get();
    
    if (!existing.empty) {
      console.log(`⏭️ Skipped "${template.slug}" (already exists)`);
      continue;
    }
    
    const ref = await db.collection("offer_templates").add(template);
    console.log(`✅ Created "${template.slug}" → ${ref.id}`);
  }
  
  console.log("Done!");
  process.exit(0);
}

seed().catch((e) => {
  console.error("Seed failed:", e);
  process.exit(1);
});
```

---

## #2 — Migrate User Offer Data

### Mapping เก่า → ใหม่

| Field เก่า (V3) | Field ใหม่ (Dynamic) | Logic |
|---|---|---|
| `offers.firstPurchaseClaimed: true` | `offers.active[starter_deal_templateId].claimed: true` | Copy ถ้า firstPurchaseClaimed == true |
| `offers.firstPurchaseAvailable: true` | `offers.active[starter_deal_templateId]` exists | สร้าง entry ถ้า available && !claimed |
| `offers.firstPurchaseExpiry` | `offers.active[...].expiresAt` | Copy timestamp |
| `offers.welcomeBonusClaimed: true` | `offers.active[bonus_40_templateId].claimed: true` | Copy ถ้า claimed == true |
| `offers.welcomeBonusAvailable: true` | `offers.active[bonus_40_templateId]` exists | สร้าง entry ถ้า available && !claimed |
| `offers.dismissed` | `offers.dismissed` | ไม่ต้องเปลี่ยน format (แต่ต้อง map offerId เก่า → templateId ใหม่) |

### Migration Script

**ไฟล์ใหม่:** `functions/src/scripts/migrateUserOffers.ts`

```typescript
async function migrateUserOffers() {
  // 1. Load template IDs by slug
  const templates = await db.collection("offer_templates").get();
  const slugToId: Record<string, string> = {};
  templates.forEach(doc => {
    slugToId[doc.data().slug] = doc.id;
  });

  // 2. Scan all users
  const users = await db.collection("users").get();
  let migrated = 0;
  let skipped = 0;

  for (const userDoc of users.docs) {
    const user = userDoc.data();
    const oldOffers = user.offers || {};
    
    // ข้ามถ้าไม่มี offers เก่า
    if (!oldOffers.firstPurchaseAvailable && !oldOffers.welcomeBonusAvailable) {
      skipped++;
      continue;
    }

    const newActive: Record<string, any> = {};

    // Migrate starter_deal
    const starterDealId = slugToId["starter_deal"];
    if (starterDealId && oldOffers.firstPurchaseAvailable) {
      newActive[starterDealId] = {
        templateId: starterDealId,
        slug: "starter_deal",
        activatedAt: oldOffers.firstPurchaseClaimedAt || admin.firestore.Timestamp.now(),
        expiresAt: oldOffers.firstPurchaseExpiry || null,
        claimed: oldOffers.firstPurchaseClaimed || false,
        claimedAt: oldOffers.firstPurchaseClaimedAt || null,
        claimCount: oldOffers.firstPurchaseClaimed ? 1 : 0,
      };
    }

    // Migrate bonus_40
    const bonus40Id = slugToId["bonus_40_after_purchase"];
    if (bonus40Id && oldOffers.welcomeBonusAvailable) {
      newActive[bonus40Id] = {
        templateId: bonus40Id,
        slug: "bonus_40_after_purchase",
        activatedAt: oldOffers.welcomeBonusClaimedAt || admin.firestore.Timestamp.now(),
        expiresAt: oldOffers.welcomeBonusExpiry || null,
        claimed: oldOffers.welcomeBonusClaimed || false,
        claimedAt: oldOffers.welcomeBonusClaimedAt || null,
        claimCount: oldOffers.welcomeBonusClaimed ? 1 : 0,
      };
    }

    // Write new format (keep old fields for backward compat)
    await userDoc.ref.update({
      "offers.active": newActive,
    });

    migrated++;
    if (migrated % 100 === 0) {
      console.log(`Migrated ${migrated} users...`);
    }
  }

  console.log(`Done! Migrated: ${migrated}, Skipped: ${skipped}`);
}
```

### รันเมื่อไหร่

1. **หลัง** seed script เสร็จ (ต้องมี templates ก่อนเพื่อได้ templateId)
2. **หลัง** deploy backend ใหม่ที่อ่าน `offers.active` ได้
3. **ก่อน** ลบ code เก่า

### Rollback Plan

- Fields เก่า (`firstPurchaseClaimed`, etc.) ไม่ถูกลบ
- ถ้ามีปัญหา → rollback code ให้อ่าน field เก่าได้ทันที
- ลบ field เก่าทีหลังเมื่อมั่นใจว่า stable (Phase 3)

---

## #3 — Cleanup: ลบ Hardcoded Logic เก่า

### ทำหลังจากทุกอย่าง stable (สัปดาห์ที่ 4+)

#### Backend Files

| ไฟล์ | ลบอะไร |
|------|--------|
| `functions/src/energy/offersV2.ts` | ลบ hardcoded offer definitions (OFFER_TYPES, etc.) |
| `functions/src/energy/promotions.ts` | ลบ `activateTierUpgradePromotion()` ถ้าถูกแทนที่ด้วย offerEngine |
| `functions/src/verifyPurchase.ts` | ลบ `energy_*_welcome` product IDs + ONE_TIME_PRODUCTS entries |
| `functions/src/energy/dailyCheckIn.ts` | ลบ import `activateTierUpgradePromotion` ถ้าไม่ใช้แล้ว |

#### Flutter Files

| ไฟล์ | ลบอะไร |
|------|--------|
| `lib/core/services/purchase_service.dart` | ลบ `energy_*_welcome` product constants |
| `lib/features/energy/presentation/energy_store_screen.dart` | ลบ `_inferRewardType()` helper (เมื่อ backend return rewardType แล้ว) |

#### Firestore Fields (User Document)

| Field เก่า | ลบเมื่อไหร่ |
|---|---|
| `offers.firstPurchaseAvailable` | หลัง migration + stable 2 สัปดาห์ |
| `offers.firstPurchaseClaimed` | หลัง migration + stable 2 สัปดาห์ |
| `offers.firstPurchaseExpiry` | หลัง migration + stable 2 สัปดาห์ |
| `offers.firstPurchaseClaimedAt` | หลัง migration + stable 2 สัปดาห์ |
| `offers.welcomeBonusAvailable` | หลัง migration + stable 2 สัปดาห์ |
| `offers.welcomeBonusClaimed` | หลัง migration + stable 2 สัปดาห์ |
| `offers.welcomeBonusExpiry` | หลัง migration + stable 2 สัปดาห์ |
| `offers.welcomeBonusClaimedAt` | หลัง migration + stable 2 สัปดาห์ |

> **สำคัญ:** Firestore เป็น schemaless → field เก่าไม่กินพื้นที่มาก ไม่ต้องรีบลบ

---

## Deployment Order

```
Step 1: รัน seed script (สร้าง offer_templates)
  └── ไม่กระทบ production — collection ใหม่ยังไม่มีใครอ่าน

Step 2: Deploy backend ใหม่ (offerEngine + rewritten offersV2)
  └── backward compat: ยังอ่าน field เก่าได้ + เริ่มเขียน format ใหม่
  └── user ใหม่จะได้ offers ใน format ใหม่
  └── user เก่าจะยังเห็น offers จาก field เก่า (fallback)

Step 3: รัน migration script (migrate user offers)
  └── user เก่าจะถูกย้ายเป็น format ใหม่
  └── field เก่ายังอยู่ (ไม่ลบ)

Step 4: Deploy Flutter app update
  └── รองรับ rewardType ใหม่ + notification deep-link

Step 5: Deploy Admin Panel update
  └── หน้า Offers CRUD ใช้งานได้

Step 6: Cleanup (2 สัปดาห์หลัง step 3)
  └── ลบ hardcoded logic + field เก่า
```

---

## Risk Assessment

| ความเสี่ยง | Impact | Mitigation |
|---|---|---|
| Migration script ล้มเหลว mid-way | สูง | Script idempotent — รันซ้ำได้ ไม่ duplicate |
| User เก่าเสีย offer ระหว่าง migration | สูง | Keep field เก่าไว้ + fallback logic |
| Offer template ถูกลบโดยไม่ตั้งใจ | กลาง | Admin confirm dialog + soft delete option |
| evaluateOffers slow (query templates ทุกครั้ง) | ต่ำ | Templates < 50 docs, cache ได้ในอนาคต |
| Push notification deep-link ไม่ทำงาน | ต่ำ | User ยังเข้า app ได้ปกติ แค่ไม่ไป offer ตรง |
