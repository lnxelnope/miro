# MIRO — Bug Report & Feature Improvements

> **IMPORTANT: This entire project must be in English only. All code, comments, UI text, documentation, and commit messages must be written in English.**

> Summarized from real-device testing and usage.
> Date: February 15, 2026

---

## Table of Contents

1. [UI/UX — Camera & Chat Button Redesign](#1-uiux--camera--chat-button-redesign)
2. [UI — Remove Beta Feedback](#2-ui--remove-beta-feedback)
3. [Feature — Image Analysis Preview Screen](#3-feature--image-analysis-preview-screen)
4. [Bug/Feature — AI Image Analysis Missing Ingredient Breakdown](#4-bugfeature--ai-image-analysis-missing-ingredient-breakdown)
5. [Bug — Energy Badge Overflow on Small Screens](#5-bug--energy-badge-overflow-on-small-screens)
6. [Bug — Tutorial: Pull-to-Refresh Text Off-Screen](#6-bug--tutorial-pull-to-refresh-text-off-screen)
7. [Feature — Tutorial: Add Chat System Walkthrough](#7-feature--tutorial-add-chat-system-walkthrough)
8. [Feature — Tutorial: Food Mock-up & Detailed Usage Guide](#8-feature--tutorial-food-mock-up--detailed-usage-guide)
9. [Feature — Micronutrients in Summary Page](#9-feature--micronutrients-in-summary-page)
10. [Feature — Today Summary: Full Nutrition Dashboard](#10-feature--today-summary-full-nutrition-dashboard)
11. [Feature — Micronutrient Charts (Collapsible)](#11-feature--micronutrient-charts-collapsible)
12. [Legal — Health Disclaimer Note](#12-legal--health-disclaimer-note)

---

## 1. UI/UX — Camera & Chat Button Redesign

**Type:** Feature / UI Improvement
**Priority:** High
**Location:** Home Screen — Floating Action Buttons

### What Needs to Be Done

- [ ] **Add a camera button** next to the existing chat button (Magic Button) on the home screen
- [ ] **Reduce icon sizes** for both chat and camera buttons — currently too large and obstructing the user's view
- [ ] **Camera screen:** Tapping the camera button → opens a camera capture screen
- [ ] **Gallery icon:** At the bottom-right corner of the camera screen, add an icon to open the device's Image Gallery (select existing photos)

### Rationale

Combining camera and gallery into one flow keeps the main screen clean with only **2 icons** (camera + chat) → less clutter, better UX.

### Expected Flow

```
Home Screen
  ├── Chat Button (smaller size) → Opens Chat Screen
  └── Camera Button (smaller size) → Opens Camera Screen
                                        └── Bottom-right icon → Opens Image Gallery
```

---

## 2. UI — Remove Beta Feedback

**Type:** Cleanup
**Priority:** High
**Location:** Beta Feedback section (possibly in Profile or AppBar)

### What Needs to Be Done

- [ ] Remove/hide the Beta Feedback submission UI from the entire app
- [ ] Remove Beta Tester Bonus logic if no longer needed

### Rationale

The app is no longer in Beta — no Beta-related UI should be visible to users.

---

## 3. Feature — Image Analysis Preview Screen

**Type:** Feature Enhancement
**Priority:** High
**Location:** Screen shown after selecting/capturing a food photo (before sending to AI)

### What Needs to Be Done

When a user selects an image (from camera, gallery, or device scan) → display a **Preview + Input** screen with the following:

- [ ] **Display the selected image** (Preview)
- [ ] **Food name input field** — Default value: `"food"` (user-editable)
- [ ] **Quantity input field** — Default value: `1`
- [ ] **Unit dropdown selector** — Default value: `"serving"` (options: plate, cup, piece, gram, etc.)
- [ ] **"Analyze with AI" button** — Sends all data for analysis

### Note to Display to Users

> Entering the food name and quantity is optional, but providing them will improve AI analysis accuracy.

### Mockup Layout

```
┌─────────────────────────────────┐
│         [Food Image Preview]    │
│                                 │
├─────────────────────────────────┤
│ Food name: [____food________]   │
│ Quantity:  [_1_] [serving ▼]    │
│                                 │
│ 💡 Optional, but improves       │
│    analysis accuracy            │
│                                 │
│      [ 🤖 Analyze with AI ]    │
└─────────────────────────────────┘
```

---

## 4. Bug/Feature — AI Image Analysis Missing Ingredient Breakdown

**Type:** Bug + Feature Enhancement
**Priority:** High
**Location:** AI Analysis Pipeline (all modes: camera, gallery, device scan)

### Problem

When analyzing food via image (camera capture, gallery selection, or auto-scan from device):
- **AI sometimes returns aggregated/summary data only** without breaking down individual ingredients
- It should return **detailed ingredient-level data** identical to what text-based analysis (food name + quantity + unit) returns

### What Needs to Be Done

- [ ] Review the prompt sent to Gemini AI for all image analysis modes
- [ ] Ensure AI **always returns `ingredients_detail`** as an array of individual ingredients
- [ ] Each ingredient must include its own calories, protein, carbs, and fat values
- [ ] Behavior must be consistent across all 3 modes:
  - Camera capture
  - Gallery selection
  - Auto-scan from device (Pull-to-refresh)

### Example: Expected vs Current Behavior

```
Input: Photo of steak with french fries

❌ Current behavior (sometimes):
  → "Steak with fries" - 650 kcal (aggregated, no breakdown)

✅ Expected behavior:
  → Steak with fries - 650 kcal (total)
     ├── Beef Steak (150g) - 375 kcal | P: 40g | C: 0g | F: 22g
     ├── French Fries (100g) - 220 kcal | P: 3g | C: 30g | F: 11g
     └── Sauce (20ml) - 55 kcal | P: 0g | C: 5g | F: 4g
```

---

## 5. Bug — Energy Badge Overflow on Small Screens

**Type:** Bug (UI Overflow)
**Priority:** Medium
**Location:** AppBar → Energy Badge (green border)

### Problem

- When Energy count exceeds **1,000** → the number overflows outside the green badge border
- This occurs on phones with narrower-than-normal screens

### What Needs to Be Done

- [ ] Make the green Energy Badge border **flexible/expandable** based on the number of digits
- [ ] Use `FittedBox`, `Flexible`, or dynamic `padding` based on text length
- [ ] Test with values: `99`, `999`, `1,000`, `9,999`, `99,999`
- [ ] Test on narrow screens (width < 360dp)

---

## 6. Bug — Tutorial: Pull-to-Refresh Text Off-Screen

**Type:** Bug
**Priority:** High
**Location:** Feature Tour → Step 2 (Pull-to-Refresh tutorial)

### Problem

- During the Pull-to-Refresh tutorial step → **the description text is positioned above the screen (off-screen)**
- Users see only a **blank dark overlay/box** with no visible text
- The tooltip/description text is placed at an incorrect position (likely negative Y offset or top overflow)

### What Needs to Be Done

- [ ] Check the `TutorialCoachMark` target configuration for the Pull-to-Refresh step
- [ ] Fix the `contentAlign` / `position` of the tooltip to ensure it remains within the visible screen area
- [ ] Test on multiple screen sizes

---

## 7. Feature — Tutorial: Add Chat System Walkthrough

**Type:** Feature Enhancement
**Priority:** Medium
**Location:** Feature Tour → Add new step(s) for Chat

### What Needs to Be Done

- [ ] Add a Chat tutorial step to the Feature Tour
- [ ] Explain to users that they can:
  - Type food names to analyze them
  - Use multiple languages (with Miro AI)
  - Access Quick Actions / FAQ buttons
  - Understand that sending messages uses Energy

---

## 8. Feature — Tutorial: Food Mock-up & Detailed Usage Guide

**Type:** Feature Enhancement
**Priority:** High
**Location:** Onboarding / Feature Tour — Food analysis walkthrough

### What Needs to Be Done

Use a sample image of **steak with french fries** (`assets/images/tutorial_steak.png` — copied from `C:\Users\ASUS\Downloads\OIP.png`) to create an interactive tutorial flow:

#### Step 1: Teach Users to Edit Food Name

- [ ] Display the steak and fries sample image
- [ ] Guide users to **change the food name**, e.g., from `"food"` → `"Beyond Meat and Fries"`
- [ ] **Explanation:** "Specifying an accurate food name helps AI analyze more precisely. For example, without specifying, AI might identify this as **beef steak** when it's actually a **Vegan Steak (Beyond Meat)**, which has very different nutritional values."

#### Step 2: Teach Users to Adjust Quantity and Unit

- [ ] Show users they can **change quantity** and **select a unit** for maximum accuracy
- [ ] **Note:** "This is optional — you can always come back and edit later."

#### Step 3: Teach Users to Edit Ingredients After AI Analysis

- [ ] Using the **same image** (steak and fries), show the result after AI analysis
- [ ] Demonstrate that users can **edit individual ingredients** and re-submit for AI re-analysis
- [ ] **Explanation:** "If you're in a hurry, just analyze as-is first. You can always fine-tune any item that doesn't look right later."

### Tutorial Flow

```
Steak & Fries sample image
    │
    ├── Step 1: "Try changing the name to 'Beyond Meat and Fries'"
    │            → Because AI might misidentify it as real beef
    │
    ├── Step 2: "Adjust quantity/unit for better accuracy"
    │            → Or skip it — you can edit later
    │
    └── Step 3: "View results, edit ingredients, re-analyze"
                 → Fine-tune anything that seems off
```

---

## 9. Feature — Micronutrients in Summary Page

**Type:** Feature Enhancement (conditional — only if AI returns micronutrient data)
**Priority:** Low — Medium
**Location:** New Summary page (currently under development)

### Pre-Check Required

- [ ] Verify whether the current system **stores micronutrients** (fiber, sugar, sodium, cholesterol, saturated fat) in the database
- [ ] Verify whether AI responses include micronutrient data

### If AI Returns Micronutrient Data

- [ ] Display micronutrients on the new Summary page showing daily intake totals
- [ ] Show as a table or list: Fiber, Sugar, Sodium, Cholesterol, Saturated Fat

### If AI Does NOT Return Micronutrient Data

- Skip this item — no implementation needed

---

## 10. Feature — Today Summary: Full Nutrition Dashboard

**Type:** Feature (Major)
**Priority:** High
**Location:** Today Summary button → New Dashboard Screen

### What Needs to Be Done

#### 10.1 — Data Display on Today Summary

- [ ] Show summary of **today's intake** (kcal, protein, carbs, fat)
- [ ] Support **date navigation** (Date Picker or Arrow Navigation) to view any date
- [ ] Tap any date to view that day's data

#### 10.2 — Macro Goals vs Actual Table

Display a comparison table of **Baseline Goals (user-configured)** vs **Actual Intake**:

| Category | Goal | Actual | Difference |
|----------|:----:|:------:|:----------:|
| **Calories (kcal)** | 2,000 | 1,850 | -150 (under) |
| **Protein (g)** | 120 | 95 | -25 (under) |
| **Carbohydrates (g)** | 250 | 280 | +30 (over) |
| **Fat (g)** | 65 | 50 | -15 (under) |

#### 10.3 — Time-Period Summaries (Surplus/Deficit)

Show cumulative surplus/deficit across different time periods:

- [ ] **1 Day** — Today's surplus or deficit
- [ ] **1 Week** — Past 7 days cumulative surplus/deficit
- [ ] **1 Month** — Past 30 days cumulative surplus/deficit
- [ ] **1 Year** — Past 365 days cumulative surplus/deficit
- [ ] **All Time** — Since first use

---

## 11. Feature — Micronutrient Charts (Collapsible)

**Type:** Feature Enhancement
**Priority:** Medium
**Location:** Summary / Dashboard Page

### What Needs to Be Done

- [ ] Display charts for micronutrients (fiber, sugar, sodium, cholesterol, saturated fat)
- [ ] **No baseline required** (users do not set micronutrient goals)
- [ ] Show **average values** for micronutrients across:
  - Daily average
  - Monthly average
  - Yearly average
- [ ] Implement as a **Collapsible Section** — expandable/collapsible to reduce visual clutter
- [ ] Default state: **Collapsed** (hidden)

### Layout

```
┌─────────────────────────────────────────┐
│  📊 Macronutrient Summary               │ ← Always visible
│  [Macro goals table & charts]           │
├─────────────────────────────────────────┤
│  ▶ Micronutrient Details     [expand]   │ ← Collapsed by default
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│  (When expanded)                        │
│  📈 Fiber avg: 12g/day                 │
│  📈 Sugar avg: 45g/day                 │
│  📈 Sodium avg: 1,800mg/day           │
│  📈 Cholesterol avg: 200mg/day        │
│  📈 Saturated Fat avg: 15g/day        │
│  [Trend charts: daily/monthly/yearly]  │
└─────────────────────────────────────────┘
```

---

## 12. Legal — Health Disclaimer Note

**Type:** Legal / Compliance
**Priority:** Critical (liability protection)
**Location:** Summary page, AI analysis results, and general app footer

### What Needs to Be Done

- [ ] Add a Health Disclaimer on the Summary page and all relevant screens
- [ ] The text must clearly state that MIRO is **not a health advisory service**

### Disclaimer Text (English)

> **⚠️ Disclaimer**
>
> MIRO is a nutrition tracking and analysis tool designed for **informational and personal reference purposes only**. The data, estimates, and analyses provided by MIRO — including AI-generated nutritional information — are **approximations** and should **not** be considered as medical advice, dietary prescriptions, or professional health recommendations.
>
> MIRO is **not** a licensed healthcare provider, dietitian, or nutritionist. The information presented within this application is intended to assist users in tracking and understanding their dietary intake, and should be used solely as **a supplementary reference for the user's own analysis and decision-making**.
>
> For personalized health, dietary, or medical advice, please consult a qualified healthcare professional, registered dietitian, or licensed nutritionist.
>
> By using MIRO, you acknowledge and agree that all nutritional data is provided on an "as-is" basis without warranty of accuracy, completeness, or fitness for any particular purpose.

---

## Priority Summary

| # | Item | Type | Priority |
|:-:|------|------|:--------:|
| 1 | Energy Badge overflow (#5) | Bug | 🔴 High |
| 2 | Tutorial Pull-to-Refresh text off-screen (#6) | Bug | 🔴 High |
| 3 | Remove Beta Feedback (#2) | Cleanup | 🔴 High |
| 4 | AI not returning ingredient breakdown (#4) | Bug/Feature | 🔴 High |
| 5 | Health Disclaimer (#12) | Legal | 🔴 Critical |
| 6 | Camera & Chat button redesign (#1) | UI/UX | 🔴 High |
| 7 | Image analysis preview screen (#3) | Feature | 🔴 High |
| 8 | Tutorial mock-up + detailed guide (#8) | Feature | 🔴 High |
| 9 | Today Summary dashboard (#10) | Feature | 🟡 High |
| 10 | Tutorial: Chat walkthrough (#7) | Feature | 🟡 Medium |
| 11 | Micronutrient charts — collapsible (#11) | Feature | 🟡 Medium |
| 12 | Micronutrients in summary (#9) | Feature | 🟢 Low-Medium |

---

> **Note:** This document serves as a development and bug-fix roadmap. Priorities may be adjusted as needed based on development progress and user feedback.
