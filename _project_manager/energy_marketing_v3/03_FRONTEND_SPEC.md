# Frontend Spec — Flutter

> **สำหรับ:** Junior Developer  
> **Stack:** Flutter + Riverpod  
> **อ้างอิง:** `_project_manager/ENERGY_MARKETING_BLUEPRINT.md`

---

## #1 — Quest Bar UI (หน้า Home)

### ตำแหน่ง
`lib/features/home/presentation/home_screen.dart` — เพิ่ม widget ใต้ "Analyze All"

### Widget ใหม่
`lib/features/energy/widgets/quest_bar.dart`

### Spec

**ขนาด:** 1 row (height ~56-64dp), full width, padding 16dp

**State 1: มี Offer**
```
┌─────────────────────────────────────────────────┐
│ 🔥 [Offer text] ⏰ [countdown]                → │
└─────────────────────────────────────────────────┘
```
- Background: gradient (ส้ม/แดง สำหรับ urgent, น้ำเงิน/ม่วง สำหรับ normal)
- Icon ซ้าย: 🔥 หรือ ⚡ ตาม offer type
- Text: ชื่อ offer + countdown timer (HH:MM:SS)
- Arrow ขวา: `→` indicating tappable
- **Tap:** เปิด Offer detail bottom sheet
- **Swipe left:** ซ่อน offer → แสดง Snackbar ด้านล่าง

**State 2: ไม่มี Offer (แสดง Streak + Claim)**
```
┌─────────────────────────────────────────────────┐
│ 🥉 Streak 12 วัน ━━━━━●━━━ 🥈 อีก 2 วัน [+2E]│
└─────────────────────────────────────────────────┘
```
- Tier icon ซ้าย (current tier)
- Progress bar ตรงกลาง (streak → next tier)
- Tier icon ขวา (next tier target)
- Text: "อีก X วัน"
- **Claim Badge** `[+NE]` — สีเขียว, pulse animation ถ้า claimable
- Badge ปรากฏเฉพาะเมื่อ **ทุก Offer ถูกปิด/อ่านแล้ว**

**Swipe Behavior:**
- มี Offer → ปัดซ้าย = ซ่อน Offer ปัจจุบัน
- ถ้ามี Offer อีกอัน → แสดง Offer ถัดไป
- ถ้าไม่มี Offer เหลือ → แสดง Streak + Claim

**Collapsible (Tap บน Streak bar):**
- Expand ลง (AnimatedContainer) แสดง:
  1. Active Offers (พร้อม countdown) — ถ้ามี
  2. Weekly Challenges (progress bars)
  3. Milestone ถัดไป (progress bar + 🔒 ถัดไป)
  4. ลิงค์ Referral "👥 ชวนเพื่อนได้ 5E"

### Provider
`lib/features/energy/providers/quest_bar_provider.dart`
```dart
class QuestBarState {
  final List<OfferData> activeOffers;
  final int dismissedOfferCount;
  final bool allOffersDismissed;
  final int claimableEnergy;
  final bool canClaim; // true เมื่อ allOffersDismissed && ยังไม่ claim วันนี้
  final int currentStreak;
  final String currentTier;
  final String nextTier;
  final int daysToNextTier;
  final List<ChallengeProgress> challenges;
  final MilestoneProgress currentMilestone;
}
```

### สิ่งที่ต้องย้ายออก
- ย้าย Streak display, Challenge cards, Milestone cards ออกจาก Energy Store screen
- Energy Store screen เหลือแค่ Energy balance + Purchase packages

---

## #2 — Daily Claim + Confetti

### Widget
`lib/features/energy/widgets/claim_button.dart`

### Flow
```
กด Claim Badge [+NE]
    │
    ▼
เรียก API: claimDailyEnergy
    │
    ▼
สำเร็จ → Confetti animation 2 วิ (ใช้ package: confetti)
    │
    ▼
อัพเดท balance แสดงในแอป
    │
    ▼
เช็ค tierUpgraded → ถ้าใช่ → Tier Up Overlay (#3)
```

### Animation
- ใช้ package `confetti` หรือ custom Lottie animation
- ระยะเวลา: 2 วินาที
- พลุระเบิดจากตรงกลาง + ตัวเลข "+NE" ลอยขึ้นแล้ว fade out

### Dependencies
- package: `confetti: ^0.7.0` หรือ `lottie: ^3.0.0`

---

