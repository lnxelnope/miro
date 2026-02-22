# Backend Spec — Dynamic Offer Engine

> **สำหรับ:** Junior Developer  
> **Stack:** Firebase Functions (TypeScript)  
> **อ้างอิง:** `_project_manager/dynamic_offers/01_FIRESTORE_SCHEMA.md`

---

## #1 — สร้าง Offer Engine (ไฟล์ใหม่)

**ไฟล์ใหม่:** `functions/src/energy/offerEngine.ts`

### หน้าที่
เป็น central function ที่ทุก trigger event เรียก — ตรวจสอบว่า user ตรงเงื่อนไขของ offer template ไหนบ้าง แล้ว activate offer ให้

### Function Signature

```typescript
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Evaluate ว่า user ควรได้ offer ไหนบ้างเมื่อเกิด event
 * 
 * @param deviceId - user device ID
 * @param event - trigger event name (เช่น 'first_energy_use')
 * @param eventData - ข้อมูลเพิ่มเติมจาก event
 * 
 * เรียกจาก: analyzeFood, dailyCheckIn, registerUser, verifyPurchase
 */
export async function evaluateOffers(
  deviceId: string,
  event: string,
  eventData: Record<string, any> = {}
): Promise<void> {
  // Implementation ด้านล่าง
}
```

### Logic (step-by-step)

```
evaluateOffers(deviceId, event, eventData):

1. Query offer_templates:
   - WHERE triggerEvent == event
   - WHERE isActive == true
   - ถ้าไม่มี template ตรง → return (ไม่ต้องทำอะไร)

2. Load user document:
   - const userDoc = await db.collection("users").doc(deviceId).get()
   - const user = userDoc.data()
   - const activeOffers = user.offers?.active || {}
   - const dismissedOffers = user.offers?.dismissed || []

3. สำหรับแต่ละ template:
   a. Check: template.id อยู่ใน activeOffers แล้วหรือยัง?
      - ถ้ามี → ข้ามไป (user ได้ offer นี้แล้ว)
   
   b. Check: template.id อยู่ใน dismissedOffers?
      - ถ้ามี → ข้ามไป
   
   c. Check: triggerCondition ตรงกับ eventData?
      - ถ้า triggerCondition.minTotalSpent มีค่า:
        → eventData.totalSpent >= triggerCondition.minTotalSpent?
      - ถ้า triggerCondition.tier มีค่า:
        → eventData.newTier == triggerCondition.tier?
      - ถ้า triggerCondition.minMealsLogged มีค่า:
        → eventData.totalMealsLogged >= triggerCondition.minMealsLogged?
      - ถ้า triggerCondition.afterProductId มีค่า:
        → eventData.productId == triggerCondition.afterProductId?
      - ถ้าไม่ตรง → ข้ามไป
   
   d. Check: maxClaimsPerUser
      - ถ้า activeOffers[template.id] มี claimCount >= maxClaimsPerUser → ข้ามไป
   
   e. ผ่านทุกเงื่อนไข → Activate offer:
      - คำนวณ expiresAt:
        → ถ้า template.expiresAfterHours != null:
            expiresAt = now + expiresAfterHours hours
        → ถ้า null: expiresAt = null
      
      - เขียน Firestore:
        await userDoc.ref.update({
          [`offers.active.${template.id}`]: {
            templateId: template.id,
            slug: template.slug,
            activatedAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: expiresAt,
            claimed: false,
            claimedAt: null,
            claimCount: 0,
          }
        })
      
      - Log:
        console.log(`🎁 [OfferEngine] Activated "${template.slug}" for ${deviceId}`)

4. จบ — ไม่ return ค่าอะไร (fire-and-forget)
```

### Edge Cases

| กรณี | จัดการยังไง |
|------|-----------|
| User ยังไม่มี `offers` field | ใช้ `|| {}` default |
| Template ถูก disable ระหว่าง user ยังมี offer active | ไม่กระทบ — user ที่ activate แล้วยังเห็นจนหมดอายุ |
| 2 templates มี triggerEvent เดียวกัน | ทั้งสองอาจ activate ได้ (ถ้าผ่านเงื่อนไขทั้งคู่) |
| evaluateOffers error | ต้อง try-catch ใน caller — ห้าม crash main flow |

### Export

เพิ่มใน `functions/src/index.ts`:
```typescript
// ไม่ต้อง export เป็น Cloud Function — เป็น internal function เท่านั้น
// ถูกเรียกจาก analyzeFood, dailyCheckIn, registerUser, verifyPurchase
```

---

## #2 — เพิ่ม totalMealsLogged Counter

**ไฟล์:** `functions/src/analyzeFood.ts`

### ตำแหน่งที่แก้

