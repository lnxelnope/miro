# MiRO Energy Marketing Blueprint
> **สถานะ:** v3.1 — Balanced Edition + Rewarded Ads — **Implementation In Progress**  
> **วันที่:** 20 ก.พ. 2026  
> **อัปเดตล่าสุด:** 20 ก.พ. 2026  
> **วัตถุประสงค์:** วางกระบวนการขาย Energy ทั้งหมด ตั้งแต่ผู้ใช้เข้ามาจนถึงการซื้อซ้ำ

---

## 📋 สถานะการดำเนินงานทั้งหมด

### สรุปภาพรวม

| ส่วน | สถานะ | หมายเหตุ |
|------|--------|----------|
| **Backend (Cloud Functions)** | ✅ เสร็จ 100% | ทุก API + Logic + Migration Script |
| **Frontend (Flutter) — Core** | ✅ เสร็จ 100% | Quest Bar, Claim, Tier Up, Ad Service |
| **Frontend (Flutter) — ปรับค่า** | ⚠️ ยังไม่เสร็จ | Fix 7 จุด (ดู Fixlist ด้านล่าง) |
| **Admin Panel (Next.js)** | ✅ เสร็จ Phase 1 | User Management 5 Tabs + Test Scenarios |
| **Admin Panel — Analytics** | 🔲 ยังไม่ทำ | Promotion Conversion, ARPU, Funnel |
| **Google Play IAP Setup** | ✅ เสร็จ | $1/200E, $2/wk, $5/mo, $40/yr + Offers |
| **AdMob Ad Unit Setup** | ✅ เสร็จ | Rewarded Ad Unit ID + SSV Callback |
| **Testing & QA** | 🔲 ยังไม่ทำ | End-to-end testing ทุก flow |
| **Deployment** | 🔲 ยังไม่ทำ | ตาม Migration Rollout Plan |

---

### ✅ สิ่งที่เสร็จแล้ว (Backend)

| # | งาน | ไฟล์ | สถานะ |
|---|------|------|--------|
| B1 | แก้ Bug: Offer ซื้อซ้ำไม่จำกัด | `promotions.ts`, `verifyPurchase.ts` | ✅ |
| B2 | ปรับ Challenge Reward 5E → 3E | `challenge.ts` | ✅ |
| B3 | ปรับ Tier Upgrade Reward (5/10/15/25E) | `dailyCheckIn.ts` | ✅ |
| B4 | ลบ Subscriber Double Quest | `challenge.ts` | ✅ |
| B5 | ลบ Random Daily Bonus | `dailyCheckIn.ts` | ✅ |
| B6 | ลบ First Empty Bonus +50E | `energy/` | ✅ |
| B7 | ลบ Welcome Offer +50E | `promotions.ts` | ✅ |
| B8 | Milestone V2 (10 ขั้น) | `milestoneV2.ts` (ใหม่) | ✅ |
| B9 | $1 = 200E Offer Flow | `promotions.ts`, `verifyPurchase.ts` | ✅ |
| B10 | 40% Bonus Offer | `promotions.ts` | ✅ |
| B11 | Daily Claim (Manual) | `claimDailyEnergy.ts` (ใหม่) | ✅ |
| B12 | Rewarded Ads SSV | `rewardedAd.ts` (ใหม่) | ✅ |
| B13 | Push Notification (3 triggers) | `notifications/pushTriggers.ts` (ใหม่) | ✅ |
| B14 | Referral Two-Way | `checkReferralProgress.ts` | ✅ |
| B15 | Winback Subscription | `winbackScheduler.ts` (ใหม่) | ✅ |
| B16 | Firestore Schema V3 | `FIRESTORE_SCHEMA_V3.md` | ✅ |
| B17 | Migration Script | `scripts/migrateUsersToV3.ts` | ✅ |
| B18 | Rollback Script | `scripts/rollbackV3.ts` | ✅ |

### ✅ สิ่งที่เสร็จแล้ว (Frontend Core)

| # | งาน | ไฟล์ | สถานะ |
|---|------|------|--------|
| FC1 | Quest Bar Widget | `quest_bar.dart` | ✅ |
| FC2 | Claim Button + Confetti | `claim_button.dart` | ✅ |
| FC3 | Tier Up Overlay | `tier_up_overlay.dart` | ✅ |
| FC4 | AdMob Rewarded Ad Service | `ad_service.dart` | ✅ |
| FC5 | No Energy Dialog + Ad Button | `no_energy_dialog.dart` | ✅ |
| FC6 | Quest Bar ใน Home Screen | `home_screen.dart` | ✅ |
| FC7 | Localization EN + TH | `app_en.arb`, `app_th.arb` | ✅ |
| FC8 | Integration Tests (10 cases) | `quest_bar_test.dart` | ✅ |

### ✅ สิ่งที่เสร็จแล้ว (Admin Panel)

| # | งาน | สถานะ |
|---|------|--------|
| A1 | User Detail Modal (5 Tabs) | ✅ |
| A2 | Quick Actions (Reset, Set Tier, Balance, Streak) | ✅ |
| A3 | Energy History + Manual Transaction | ✅ |
| A4 | Offers & Promotions State | ✅ |
| A5 | Gamification State (Milestones, Streak, Ads) | ✅ |
| A6 | Test Scenarios (5 Presets) | ✅ |
| A7 | Bulk User Management | ✅ |
| A8 | Audit Logs | ✅ |
| A9 | Promotion Analytics | ✅ |
| A10 | Push Notification Campaign UI | ✅ |

### ✅ สิ่งที่เสร็จแล้ว (Documentation)

| # | เอกสาร | สถานะ |
|---|--------|--------|
| D1 | PR Template + Code Review Checklist | ✅ |
| D2 | Performance Optimization Guide | ✅ |
| D3 | Security Audit | ✅ |
| D4 | Migration & Rollout Plan | ✅ |
| D5 | Firestore Schema V3 | ✅ |