## #3 — Tier Up Overlay

### Widget
`lib/features/energy/widgets/tier_up_overlay.dart`

### Flow
```
Tier Upgrade detected จาก API response
    │
    ▼
แสดง Full-screen overlay (semi-transparent background)
    │
    ├─ Icon Tier ใหม่ (ใหญ่, มี glow animation)
    ├─ "🎉 ยินดีด้วย!"
    ├─ "คุณเลื่อนเป็น [Tier Name]!"
    ├─ "Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!"
    ├─ "+[N]E Reward!" (ตัวเลขใหญ่ สีทอง)
    │
    ▼
Auto-dismiss หลัง 3 วิ หรือ tap anywhere
    │
    ▼
แสดง Tier Special Offer (20% bonus, 24hr)
```

### Design
- Background: สีเข้ม semi-transparent
- Tier icon: ใหญ่ตรงกลาง + particle effect
- Text: สีขาว, font ใหญ่
- Reward number: สีทอง, bounce animation

---

## #4 — Rewarded Ads (AdMob)

### Package
`google_mobile_ads: ^5.0.0` (ตรวจสอบเวอร์ชันล่าสุด)

### Setup
```dart
// lib/core/services/ad_service.dart
class AdService {
  RewardedAd? _rewardedAd;
  int _adsWatchedToday = 0;
  static const maxAdsPerDay = 3;
  
  bool get canWatchAd => _adsWatchedToday < maxAdsPerDay;
  int get remainingAds => maxAdsPerDay - _adsWatchedToday;
}
```

### UI ที่หน้า Analyze (เมื่อ Energy = 0)
**ไฟล์:** `lib/features/camera/presentation/camera_screen.dart` หรือที่กดปุ่ม Analyze

```
เมื่อ Energy = 0 && Free AI หมด:
┌─────────────────────────────────────────────────┐
│    ⚡ Energy หมดแล้ว                             │
│                                                 │
│    [📺 ดูโฆษณา วิเคราะห์ฟรี (เหลือ X/3)]       │
│                                                 │
│    ───────── หรือ ─────────                     │
│                                                 │
│    [🔥 200E แค่ $1! ⏰ countdown]               │  ← ถ้ามี offer
│    [⭐ Subscribe $5/เดือน — AI ไม่จำกัด]        │
└─────────────────────────────────────────────────┘
```

### Edge Cases
| กรณี | UI |
|------|-----|
| Ad โหลดไม่ทัน (No Fill) | "โฆษณายังไม่พร้อม กรุณาลองอีกครั้งในอีกสักครู่" + ปุ่ม Retry |
| ดูไม่จบ (ปิดกลางทาง) | "ดูโฆษณาไม่สำเร็จ ลองอีกครั้ง" — ไม่นับ quota |
| ดูครบ 3 ครั้ง | ซ่อนปุ่ม Ad, แสดงเฉพาะปุ่มซื้อ |
| Offline | ซ่อนปุ่ม Ad |
| Subscriber | ไม่แสดงระบบ Ad เลย |

### Quality
- AI analysis จาก Ad-funded **ต้องเหมือนกับใช้ Energy ปกติทุกประการ**
- ไม่ลดคุณภาพ ไม่ช้าลง ไม่จำกัดผลลัพธ์

### Pre-loading
- Pre-load rewarded ad เมื่อเปิดแอป (background)
- เมื่อดู ad จบ → load ad ถัดไปทันที
- ลด wait time ให้ผู้ใช้

---

## #5 — Offer Snackbar (ปัดซ้าย)

### Widget
`lib/features/energy/widgets/offer_snackbar.dart`

### Behavior
```
ปัดซ้ายที่ Quest Bar (Offer)
    │
    ▼
Offer slide out → แสดง Snackbar ด้านล่างหน้าจอ
    │
    ├─ "[Offer name] — กดเพื่อดู"
    ├─ ค้างอยู่จนกว่าจะ:
    │   ├─ ปัดซ้ายอีกครั้ง → dismiss ถาวร
    │   └─ กด "ดู" → เปิด Offer detail
    │
    ▼
คล้าย ScaffoldMessenger.showSnackBar แต่ persistent (ไม่ auto-dismiss)
```

### Design
- คล้ายกับ Snackbar ตอนลบรายการอาหาร (consistency)
- มีปุ่ม "ดู Offer" ทางขวา
- สี: เทาเข้ม + text ขาว

---

