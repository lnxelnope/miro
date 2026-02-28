# Monetization Upgrade — Energy Gamification System

**โปรเจค:** ระบบ Gamification เพื่อสร้างรายได้จาก Energy System  
**สถานะ:** Phase 1 — In Development  
**เริ่ม:** กุมภาพันธ์ 2026

---

## สารบัญ

1. [ภาพรวมโปรเจค](#-1-ภาพรวมโปรเจค)
2. [Architecture ปัจจุบัน vs ใหม่](#-2-architecture-ปัจจุบัน-vs-ใหม่)
3. [MiRO ID System](#-3-miro-id-system)
4. [ระบบ Gamification ทั้งหมด](#-4-ระบบ-gamification-ทั้งหมด)
5. [Revenue Model](#-5-revenue-model)
6. [Roadmap ทุก Phase](#-6-roadmap-ทุก-phase)
7. [Firestore Schema (Final)](#-7-firestore-schema-final)
8. [Decision Log](#-8-decision-log)

---

## 📋 1. ภาพรวมโปรเจค

### เป้าหมาย

สร้างระบบ Gamification ที่:
- **ล่อให้ user กลับเข้าแอปทุกวัน** (Daily Check-in + Streak)
- **สร้างรายได้** จากการขาย Energy (Heavy users ซื้อ 1-3 ครั้ง/เดือน)
- **ไม่ให้ user หมดกำลังใจ** (Normal users ไม่ต้องซื้อเลย)

### หลักการ

```
สมดุลระหว่าง:

  RETENTION ←――――→ REVENUE ←――――→ USER EXPERIENCE
  (กลับมาทุกวัน)    (ต้องซื้อบ้าง)    (ไม่รู้สึกถูกบังคับ)
```

### ผลลัพธ์ที่คาดหวัง (60 วัน)

| User Type | ใช้ AI/วัน | ต้องซื้อ | Frequency |
|-----------|-----------|---------|-----------|
| **Normal** | 3 | ไม่ต้องซื้อ | — |
| **Active** | 6 | ~54 Energy | ~1 ครั้ง/2 เดือน |
| **Heavy** | 10 | ~181 Energy | ~1.5 ครั้ง/เดือน |

### Tech Stack

| Component | Technology | Status |
|-----------|-----------|--------|
| Mobile App | Flutter (Android) | มีอยู่แล้ว |
| Backend | Firebase Cloud Functions (TypeScript) | มีอยู่แล้ว |
| Database | Firestore | มีอยู่แล้ว |
| Admin Panel | Next.js + Cloud Run | Phase 3 |
| Notifications | Firebase Cloud Messaging | Phase 3 |
| IAP | Google Play Billing | มีอยู่แล้ว |

---

## 🏗️ 2. Architecture ปัจจุบัน vs ใหม่

### ปัจจุบัน (Before)

```
┌─────────────────────────────────────────┐
│  Flutter App                            │
│  - DeviceIdService → deviceId           │
│  - EnergyTokenService → HMAC token      │
│  - BackupService → MIRO-XXXX-XXXX-XXXX │
│  - EnergyService → local cache          │
└─────────────────┬───────────────────────┘
                  │ HTTPS
┌─────────────────▼───────────────────────┐
│  Cloud Functions                        │
│  - analyzeFood    (Gemini + energy)     │
│  - syncBalance    (startup sync)        │
│  - verifyPurchase (Google Play)         │
│  - transferKey    (backup/restore)      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  Firestore                              │
│  - energy_balances/{deviceId}           │
│  - transfer_keys/{keyId}               │
│  - purchase_records/{hash}             │
└─────────────────────────────────────────┘
```

### ใหม่ (After — Phase 1-5)

```
┌─────────────────────────────────────────────┐
│  Flutter App                                │
│  ═══════════════════════════════             │
│  เดิม:                                      │
│  - DeviceIdService → deviceId               │
│  - EnergyTokenService → HMAC token          │
│  - EnergyService → local cache              │
│  - BackupService → backup/restore           │
│                                             │
│  ใหม่ (Phase 1):                             │
│  + MiRO ID display (Profile)               │
│  + Daily Check-in flow                      │
│  + Streak Tier display                      │
│  + "First AI Free" indicator                │
│                                             │
│  ใหม่ (Phase 2):                             │
│  + Weekly Challenge UI                      │
│  + Milestone progress UI                    │
│  + Bonus Energy animation                   │
│  + Random Bonus animation                   │
│                                             │
│  ใหม่ (Phase 3):                             │
│  + Push Notification handling               │
│                                             │
│  ใหม่ (Phase 4):                             │
│  + Referral code UI                         │
│  + Comeback Bonus UI                        │
└─────────────────────┬───────────────────────┘
                      │ HTTPS
┌─────────────────────▼───────────────────────┐
│  Cloud Functions                            │
│  ═══════════════════════════════             │
│  เดิม:                                      │
│  - analyzeFood     → แก้ไข (free AI logic) │
│  - syncBalance     → แก้ไข (return MiRO ID)│
│  - verifyPurchase  → คงเดิม                │
│  - transferKey     → แก้ไข (include MiRO)  │
│                                             │
│  ใหม่ (Phase 1):                             │
│  + registerUser    → สร้าง MiRO ID         │
│  + claimDailyCheckIn → streak + free AI    │
│                                             │
│  ใหม่ (Phase 2):                             │
│  + completeChallenge                        │
│  + claimMilestone                           │
│  + checkRandomBonus                         │
│  + resetWeeklyChallenges (cron)             │
│                                             │
│  ใหม่ (Phase 3):                             │
│  + admin/* (CRUD + metrics)                 │
│  + sendNotifications (cron)                 │
│                                             │
│  ใหม่ (Phase 4):                             │
│  + claimReferral                            │
│  + claimComebackBonus                       │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│  Firestore (Expanded)                       │
│  ═══════════════════════════════             │
│  เดิม:                                      │
│  - energy_balances/{deviceId}  → ยกเลิก    │
│  - transfer_keys/{keyId}       → คงเดิม    │
│  - purchase_records/{hash}     → คงเดิม    │
│                                             │
│  ใหม่:                                       │
│  + users/{deviceId}            → แทนที่     │
│  + transactions/{txId}         → ประวัติ    │
│  + config/rewards              → ค่า config │
│  + config/features             → feature flags│
│  + metrics/{date}              → Phase 3    │
└─────────────────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────┐
│  Admin Panel (Phase 3)                      │
│  ═══════════════════════════════             │
│  - Next.js + shadcn/ui                      │
│  - Deploy: Cloud Run                        │
│  - Auth: Firebase Admin                     │
│  - Dashboard, User Lookup, Config           │
└─────────────────────────────────────────────┘
```

---

## 🆔 3. MiRO ID System

### หลักการ

- ผู้ใช้ **anonymous** — ไม่ต้อง login, ไม่ต้องใส่ email/phone
- ทุกคนได้ MiRO ID อัตโนมัติ (format: `MIRO-XXXX-XXXX-XXXX`)
- MiRO ID เป็น **identity ถาวร** ของ user
- Anonymous = จุดขายของ MIRO — ต้องสื่อสารให้ชัดเจน

### Flow

```
เปิดแอปครั้งแรก
      │
      ▼
  deviceId ถูกสร้าง (DeviceIdService)
      │
      ▼
  เรียก registerUser Cloud Function
      │
      ▼
  Server สร้าง MiRO ID: "MIRO-A3F9-K7X2-P8M1"
  Server สร้าง user document ใน Firestore
      │
      ▼
  Client เก็บ MiRO ID ใน SecureStorage
      │
      ▼
  แสดง MiRO ID ใน Profile (optional)
```

### การ Backup/Restore

```
Backup:
  App สร้าง JSON file ที่ประกอบด้วย:
  {
    "miroId": "MIRO-A3F9-K7X2-P8M1",     ← MiRO ID
    "transferKey": "MIRO-H7T2-P9K3-X4M1", ← Transfer Key (เดิม)
    "energyBalance": 150,
    "foodEntries": [...],
    "myMeals": [...],
    "streakTier": "silver",                ← ใหม่
    "dailyStreak": 14                      ← ใหม่
  }

Restore:
  1. User เลือกไฟล์ backup
  2. App redeem Transfer Key (เดิม)
  3. Server โอน energy + ผูก MiRO ID กับ deviceId ใหม่
  4. เครื่องเดิมหมดสิทธิ์ (energy = 0, MiRO ID ถูก unlink)
```

### ข้อควรระวัง (แจ้ง User ให้ชัดเจน)

```
⚠️ MIRO ใช้ระบบ Anonymous — ไม่มี Login
⚠️ ถ้าเปลี่ยนเครื่องโดยไม่ Backup → ข้อมูลหายทั้งหมด
⚠️ ถ้าลบแอปโดยไม่ Backup → ข้อมูลหายทั้งหมด (Android)
⚠️ กรุณา Backup ข้อมูลเป็นประจำ

(iOS: IDFV + Keychain อาจรอดได้หลัง reinstall แต่ไม่ guarantee)
```

---

## 🎮 4. ระบบ Gamification ทั้งหมด

### 4.1 Daily Check-in + Free AI

| Feature | รายละเอียด |
|---------|-----------|
| **กด AI ครั้งแรกของวัน** | ไม่คิด energy (ฟรี!) |
| **Streak** | นับจากวันที่ใช้ AI ครั้งแรก (ฟรี) |
| **Reset** | ตาม Tier Grace Period (ดูด้านล่าง) |

### 4.2 Streak Tier System

```
Tier         ปลดล็อค     Bonus Energy    Grace Period
─────────────────────────────────────────────────────
🥉 Bronze    Day 7       +10 Energy      ไม่มี
🥈 Silver    Day 14      +15 Energy      หยุดได้ 1 วัน
🥇 Gold      Day 30      +30 Energy      หยุดได้ 2 วัน
💎 Diamond   Day 60      +45 Energy      หยุดได้ 3 วัน

กฎ:
  1. Tier ที่ปลดล็อคแล้ว → ไม่หลุด (permanent)
  2. ปลดล็อค Tier ใหม่ ต้อง streak ติดต่อกัน (มี Grace จาก Tier ก่อนหน้า)
  3. Streak counter อาจ reset แต่ Tier ยังอยู่
  4. Bonus Energy ได้ตอนปลดล็อค Tier เท่านั้น (ได้ครั้งเดียว)
```

### 4.3 Weekly Challenges (Phase 2)

| Challenge | Target | Reward | Frequency |
|-----------|--------|--------|-----------|
| Log meals | 7 meals | 5 Energy | Weekly |
| Use AI | 3 times (นับ free + paid) | 5 Energy | Weekly |

### 4.4 Milestone Rewards (Phase 2)

| Milestone | Reward |
|-----------|--------|
| 500 Energy spent (lifetime) | 15 Energy back |
| 1000 Energy spent (lifetime) | 30 Energy back |

### 4.5 Bonus Energy (แทน Discount) (Phase 2)

```
Day 30 Gold:     ซื้อ Energy ได้ Bonus +20%
Day 60 Diamond:  ซื้อ Energy ได้ Bonus +30%

ตัวอย่าง:
  Gold user ซื้อ 100 Energy (99 THB) → ได้ 120 Energy
  Diamond user ซื้อ 100 Energy (99 THB) → ได้ 130 Energy
```

### 4.6 Random Daily Bonus (Phase 2)

- 5% chance ได้ 5-10 Energy ทุกวัน (ตอน check-in)
- Surprise & delight mechanic

### 4.7 Referral System (Phase 4)

- 15 Energy per friend referred
- Max 2 friends/month
- ต้องมี MiRO ID ทั้งคู่
- Friend ต้องใช้ AI จริง 3 ครั้งก่อน referrer ได้ reward

### 4.8 Comeback Bonus (Phase 4)

| หายไป | Reward |
|-------|--------|
| 3-7 วัน | 3 Energy |
| 7-14 วัน | 5 Energy |
| 14-30 วัน | 10 Energy + 1 Streak Freeze |
| 30+ วัน | 15 Energy + Start at Bronze |

### 4.9 Push Notifications (Phase 3)

| Notification | เวลา | เงื่อนไข |
|-------------|------|---------|
| Streak Reminder | 20:00 | ยังไม่เปิดแอปวันนี้ |
| Streak Break Warning | 22:00 | ใกล้เสีย streak สำคัญ |
| Challenge Almost Done | Dynamic | เหลือ 20% ของ target |
| Challenge Reset Warning | วันเสาร์ | ยัง challenge ค้างอยู่ |
| Tier Almost Unlocked | Dynamic | อีก 1-3 วันจะปลดล็อค |
| Random Bonus Alert | Dynamic | ได้ random bonus |
| Win-back | หลัง 3 วัน | ไม่เข้าแอป 3+ วัน |

---

## 💰 5. Revenue Model

### 5.1 Revenue Projection (10,000 users)

```
60% Normal (6,000 users) → ไม่ซื้อ       → 0 THB
30% Active (3,000 users) → ~1x/2 เดือน   → 1,500 purchases/60 วัน
10% Heavy  (1,000 users) → ~1.5x/เดือน   → 3,000 purchases/60 วัน

Total: ~4,500 purchases/60 วัน = ~75 purchases/day
ถ้า package เฉลี่ย 99 THB → ~7,425 THB/day → ~222,750 THB/month

Firebase costs: ~3,000-5,600 THB/month (2-3% of revenue)
Net: ~217,000-220,000 THB/month
```

### 5.2 Energy Subscription (Phase 5)

```
Energy Pass — 149 THB/month
  ✓ Unlimited AI analysis (no energy cost)
  ✓ Double streak rewards
  ✓ Exclusive badge
  ✓ Priority support
```

---

## 📅 6. Roadmap ทุก Phase

### Phase 1: Core System (Week 1-2) ← ปัจจุบัน

```
📄 คู่มือ: PHASE_1_CORE.md

สิ่งที่ทำ:
  ✓ MiRO ID system (anonymous user identity)
  ✓ Firestore schema migration (energy_balances → users)
  ✓ "First AI free per day" (แก้ analyzeFood)
  ✓ Streak Tier system (Bronze → Diamond + Grace Period)
  ✓ Cloud Function: registerUser
  ✓ Cloud Function: claimDailyCheckIn
  ✓ Flutter: Daily check-in UI
  ✓ Flutter: Streak display + Tier badges
  ✓ Flutter: Free AI indicator
  ✓ Backup system update (include MiRO ID)
  ✓ Testing

Deliverables:
  - 2 Cloud Functions ใหม่ (registerUser, claimDailyCheckIn)
  - 2 Cloud Functions แก้ไข (analyzeFood, syncBalance)
  - Firestore schema migration
  - Flutter UI components
```

### Phase 2: Challenges & Milestones (Week 3-4)

```
📄 คู่มือ: PHASE_2_CHALLENGES.md (ยังไม่สร้าง)

สิ่งที่ทำ:
  - Weekly challenges (Log meals + Use AI)
  - Milestone rewards (500, 1000 Energy spent)
  - Bonus Energy system (แทน Discount)
  - Random Daily Bonus (5% chance)
  - Cloud Functions: completeChallenge, claimMilestone, checkRandomBonus
  - Cron job: resetWeeklyChallenges (ทุกวันจันทร์ 00:00 UTC+7)
  - Flutter: Challenge UI, Milestone progress, Bonus animation
```

### Phase 3: Admin Panel + Notifications (Week 5-6)

```
📄 คู่มือ: PHASE_3_ADMIN.md (ยังไม่สร้าง)

สิ่งที่ทำ:
  - Admin Panel (Next.js + Cloud Run)
  - Dashboard: DAU, revenue, streak distribution
  - User lookup (by MiRO ID or deviceId)
  - Manual operations (top-up, reset streak)
  - Config management (reward values, feature flags)
  - Push Notifications (FCM)
  - Fraud detection alerts
  - Emergency buttons (freeze rewards, rollback)
```

### Phase 4: Referral + Comeback (Week 7-8)

```
📄 คู่มือ: PHASE_4_SOCIAL.md (ยังไม่สร้าง)

สิ่งที่ทำ:
  - Referral system (MiRO ID based)
  - Comeback Bonus (win-back lapsed users)
  - A/B Testing framework
  - Advanced fraud detection
```

### Phase 5: Subscription + Events (Week 9+)

```
📄 คู่มือ: PHASE_5_SUBSCRIPTION.md (ยังไม่สร้าง)

สิ่งที่ทำ:
  - Energy Pass subscription (149 THB/month)
  - Seasonal Events (Songkran, New Year, etc.)
  - Social Features (leaderboard, share)
  - Energy Expiry (optional)
  - iOS IAP integration
```

---

## 📐 7. Firestore Schema (Final)

### Collection: `users/{deviceId}`

```typescript
interface UserDocument {
  // ─── Identity ───
  deviceId: string;                 // Primary key (ANDROID_ID / IDFV)
  miroId: string;                   // "MIRO-XXXX-XXXX-XXXX" (permanent, unique)
  createdAt: Timestamp;
  lastUpdated: Timestamp;

  // ─── Energy Balance ───
  balance: number;                  // Current energy balance
  totalEarned: number;              // Lifetime energy earned (rewards)
  totalSpent: number;               // Lifetime energy spent (AI usage)
  totalPurchased: number;           // Lifetime energy purchased (IAP)
  welcomeGiftClaimed: boolean;

  // ─── Daily Free AI ─── (Phase 1)
  freeAiUsedToday: boolean;         // วันนี้ใช้ free AI แล้วหรือยัง
  freeAiLastReset: string;          // "YYYY-MM-DD" วันที่ reset ล่าสุด

  // ─── Streak & Tier ─── (Phase 1)
  currentStreak: number;            // จำนวนวัน streak ปัจจุบัน
  longestStreak: number;            // สถิติ streak ที่ยาวที่สุด
  lastCheckInDate: string;          // "YYYY-MM-DD"
  tier: 'none' | 'bronze' | 'silver' | 'gold' | 'diamond';
  tierUnlockedAt: {                 // เวลาที่ปลดล็อคแต่ละ Tier
    bronze: Timestamp | null;
    silver: Timestamp | null;
    gold: Timestamp | null;
    diamond: Timestamp | null;
  };

  // ─── Challenges ─── (Phase 2)
  challenges: {
    weekly: {
      logMeals: number;             // 0-7
      useAi: number;                // 0-3 (นับ free + paid)
      claimedRewards: string[];     // ["logMeals", "useAi"]
      weekStartDate: string;        // "YYYY-MM-DD" (วันจันทร์)
    };
  };

  // ─── Milestones ─── (Phase 2)
  milestones: {
    spent500Claimed: boolean;
    spent1000Claimed: boolean;
  };

  // ─── Bonus Energy ─── (Phase 2)
  bonusRate: number;                // 0, 0.1, 0.2 (10%, 20%)
  lastRandomBonus: string | null;   // "YYYY-MM-DD"
  randomBonusCount: number;         // สถิติ

  // ─── Referrals ─── (Phase 4)
  referrals: {
    myReferralCode: string;         // = MiRO ID
    referredBy: string | null;      // MiRO ID ของคนชวน
    referralCount: number;          // 0-2 (reset ทุกเดือน)
    referralResetDate: string;      // "YYYY-MM-01"
    referredUsers: string[];        // [miroId1, miroId2]
  };

  // ─── Flags ───
  isBanned: boolean;
  banReason: string | null;
}
```

### Collection: `transactions/{txId}`

```typescript
interface TransactionDocument {
  txId: string;                     // Auto-generated
  deviceId: string;
  miroId: string;
  type: 'usage' | 'free_ai' | 'purchase' | 'welcome_gift'
      | 'streak_bonus' | 'challenge' | 'milestone'
      | 'random_bonus' | 'referral' | 'comeback'
      | 'bonus_energy' | 'transfer_in' | 'transfer_out'
      | 'admin_topup' | 'admin_deduct';
  amount: number;                   // +/- energy
  balanceAfter: number;
  description: string;
  metadata: Record<string, any>;    // type-specific data
  createdAt: Timestamp;
}
```

### Collection: `config/rewards`

```typescript
interface RewardsConfig {
  // Streak Tier
  streakTiers: {
    bronze:  { days: 7,  energy: 10, graceDays: 0 };
    silver:  { days: 14, energy: 15, graceDays: 1 };
    gold:    { days: 30, energy: 30, graceDays: 2, bonusRate: 0.10 };
    diamond: { days: 60, energy: 45, graceDays: 3, bonusRate: 0.20 };
  };

  // Weekly Challenges (Phase 2)
  challenges: {
    logMeals: { target: 7, reward: 5 };
    useAi:    { target: 3, reward: 5 };
  };

  // Milestones (Phase 2)
  milestones: {
    spent500:  { reward: 15 };
    spent1000: { reward: 30 };
  };

  // Random Bonus (Phase 2)
  randomBonus: {
    chance: 0.05;
    minReward: 5;
    maxReward: 10;
  };

  // Referral (Phase 4)
  referral: {
    reward: 15;
    maxPerMonth: 2;
    minUsageForReward: 3;
  };

  // Comeback (Phase 4)
  comeback: {
    '3-7':   { energy: 3 };
    '7-14':  { energy: 5 };
    '14-30': { energy: 10, streakFreeze: 1 };
    '30+':   { energy: 15, startTier: 'bronze' };
  };

  // Welcome Gift
  welcomeGift: 100;
}
```

### Collection: `config/features`

```typescript
interface FeatureFlags {
  enableDailyFreeAi: boolean;       // Phase 1
  enableStreakTier: boolean;         // Phase 1
  enableWeeklyChallenges: boolean;   // Phase 2
  enableMilestones: boolean;        // Phase 2
  enableRandomBonus: boolean;       // Phase 2
  enableReferral: boolean;          // Phase 4
  enableComebackBonus: boolean;     // Phase 4
  enableSubscription: boolean;      // Phase 5
  enableNotifications: boolean;     // Phase 3

  // Emergency
  freezeAllRewards: boolean;        // ปิดทุก reward ชั่วคราว
  maintenanceMode: boolean;         // ปิดระบบชั่วคราว
}
```

---

## 📝 8. Decision Log

| วันที่ | ประเด็น | การตัดสินใจ | เหตุผล |
|--------|---------|------------|--------|
| 17/02/26 | Discount vs Bonus Energy | **Bonus Energy** (+20%, +30%) | Revenue ไม่ลดลง + User รู้สึกได้มูลค่า |
| 17/02/26 | Daily Free AI | **ครั้งแรกของวันไม่คิด energy** | ง่ายกว่า track token แยก + ไม่กระทบยอด energy |
| 17/02/26 | Streak Break | **Tier System + Grace Period** | Tier ปลดล็อคแล้วไม่หลุด + Grace ตาม Tier |
| 17/02/26 | User Account | **Anonymous (MiRO-XXXX-XXXX-XXXX)** | จุดขายของแอป + ไม่ต้อง login |
| 17/02/26 | Referral Timeline | **Phase 4** (ต้องมี MiRO ID ก่อน) | ป้องกัน fraud + ลด complexity Phase 1 |
| 17/02/26 | Admin Panel | **Phase 3** (หลัง core features) | เน้น core ก่อน |
| 17/02/26 | Subscription | **Phase 5** | เน้น energy model ก่อน |
| 17/02/26 | iOS IAP | **ทีหลัง** | Android only ตอนนี้ |
| 17/02/26 | Weekly Challenge | **นับรวม free AI** | ทุกคนทำได้ → retention เน้น |

---

## 📂 โครงสร้างโฟลเดอร์

```
monetization_upgrade/
├── README.md                    ← อ่านก่อน (ภาพรวมทั้งหมด)
│
├── phase_1/                     ← Phase 1: Core System
│   ├── README.md                ← เริ่มที่นี่!
│   ├── TASK_1_SCHEMA.md         ← Firestore Schema & Migration
│   ├── TASK_2_MIRO_BACKEND.md   ← MiRO ID System
│   ├── TASK_3_FREE_AI.md        ← Free AI Logic
│   ├── TASK_4_STREAK.md         ← Streak Tier System
│   ├── TASK_5_FLUTTER.md        ← Flutter Client
│   ├── TASK_6_BACKUP.md         ← Backup System
│   └── TASK_7_TESTING.md        ← Testing Checklist
│
├── phase_2/                     ← Phase 2: Challenges & Milestones
│   ├── README.md
│   ├── TASK_1_WEEKLY_CHALLENGES.md
│   └── TASKS_SUMMARY.md         ← Quick reference
│
├── phase_3/                     ← Phase 3: Admin Panel + Notifications
│   └── README.md
│
├── phase_4/                     ← Phase 4: Referral + Comeback
│   └── README.md
│
├── phase_5/                     ← Phase 5: Subscription + Events
│   └── README.md
│
├── PHASE_1_CORE.md              ← Original detailed docs (สำรอง)
├── PHASE_2_CHALLENGES.md
├── PHASE_3_ADMIN.md
├── PHASE_4_SOCIAL.md
└── PHASE_5_SUBSCRIPTION.md
```

---

## 🚀 วิธีใช้งานคู่มือ

### สำหรับ Junior Developer (ต้องการทำงานทันที)

```bash
# 1. เริ่มที่ Phase 1
cd phase_1
cat README.md

# 2. ทำทีละ Task
cat TASK_1_SCHEMA.md    # อ่าน + ทำตาม step-by-step
# ... เสร็จแล้วไป TASK_2, TASK_3, ...

# 3. เสร็จ Phase 1 → ไป Phase 2
cd ../phase_2
cat README.md
```

### สำหรับ Senior Developer (ต้องการภาพรวม)

```bash
# อ่านไฟล์ PHASE_X_XXX.md ในโฟลเดอร์หลัก
cat PHASE_1_CORE.md         # รายละเอียดเต็ม Phase 1
cat PHASE_2_CHALLENGES.md   # รายละเอียดเต็ม Phase 2
# ... etc
```

---

## 📝 การจัดการคู่มือ

- **`phase_X/TASK_Y.md`** — คู่มือ step-by-step สำหรับ junior (ละเอียดมาก, ไม่ต้องคิดเอง)
- **`PHASE_X_XXX.md`** — คู่มือเต็มสำหรับ senior (ภาพรวม, technical details)
- **`phase_X/README.md`** — สรุป deliverables + task list