---

### ⚠️ Frontend Fixlist — ยังต้องทำ (ปรับ Frontend ให้ตรง Blueprint)

> **รายละเอียดเต็ม:** `_project_manager/energy_marketing_v3/V3_FRONTEND_FIXLIST.md`  
> **ประมาณเวลารวม:** ~5-6 ชั่วโมง

| # | งาน | Priority | ไฟล์ | เวลา | สถานะ |
|---|------|----------|------|------|--------|
| F1 | Energy Store ลบ Streak/Challenge/Milestone ออก | 🔴 Critical | `energy_store_screen.dart` | 30 นาที | 🔲 |
| F2 | Milestone เปลี่ยน 2 ขั้น → 10 ขั้น (model+provider+widget) | 🔴 Critical | `gamification_state.dart`, `gamification_provider.dart`, `milestone_progress_card.dart` | 3-4 ชม. | 🔲 |
| F3 | Weekly Challenge reward 5E → 3E | 🟡 Medium | `weekly_challenge_card.dart` | 15 นาที | 🔲 |
| F4 | ลบ First Empty Bonus +50E | 🟡 Medium | `no_energy_dialog.dart` | 30 นาที | 🔲 |
| F5 | Home Screen daily energy ค่าผิด (ใช้ Tier Reward แทน Daily) | 🟡 Medium | `home_screen.dart` | 15 นาที | 🔲 |
| F6 | Subscription ราคาเก่า ฿149 → $2/wk, $5/mo, $40/yr | 🟢 Low | `energy_store_screen.dart`, `subscription_screen.dart` | 15 นาที | 🔲 |
| F7 | ลบ Random Bonus handler | 🟢 Low | `gamification_provider.dart` | 15 นาที | 🔲 |

### ✅ Owner / Setup Tasks — เสร็จแล้ว

| # | งาน | ผู้รับผิดชอบ | สถานะ |
|---|------|------------|--------|
| O1 | Google Play: สร้าง IAP Product `$1 = 200E` | Owner | ✅ |
| O2 | Google Play: สร้าง Subscription Base Plans ($2/wk, $5/mo, $40/yr) | Owner | ✅ |
| O3 | Google Play: สร้าง Offer IDs (first-month-free, winback-3usd) | Owner | ✅ |
| O4 | AdMob: สร้าง Rewarded Ad Unit ID (Android + iOS) | Owner | ✅ |
| O5 | AdMob: ตั้งค่า SSV Callback URL | Owner | ✅ |
| O6 | Firebase: Deploy Firestore Indexes | Owner/Dev | ✅ |
| O7 | Firebase: Deploy Security Rules | Owner/Dev | ✅ |
| O8 | Firebase: Setup Remote Config (Feature Flags) | Owner/Dev | ✅ |
| O9 | ตรวจสอบราคา Energy Package (Power $7.99→$9.99?, Ultimate $9.99→$14.99?) | Owner | ✅ |

### 🔲 Admin Panel — ยังไม่ทำ (Priority กลาง-ต่ำ)

| # | งาน | Priority | สถานะ |
|---|------|----------|--------|
| AP1 | Revenue per User (ARPU) Dashboard | 🔴 สูง | 🔲 |
| AP2 | Energy Purchase Funnel Chart | 🔴 สูง | 🔲 |
| AP3 | Flash Sale / Custom Promo Creator | 🔴 สูง | 🔲 |
| AP4 | Tier Distribution Chart | 🟡 กลาง | 🔲 |
| AP5 | DAU/WAU/MAU Dashboard | 🟡 กลาง | 🔲 |
| AP6 | A/B Test Management | 🟡 กลาง | 🔲 |
| AP7 | Churn Risk Users List | 🟡 กลาง | 🔲 |
| AP8 | Rewarded Ads Analytics | 🟡 กลาง | 🔲 |
| AP9 | Milestone Config Editor | 🟡 กลาง | 🔲 |
| AP10 | Dashboard Overview (Homepage) | 🟡 กลาง | 🔲 |

### 🔲 Pre-Launch Tasks

| # | งาน | สถานะ |
|---|------|--------|
| PL1 | ทำ Frontend Fixlist (F1-F7) ให้เสร็จ | 🔲 |
| PL2 | Owner ตั้งค่า IAP + AdMob (O1-O5) | ✅ |
| PL3 | Deploy Firestore Indexes + Security Rules (O6-O7) | ✅ |
| PL4 | End-to-End Testing ทุก Flow | 🔲 |
| PL5 | `flutter analyze` — ต้องไม่มี error | 🔲 |
| PL6 | `flutter build apk --release` — ต้อง build ผ่าน | 🔲 |
| PL7 | ทดสอบ Ad Reward Flow บนเครื่องจริง | 🔲 |
| PL8 | ทดสอบ IAP Purchase Flow บนเครื่องจริง | 🔲 |
| PL9 | Database Backup ก่อน Deploy | 🔲 |
| PL10 | Deploy Cloud Functions | 🔲 |
| PL11 | Run Migration Script | 🔲 |
| PL12 | 10% Rollout (3 วัน) → 50% (3 วัน) → 100% | 🔲 |

---

## สารบัญ

