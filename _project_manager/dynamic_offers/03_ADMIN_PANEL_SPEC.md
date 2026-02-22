# Admin Panel Spec — Offer Templates CRUD

> **สำหรับ:** Junior Developer  
> **Stack:** Next.js 14 (App Router), Tailwind CSS, shadcn/ui  
> **อ้างอิง:** `_project_manager/dynamic_offers/01_FIRESTORE_SCHEMA.md`

---

## #1 — API Routes

### 1.1 List Offers

**ไฟล์ใหม่:** `admin-panel/src/app/api/offers/route.ts`

```
GET /api/offers

Response:
{
  "success": true,
  "offers": [
    {
      "id": "abc123",
      "slug": "starter_deal",
      "triggerEvent": "energy_use_milestone",
      "triggerCondition": { "minTotalSpent": 10 },
      "title": { "en": "⚡ Starter Deal", "th": "⚡ ดีลสตาร์ทเตอร์" },
      "description": { "en": "200 Energy for just $1!", "th": "200 Energy แค่ $1!" },
      "ctaText": { "en": "Buy Now", "th": "ซื้อเลย" },
      "icon": "⚡",
      "rewardType": "special_product",
      "rewardConfig": { "productId": "energy_first_purchase_200", "energyAmount": 200, "displayPrice": "$1.00" },
      "expiresAfterHours": 4,
      "priority": 1,
      "maxClaimsPerUser": 1,
      "isActive": true,
      "createdAt": "2026-02-21T10:00:00Z",
      "updatedAt": "2026-02-21T10:00:00Z"
    }
  ]
}
```

**Logic:**
```
1. const snapshot = await db.collection("offer_templates").orderBy("priority").get()
2. return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
```

### 1.2 Create Offer

**ไฟล์เดียวกัน:** `admin-panel/src/app/api/offers/route.ts`

```
POST /api/offers

Body:
{
  "slug": "starter_deal",
  "triggerEvent": "energy_use_milestone",
  "triggerCondition": { "minTotalSpent": 10 },
  "title": { "en": "⚡ Starter Deal", "th": "⚡ ดีลสตาร์ทเตอร์" },
  "description": { "en": "200 Energy for just $1!", "th": "200 Energy แค่ $1!" },
  "ctaText": { "en": "Buy Now", "th": "ซื้อเลย" },
  "icon": "⚡",
  "rewardType": "special_product",
  "rewardConfig": { "productId": "energy_first_purchase_200", "energyAmount": 200, "displayPrice": "$1.00" },
  "expiresAfterHours": 4,
  "priority": 1,
  "maxClaimsPerUser": 1,
  "isActive": true
}

Response:
{ "success": true, "id": "abc123" }
```

**Validation:**
```
1. slug ต้องไม่ว่าง, ต้องเป็น snake_case (a-z0-9_)
2. slug ต้องไม่ซ้ำ — query offer_templates WHERE slug == inputSlug
3. triggerEvent ต้องอยู่ใน list ที่กำหนด
4. title.en ต้องไม่ว่าง
5. rewardType ต้องอยู่ใน list ที่กำหนด
6. rewardConfig ต้องมี field ที่จำเป็นตาม rewardType
7. priority ต้อง > 0
8. maxClaimsPerUser ต้อง >= 1
```

### 1.3 Get/Update/Delete Single Offer

**ไฟล์ใหม่:** `admin-panel/src/app/api/offers/[id]/route.ts`

```
GET /api/offers/:id       → return offer document
PUT /api/offers/:id       → update offer fields
DELETE /api/offers/:id    → delete offer template
```

**PUT Validation:**
- เหมือน POST แต่ slug ต้องเช็คว่าไม่ซ้ำกับ doc อื่น (ยกเว้นตัวเอง)
- ถ้าเปลี่ยน triggerEvent → warn ว่า user ที่ activate แล้วจะไม่กระทบ

**DELETE:**
- ลบ template document
- user ที่ activate แล้วจะยังเห็น offer จนหมดอายุ (เพราะ getActiveOffers จะ skip ถ้า template ไม่มี)

### Firebase Admin Setup

ใช้ Firebase Admin SDK ที่มีอยู่แล้ว:

```typescript
// admin-panel/src/lib/firebase-admin.ts (มีอยู่แล้ว)
import { getFirestore } from 'firebase-admin/firestore';
const db = getFirestore();

// ใน API route:
const db = getFirestore();
const offersRef = db.collection('offer_templates');
```