หา block `deductServerBalance` (ประมาณบรรทัด 296) ที่มี updateData:

```typescript
// ───── ก่อน (เดิม) ─────
const updateData: any = {
  balance: updated,
  totalSpent: prevTotalSpent + amount,
  "milestones.totalSpent": prevMilestoneTotalSpent + amount,
  lastAiUsageDate: today,
  // ... challenges ...
};

// ───── หลัง (เพิ่ม) ─────
const prevTotalMealsLogged = doc.data()?.totalMealsLogged || 0;

const updateData: any = {
  balance: updated,
  totalSpent: prevTotalSpent + amount,
  "milestones.totalSpent": prevMilestoneTotalSpent + amount,
  totalMealsLogged: prevTotalMealsLogged + 1,    // ⬅️ เพิ่มบรรทัดนี้
  lastAiUsageDate: today,
  // ... challenges ...
};
```

> **สำคัญ:** ต้องอยู่ใน transaction เดียวกับ balance deduction (atomic)

### สำหรับ Subscriber (ไม่หัก energy)

หาส่วนที่ subscriber ใช้ AI ฟรี (ประมาณบรรทัด 1088-1120) แล้วเพิ่ม increment ด้วย:

```typescript
// ใน subscriber section — หลังจาก log transaction
await userRef.update({
  totalMealsLogged: admin.firestore.FieldValue.increment(1),
  // ... existing updates ...
});
```

---

## #3 — Integrate evaluateOffers ใน analyzeFood.ts

**ไฟล์:** `functions/src/analyzeFood.ts`

### Import

```typescript
import { evaluateOffers } from "./energy/offerEngine";
```

### ตำแหน่ง: หลัง deduct balance สำเร็จ

หาจุดที่ `deductServerBalance` สำเร็จแล้ว (หลัง milestone check) เพิ่ม:

```typescript
// ───── หลัง milestone check (ก่อน res.status(200).json()) ─────

// Evaluate offers based on events
const newTotalSpent = prevTotalSpent + amount;
const newTotalMealsLogged = prevTotalMealsLogged + 1;

try {
  // Event: first_energy_use (totalSpent เปลี่ยนจาก 0 → 1+)
  if (prevTotalSpent === 0 && newTotalSpent > 0) {
    await evaluateOffers(deviceId, "first_energy_use", { totalSpent: newTotalSpent });
  }

  // Event: energy_use_milestone (ตรวจทุกครั้ง — engine จะ filter เอง)
  await evaluateOffers(deviceId, "energy_use_milestone", { totalSpent: newTotalSpent });

  // Event: meals_logged_milestone
  await evaluateOffers(deviceId, "meals_logged_milestone", { totalMealsLogged: newTotalMealsLogged });
} catch (e) {
  // Silent fail — ห้าม crash analyzeFood
  console.error("[analyzeFood] evaluateOffers error:", e);
}
```

### สำคัญ

- ต้อง try-catch — ถ้า evaluateOffers error ห้ามทำให้ analyzeFood fail
- prevTotalSpent อ่านจาก transaction ได้เลย (มีอยู่แล้ว)
- ทำ **หลัง** milestone check แต่ **ก่อน** res.status(200)

---

## #4 — Integrate evaluateOffers ใน dailyCheckIn.ts

**ไฟล์:** `functions/src/energy/dailyCheckIn.ts`

### Import

```typescript
import { evaluateOffers } from "./offerEngine";
```

### ตำแหน่ง: หลัง tier upgrade detected

หาจุดที่ `tierUpgraded = true` (ใน processCheckIn function) เพิ่ม:

```typescript
// ───── หลัง tier upgrade logic + tier reward ─────

if (tierUpgraded && newTier) {
  // Existing: sendTierUpNotification, activateTierUpgradePromotion
  // ...existing code...

  // NEW: Evaluate offers for tier_up event
  try {
    await evaluateOffers(deviceId, "tier_up", {
      newTier: newTier,
      previousTier: previousTier,
    });
  } catch (e) {
    console.error("[dailyCheckIn] evaluateOffers error:", e);
  }
}
```

---

## #5 — Integrate evaluateOffers ใน registerUser.ts

**ไฟล์:** `functions/src/registerUser.ts`

### Import

```typescript
import { evaluateOffers } from "./energy/offerEngine";
```

### ตำแหน่ง: หลังสร้าง user ใหม่สำเร็จ

หาจุดหลัง `db.collection("users").doc(deviceId).set({...})` (ประมาณบรรทัด 206) เพิ่ม:

```typescript
// ───── หลัง set user document + log transaction ─────

// Evaluate offers for new user
try {
  await evaluateOffers(deviceId, "first_app_open", {});
} catch (e) {
  console.error("[registerUser] evaluateOffers error:", e);
}
```

