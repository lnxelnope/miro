# Welcome Strategy Update — Energy System Changes

**Date:** February 17, 2026  
**Status:** ✅ Implemented  
**Impact:** Improves conversion funnel by reducing friction and demonstrating value before asking for purchase

---

## Overview

Changed the welcome gift and monetization strategy to improve user acquisition and conversion:

**OLD Strategy:**
- Welcome Gift: 100 Energy
- Welcome Offer: Triggered after 10 AI uses

**NEW Strategy:**
- Welcome Gift: 10 Energy (to try the app)
- First Empty Bonus: 50 Energy + Welcome Offer unlock (when running out for first time)
- Welcome Offer: 40% OFF for 24 hours (one-time, lifetime deal)

---

## Why This Change?

### Problem with Old Strategy
- 100 Energy was TOO generous → users might never need to buy
- Users downloaded the app but didn't convert → free tier was too comfortable
- No urgency to purchase

### Solution: New Strategy
1. **Lower initial gift (10 Energy)** → Users experience value but need more
2. **"First Empty" moment** → Perfect timing to offer bonus + discount
   - User has already used the app (proven value)
   - User needs more Energy (moment of desire)
   - Bonus 50 Energy → immediate relief + goodwill
   - 40% OFF → urgency (24h) + scarcity (one-time only)

### Expected Outcomes
- ✅ More downloads (still free to start)
- ✅ Higher conversion rate (offer at perfect timing)
- ✅ Better LTV (users who buy once are likely to buy again)
- ✅ User feels rewarded, not pressured

---

## Technical Implementation

### Files Changed

#### 1. Backend (`functions/src/registerUser.ts`)
```typescript
const WELCOME_GIFT = 10; // Changed from 100
```

#### 2. Energy Service (`lib/core/services/energy_service.dart`)
- Changed `welcomeGift = 10` (from 100)
- Added `checkAndHandleFirstEnergyEmpty()` method
- Added `firstTimeBonus = 50`
- Removed old AI usage counting logic

#### 3. Welcome Offer Service (`lib/core/services/welcome_offer_service.dart`)
- Updated trigger description (now triggered by first energy empty, not AI usage count)
- Deprecated old AI usage counting methods

#### 4. No Energy Dialog (`lib/features/energy/widgets/no_energy_dialog.dart`)
- Now checks for first-time bonus on display
- If first time empty → grants 50 Energy + shows Welcome Offer
- Uses `ConsumerStatefulWidget` for state management

#### 5. Welcome Offer Dialog (`lib/features/energy/widgets/welcome_offer_unlocked_dialog.dart`)
- Updated messaging to reflect new trigger
- Changed from "You've used AI 10 times!" to "Out of Energy? We gave you 50 Energy FREE + 40% OFF"

#### 6. App Icons (`lib/core/theme/app_icons.dart`)
- Added `discount` icon for UI consistency

#### 7. Marketing Doc (`_project_manager/MARKETING_FEATURES_SUMMARY.md`)
- Updated Welcome Gift: 100 → 10 Energy
- Added First Empty Bonus section
- Updated Welcome Offer description
- Updated monetization summary table

---

## User Flow

### New User Journey

```
1. Download app → Get 10 Energy FREE ✅
   ↓
2. Use AI to analyze food (10 times max)
   ↓
3. Energy runs out (0 remaining)
   ↓
4. "Out of Energy" dialog appears
   ↓
5. App checks: First time empty? YES
   ↓
6. 🎉 Grant 50 Energy + Unlock Welcome Offer (40% OFF - 24h)
   ↓
7. Show "Welcome Offer Unlocked!" dialog
   ↓
8. User can:
   - Use the 50 Energy (buy later)
   - Buy Energy now at 40% OFF (limited time)
   - Do nothing and continue manually logging
```

### Subsequent "Out of Energy" (if they run out again)
- No bonus
- Just the normal "Out of Energy" dialog → Buy Energy or log manually

---

## Key Features

### First Empty Bonus
- **Trigger:** Energy = 0 (first time only)
- **Reward:** 50 Energy + Welcome Offer unlock
- **Storage:** `first_energy_empty_handled` flag in SharedPreferences
- **One-time:** Per device (uses device ID)

### Welcome Offer (40% OFF)
- **Duration:** 24 hours from unlock
- **Scope:** All Energy packages discounted
- **Limit:** Can purchase ONE package only during this window (lifetime deal)
- **Tracking:** Uses existing Welcome Offer Service infrastructure

---

## Backend Considerations

### registerUser Function
- Now grants 10 Energy instead of 100
- Migration: Existing users with 100 Energy are unaffected (data remains)

### Future Backend Update Needed
- Consider syncing "first_energy_empty_handled" flag to backend
- Currently stored locally only (device-specific)

---

## Marketing Angles

### Key Messages
1. **"Try it FREE"** — 10 Energy to start, no credit card
2. **"Run out? We got you"** — 50 Energy bonus when you need it
3. **"40% OFF — 24 hours only"** — Urgency + scarcity
4. **"One-time deal"** — Creates FOMO

### Why This Works
- **Lower barrier to entry** — 10 Energy feels like a trial, not a full gift
- **Perfect timing** — Offer appears when user wants more (proven interest)
- **Reciprocity** — Bonus 50 Energy creates goodwill → higher conversion
- **Urgency + Scarcity** — 24h + one-time = psychological triggers to act now

---

## Testing Checklist

- [ ] New user flow: Download → Get 10 Energy
- [ ] Use 10 Energy → Out of Energy dialog appears
- [ ] First time empty → 50 Energy granted + Welcome Offer unlocked
- [ ] Welcome Offer countdown shows (24h timer)
- [ ] Purchase during Welcome Offer → 40% discount applied
- [ ] Second time empty → NO bonus, just regular "Out of Energy" dialog
- [ ] Energy balance syncs correctly with backend
- [ ] Flag persists across app restarts

---

## Rollout Plan

### Phase 1: Soft Launch (Testing)
- Deploy to small percentage of new users (A/B test)
- Monitor conversion rates vs. old strategy

### Phase 2: Full Rollout
- If metrics are positive → deploy to 100% of new users
- Update app store screenshots and description

### Phase 3: Optimization
- Analyze data:
  - % of users who reach "first empty"
  - Conversion rate during Welcome Offer window
  - LTV of converted users
- Iterate on messaging, timing, bonus amount

---

## Success Metrics

### Key KPIs to Track
1. **Download → Trial Rate** (% who use at least 1 Energy)
2. **Trial → First Empty Rate** (% who use all 10 Energy)
3. **First Empty → Conversion Rate** (% who buy during 24h window)
4. **Average Purchase Value** (during Welcome Offer vs. regular)
5. **Repeat Purchase Rate** (users who buy again after Welcome Offer)

### Target Goals
- Trial Rate: >80% (most users try AI at least once)
- First Empty Rate: >60% (users engage enough to run out)
- Conversion Rate: >15% (industry standard is 2-5%, we aim higher due to timing)
- Avg Purchase: $4.99+ (mid-tier or higher packages)

---

## Notes

- All text in the app is in **English** (Cursor rule compliance)
- Backend functions updated to match (WELCOME_GIFT = 10)
- Marketing doc updated with new strategy
- Dialog UI uses Material Icons (no emojis except in text strings for celebration)

---

*Last Updated: February 17, 2026*  
*Owner: Product Team*  
*Status: ✅ Ready for Deployment*