---

## #2 — Offers List Page

**ไฟล์ใหม่:** `admin-panel/src/app/(dashboard)/offers/page.tsx`

### UI Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Offer Templates                          [+ Create Offer]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ #  Slug           Trigger          Reward    Active │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │ 1  starter_deal   energy_use_10    $1=200E   ✅ ON  │    │
│  │ 2  bonus_40       first_purchase   +40%      ✅ ON  │    │
│  │ 3  tier_up_bonus  tier_up          +20%      ✅ ON  │    │
│  │ 4  welcome_gift   first_app_open   10E free  ❌ OFF │    │
│  │ 5  meals_100      meals_100        25E free  ✅ ON  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Table Columns

| Column | แสดง | Source |
|--------|------|--------|
| # | priority | `template.priority` |
| Slug | slug (clickable → edit page) | `template.slug` |
| Trigger | triggerEvent + condition summary | `template.triggerEvent` + `triggerCondition` |
| Reward | reward summary | `template.rewardType` + `rewardConfig` |
| Duration | expiry hours หรือ "No expiry" | `template.expiresAfterHours` |
| Active | Toggle switch | `template.isActive` |
| Actions | Edit / Delete buttons | — |

### Active Toggle

กด toggle → เรียก `PUT /api/offers/:id` เปลี่ยน `isActive`

### Delete Confirmation

กด Delete → แสดง confirm dialog:
"ลบ offer template นี้? User ที่ได้ offer แล้วจะยังเห็นจนหมดอายุ"

---

## #3 — Create / Edit Form

**ไฟล์ใหม่:** `admin-panel/src/app/(dashboard)/offers/create/page.tsx`  
**ไฟล์ใหม่:** `admin-panel/src/app/(dashboard)/offers/[id]/edit/page.tsx`

> ทั้ง 2 หน้าใช้ form component เดียวกัน — แยกเป็น `OfferForm` component