> **สำคัญ:** เฉพาะ user ใหม่เท่านั้น — ไม่เรียกตอน existing user login

---

## #6 — Integrate evaluateOffers ใน verifyPurchase.ts

**ไฟล์:** `functions/src/verifyPurchase.ts`

### Import

```typescript
import { evaluateOffers } from "./energy/offerEngine";
```

### ตำแหน่ง: หลัง purchase สำเร็จ + mark as claimed

หาจุดที่ purchase verified + energy added สำเร็จ (หลัง `offers[claimField] = true`) เพิ่ม:

```typescript
// ───── หลัง purchase verified + energy added ─────

// Evaluate offers triggered by this purchase
try {
  await evaluateOffers(deviceId, "first_purchase_complete", {
    productId: productId,
  });
} catch (e) {
  console.error("[verifyPurchase] evaluateOffers error:", e);
}
```

### เปลี่ยน One-Time Validation

ปัจจุบัน `ONE_TIME_PRODUCTS` map ใช้ hardcoded field (`offers.firstPurchaseClaimed`). ต้องเปลี่ยนให้ตรวจจาก `offers.active[templateId].claimed`:

```typescript
// ───── ก่อน (hardcoded) ─────
const ONE_TIME_PRODUCTS = {
  "energy_first_purchase_200": {
    claimField: "firstPurchaseClaimed",
    errorMessage: "Starter Deal already claimed",
  },
};

// ───── หลัง (template-based) ─────
// ตรวจจาก offers.active map แทน
// หา template ที่มี rewardConfig.productId == productId
// แล้วเช็ค offers.active[templateId].claimed == true

async function isOfferProductClaimed(
  deviceId: string, 
  productId: string
): Promise<boolean> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  const activeOffers = userDoc.data()?.offers?.active || {};
  
  // หา offer ที่ผูกกับ productId นี้
  for (const [templateId, offerState] of Object.entries(activeOffers)) {
    const state = offerState as any;
    if (state.claimed) {
      // Load template เพื่อเช็ค productId
      const templateDoc = await db.collection("offer_templates").doc(templateId).get();
      const template = templateDoc.data();
      if (template?.rewardConfig?.productId === productId) {
        return true; // offer นี้ claimed แล้ว
      }
    }
  }
  return false;
}
```

### Mark Offer as Claimed หลัง Purchase

```typescript
// หลัง purchase verified → mark offer as claimed
async function markOfferClaimed(
  deviceId: string, 
  productId: string
): Promise<void> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  const activeOffers = userDoc.data()?.offers?.active || {};
  
  for (const [templateId, offerState] of Object.entries(activeOffers)) {
    const state = offerState as any;
    if (!state.claimed) {
      const templateDoc = await db.collection("offer_templates").doc(templateId).get();
      const template = templateDoc.data();
      if (template?.rewardConfig?.productId === productId) {
        await userDoc.ref.update({
          [`offers.active.${templateId}.claimed`]: true,
          [`offers.active.${templateId}.claimedAt`]: admin.firestore.FieldValue.serverTimestamp(),
          [`offers.active.${templateId}.claimCount`]: (state.claimCount || 0) + 1,
        });
        console.log(`✅ [verifyPurchase] Marked offer "${state.slug}" as claimed`);
        break;
      }
    }
  }
}
```

---

## #7 — Rewrite getActiveOffers (offersV2.ts)

**ไฟล์:** `functions/src/energy/offersV2.ts`

### เปลี่ยนทั้ง function `getActiveOffers()`

```
getActiveOffers(deviceId):

1. Load user document
   - const user = userDoc.data()
   - const activeOffers = user.offers?.active || {}
   - const dismissed = user.offers?.dismissed || []

2. สำหรับแต่ละ entry ใน activeOffers:
   a. ข้าม ถ้า dismissed.includes(templateId)
   b. ข้าม ถ้า claimed == true
   c. ข้าม ถ้า expiresAt != null && expiresAt < now (หมดอายุ)
   d. Load template จาก offer_templates collection
   e. ข้าม ถ้า template ไม่มี (ถูกลบ)
   
   f. สร้าง OfferData object:
      {
        id: templateId,
        type: template.slug,    // ใช้ slug แทน type เดิม
        priority: template.priority,
        title: template.title[userLocale] || template.title.en,
        description: template.description[userLocale] || template.description.en,
        ctaText: template.ctaText[userLocale] || template.ctaText.en,
        expiry: offer.expiresAt,
        remainingSeconds: เวลาที่เหลือ (คำนวณจาก expiresAt - now),
        metadata: template.rewardConfig,
        rewardType: template.rewardType,   // ⬅️ เพิ่ม field ใหม่
      }

3. เรียงตาม priority (น้อยก่อน = สำคัญกว่า)

4. Return OfferData[]
```

