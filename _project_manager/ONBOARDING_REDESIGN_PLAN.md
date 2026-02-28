# MIRO Onboarding & Tutorial Redesign Plan

## Philosophy

> **"Don't bother the user."**
> MIRO เกิดมาเพื่อ track calories — ไม่ยุ่งเรื่องส่วนตัวของ user
> ไม่ถามเพศ ไม่ถามอายุ ไม่คำนวณ TDEE ให้
> User ตั้ง calorie goal เองทีหลังใน Profile ได้
> **เก็บ cuisine preference ไว้** — ใช้ช่วย AI วิเคราะห์ได้แม่นขึ้น

---

## Table of Contents

1. [สิ่งที่ต้องลบ / เปลี่ยน](#1-สิ่งที่ต้องลบ--เปลี่ยน)
2. [New Feature: Search Mode](#2-new-feature-search-mode)
3. [Onboarding Flow ใหม่](#3-onboarding-flow-ใหม่)
4. [Tutorial Flow ใหม่](#4-tutorial-flow-ใหม่)
5. [Feature Tour (Post-Onboarding)](#5-feature-tour-post-onboarding)
6. [UI Design Guidelines](#6-ui-design-guidelines)
7. [Technical Implementation](#7-technical-implementation)
8. [File Changes](#8-file-changes)
9. [Migration & Compatibility](#9-migration--compatibility)

---

## 1. สิ่งที่ต้องลบ / เปลี่ยน

### ลบออกจาก Onboarding
- [ ] **Page 3 (User Info + TDEE)** — ลบส่วน เพศ, อายุ, น้ำหนัก, ส่วนสูง, activity level, TDEE calculation
- [ ] **เก็บ Cuisine Preference ไว้** — ย้ายไปอยู่ใน Page 2 (setup เบาๆ)
- [ ] **Page 4 (Energy System + Welcome Gift)** — redesign เป็นหน้าสั้นๆ ไม่เน้น energy system มาก
- [ ] **Disclaimer Dialog** — ย้ายไปแสดงแบบ inline ในหน้า Welcome แทน (ไม่ popup)
- [ ] **TdeeCalculator dependency** — ลบออกจาก onboarding

### ลบจาก Tutorial (เก่า)
- [ ] **Food name tutorial** (before/after comparison) — เปลี่ยนแนวทางเป็นสอนจากการใช้จริง
- [ ] **Quantity/Unit tutorial** — ยุบรวมเข้า flow หลัก
- [ ] **Mock analysis results** — ใช้ interactive demo แทน
- [ ] **6-step linear tutorial** — เปลี่ยนเป็น 3-step practical tutorial

### พิจารณาลบจากแอป
- [ ] **Water tracking** — ไม่ใช่ core feature (ลบทีหลัง)
- [ ] **UserProfile fields** — gender, age, weight, height ยังเก็บได้แต่ไม่บังคับกรอก

---

## 2. New Feature: Search Mode (ตัวเสริมบนหน้า Analyze)

### Concept
เพิ่ม **toggle เล็กๆ** บนหน้าที่ user จะกดส่งไปวิเคราะห์ด้วย AI
ไม่ใช่ feature ใหญ่ แค่ **ตัวเสริม** เพื่อบอก AI ว่าอาหาร/รูปที่จะส่งเป็นอะไร

### 2 Modes

#### Mode 1: `normal` — อาหารทั่วไป (Default)
- ใช้สำหรับอาหารปรุงเอง, อาหารตามสั่ง, อาหารจานเดียว
- AI จะ **ประมาณค่า** จากวัตถุดิบที่เห็น/ที่ระบุ
- วิเคราะห์แบบ break down ingredients
- เช่น: ข้าวผัด, ส้มตำ, สเต็ก, stir-fry noodles

#### Mode 2: `product` — สินค้าที่มี Nutrition Facts
- ใช้สำหรับสินค้าที่มีฉลากโภชนาการ (packaged food)
- AI จะ **ใช้ข้อมูล nutrifact จริง** ของสินค้า (ถ้ารู้จัก)
- รับค่า **portion** จาก user: 1 serving, 1 box, 1 bag, 100g, etc.
- ค่าที่ได้จะ **แม่นยำกว่า** เพราะ based on actual nutrition label
- เช่น: Lay's Original, Coca-Cola, KIND Bar, Yakult, นมไทย-เดนมาร์ค

### ตำแหน่งที่แสดง (เฉพาะหน้า Analyze เท่านั้น)

Search Mode จะเป็น **toggle pill เล็กๆ** อยู่บนหน้าที่มีปุ่ม "Analyze with AI":

#### 1. `ImageAnalysisPreviewScreen` — หน้าหลักที่ส่งรูปไปวิเคราะห์
ตำแหน่ง: **ระหว่าง Food name input กับ Quantity input**

```
┌─────────────────────────────────────────┐
│  [Image Preview]                        │
│                                         │
│  Food name: [Steak and Fries........]   │
│                                         │
│  Type:  [🍳 Food ✓] [📦 Product]       │  ← toggle pills
│                                         │
│  Qty: [1      ]  Unit: [serving ▾]      │
│                                         │
│  💡 Tip: ...                            │
│                                         │
│  [   ✨ Analyze with AI   ]             │
└─────────────────────────────────────────┘
```

#### 2. `FoodPreviewScreen` — หน้า preview ก่อนบันทึก
ตำแหน่ง: **ข้างๆ ปุ่ม AI Analysis**

```
┌─────────────────────────────────────────┐
│  [Image Preview]                        │
│                                         │
│  [🍳 Food ✓] [📦 Product]              │  ← toggle pills
│  [   ✨ AI Analysis   ]                 │
│                                         │
│  Food name: [......................]    │
│  ...                                    │
└─────────────────────────────────────────┘
```

#### 3. `GeminiAnalysisSheet` — ตอน re-search ingredient ด้วย AI
ตำแหน่ง: **ใน dialog ก่อนส่ง re-search**

> เมื่อ user กด 🔍 re-search บน ingredient → 
> แสดง dialog เล็กๆ ถาม "Search as Food or Product?" → ส่งไป AI

### UI Design: Toggle Pills (Compact)

```dart
// ขนาดเล็ก ไม่กินพื้นที่ แค่ 2 pills อยู่ข้างกัน
Row(
  children: [
    _buildModePill('🍳 Food', FoodSearchMode.normal, isSelected),
    SizedBox(width: 8),
    _buildModePill('📦 Product', FoodSearchMode.product, isSelected),
  ],
)
```

**Style:**
- Pill shape (borderRadius: 20)
- Selected: `AppColors.primary` bg + white text
- Unselected: `surfaceVariant` bg + `textSecondary` text
- Height: 36px
- ไม่มี label/header — แค่ pills เอง (self-explanatory)

### Search Mode — Impact on AI Prompt

#### Normal Mode Prompt Addition:
```
Analyze this as a regular prepared/cooked food.
Break down into individual ingredients with estimated portions.
```

#### Product Mode Prompt Addition:
```
This is a well-known packaged product with a nutrition facts label.
Use the official nutrition data for this product.
The user specifies: [quantity] [unit] (e.g., "1 serving", "1 bag", "100g").
Return nutrition values based on the specified portion.
If the product is not recognized, indicate so and fall back to estimation.
```

### Data Model Change

```dart
enum FoodSearchMode {
  normal,   // อาหารทั่วไป — AI ประมาณค่า
  product,  // สินค้ามี Nutrition Facts — AI ใช้ข้อมูลจริง
}
```

---

## 3. Onboarding Flow ใหม่

### Design: 3 หน้า (ลดจาก 4 หน้า, ลบ TDEE/เพศ/อายุ ทิ้ง)

### Page 1: Welcome
> เป้าหมาย: สร้างความเชื่อมั่น + บอก core value

```
┌─────────────────────────────────────────┐
│                                         │
│          [MIRO Logo - 100px]            │
│                                         │
│              M I R O                    │
│          Intake Oracle                  │
│                                         │
│     "Track calories effortlessly        │
│      with AI-powered analysis"          │
│                                         │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 📸 Snap → AI analyzes instantly │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ 💬 Type → Log in seconds       │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ ✏️ Edit → Fine-tune accuracy    │    │
│  └─────────────────────────────────┘    │
│                                         │
│                                         │
│       ●  ○  ○    (page dots)            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │         Get Started →           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  "ℹ️ AI-estimated data. Not medical     │
│   advice." (inline disclaimer)          │
│                                         │
└─────────────────────────────────────────┘
```

**Design Notes:**
- Logo + app name ด้านบน (ย่อลงจากเดิม)
- 3 feature pills แบบ clean (ไม่เยอะ)
- Inline disclaimer เล็กๆ ด้านล่าง (ไม่ popup)
- Page indicator dots
- "Get Started" button → ไปหน้าถัดไป

---

### Page 2: Cuisine Preference + Calorie Goal (เบาๆ)
> เป้าหมาย: ถามแค่สิ่งที่จำเป็นเท่านั้น — cuisine ช่วย AI, calorie goal ช่วย tracking

```
┌─────────────────────────────────────────┐
│                                         │
│    🍽️ Quick Setup                       │
│                                         │
│    "Help AI understand your food"       │
│                                         │
│  Your typical cuisine:                  │
│  ┌─────────────────────────────────┐    │
│  │ 🇹🇭 Thai   🌍 International      │    │
│  │ 🇯🇵 Japanese  🇰🇷 Korean          │    │
│  │ 🇨🇳 Chinese  🇮🇹 Western          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Daily calorie goal (optional):         │
│  ┌─────────────────────────────────┐    │
│  │  [    2000    ] kcal/day        │    │
│  └─────────────────────────────────┘    │
│  "You can change this anytime           │
│   in Profile settings"                  │
│                                         │
│       ○  ●  ○    (page dots)            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │             Next →              │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

**Design Notes:**
- Cuisine ChoiceChips (เหมือนเดิม แต่ layout สวยขึ้น)
- Calorie goal: text field เดี่ยว default 2000 (optional)
- **ไม่มี** เพศ อายุ น้ำหนัก ส่วนสูง activity level TDEE
- "You can change this anytime" — ไม่กดดัน user
- ถ้า user ไม่อยากกรอก ก็กด Next ได้เลย (default values)

---

### Page 3: You're Ready! + Energy Gift
> เป้าหมาย: ให้กำลังใจ + mention energy system สั้นๆ

```
┌─────────────────────────────────────────┐
│                                         │
│              🎉                          │
│                                         │
│      You're All Set!                    │
│                                         │
│   "Start tracking your meals today.     │
│    Snap a photo or type what you ate."  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🎁 Welcome Gift                │    │
│  │                                 │    │
│  │    100 FREE Energy              │    │
│  │    = 100 AI analyses            │    │
│  │                                 │    │
│  │  Each photo/chat analysis       │    │
│  │  costs 1 Energy                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│                                         │
│       ○  ○  ●    (page dots)            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      Start Tracking! →          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  "No credit card. No hidden fees."      │
│                                         │
└─────────────────────────────────────────┘
```

**Design Notes:**
- ไม่ซับซ้อน แค่บอกว่าพร้อมใช้
- Gift card สวยๆ ด้วย gradient border
- "Start Tracking!" → บันทึก onboarding + ไป Tutorial

---

## 4. Tutorial Flow ใหม่

### Design: 3 Steps (ลดจาก 6 steps)
> **Interactive demo** — ไม่ใช่แค่อ่าน แต่ลองทำจริง

### Step 1: "Analyze Your First Food"
> เป้าหมาย: สอนการวิเคราะห์อาหาร — แสดงว่าหน้า analyze มีอะไรบ้าง + มี search mode toggle

```
┌─────────────────────────────────────────┐
│  Tutorial  1/3              [Skip →]    │
│  ━━━━━━━━━━━━━░░░░░░░░░░░░░░░           │
│                                         │
│  Let's analyze a sample meal!           │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  [Sample food image]           │    │
│  │  (steak and fries)             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Food name:                             │
│  ┌─────────────────────────────────┐    │
│  │ Steak and Fries                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🍳 Food ✓] [📦 Product]   ← toggle   │
│                                         │
│  ┌──────────┐  ┌───────────────────┐    │
│  │ Qty: 1   │  │ Unit: plate   ▾  │    │
│  └──────────┘  └───────────────────┘    │
│                                         │
│  💡 Tip: ถ้าเป็นสินค้ามีฉลาก เช่น      │
│  Lay's, Coca-Cola ให้เลือก "Product"    │
│  เพื่อให้ AI ใช้ข้อมูล nutrifact จริง  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │    🔍 Analyze (Demo)  →        │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

**Behavior:**
- User เห็นรูปตัวอย่าง + input form เหมือนหน้า analyze จริง
- Search mode toggle อยู่ระหว่าง food name กับ quantity (เหมือน production)
- ลอง toggle ระหว่าง Food / Product ได้ — tip เปลี่ยนตาม mode
- กด "Analyze (Demo)" → แสดง mock results ใน step 2 (ไม่เสีย Energy)
- กด Next ก็ได้ ข้ามไป step 2 เลย

---

### Step 2: "Edit & Fix Ingredients"
> เป้าหมาย: สอนแก้วัตถุดิบที่ AI เข้าใจผิด + re-search

```
┌─────────────────────────────────────────┐
│  Tutorial  2/3              [Skip →]    │
│  ━━━━━━━━━━━━━━━━━━━░░░░░░░░░           │
│                                         │
│  AI analyzed your meal:                 │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ ✅ Grilled Steak        280kcal │    │
│  │    150g                         │    │
│  │    P:20  C:5  F:18              │    │
│  ├─────────────────────────────────┤    │
│  │ ⚠️ Chicken Breast  ← WRONG!    │    │
│  │    100g                 165kcal │    │
│  │    P:31  C:0  F:3.6            │    │
│  │                                 │    │
│  │  ┌──────────┐ ┌──────────────┐  │    │
│  │  │ ✏️ Edit  │ │ 🔍 Re-search │  │    │
│  │  └──────────┘ └──────────────┘  │    │
│  ├─────────────────────────────────┤    │
│  │ ✅ French Fries          312kcal│    │
│  │    100g                         │    │
│  │    P:3.4  C:41  F:15           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  💡 Tip: AI sometimes guesses wrong.   │
│  You can:                               │
│  • ✏️ Edit the name/amount manually     │
│  • 🔍 Re-search with AI for better     │
│       results                           │
│                                         │
│  ┌──────────┐  ┌───────────────────┐    │
│  │ Previous │  │     Next →        │    │
│  └──────────┘  └───────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

**Behavior:**
- Mock results แสดงโดยมี 1 item ที่ "ผิด" (เช่น AI เห็นเป็น Chicken แต่จริงๆเป็น Beef)
- Highlight ⚠️ ที่ item ผิด พร้อม pulse animation
- User กด "Edit" → เปลี่ยนชื่อ ingredient ได้ (interactive)
- User กด "Re-search" → แสดง loading animation → mock ผลลัพธ์ใหม่ที่ถูกต้อง
- 💡 Tip box อธิบายสิ่งที่ทำได้

---

### Step 3: "You're a Pro!"
> เป้าหมาย: สรุป + ปล่อยไปใช้งาน

```
┌─────────────────────────────────────────┐
│  Tutorial  3/3              [Skip →]    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━        │
│                                         │
│              🏆                          │
│                                         │
│      You're Ready!                      │
│                                         │
│   Quick recap:                          │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 📸 Snap or 💬 Type              │    │
│  │ to analyze any food             │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ 🍳 Food or 📦 Product           │    │
│  │ choose mode for better accuracy │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ ✏️ Edit or 🔍 Re-search         │    │
│  │ fix anything AI got wrong       │    │
│  └─────────────────────────────────┘    │
│                                         │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     🚀 Start Tracking!          │    │
│  └─────────────────────────────────┘    │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

**Behavior:**
- สรุป 3 สิ่งหลักที่เรียนมา
- "Start Tracking!" → ไป HomeScreen
- ไม่มี Feature Tour อีก (ยุบรวมกับ tutorial แล้ว)

---

## 5. Feature Tour (Post-Onboarding)

### ยุบเหลือ 1 step (จากเดิม 3 steps)

**Energy Badge Tour** เก็บไว้:
- แค่ highlight Energy Badge บน AppBar
- บอกสั้นๆ: "This is your Energy. Each analysis costs 1. You have 100 free!"
- Auto-dismiss after 5 seconds หรือ tap anywhere

**ลบออก:**
- Pull-to-Refresh tour → ย้ายเป็น tooltip เมื่อ user เห็น empty state แทน
- Chat button tour → ลบ (BottomNav ชัดเจนแล้ว)

---

## 6. UI Design Guidelines

### ตาม Design System ใหม่ (Airbnb-inspired)

| Element | Spec |
|---------|------|
| Card radius | 16px |
| Button radius | 20px (pill) หรือ 12px (standard) |
| Shadow | `BoxShadow(color: black.withOpacity(0.06), blur: 8, offset: (0,2))` |
| Primary color | `AppColors.primary` (#2D8B75) |
| Background | `AppColors.background` (#F9FAFB) |
| Text Primary | `AppColors.textPrimary` (#111827) |
| Text Secondary | `AppColors.textSecondary` (#6B7280) |
| Spacing | 16px standard, 24px sections |
| Font weight | w800 for headlines, w600 for subheads |

### Colors for Search Modes
| Mode | Color | Bg Color |
|------|-------|----------|
| Normal Food 🍳 | `AppColors.primary` (#2D8B75) | `primary.withOpacity(0.08)` |
| Product 📦 | `AppColors.health` (#F59E0B) | `health.withOpacity(0.08)` |

### Animation Guidelines
- Page transitions: 300ms, `Curves.easeInOut`
- Highlights/Pulses: 800ms, `Curves.easeInOut`, repeat
- Progress bar: Smooth linear interpolation
- Card appearances: 200ms fade + 20px slide up

### Dark Mode
- ต้อง support ทั้ง light & dark mode
- ใช้ `Theme.of(context)` ทุกที่ ไม่ hardcode สี

---

## 7. Technical Implementation

### Task Breakdown

#### TASK 1: Search Mode Data Model & AI Prompt
**Priority: HIGH** (ต้องทำก่อนเพราะ Tutorial ใช้)

**Files:**
- `lib/core/constants/enums.dart` — เพิ่ม `FoodSearchMode` enum
- `lib/core/ai/gemini_service.dart` — เพิ่ม search mode ใน prompt
- `lib/core/ai/gemini_chat_service.dart` — เพิ่ม search mode support

**Changes:**
```dart
// enums.dart
enum FoodSearchMode {
  normal,   // อาหารทั่วไป
  product,  // สินค้า packaged
}
```

```dart
// gemini_service.dart - เพิ่มใน analyzeFood()
// เพิ่ม parameter: FoodSearchMode searchMode = FoodSearchMode.normal
// ปรับ prompt ตาม mode:
// - normal: "Analyze as regular food, break down ingredients..."
// - product: "This is a packaged product with nutrition label. 
//             Use official nutrition data. Portion: [qty] [unit]..."
```

---

#### TASK 2: Search Mode UI Widget
**Priority: HIGH**

**New file:** `lib/core/widgets/search_mode_selector.dart`

**Widget spec:**
```dart
/// Toggle pills ขนาดเล็ก สำหรับเลือก Food / Product
/// ใช้บนหน้า analyze เท่านั้น
class SearchModeSelector extends StatelessWidget {
  final FoodSearchMode selectedMode;
  final ValueChanged<FoodSearchMode> onChanged;
}
```

**Style:** 2 pill buttons อยู่ข้างกัน (Row)
- Selected: `primary` bg, white text, bold
- Unselected: `surfaceVariant` bg, `textSecondary` text
- Height: 36px, borderRadius: 20
- ไม่มี label/header

**Integrate into (เฉพาะหน้า analyze):**
- `ImageAnalysisPreviewScreen` — ระหว่าง food name กับ quantity
- `FoodPreviewScreen` — เหนือปุ่ม AI Analysis
- `GeminiAnalysisSheet` — ตอน re-search ingredient (ใน lookup dialog)

---

#### TASK 3: Onboarding Redesign
**Priority: HIGH**

**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

**Changes:**
- ลบ Page 3 เดิม (User Info + TDEE) → แทนที่ด้วย Cuisine + Calorie Goal เบาๆ
- ลบ Page 4 เดิม
- Redesign เป็น 3 pages:
  1. Welcome + Features + inline disclaimer
  2. Cuisine Preference + Calorie Goal (optional)
  3. Ready + Energy Gift
- ลบ dependencies: `TdeeCalculator` (ไม่ใช้แล้ว)
- **เก็บ** `CuisineOptions` (ยังใช้อยู่)
- ลดจำนวน state variables ลงมาก (ลบ gender, age, weight, height, activityLevel)
- เก็บ: `_selectedCuisine`, `_calorieGoal` (TextEditingController, default 2000)
- `_completeOnboarding()` → สร้าง UserProfile (cuisine + calorieGoal + `onboardingComplete = true`)
- Navigate ไป Tutorial (ไม่มี Disclaimer popup)

---

#### TASK 4: Tutorial Redesign
**Priority: HIGH**

**File:** `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart`

**Changes:**
- ลดจาก 6 steps → 3 steps
- Step 1: Analyze (interactive) + Search Mode demo
- Step 2: Edit & Re-search (interactive)
- Step 3: Summary + Start
- ลบ before/after comparison
- ลบ mock quantity/unit editing
- เพิ่ม interactive edit + re-search demo
- เพิ่ม search mode toggle demo

**Model:** `lib/features/onboarding/models/tutorial_step.dart`
```dart
enum TutorialStepType {
  analyzeDemo,       // Step 1: วิเคราะห์อาหาร + Search Mode
  editAndResearch,   // Step 2: แก้ไข + ค้นหาซ้ำ
  completion,        // Step 3: สรุป
}
```

---

#### TASK 5: Feature Tour Simplification
**Priority: LOW**

**File:** `lib/features/home/widgets/feature_tour.dart`

**Changes:**
- ลบ `buildPullRefreshTarget`
- ลบ `buildChatButtonTarget`
- ลบ `_PullToRefreshAnimatedWidget` class
- เหลือแค่ `buildEnergyBadgeTarget` (simplified)
- เพิ่ม auto-dismiss timer

**File:** `lib/features/home/presentation/home_screen.dart`
- ลบ `_timelineAreaKey`
- Simplify `_checkAndShowFeatureTour()`

---

#### TASK 6: Cleanup
**Priority: LOW**

- ลบ unused imports จาก onboarding_screen.dart
- ลบ unused fields จาก UserProfile (optional — backward compat)
- Update `main.dart` ถ้าจำเป็น
- Run `dart fix --apply` + `dart format .`
- Test ทั้ง fresh install + existing user

---

## 8. File Changes

### Files to Modify
| File | Change |
|------|--------|
| `lib/core/constants/enums.dart` | เพิ่ม `FoodSearchMode` enum |
| `lib/core/ai/gemini_service.dart` | เพิ่ม search mode ใน prompt |
| `lib/core/ai/gemini_chat_service.dart` | เพิ่ม search mode support |
| `lib/features/onboarding/presentation/onboarding_screen.dart` | **Rewrite** — 3 pages |
| `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart` | **Rewrite** — 3 steps |
| `lib/features/onboarding/models/tutorial_step.dart` | Simplify enum |
| `lib/features/home/widgets/feature_tour.dart` | Simplify |
| `lib/features/home/presentation/home_screen.dart` | Simplify tour |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | เพิ่ม search mode ตอน re-search ingredient |
| `lib/features/health/presentation/image_analysis_preview_screen.dart` | เพิ่ม search mode toggle (หน้าหลัก) |
| `lib/features/health/presentation/food_preview_screen.dart` | เพิ่ม search mode toggle |

### Files to Create
| File | Purpose |
|------|---------|
| `lib/core/widgets/search_mode_selector.dart` | Reusable search mode toggle widget |

### Files to Consider Deleting (ภายหลัง)
| File | Reason |
|------|--------|
| `lib/core/utils/tdee_calculator.dart` | ไม่ใช้ใน onboarding แล้ว (ลบได้ถ้า Profile ไม่ใช้) |

---

## 9. Migration & Compatibility

### Existing Users (มี onboardingComplete = true)
- **ไม่กระทบ** — ข้ามทั้ง onboarding + tutorial
- Feature Tour จะ simplified (ถ้ายังไม่เคยเห็น)
- Search mode จะ default เป็น `normal` (เหมือนเดิม)

### New Users
- เห็น onboarding ใหม่ 3 หน้า
- ทำ tutorial ใหม่ 3 steps
- UserProfile สร้างแบบ minimal (`onboardingComplete = true` เท่านั้น)
- ตั้ง calorie goal เอง ทีหลังใน Profile

### UserProfile Schema
- ไม่ลบ fields เดิม (gender, age, weight, height) — backward compat
- แค่ไม่บังคับกรอกตอน onboarding
- User สามารถไปกรอกเองใน Profile ทีหลังได้ (ถ้าอยากใช้ TDEE)

### Disclaimer
- ย้ายจาก popup dialog → inline text ใน Onboarding Page 1
- SharedPreferences key `'disclaimer_acknowledged'` → set `true` เมื่อผ่าน onboarding
- Existing users ที่มี key นี้แล้ว → ไม่กระทบ

---

## Implementation Order

```
TASK 1: Search Mode Data Model & AI Prompt
    ↓
TASK 2: Search Mode UI Widget
    ↓  
TASK 3: Onboarding Redesign (ใช้ SearchModeSelector)
    ↓
TASK 4: Tutorial Redesign (ใช้ SearchModeSelector)
    ↓
TASK 5: Feature Tour Simplification
    ↓
TASK 6: Cleanup & Testing
```

**Estimated effort:** 2-3 days for a senior dev

---

## Notes

- ทุก text ควร support i18n (EN/TH) ผ่าน `L10n`
- Animation ทุกตัวต้อง respect `MediaQuery.disableAnimations`
- Tutorial ต้อง skip ได้ทุก step
- Search mode เป็น optional — ถ้า user ไม่เลือก จะ default เป็น `normal`
- Product mode ยังเป็น "best effort" — ถ้า AI ไม่รู้จักสินค้า จะ fallback เป็น estimation