## #6 — Milestone Progressive UI

### Widget
`lib/features/energy/widgets/milestone_progress_card.dart` (แก้ไขของเดิม)

### แสดงใน Quest Bar Collapsible

```
🏆 Milestones
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ใช้ Energy ครบ 100 (82/100)  [━━━━━━━░░░]  +10E
ถัดไป: 250E                   🔒
```

### Logic
- แสดงเฉพาะ **milestone ปัจจุบัน** (ที่กำลังทำ) + ถัดไป (🔒)
- เมื่อผ่าน milestone → animation celebration → reveal ถัดไป
- Progress bar แสดง `totalSpent / nextThreshold`
- Badge แสดง reward ที่จะได้ "+NE"

---

## #7 — Subscription Plans UI

### ไฟล์
`lib/features/subscription/presentation/subscription_screen.dart`

### เปลี่ยน
- **เดิม:** แสดง 1 plan (Monthly ฿149)
- **ใหม่:** แสดง 3 plans

```
┌─────────────────────────────────────────────────┐
│  Weekly        $2/สัปดาห์                        │
│                                                 │
│  Monthly ⭐    $5/เดือน         ← RECOMMENDED   │
│  BEST VALUE    ประหยัด 42%                      │
│                                                 │
│  Yearly        $40/ปี                            │
│                ประหยัด 62%                       │
│                เฉลี่ย $3.33/เดือน                 │
└─────────────────────────────────────────────────┘
```

### Benefits ที่แสดง
- ✅ AI ไม่จำกัด
- ✅ Badge พิเศษ
- ✅ Priority Support
- ✅ ยังเคลม Reward ได้

### ลบออก
- ~~Double Quest Reward~~ (ไม่แสดงแล้ว)

### Upsell Trigger (Milestone 50E)
- เมื่อ milestone 50E สำเร็จ → แสดง bottom sheet:
  - "🎉 ใช้ Energy ครบ 50 แล้ว!"
  - "ลองใช้ Energy Pass — AI ไม่จำกัด"
  - "$5/เดือน + 1 เดือนแรกฟรี!"
  - [เริ่มทดลอง] [ไว้ก่อน]
- 1 ครั้ง/บัญชี

### Winback UI
- เมื่อ `winbackOfferAvailable == true`
- แสดง banner หน้า home หรือ bottom sheet:
  - "กลับมาใช้ MiRO! Energy Pass เดือนแรกแค่ $3"
  - [Subscribe $3] [ไว้ก่อน]

---

## #8 — Push Notification Handling

### Package
ใช้ `firebase_messaging` ที่มีอยู่แล้ว

### Handler
`lib/core/services/notification_service.dart`

```dart
void handleNotification(RemoteMessage message) {
  switch (message.data['type']) {
    case 'offer_expiry':
      // Navigate ไป Quest Bar / Offer detail
      break;
    case 'streak_reminder':
      // Navigate ไป Home (Quest Bar จะแสดง Claim)
      break;
    case 'tier_up':
      // Navigate ไป Home (จะเห็น Tier Up overlay ถ้ายังไม่เคยเห็น)
      break;
  }
}
```

### Foreground Notification
- แสดงเป็น local notification (ไม่ใช่ in-app dialog)
- Tap → navigate ตาม type

---

## Localization

ทุก text ต้องอยู่ใน `lib/l10n/app_en.arb` และ `app_th.arb`

### ตัวอย่าง Keys ที่ต้องเพิ่ม
```json
{
  "questBarOfferTitle": "Special Offer!",
  "questBarStreakDays": "Streak {days} days",
  "questBarDaysToNext": "{days} more days to {tier}",
  "questBarClaimEnergy": "+{amount}E",
  "tierUpCongrats": "Congratulations!",
  "tierUpMessage": "You've reached {tier}!",
  "tierUpMotivation": "Great job tracking calories! Your dream body is getting closer!",
  "adWatchButton": "Watch ad for free analysis ({remaining}/{max})",
  "adNotReady": "Ad not ready yet, please try again shortly",
  "adFailed": "Ad didn't complete, try again",
  "energyEmpty": "Energy depleted",
  "milestoneReached": "Milestone reached! +{reward}E",
  "referralInvite": "Invite friends, get 5E",
  "subscribeMonthly": "Subscribe ${price}/month — Unlimited AI",
  "winbackOffer": "Come back to MiRO! First month only ${price}"
}
```