### API Response (เพิ่ม field)

```typescript
// Response shape — เพิ่ม rewardType
interface OfferData {
  id: string;            // templateId
  type: string;          // template.slug (เช่น 'starter_deal', 'bonus_40')
  priority: number;
  title: string;         // localized title
  description: string;   // localized description
  ctaText: string;       // localized CTA
  expiry: Timestamp | null;
  remainingSeconds: number | null;
  metadata: Record<string, any>;  // rewardConfig
  rewardType: string;    // ⬅️ NEW: 'special_product' | 'bonus_rate' | 'free_energy' | 'subscription_deal'
}
```

> **สำคัญ:** Flutter ที่อ่าน API นี้อยู่แล้ว (Quest Bar + Energy Store) จะยังทำงานได้ เพราะ field เดิมยังอยู่ครบ + เพิ่ม `rewardType` เข้ามาใหม่

### dismissOffer — ไม่เปลี่ยนมาก

```typescript
// เปลี่ยนจาก hardcoded validOfferIds → accept any templateId
export async function dismissOffer(deviceId: string, offerId: string): Promise<void> {
  // validate: offerId ต้องอยู่ใน user's active offers
  const userDoc = await db.collection("users").doc(deviceId).get();
  const activeOffers = userDoc.data()?.offers?.active || {};
  
  if (!activeOffers[offerId]) {
    throw new Error(`Offer not found: ${offerId}`);
  }

  await userDoc.ref.update({
    "offers.dismissed": admin.firestore.FieldValue.arrayUnion(offerId),
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

### เพิ่ม: claimFreeEnergy endpoint

สำหรับ `rewardType == 'free_energy'` ที่ไม่ต้องซื้อผ่าน IAP:

```typescript
export async function claimFreeEnergyOffer(
  deviceId: string, 
  templateId: string
): Promise<{ success: boolean; energyAdded: number; newBalance: number }> {
  // 1. Load user + offer state
  // 2. Validate: offer exists, not claimed, not expired
  // 3. Load template: check rewardType == 'free_energy'
  // 4. Add energy: balance += rewardConfig.amount
  // 5. Mark claimed: offers.active[templateId].claimed = true
  // 6. Log transaction (type: 'offer_free_energy')
  // 7. Return new balance
}
```

**Export endpoint ใน index.ts:**
```typescript
export { claimFreeEnergyEndpoint } from "./energy/offersV2";
```

---

## #8 — Cleanup: ลบ Welcome Offer Products จาก Backend

**ไฟล์:** `functions/src/verifyPurchase.ts`

เมื่อ migration เสร็จแล้ว ลบ welcome offer products ออก:

```typescript
// ─── ลบออก ───
// "energy_100_welcome": 100,
// "energy_550_welcome": 550,
// "energy_1200_welcome": 1200,
// "energy_2000_welcome": 2000,

// ─── ลบออกจาก ONE_TIME_PRODUCTS ───
// "energy_100_welcome": { claimField: "welcomeBonusClaimed", ... },
// "energy_550_welcome": { ... },
// "energy_1200_welcome": { ... },
// "energy_2000_welcome": { ... },
```

> **สำคัญ:** ทำหลัง migration เสร็จ + confirm ว่าไม่มี pending purchases ค้างอยู่

---

## Testing Checklist

| # | ทดสอบ | Expected |
|---|-------|----------|
| 1 | สร้าง offer_template slug=`test_first_use`, triggerEvent=`first_energy_use`, rewardType=`free_energy`, amount=10 | Template สร้างสำเร็จ |
| 2 | User ใหม่ใช้ AI ครั้งแรก | offer `test_first_use` ปรากฏใน user.offers.active |
| 3 | เรียก getActiveOffers | ได้ offer `test_first_use` กลับมา |
| 4 | Claim free energy | balance เพิ่ม 10, offer.claimed = true |
| 5 | เรียก getActiveOffers อีกครั้ง | ไม่เห็น `test_first_use` แล้ว (claimed) |
| 6 | สร้าง template triggerEvent=`tier_up`, triggerCondition.tier=`bronze` | Template สร้างสำเร็จ |
| 7 | User เลื่อนเป็น Bronze | offer ปรากฏ |
| 8 | User เลื่อนเป็น Silver | offer ไม่ปรากฏ (condition tier=bronze ไม่ตรง) |
| 9 | ปิด template (isActive=false) | User ใหม่ไม่ได้ offer แล้ว |
| 10 | User เดิมที่ activate แล้ว ยังเห็น offer | ถูกต้อง (isActive ไม่กระทบ user ที่ได้แล้ว) |