### Form Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Create Offer Template                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ─── Basic Info ───                                         │
│  Slug:        [starter_deal          ]                      │
│  Icon:        [⚡] (emoji picker or text input)             │
│  Priority:    [1  ]                                         │
│  Active:      [✅ toggle]                                    │
│                                                             │
│  ─── Trigger ───                                            │
│  Event:       [▼ energy_use_milestone]                      │
│                                                             │
│  ── Condition (dynamic fields based on event) ──            │
│  Min Total Spent: [10]                                      │
│                                                             │
│  ─── Content ───                                            │
│  [EN] [TH]  ← tab switcher                                 │
│  Title:       [⚡ Starter Deal                    ]         │
│  Description: [200 Energy for just $1!            ]         │
│  CTA Text:    [Buy Now                            ]         │
│                                                             │
│  ─── Reward ───                                             │
│  Type:        [▼ special_product]                           │
│                                                             │
│  ── Config (dynamic fields based on rewardType) ──          │
│  Product ID:    [energy_first_purchase_200]                  │
│  Energy Amount: [200]                                       │
│  Display Price: [$1.00]                                     │
│                                                             │
│  ─── Duration & Limits ───                                  │
│  Expires After: [4] hours  (leave empty = no expiry)        │
│  Max Claims:    [1] per user                                │
│                                                             │
│                          [Cancel]  [Save]                    │
└─────────────────────────────────────────────────────────────┘
```

### Trigger Event Dropdown Options

```typescript
const TRIGGER_EVENTS = [
  { value: 'first_energy_use', label: 'First Energy Use (ใช้ Energy ครั้งแรก)' },
  { value: 'energy_use_milestone', label: 'Energy Use Milestone (ใช้ Energy ถึง X)' },
  { value: 'tier_up', label: 'Tier Up (เลื่อน Tier)' },
  { value: 'first_app_open', label: 'First App Open (เปิด App ครั้งแรก)' },
  { value: 'meals_logged_milestone', label: 'Meals Logged Milestone (Log อาหารถึง X ครั้ง)' },
  { value: 'first_purchase_complete', label: 'First Purchase Complete (ซื้อ offer product สำเร็จ)' },
];
```

### Dynamic Condition Fields

| triggerEvent | แสดง field | Field name |
|---|---|---|
| `energy_use_milestone` | "Min Total Spent" (number input) | `triggerCondition.minTotalSpent` |
| `tier_up` | "Tier" (dropdown: any/bronze/silver/gold/diamond) | `triggerCondition.tier` |
| `meals_logged_milestone` | "Min Meals Logged" (number input) | `triggerCondition.minMealsLogged` |
| `first_purchase_complete` | "After Product ID" (text input) | `triggerCondition.afterProductId` |
| `first_energy_use` | ไม่มี condition เพิ่ม | — |
| `first_app_open` | ไม่มี condition เพิ่ม | — |

### Reward Type Dropdown + Dynamic Config

| rewardType | แสดง fields |
|---|---|
| `special_product` | Product ID (text), Energy Amount (number), Display Price (text) |
| `bonus_rate` | Bonus Rate (number, 0-1, เช่น 0.4 = 40%) |
| `free_energy` | Amount (number) |
| `subscription_deal` | Product ID (text), Base Plan ID (text), Offer ID (text) |

### Validation (Client-side + Server-side)

```typescript
// Validation rules
const rules = {
  slug: { required: true, pattern: /^[a-z0-9_]+$/, message: 'Slug must be lowercase + underscore only' },
  'title.en': { required: true, message: 'English title is required' },
  triggerEvent: { required: true, message: 'Select a trigger event' },
  rewardType: { required: true, message: 'Select a reward type' },
  priority: { required: true, min: 1, message: 'Priority must be >= 1' },
  maxClaimsPerUser: { required: true, min: 1, message: 'Max claims must be >= 1' },
  
  // Conditional validation based on rewardType:
  'rewardConfig.productId': { requiredIf: ['special_product', 'subscription_deal'] },
  'rewardConfig.energyAmount': { requiredIf: ['special_product'] },
  'rewardConfig.bonusRate': { requiredIf: ['bonus_rate'], min: 0.01, max: 1.0 },
  'rewardConfig.amount': { requiredIf: ['free_energy'], min: 1 },
};
```

---

## #4 — Sidebar Menu

**ไฟล์:** `admin-panel/src/components/Sidebar.tsx`

### เพิ่ม menu item

```typescript
import { Gift } from 'lucide-react';  // ⬅️ เพิ่ม import

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', href: '/' },
  { icon: Users, label: 'Users', href: '/users' },
  { icon: Gift, label: 'Offers', href: '/offers' },         // ⬅️ เพิ่มบรรทัดนี้
  { icon: FlaskConical, label: 'Test Scenarios', href: '/test-scenarios' },
  // ...rest
];
```

### ตำแหน่ง

วางหลัง Users, ก่อน Test Scenarios

---

## #5 — Component Structure

### ไฟล์ที่ต้องสร้าง

```
admin-panel/src/
├── app/
│   ├── api/
│   │   └── offers/
│   │       ├── route.ts                    — GET (list) + POST (create)
│   │       └── [id]/
│   │           └── route.ts                — GET + PUT + DELETE
│   │
│   └── (dashboard)/
│       └── offers/
│           ├── page.tsx                    — List page
│           ├── create/
│           │   └── page.tsx                — Create form
│           └── [id]/
│               └── edit/
│                   └── page.tsx            — Edit form
│
└── components/
    └── offers/
        └── OfferForm.tsx                   — Shared form component (create + edit)
```

### OfferForm Component Props

```typescript
interface OfferFormProps {
  initialData?: OfferTemplate;  // undefined = create mode, มีค่า = edit mode
  onSubmit: (data: OfferTemplate) => Promise<void>;
  isLoading: boolean;
}
```

---

## Testing Checklist

| # | ทดสอบ | Expected |
|---|-------|----------|
| 1 | เปิดหน้า /offers | แสดง list ว่างเปล่า (หรือ seeded data) |
| 2 | กด Create Offer | ไปหน้า form |
| 3 | กรอก slug ซ้ำ → Save | Error: "Slug already exists" |
| 4 | กรอกถูกต้อง → Save | Redirect ไป /offers, เห็น offer ใน list |
| 5 | กด Edit | form มี data เดิมอยู่ |
| 6 | แก้ title → Save | กลับ list, title อัปเดต |
| 7 | Toggle Active off | isActive เปลี่ยนเป็น false |
| 8 | กด Delete + Confirm | offer หายจาก list |
| 9 | เลือก triggerEvent = tier_up | แสดง Tier dropdown |
| 10 | เลือก rewardType = bonus_rate | แสดง Bonus Rate input |