1. [ภาพรวม Marketing Funnel](#1-ภาพรวม-marketing-funnel)
2. [Quest Bar — แถบหลักบนหน้า Home](#2-quest-bar--แถบหลักบนหน้า-home)
3. [Daily Energy — ต้องมากด Claim](#3-daily-energy--ต้องมากด-claim)
4. [Rewarded Ads — Safety Net เมื่อ Energy หมด](#4-rewarded-ads--safety-net-เมื่อ-energy-หมด)
5. [Streak & Tier System](#5-streak--tier-system)
6. [Milestone System — Diminishing Cashback](#6-milestone-system--diminishing-cashback)
7. [Weekly Challenges](#7-weekly-challenges)
8. [Offer & Promotion — จังหวะขาย](#8-offer--promotion--จังหวะขาย)
9. [Energy Pass (Subscription)](#9-energy-pass-subscription)
10. [Referral System](#10-referral-system)
11. [Push Notifications](#11-push-notifications)
12. [Admin Marketing Dashboard](#12-admin-marketing-dashboard)
13. [Bug Fixes ที่ต้องทำ](#13-bug-fixes-ที่ต้องทำ)
14. [Appendix: ตัวเลข & สูตรคำนวณ](#14-appendix-ตัวเลข--สูตรคำนวณ)

---

## 1. ภาพรวม Marketing Funnel

```
วันที่ 1              หลังใช้ 10E          4 ชม.หลัง 10E        ซื้อ $1 แล้ว
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Welcome     │──▶│  Milestone   │──▶│  $1 = 200E   │──▶│  40% Bonus   │
│  Gift +10E   │   │  10E → +3E   │   │  First Buy!  │   │  Offer #2    │
│              │   │  cashback    │   │  4hr / 1time  │   │  24hr / 1time│
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘

วันที่ 7+             วันที่ 14+           วันที่ 30+           วันที่ 60+
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Bronze     │──▶│    Silver    │──▶│     Gold     │──▶│   Diamond    │
│   +5E        │   │    +10E     │   │    +15E      │   │    +25E      │
│   Tier Promo │   │   Tier Promo │   │  Tier Promo  │   │  Tier Promo  │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘

Milestone 50E spent                    Ex-Diamond ตก Tier
┌──────────────┐                      ┌──────────────┐
│  Sub Upsell  │                      │ Welcome Back │
│  $5/mo       │                      │ $3 first mo  │
│  +1mo FREE   │                      │              │
└──────────────┘                      └──────────────┘
```

**เป้าหมายหลัก:**
- **Retention:** ทำให้ผู้ใช้กลับมาทุกวัน (Streak + Daily Claim + Quest Bar)
- **Engagement:** ทำให้ผู้ใช้ใช้ฟีเจอร์มากขึ้น (Challenges + Milestones)
- **First Purchase:** ทำลายกำแพงจ่ายครั้งแรกด้วย $1 = 200E
- **Monetization:** ขาย Energy Package & Energy Pass ในจังหวะที่เหมาะสม

**เป้าหมาย Survival:**
- ใช้ 3 ครั้ง/วัน (แค่มื้อหลัก): อยู่ได้ตลอด → ให้ DAU
- ใช้ 5 ครั้ง/วัน (จริงจัง): ร้อนตัววันที่ ~11-13 → จุดขาย
- ใช้ 7+ ครั้ง/วัน (hardcore): หมดภายใน 2-3 วัน → ต้องซื้อ/subscribe
- **Energy = 0:** ไม่บล็อค! → Rewarded Ads 3 ครั้ง/วัน → ยังใช้ได้แต่รำคาญ → อยากซื้อ

---

## 2. Quest Bar — แถบหลักบนหน้า Home

### ตำแหน่ง
อยู่ใต้ "Analyze All" ขนาด 1 row

### พฤติกรรม

#### State 1: มี Offer (แสดง Offer ก่อนเสมอ)
```
┌─────────────────────────────────────────────────┐
│ 🔥 200E แค่ $1! ⏰ 3:42:15                    → │
└─────────────────────────────────────────────────┘
```
- แสดง Offer ที่ urgent ที่สุดก่อน (countdown น้อยสุด)
- **Max 2 Offers active พร้อมกัน**
- กดที่แถบ → เปิด Offer detail
- ปัดซ้าย → ซ่อน Offer → แสดง **Snackbar ด้านล่าง** (เหมือน undo ลบอาหาร)
  - Snackbar ค้างจนกว่าจะปัดซ้ายอีกที หรือกด "ดู Offer"

#### State 2: ไม่มี Offer (แสดง Streak + Claim)
```
┌─────────────────────────────────────────────────┐
│ 🥉 Streak 12 วัน ──────●── 🥈 อีก 2 วัน  [+2E]│
└─────────────────────────────────────────────────┘
  ↑ Tier ปัจจุบัน    Progress Bar    ↑ Tier ถัดไป  ↑ Claim Badge
```
- ซ้าย: ไอคอน Tier ปัจจุบัน
- กลาง: Streak วัน + Progress bar ไป Tier ถัดไป + "อีก X วัน"
- ขวา: **Claim Badge** `[+NE]` — แสดงจำนวน Energy ที่ claim ได้
- **ต้องอ่าน/ปิด Offer ทั้งหมดก่อน** จึงจะเห็น Streak + กด Claim ได้

#### กด Claim:
1. Claim Energy → animation confetti/พลุ 2 วินาที
2. ถ้า Tier Up → Overlay แสดงความยินดี 2 วิ
   - "🎉 ยินดีด้วย! คุณเลื่อนเป็น [Tier]!"
   - "Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!"
3. หลัง Tier Up → แสดง Special Offer ของ Tier ใหม่
4. หลังปิด Offer → กลับมาแสดง Streak ปกติ

#### Collapsible (กดขยาย):
```
┌─────────────────────────────────────────────────┐
│ 🥉 Streak 12 วัน ──────●── 🥈 อีก 2 วัน  [+2E]│
├─────────────────────────────────────────────────┤
│ 📋 Offers                                       │
│  • 40% Bonus ⏰ 18:30:00                        │
│  • (ไม่มี Offer อื่น)                            │
├─────────────────────────────────────────────────┤
│ 🎯 Weekly Challenges                             │
│  • บันทึกอาหาร 5/7 มื้อ           [━━━━━━━░░]  │
│  • ใช้ AI 2/3 ครั้ง                [━━━━━░░░░]  │
├─────────────────────────────────────────────────┤
│ 🏆 Milestones                                    │
│  • ใช้ Energy ครบ 100 (82/100)     [━━━━━━░░░]  │
│  • ถัดไป: 250E                     🔒            │
├─────────────────────────────────────────────────┤
│ 👥 ชวนเพื่อนได้ 5E                         ▶    │
└─────────────────────────────────────────────────┘
```

### สิ่งที่ต้องย้ายออก
- ย้าย Streak/Challenge/Milestone ออกจากหน้า Energy Store → มาที่ Quest Bar แทน

---

## 3. Daily Energy — ต้องมากด Claim

### การเปลี่ยนแปลง
| รายการ | เดิม | v3 |
|--------|------|-----|
| Check-in | อัตโนมัติเมื่อใช้ AI | **ต้องกด Claim ที่ Quest Bar** |
| Random Bonus | 5% chance +5-10E | **❌ ลบออก** |
| First Empty Bonus | +50E | **❌ ลบออก** |
| ต้องอ่าน Offer ก่อน | ไม่มี | **✅ ต้องปิด/อ่าน Offer ก่อน Claim** |

### Daily Energy ตาม Tier (ไม่เปลี่ยน)
| Tier | Daily Energy |
|------|-------------|
| Starter | +1E |
| Bronze | +1E |
| Silver | +2E |
| Gold | +3E |
| Diamond | +4E |

### Free AI
- 1 ครั้ง/วัน (ไม่สะสม) — ไม่เปลี่ยน

### Flow
```
เปิดแอป
    │
    ▼
Quest Bar แสดง Offer (ถ้ามี)
    │
    ├─ อ่าน/ปิด Offer ทั้งหมด
    │
    ▼
Quest Bar แสดง Streak + Claim Badge [+NE]
    │
    ├─ กด Claim
    │
    ▼
ได้ Daily Energy → Confetti → เช็ค Tier Up
    │
    ▼
ใช้ AI วิเคราะห์อาหาร (ใช้ 1 Free AI หรือ 1E)
    │
    ▼
Challenge Progress Update (Log Meals / Use AI)
```

---

## 4. Rewarded Ads — Safety Net เมื่อ Energy หมด

### แนวคิด
เมื่อ Energy = 0 และ Free AI ใช้หมดแล้ว แทนที่จะบล็อคผู้ใช้ → เสนอ **"ดูโฆษณาเพื่อวิเคราะห์ฟรี"**

### Business Impact
```
┌─────────────────────────────────────────────────────┐
│  1. 💰 Ad Revenue     eCPM จากโฆษณา Rewarded Video  │
│  2. 📱 Retention      ผู้ใช้ยังใช้แอปได้ ไม่ลบทิ้ง    │
│  3. 📊 Store Signal   High Reward Ad Engagement      │
│  4. 🎯 Purchase Push  ดู Ad บ่อย → รำคาญ → อยากซื้อ  │
└─────────────────────────────────────────────────────┘
```

### Spec

| รายการ | รายละเอียด |
|--------|------------|
| ปุ่ม | **"📺 ดูโฆษณา วิเคราะห์ฟรี"** (แสดงแทนปุ่ม Analyze เมื่อ Energy = 0 + Free AI หมด) |
| ประเภทโฆษณา | **Rewarded Video** (30 วินาที, ดูจบได้ reward) |
| Reward | 1 AI analysis ฟรี (ไม่ได้ Energy — ใช้ได้ทันทีครั้งเดียว) |
| จำกัด/วัน | **3 ครั้ง/วัน** |
| แสดงเมื่อ | Energy = 0 **และ** Free AI ใช้หมดแล้ว |
| ไม่แสดงเมื่อ | Subscriber (ไม่จำเป็น — AI ไม่จำกัดอยู่แล้ว) |
| Ad Provider | Google AdMob (Rewarded Ads) |
| Tracking | นับจำนวน ad views/วัน, conversion to purchase |

### User Flow

```
กดปุ่ม "Analyze" / ถ่ายรูปอาหาร
    │
    ▼
Energy > 0? ──── ใช่ ──▶ ใช้ 1E → วิเคราะห์ปกติ
    │
    ไม่ (Energy = 0)
    │
    ▼
Free AI เหลือ? ── ใช่ ──▶ ใช้ Free AI → วิเคราะห์ปกติ
    │
    ไม่ (หมดแล้ว)
    │
    ▼
Ad วันนี้ < 3? ── ใช่ ──▶ แสดงปุ่ม "📺 ดูโฆษณา วิเคราะห์ฟรี (เหลือ X ครั้ง)"
    │                              │
    │                         ผู้ใช้กดดู
    │                              │
    │                              ▼
    │                      Rewarded Video 30 วิ → ดูจบ → วิเคราะห์ฟรี
    │
    ไม่ (ดูครบ 3 ครั้งแล้ว)
    │
    ▼
แสดง: "Energy หมดแล้ว 😢"
      [ซื้อ Energy] [Subscribe $5/เดือน]
      ↑ แสดง $1=200E deal ถ้ายังไม่เคยซื้อ
```

### UI ที่หน้า Analyze (เมื่อ Energy = 0)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│    ⚡ Energy หมดแล้ว                             │
│                                                 │
│    ┌─────────────────────────────────────────┐  │
│    │  📺 ดูโฆษณา วิเคราะห์ฟรี (เหลือ 2/3)   │  │
│    └─────────────────────────────────────────┘  │
│                                                 │
│    ───────── หรือ ─────────                     │
│                                                 │
│    ┌─────────────────────────────────────────┐  │
│    │  🔥 200E แค่ $1! ⏰ 2:30:00             │  │
│    └─────────────────────────────────────────┘  │
│    ┌─────────────────────────────────────────┐  │
│    │  ⭐ Subscribe $5/เดือน — AI ไม่จำกัด    │  │
│    └─────────────────────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### ผลต่อ Monetization Funnel

```
ดู Ad 3 ครั้ง/วัน × หลายวัน
    │
    ▼
"เบื่อดูโฆษณาแล้ว ซื้อ $1 ดีกว่า" ← Friction → Purchase
    │
    ▼
200E หมดอีกรอบ → ดู Ad อีก
    │
    ▼
"เบื่อจริงๆ Subscribe $5 ดีกว่า ไม่ต้องคิดเรื่อง Energy" ← Upgrade
```

> **หลักการ:** Ad เป็น "ยาแก้ปวดชั่วคราว" ที่ทำให้ผู้ใช้ไม่ลบแอป  
> แต่ **ความรำคาญจากการดู Ad** คือแรงขับเคลื่อนให้ซื้อ — ดีกว่าการบล็อคซึ่งทำให้ลบแอป

### Edge Cases

| กรณี | การจัดการ |
|------|----------|
| **Ad No Fill (โหลดไม่ทัน)** | แสดงข้อความ "โฆษณายังไม่พร้อม กรุณาลองอีกครั้งในอีกสักครู่" — ห้ามค้างหน้าโหลดเปล่า, ห้ามเคลียร์โอกาสดู Ad ของผู้ใช้ (ยังเหลือ quota เท่าเดิม) |
| **ดู Ad ไม่จบ (ปิดกลางทาง)** | ไม่ได้ reward, ไม่นับ quota, แจ้ง "ดูโฆษณาไม่สำเร็จ ลองอีกครั้ง" |
| **Offline** | ซ่อนปุ่ม Ad, แสดงเฉพาะปุ่มซื้อ Energy |

### คุณภาพ AI จาก Ad
> **สำคัญ:** ผลวิเคราะห์จาก Ad-funded analysis ต้อง **แม่นยำและรวดเร็วเท่ากับการใช้ Energy ปกติ**  
> ไม่ลดคุณภาพ ไม่ช้าลง — เพื่อให้ผู้ใช้สัมผัสถึงความคุ้มค่าของ AI และอยากได้ Energy มาใช้แบบไหลลื่นไม่ต้องรอ Ad

### Revenue Estimate (Rewarded Video)

```
สมมติ:
- DAU ที่ Energy หมด: 30% ของ DAU ทั้งหมด
- เฉลี่ยดู 2 ads/วัน/คน
- eCPM (Thailand): ~$3-5 per 1,000 views

ถ้า DAU = 1,000 คน:
  300 คน × 2 ads × 30 วัน = 18,000 ad views/เดือน
  Revenue: 18,000 ÷ 1,000 × $4 = ~$72/เดือน

ถ้า DAU = 10,000 คน:
  Revenue: ~$720/เดือน (passive income เสริม)
```

---

## 5. Streak & Tier System

### Tier Levels & Benefits

| Tier | Streak ที่ต้องการ | Daily Energy | Purchase Bonus | Grace Period | Upgrade Reward (1 time) |
|------|-----------------|--------------|----------------|--------------|------------------------|
| Starter | 0 วัน | +1E | 0% | 0 วัน | — |
| Bronze | 7 วัน | +1E | 0% | 0 วัน | **+5E** |
| Silver | 14 วัน | +2E | 0% | 1 วัน | **+10E** |
| Gold | 30 วัน | +3E | +10% | 1 วัน | **+15E** |
| Diamond | 60 วัน | +4E | +20% | 1 วัน | **+25E** |

> **รวม Tier Upgrade Reward ตลอดชีพ: 55E** (1 time per tier per user)

### Streak Break & Recovery
```
Diamond (60+ วัน) ─── miss 2 วัน ──▶ Gold (streak → 30)
Gold (30+ วัน)    ─── miss 2 วัน ──▶ Silver (streak → 14)
Silver (14+ วัน)  ─── miss 2 วัน ──▶ Bronze (streak → 7)
Bronze (7+ วัน)   ─── miss 1 วัน ──▶ Starter (streak → 0)

Ex-Diamond ตกไป Starter/Bronze → Trigger "Welcome Back Offer"
```

### Tier Up Flow (ใน Quest Bar)
```
กด Claim Daily Energy
    │
    ▼
เช็ค: streak >= tier ถัดไป?
    │
    ├─ ใช่ → 🎆 Confetti Overlay 2 วิ
    │         "🎉 ยินดีด้วย! คุณเลื่อนเป็น [Tier]!"
    │         "Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!"
    │         + ได้ Tier Reward (+5/10/15/25E)
    │              │
    │              ▼
    │         แสดง Special Tier Offer (20% Bonus, 24hr)
    │
    ├─ ไม่ → แสดง Streak ปกติ
```

---

## 6. Milestone System — Diminishing Cashback

### สูตรคำนวณ (RPG-style Inverse Square Root Decay)

```
reward = round_nice(3 × √(milestone ÷ 10))
cashback% = reward ÷ milestone × 100
```

ยิ่ง milestone สูง → cashback% ยิ่งต่ำ (เหมือน XP curve ในเกม RPG)

### ตาราง Milestone (10 ขั้น, cap ที่ 10,000E)

| # | Milestone (E spent) | Reward | Cashback % | Reward สะสม | แสดงเมื่อ |
|---|---------------------|--------|-----------|-------------|----------|
| 1 | 10 | 3E | 30.0% | 3E | เริ่มต้น |
| 2 | 25 | 5E | 20.0% | 8E | ผ่าน #1 |
| 3 | 50 | 7E | 14.0% | 15E | ผ่าน #2 |
| 4 | 100 | 10E | 10.0% | 25E | ผ่าน #3 |
| 5 | 250 | 15E | 6.0% | 40E | ผ่าน #4 |
| 6 | 500 | 20E | 4.0% | 60E | ผ่าน #5 |
| 7 | 1,000 | 30E | 3.0% | 90E | ผ่าน #6 |
| 8 | 2,500 | 50E | 2.0% | 140E | ผ่าน #7 |
| 9 | 5,000 | 65E | 1.3% | 205E | ผ่าน #8 |
| 10 | 10,000 | 100E | 1.0% | **305E** | ผ่าน #9 |

> **สรุป: ใช้ 10,000E ตลอดชีพ → ได้คืน 305E = 3.05%** — ไม่เกิด Energy Inflation

### การแสดงผล (Progressive Reveal)
- แสดงทีละ 1 milestone ถัดไปเท่านั้น (milestone ที่ยังไม่ผ่าน)
- milestone ที่ยังไม่ unlock แสดงเป็น 🔒
- เมื่อผ่าน milestone → animation → reveal milestone ถัดไป

### Milestone Triggers
- **Milestone #1 (10E spent):** → Trigger $1 = 200E Offer (4 ชม.)
- **Milestone #3 (50E spent):** → Trigger Subscription Upsell ($5/mo + 1 เดือนฟรี)

---

## 7. Weekly Challenges

| Challenge | เป้าหมาย | รางวัล |
|-----------|---------|--------|
| Log Meals | บันทึกอาหาร 7 มื้อ | **+3E** |
| Use AI | ใช้ AI วิเคราะห์ 3 ครั้ง | **+3E** |

- **Reset:** ทุกวันจันทร์ 00:00 (UTC+7)
- **รวมสูงสุด/สัปดาห์:** **6E** (ทุกคนเท่ากัน, ไม่มี Subscriber bonus)
- **ตำแหน่ง UI:** Quest Bar (collapsible section)

---

## 8. Offer & Promotion — จังหวะขาย

### 7.1 Promotion Timeline

```
สมัคร          ใช้ 10E (MS#1)      ทันที 4hr         ซื้อ $1 แล้ว
   │                │                  │                  │
   ▼                ▼                  ▼                  ▼
Welcome Gift    Milestone #1       $1 = 200E         40% Bonus
+10E ฟรี        +3E cashback      First Purchase     on purchase
                                   4hr / 1 time      24hr / 1 time

Tier Upgrade           Milestone #3 (50E)        Ex-Diamond ตก
   │                        │                        │
   ▼                        ▼                        ▼
Tier Promo              Sub Upsell               Welcome Back
+5/10/15/25E            $5/mo + 1mo FREE         Sub $3 first mo
20% Bonus 24hr          1 time                    1 time
per tier / 1 time
```

### 7.2 รายละเอียด Promotion

| # | Promotion | Trigger | รางวัล/Offer | ระยะเวลา | จำกัด |
|---|-----------|---------|-------------|----------|-------|
| 1 | Welcome Gift | สมัคร | +10E ฟรี | ทันที | 1 ครั้ง/บัญชี |
| 2 | Milestone Cashback | ใช้ E ครบ threshold | +3~100E (ตามสูตร) | ทันที | 1 ครั้ง/milestone |
| 3 | **🔥 $1 = 200E** | ผ่าน Milestone 10E | 200E ราคา $1 | **4 ชม.** | **1 ครั้ง/บัญชี** |
| 4 | **40% Bonus** | หลังซื้อ $1 Offer | ซื้อ package ได้ +40% bonus | **24 ชม.** | **1 ครั้ง/บัญชี** |
| 5 | Tier Upgrade | เลื่อน Tier | +5/10/15/25E + 20% bonus 24hr | 24 ชม. | 1 ครั้ง/tier |
| 6 | Sub Upsell | Milestone 50E | $5/mo + 1 เดือนฟรี | ไม่หมดอายุ | 1 ครั้ง |
| 7 | Welcome Back | Ex-Diamond ตก Starter/Bronze | Sub $3 เดือนแรก | 24 ชม. | 1 ครั้ง |

### 7.3 ทำไม $1 = 200E ถึงคุ้ม (Business Logic)

```
เป้าหมาย: ทำลายกำแพงการจ่ายครั้งแรก (First Purchase Barrier)

ต้นทุน:    ~$2 (มูลค่า 200E ราคาปกติ)
ได้คืน:    • App Store Conversion Rate สูงขึ้น → ranking ดีขึ้น
           • ผู้ใช้ที่จ่ายครั้งแรกแล้ว → จ่ายซ้ำง่ายกว่า 5-10x
           • ตามด้วย 40% Bonus Offer → อาจซื้อทันทีอีกรายการ
           • 2 purchases ติดกัน → App Store เห็นว่า high purchase intent
           • ถูกกว่าค่าโฆษณา (CPI เฉลี่ย $2-5/คน)
           • 200E พอให้ใช้ ~3-6 สัปดาห์ แล้วต้องกลับมาซื้ออีก
```

### 7.4 Energy Packages (ราคาปกติ)

| Package | Energy | ราคา | E/$ |
|---------|--------|------|-----|
| Starter Pack | 100E | $0.99 | 101 |
| Value Pack | 550E | $4.99 | 110 |
| Pro Pack | 1,200E | $9.99 | 120 |
| Ultimate Pack | 2,000E | $14.99 | 133 |

> **Bonus คำนวณ:** `ได้จริง = Energy × (1 + max(tierBonus, promoBonus))`  
> เช่น Gold + 40% Offer: 550E × 1.40 = 770E

---

## 9. Energy Pass (Subscription)

### แผนราคา

| Plan | ราคา | ต่อเดือน | ประหยัด |
|------|------|---------|---------|
| Weekly | $2/สัปดาห์ | ~$8.67/mo | — |
| **Monthly** | **$5/เดือน** | $5/mo | 42% vs Weekly |
| **Yearly** | **$40/ปี** | $3.33/mo | **62% vs Weekly** |

### Benefits

| Benefit | รายละเอียด |
|---------|------------|
| ✅ Unlimited AI | ใช้ AI วิเคราะห์อาหารไม่เสีย Energy |
| ✅ Badge พิเศษ | แสดงใน Profile |
| ✅ Priority Support | — |
| ✅ ยังเคลม Reward ได้ | Daily Energy, Milestone, Tier Reward — ได้หมด |

> **Subscriber Energy ไม่ลดเมื่อใช้ AI แต่ยังเคลมรางวัลต่างๆ ได้ปกติ**

### Subscription Upsell จังหวะ

| Trigger | Offer | ครั้งเดียว? |
|---------|-------|------------|
| Milestone 50E spent | $5/mo + **1 เดือนฟรี** | ✅ |
| Energy < 5 + ต้องการ AI | แสดง Sub option ในหน้าซื้อ | ❌ (ทุกครั้ง) |
| Gold/Diamond tier | Soft upsell ใน Quest Bar | ❌ |

### Winback (Ex-Subscriber)

| เงื่อนไข | Offer |
|----------|-------|
| Unsubscribe > 7 วัน | **$3 เดือนแรก** (Promotional Price) |

---

## 10. Referral System

### Two-Way Referral

| ฝ่าย | ได้ | เงื่อนไข |
|------|-----|---------|
| ผู้ชวน | +5E | เพื่อนใช้ Energy ครบ 10E |
| เพื่อนที่ถูกชวน | +5E | ใช้ Energy ครบ 10E |

### UI
- อยู่ใน Quest Bar (ล่างสุดของ collapsible section)
- แสดงเป็นลิงค์เล็กๆ: **"👥 ชวนเพื่อนได้ 5E"**
- กด → แชร์ลิงค์ผ่าน native share (Line, Messenger, Email, etc.)
- ลิงค์เป็น Dynamic Link → เปิดแอปหรือ Store

---

## 11. Push Notifications

### เฉพาะ 3 กรณีเท่านั้น (ไม่ spam)

| # | กรณี | เวลาส่ง | ข้อความ |
|---|------|---------|---------|
| 1 | **Offer ใกล้หมด** | 1 ชม. ก่อนหมดอายุ | "⏰ โปรพิเศษกำลังจะหมด! เหลือเวลาอีก 1 ชั่วโมง" |
| 2 | **ยังไม่ Login** | 21:00 (3 ทุ่ม) | "ลืม log หรือเปล่า? Streak จะหาย! 🔥 Daily reward รอคุณอยู่" |
| 3 | **Tier Up** | ทันทีที่ Tier Up | "🎉 ยินดีด้วย! คุณเลื่อนเป็น [Tier]! Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!" |

---

## 12. Admin Marketing Dashboard

### มีอยู่แล้ว ✅

| หมวด | ฟีเจอร์ |
|------|---------|
| User Management | ดูข้อมูล User, ปรับ Balance, Ban |
| Config | ตั้งค่า Daily Rewards, Challenges, Milestones, Promotions |
| Analytics | Streak Distribution, User Growth, Subscription Metrics |
| Fraud | Fraud Detection |

### ต้องเพิ่ม (สูง + กลาง)

| Priority | หมวด | ฟีเจอร์ |
|----------|------|---------|
| 🔴 สูง | Analytics | Promotion Conversion Rate |
| 🔴 สูง | Analytics | Revenue per User (ARPU) |
| 🔴 สูง | Analytics | Energy Purchase Funnel |
| 🔴 สูง | Campaign | สร้าง Flash Sale / Custom Promo |
| 🔴 สูง | Campaign | Push Notification Campaign |
| 🟡 กลาง | Analytics | Tier Distribution Chart |
| 🟡 กลาง | Analytics | Daily/Weekly Active Users |
| 🟡 กลาง | Campaign | A/B Test Management UI |
| 🟡 กลาง | Campaign | Scheduled Promotion |
| 🟡 กลาง | Retention | Churn Risk Users List |
| 🟡 กลาง | Retention | Re-engagement Campaign |
| 🟡 กลาง | Content | In-App Banner Management |

> ส่วนนี้จะทำเป็น spec MD แยก สำหรับ senior แจกงานให้ junior

---

## 13. Bug Fixes ที่ต้องทำ

| # | Bug | รายละเอียด | Priority |
|---|-----|-----------|----------|
| 1 | **Offer ซื้อซ้ำได้ไม่จำกัด** | Promotion offer ซื้อได้เรื่อยๆจนหมดเวลา ต้องล็อค 1 ครั้ง/บัญชี | 🔴 Critical |

### แก้ไข:
- **Backend:** เพิ่ม flag `firstPurchaseOfferClaimed: true` ใน user doc → check ก่อน process
- **Frontend:** disable ปุ่มซื้อหลังจากซื้อสำเร็จ
- **Apply กับทุก Offer:** $1 Offer, 40% Bonus, Tier Promo

---

## 14. Appendix: ตัวเลข & สูตรคำนวณ

### สูตร Milestone Reward (Diminishing Cashback)

```
reward(m) = round_nice(3 × √(m ÷ 10))

โดย round_nice() ปัดเป็นเลขสวย (1, 3, 5, 7, 10, 15, 20, 30, 50, 65, 100)
```

**กราฟ Cashback %:**
```
30% │ ●
    │
20% │   ●
    │
14% │     ●
10% │       ●
 6% │          ●
 4% │            ●
 3% │              ●
 2% │                ●
 1% │                   ●  ●
    └──┬──┬──┬──┬──┬──┬──┬──┬──┬──▶ Energy Spent
      10 25 50 100 250 500 1K 2.5K 5K 10K
```

### Income vs Cost รายสัปดาห์

**รายรับ/สัปดาห์:**
| แหล่ง | Starter | Bronze | Silver | Gold | Diamond |
|-------|---------|--------|--------|------|---------|
| Daily × 7 | 7E | 7E | 14E | 21E | 28E |
| Challenges | 6E | 6E | 6E | 6E | 6E |
| Free AI | 7 saves | 7 saves | 7 saves | 7 saves | 7 saves |
| **รวม/สัปดาห์** | **20E** | **20E** | **27E** | **34E** | **41E** |

**Net รายสัปดาห์ (Income - Cost):**
| ใช้/วัน | Starter | Bronze | Silver | Gold | Diamond |
|--------|---------|--------|--------|------|---------|
| 3/วัน (21E) | **-1E** ≈ 0 | -1E | +6E ✅ | +13E | +20E |
| 4/วัน (28E) | **-8E** 📉 | -8E | -1E ≈ 0 | +6E | +13E |
| 5/วัน (35E) | **-15E** 🔴 | -15E | -8E | -1E ≈ 0 | +6E |
| 7/วัน (49E) | **-29E** 💀 | -29E | -22E | -15E | -8E |

> **เมื่อ Energy = 0:** ไม่บล็อค → ผู้ใช้ได้ 1 Free AI + 3 Rewarded Ads = **4 analyses/วัน** (แต่ต้องดูโฆษณา 30 วิ ต่อครั้ง)

### Persona Simulation Summary (Balanced v3)

**ขี้เหนียว 5 ครั้ง/วัน:**
```
วันที่ 1-5:   สบาย (Welcome Gift + Challenge)
วันที่ 6:     ⚠️ เริ่มร้อน (เหลือ 1E)
วันที่ 7:     ✅ Bronze +5E + MS#2 +5E → ชุบชีวิต
วันที่ 11-13: 🔴 Energy หมด → ใช้ 1 Free AI + 3 Ads = 4 ครั้ง (ยังใช้ได้ แต่ต้องดู Ad)
วันที่ 14:    ✅ Silver +10E → ชุบชีวิตครั้งสุดท้าย
วันที่ 15-28: 📉 ค่อยๆ ลด ~1E/วัน (สลับใช้ Ad เป็นระยะ)
วันที่ ~30:   📺 ต้องดู Ad ทุกวัน → "เบื่อแล้ว ซื้อ $1 ดีกว่า"
```

**Budget $5/เดือน:**
```
วันที่ 2-3:   ซื้อ $1 = 200E → อยู่ได้ ~3-6 สัปดาห์
สัปดาห์ 4-6:  เริ่มร้อนอีก → ซื้อ Package หรือ Subscribe
Revenue:      $1 + $5/เดือน = ~$6-7/เดือน
```

**ลดจริงจัง 7+ ครั้ง/วัน:**
```
วันที่ 2:     หมด → ดู Ad 3 ครั้ง (ใช้ได้ 4/วัน = ไม่พอ!)
              "แค่ $1 เอง ซื้อเลย" → $1 = 200E
วันที่ 2:     ซื้อ 40% Bonus → Value Pack $5 → 770E
สัปดาห์ 3-4:  Energy ร้อน → Subscribe $5/เดือน
Revenue:      $6 + $5/เดือน = ~$36/ปีแรก
```

### สิ่งที่ลบ/เปลี่ยนจากระบบเดิม

| รายการ | เดิม | v3 Balanced |
|--------|------|-------------|
| Random Daily Bonus | 5% chance +5-10E | ❌ ลบ |
| First Empty Bonus | +50E | ❌ ลบ |
| Welcome Offer | +50E ฟรี + 40% OFF | Milestone +3E + $1=200E |
| Challenge reward | 5E × 2 = 10E/wk | **3E × 2 = 6E/wk** |
| Tier Upgrade Reward | 3/5/10/15E = 33E | **5/10/15/25E = 55E** |
| $1 Deal | ไม่มี | **$1 = 200E (ใหม่)** |
| Double Quest (Sub) | 2x rewards | ❌ ลบ |
| Subscription | ฿149/mo only | **$2/wk, $5/mo, $40/yr** |
| Rewarded Ads | ไม่มี | **📺 ดู Ad = 1 Free AI, 3 ครั้ง/วัน** |
| Offer ซื้อซ้ำ | ซื้อได้เรื่อยๆ (bug) | **1 ครั้ง/บัญชี (fix)** |

---

> **Next Steps (อัปเดต 20 ก.พ. 2026):**
>
> **เสร็จแล้ว ✅:**
> 1. ~~🐛 แก้ Bug: Offer ซื้อซ้ำ~~ ✅
> 2. ~~📺 Integrate Google AdMob Rewarded Ads (Code)~~ ✅
> 3. ~~🎯 Implement Quest Bar UI~~ ✅
> 4. ~~📊 ปรับ Milestone system (Backend 10 ขั้น)~~ ✅
> 5. ~~🏆 ปรับ Tier Upgrade Reward (Backend 5/10/15/25E)~~ ✅
> 6. ~~🎮 ปรับ Challenge reward (Backend 3E × 2)~~ ✅
> 7. ~~❌ ลบ: Random Bonus, First Empty Bonus, Double Quest (Backend)~~ ✅
> 8. ~~🔔 Push Notification (3 กรณี)~~ ✅
> 9. ~~👥 Referral two-way~~ ✅
> 10. ~~📱 Admin Dashboard (Phase 1: User Management)~~ ✅
>
> **ต้องทำต่อ 🔲:**
> 1. 🔧 **Frontend Fixlist (F1-F7)** — ปรับค่า/ลบของเก่าใน Frontend ให้ตรง v3 (~5-6 ชม.)
> 2. ~~💰 **Owner: สร้าง IAP** — $1/200E, $2/week, $40/year ใน Google Play Console~~ ✅
> 3. ~~📺 **Owner: สร้าง AdMob Ad Unit** — Rewarded Ad Unit ID + SSV Callback~~ ✅
> 4. 🚀 **Deploy & Rollout** — ตาม MIGRATION_ROLLOUT_PLAN.md
> 5. 📊 **Admin Dashboard Phase 2-4** — Analytics, Campaigns, Advanced features
