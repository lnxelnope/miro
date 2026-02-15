# Chat System Upgrade Plan — v1.1.0

## Overview

อัปเกรดระบบ Chat ให้ผู้ใช้เลือกได้ระหว่าง **Local AI (ฟรี)** กับ **Miro AI (Gemini, 1 Energy/chat)**
พร้อม Smart Conversation, Multi-language support, และ Quick FAQ buttons

---

## 1. Dual AI Mode — Local AI vs Miro AI

### 1.1 UI: Mode Switcher (ใน Chat Screen)

**ตำแหน่ง:** AppBar หรือ ด้านบนของ chat area

```
┌─────────────────────────────────┐
│  [🧠 Local AI]  [⚡ Miro AI]   │  ← Toggle / SegmentedButton
│   Free • EN only    1⚡/chat    │
└─────────────────────────────────┘
```

**State Management:**
- เพิ่ม `chatAiModeProvider` ใน `chat_provider.dart`
- ค่า: `ChatAiMode.local` | `ChatAiMode.miroAi`
- Default: `ChatAiMode.local` (ฟรี ไม่เสีย Energy)

### 1.2 Local AI Mode (เดิม — ปรับปรุง)

- **ฟรี 100%** — ไม่ใช้ Energy
- **รองรับเฉพาะภาษาอังกฤษ** — แจ้ง user ชัดเจน
- **ความแม่นยำต่ำ** — ใช้ regex-based parsing (ไม่ใช่ AI จริง)
- **Flow เดิม:** `ChatProcessor → LLMService._localFallback() → IntentHandler`
- **ข้อจำกัด:**
  - ไม่รองรับภาษาอื่นนอกจากอังกฤษ
  - แยกอาหารได้แค่ comma/and separated
  - ไม่สามารถเข้าใจ context ซับซ้อน
  - ไม่มี smart conversation

### 1.3 Miro AI Mode (ใหม่ — Gemini Backend)

- **ใช้ 1 Energy ต่อ 1 ข้อความ** — แจ้ง user ก่อนส่ง
- **รองรับทุกภาษา** — Gemini เข้าใจ Thai, English, Japanese, etc.
- **ความแม่นยำสูง** — AI วิเคราะห์จริง
- **Flow ใหม่:** `ChatNotifier → GeminiService._callBackend(type: 'chat') → Parse response → Save entries`

---

## 2. Miro AI — Multi-Food Parsing (หัวใจหลัก)

### 2.1 Prompt Design

ส่ง prompt ให้ Gemini แยกรายการอาหารจากข้อความ:

```
User message: "วันนี้ผมทานผัดกระเพราะหมูเป็นอาหารเช้า มื้อเที่ยงทานเป็นก๋วยเตี๋ยวหมู ตอนเย็นทานพิซซ่าไป 4 ชิ้น ครับ"
```

**Expected JSON response จาก Gemini:**

```json
{
  "type": "food_log",
  "items": [
    {
      "food_name": "Stir-fried basil pork",
      "food_name_local": "ผัดกะเพราหมู",
      "meal_type": "breakfast",
      "serving_size": 1.0,
      "serving_unit": "plate",
      "calories": 450,
      "protein": 25,
      "carbs": 45,
      "fat": 18
    },
    {
      "food_name": "Pork noodle soup",
      "food_name_local": "ก๋วยเตี๋ยวหมู",
      "meal_type": "lunch",
      "serving_size": 1.0,
      "serving_unit": "bowl",
      "calories": 350,
      "protein": 20,
      "carbs": 40,
      "fat": 12
    },
    {
      "food_name": "Pizza",
      "food_name_local": "พิซซ่า",
      "meal_type": "dinner",
      "serving_size": 4.0,
      "serving_unit": "slice",
      "calories": 1100,
      "protein": 48,
      "carbs": 120,
      "fat": 48
    }
  ],
  "reply": "บันทึกแล้ว 3 รายการ! วันนี้ทานไป 1,900 kcal 💪"
}
```

### 2.2 Prompt Template

```
You are Miro, a friendly nutrition assistant.

Parse the user's message and extract ALL food items mentioned.
For each food item, provide:
- food_name: English name
- food_name_local: Original language name (as typed by user)
- meal_type: "breakfast" | "lunch" | "dinner" | "snack" (detect from context/time mentioned)
- serving_size: number (default 1 if not specified)
- serving_unit: unit (use "serving" if no unit available in app: plate, cup, bowl, piece, box, pack, bag, bottle, glass, egg, ball, item, slice, pair, stick, g, kg, ml, l, serving, tbsp, tsp, oz, lbs)
- calories, protein, carbs, fat: estimated values (best effort)

If user doesn't specify a unit, use "serving".
If user doesn't specify meal_type, detect from time context or default to current time.

IMPORTANT: Respond in the SAME LANGUAGE as the user's message.

Return JSON only, no markdown.
```

### 2.3 Serving Unit Validation

ถ้า Gemini ส่ง unit ที่ไม่อยู่ในระบบ → fallback เป็น `"serving"`

**Valid units ในระบบ:**
```
plate, cup, bowl, piece, box, pack, bag, bottle, glass, egg, ball, 
item, slice, pair, stick, g, kg, ml, l, serving, tbsp, tsp, oz, lbs
```

---

## 3. Smart Conversation

### 3.1 Greeting เมื่อเปลี่ยนมาใช้ Miro AI

เมื่อ user toggle ไปที่ Miro AI ให้แสดง greeting message อัตโนมัติ:

**Flow:**
1. User กดเปลี่ยนเป็น "Miro AI"
2. ระบบดึง `todayCaloriesProvider` + `healthGoalProvider`
3. คำนวณ remaining calories
4. แสดง greeting bubble

**ตัวอย่าง:**

```
🤖 สวัสดีครับ! วันนี้คุณยังทานได้อีก 1,200 kcal
   จะบันทึกมื้ออาหารเลยมั้ยครับ? 😊

   [📝 บันทึกอาหาร]  [🍽️ แนะนำเมนู]  [📊 สรุปสัปดาห์]
```

**กรณีไม่มีรายการอาหารเลย:**
```
🤖 สวัสดีครับ! วันนี้ยังไม่มีรายการอาหารเลย
   เป้าหมายวันนี้ 2,000 kcal — จะเริ่มบันทึกเลยมั้ยครับ? 🍽️

   [📝 บันทึกอาหาร]  [🍽️ แนะนำเมนู]  [📊 สรุปสัปดาห์]
```

**กรณีทานเกินเป้า:**
```
🤖 สวัสดีครับ! วันนี้คุณทานไปแล้ว 2,500 kcal
   เกินเป้า 500 kcal นะครับ — พรุ่งนี้ลดลงนิดนึงนะ 💪

   [📝 บันทึกอาหารเพิ่ม]  [📊 สรุปสัปดาห์]  [📊 สรุปเดือน]
```

### 3.2 Language Detection

- Greeting ให้ใช้ภาษาตาม **system locale** หรือ **ภาษาล่าสุดที่ user ใช้**
- เก็บ `lastLanguage` ใน SharedPreferences
- Miro AI จะตอบกลับด้วยภาษาเดียวกับที่ user พิมพ์มา

---

## 4. Quick FAQ Buttons (ไม่ต้องพิมพ์)

### 4.1 Quick Actions เมื่ออยู่ในโหมด Miro AI

**แสดงเป็น scrollable chips ใต้ข้อความ (แทนที่ quick actions เดิม):**

| Button | Action | Energy Cost |
|--------|--------|-------------|
| 📝 บันทึกอาหาร | แสดง hint: "บอกได้เลยว่าวันนี้ทานอะไรบ้าง" | 0 (แค่ hint) |
| 🍽️ แนะนำเมนู | AI แนะนำ 3 เมนู (ใช้ภาษา user เป็นฐานเลือก cuisine) | 1 ⚡ |
| 📊 สรุปสัปดาห์นี้ | สรุป calories สัปดาห์นี้ (ขาด/เกิน เป้า) | 0 (local query) |
| 📊 สรุปเดือนนี้ | สรุป calories เดือนนี้ (ขาด/เกิน เป้า) | 0 (local query) |
| 💡 เทคนิคลดน้ำหนัก | AI ให้ tips ส่วนตัว | 1 ⚡ |

### 4.2 Quick Actions เมื่ออยู่ในโหมด Local AI

| Button | Action | Energy Cost |
|--------|--------|-------------|
| 🍔 Log Food | "What did I eat" | Free |
| 📊 Today's Summary | "How many calories today" | Free |
| ❓ Help | แสดง format guide | Free |

### 4.3 แนะนำเมนู (Miro AI)

**Prompt:**
```
Based on the user's recent food log, suggest 3 meal ideas.
Consider: cuisine preference (detect from user's language and past meals),
remaining calorie budget for today, macro balance.

Respond in the user's language.
```

**Expected output:**
```
🤖 จากที่ดูรายการอาหารของคุณ แนะนำ 3 เมนูนี้ครับ:

1. 🥗 สลัดอกไก่ย่าง (~350 kcal)
   P: 35g | C: 20g | F: 12g
   
2. 🍱 ข้าวกล้อง + ปลาทอด (~450 kcal)
   P: 28g | C: 50g | F: 15g
   
3. 🥚 ไข่ต้ม 2 ฟอง + ขนมปังโฮลวีท (~280 kcal)
   P: 18g | C: 30g | F: 10g

ทานเมนูไหนก็บอกมาได้เลยครับ ผมบันทึกให้! 😊
```

### 4.4 สรุปสัปดาห์/เดือน

**ไม่ใช้ Energy** — Query จาก local database

**ตัวอย่าง output:**
```
📊 สรุปสัปดาห์นี้ (10-14 ก.พ. 2026)

📅 วันจันทร์:  1,800 kcal ✅ (ต่ำกว่าเป้า 200)
📅 วันอังคาร:  2,300 kcal ⚠️ (เกินเป้า 300)
📅 วันพุธ:     1,950 kcal ✅ (ต่ำกว่าเป้า 50)
📅 วันพฤหัส:   2,100 kcal ⚠️ (เกินเป้า 100)
📅 วันศุกร์:   1,750 kcal ✅ (ต่ำกว่าเป้า 250)

🔥 เฉลี่ย: 1,980 kcal/วัน
🎯 เป้าหมาย: 2,000 kcal/วัน
📈 ผลรวม: ต่ำกว่าเป้า 100 kcal — ดีมาก! 💪
```

---

## 5. Energy Confirmation Before Send (Miro AI)

### 5.1 Energy Check Flow

```
User พิมพ์ข้อความ → กด Send
       ↓
   [ตรวจ mode]
       ↓
   Local AI → ส่งเลย (ฟรี)
   Miro AI  → เช็ค Energy
       ↓
   Energy >= 1 → ส่ง + แสดง "⚡ -1 Energy"
   Energy == 0 → แสดง Dialog "Energy หมด" + link ไป Energy Store
```

### 5.2 UI Indicator

แสดง badge เล็กๆ ข้าง Send button เมื่ออยู่ในโหมด Miro AI:

```
┌──────────────────────────────────────────┐
│  [พิมพ์ข้อความ...]     [⚡1] [▶ Send]  │
└──────────────────────────────────────────┘
```

**หมายเหตุ:** Quick FAQ ที่เป็น local query (สรุปสัปดาห์/เดือน) **ไม่ใช้ Energy** แม้อยู่ในโหมด Miro AI

---

## 6. Files ที่ต้องแก้ไข

### 6.1 New Files
| File | Description |
|------|-------------|
| `lib/features/chat/models/chat_ai_mode.dart` | Enum `ChatAiMode { local, miroAi }` |
| `lib/core/ai/gemini_chat_service.dart` | Service สำหรับส่ง chat text ไป Gemini Backend |

### 6.2 Modified Files
| File | Changes |
|------|---------|
| `lib/features/chat/presentation/chat_screen.dart` | เพิ่ม AI mode toggle, Smart greeting, Quick FAQ buttons (แยกตาม mode) |
| `lib/features/chat/providers/chat_provider.dart` | เพิ่ม `chatAiModeProvider`, แก้ `sendMessage()` ให้แยก flow ตาม mode |
| `lib/features/chat/services/intent_handler.dart` | เพิ่ม `_handleMiroAiResponse()` สำหรับ parse response จาก Gemini |
| `lib/core/ai/gemini_service.dart` | เพิ่ม method `analyzeChat()` สำหรับ chat text analysis |
| `docs/terms-of-service.html` | เพิ่ม Section 4.4: AI Chat Feature |

### 6.3 Modified (Backend)
| File | Changes |
|------|---------|
| `functions/index.js` | เพิ่ม type `'chat'` ใน `analyzeFood` function (หรือสร้าง function ใหม่) |

---

## 7. Terms of Service Update

### เพิ่ม Section ใน `docs/terms-of-service.html`:

```html
<h3>4.4 AI Chat Feature</h3>
<ul>
    <li>Miro Cal offers two chat modes:</li>
    <li><strong>Local AI (Free):</strong>
        <ul>
            <li>Uses on-device text processing (regex-based)</li>
            <li><strong>Supports English language only</strong></li>
            <li>Lower accuracy — may not correctly parse complex food descriptions</li>
            <li>No Energy cost</li>
        </ul>
    </li>
    <li><strong>Miro AI (Powered by AI):</strong>
        <ul>
            <li>Uses cloud-based AI for intelligent food parsing</li>
            <li>Supports multiple languages</li>
            <li>Higher accuracy — can parse multiple food items from a single message</li>
            <li><strong>Costs 1 Energy per message sent</strong></li>
            <li>Energy is deducted when the message is sent, regardless of the response quality</li>
        </ul>
    </li>
    <li>AI-generated nutritional estimates are <strong>approximate values</strong> and should not be used as medical advice</li>
    <li>Menu suggestions from AI are for reference only and may not account for allergies or dietary restrictions</li>
</ul>
```

---

## 8. Implementation Priority

### Phase 1 — Core (ทำก่อน)
1. ✅ สร้าง `ChatAiMode` enum + provider
2. ✅ เพิ่ม AI mode toggle ใน Chat Screen UI
3. ✅ สร้าง `gemini_chat_service.dart` — ส่ง chat ไป Gemini
4. ✅ เพิ่ม type `'chat'` ใน Backend function
5. ✅ แก้ `ChatNotifier.sendMessage()` ให้แยก flow
6. ✅ Energy check + deduction สำหรับ Miro AI mode
7. ✅ Parse multi-food response จาก Gemini → save FoodEntry

### Phase 2 — Smart Conversation
8. ⬜ Smart greeting เมื่อเปลี่ยนไป Miro AI
9. ⬜ Quick FAQ buttons แยกตาม mode
10. ⬜ สรุปสัปดาห์/เดือน (local query, ไม่ใช้ Energy)

### Phase 3 — Enhancement
11. ⬜ แนะนำเมนู (Miro AI, ใช้ 1 Energy)
12. ⬜ Language detection + greeting language matching
13. ⬜ อัปเดต Terms of Service
14. ⬜ อัปเดต CHANGELOG

---

## 9. Technical Architecture

```
User types message
       ↓
┌─── Check AI Mode ───┐
│                      │
▼                      ▼
LOCAL AI (Free)        MIRO AI (1 Energy)
│                      │
│ LLMService           │ Check Energy balance
│ ._localFallback()    │ → if 0: show "No Energy" dialog
│ (regex parsing)      │ → if >= 1: proceed
│                      │
│ IntentHandler        │ GeminiService.analyzeChat()
│ ._handleHealth()     │ → POST to Backend (type: 'chat')
│                      │ → Gemini parses multi-food
│                      │ → Returns JSON with items[]
│                      │
│ Save FoodEntry       │ Parse items[] → Save FoodEntry[]
│ (single item)        │ (multiple items, with meal_type)
│                      │
▼                      ▼
Show reply             Show reply (same language as user)
```

---

## 10. Example User Scenarios

### Scenario 1: Thai User + Miro AI
```
User: "วันนี้ผมทานผัดกระเพราะหมูเป็นอาหารเช้า มื้อเที่ยงทานเป็นก๋วยเตี๋ยวหมู ตอนเย็นทานพิซซ่าไป 4 ชิ้น ครับ"

Miro AI Response:
✅ บันทึกแล้ว 3 รายการ!

🌅 มื้อเช้า:
  🍽️ ผัดกะเพราหมู (1 plate) — 450 kcal
  💪 P: 25g | C: 45g | F: 18g

🌞 มื้อเที่ยง:
  🍜 ก๋วยเตี๋ยวหมู (1 bowl) — 350 kcal
  💪 P: 20g | C: 40g | F: 12g

🌙 มื้อเย็น:
  🍕 พิซซ่า (4 slice) — 1,100 kcal
  💪 P: 48g | C: 120g | F: 48g

🔥 รวมวันนี้: 1,900 kcal (เหลืออีก 100 kcal ถึงเป้า)
⚡ -1 Energy
```

### Scenario 2: English User + Local AI
```
User: "pork 50g and rice 200g"

Local AI Response:
✅ Logged 2 items! (Lunch)

  • ⚠️ pork (50 g) — 0 kcal
  • ⚠️ rice (200 g) — 0 kcal

🔥 Total: 0 kcal

⚠️ No nutrition data yet
💡 Tap Gemini at Health screen to analyze
```

### Scenario 3: Japanese User + Miro AI
```
User: "今日の朝ごはんは卵焼き2つとご飯を食べました"

Miro AI Response:
✅ 2件記録しました！

🌅 朝食:
  🥚 卵焼き (2 piece) — 180 kcal
  🍚 ご飯 (1 bowl) — 235 kcal

🔥 合計: 415 kcal
⚡ -1 Energy
```

---

## 11. Feature Tour / Guided Tutorial (ผู้ใช้เข้ามาครั้งแรก)

### 11.1 Overview

เพิ่มระบบ **Guided Tour** สำหรับผู้ใช้ที่เข้าใช้ Home Screen ครั้งแรก (หลัง Onboarding)
ใช้รูปแบบ **Coach Mark / Spotlight Overlay** — ไฮไลท์ส่วนสำคัญทีละจุด พร้อมคำอธิบาย

**Trigger:** ครั้งแรกที่เข้า HomeScreen หลัง onboarding (เช็คจาก SharedPreferences: `tutorial_completed`)

### 11.2 Tour Steps (3 จุด)

```
Step 1 → Step 2 → Step 3 → Done!
Energy    Pull-to    Chat
Badge     Refresh    System
```

---

#### Step 1: Energy Badge (มุมบนซ้าย)

**ตำแหน่ง:** ชี้ไปที่ `EnergyBadgeRiverpod()` ใน AppBar leading

```
┌─────────────────────────────────┐
│ [⚡ 1000]  MIRO           [👤] │
│  ↑ spotlight                    │
│  ┌──────────────────────┐       │
│  │ ⚡ This is your      │       │
│  │    Energy Balance     │       │
│  │                       │       │
│  │ Each AI analysis      │       │
│  │ costs 1 Energy.       │       │
│  │                       │       │
│  │ You start with 100    │       │
│  │ FREE Energy!          │       │
│  │                       │       │
│  │ Tap to visit the      │       │
│  │ Energy Store.         │       │
│  │                       │       │
│  │ [Next →]              │       │
│  └──────────────────────┘       │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**UI:**
- Dimmed overlay ทั้งจอ (สีดำ 60% opacity)
- Spotlight circle/rounded-rect ที่ Energy Badge (cutout)
- Tooltip card ชี้ไปที่ badge
- ปุ่ม "Next" เพื่อไปขั้นตอนถัดไป
- ปุ่ม "Skip" เล็กๆ มุมบนขวาเพื่อข้ามทั้งหมด

---

#### Step 2: Pull to Refresh — Photo Auto-Scan

**ตำแหน่ง:** ชี้ไปที่กลางหน้าจอ (บริเวณ food timeline area)

```
┌─────────────────────────────────┐
│ [⚡ 1000]  MIRO           [👤] │
│                                 │
│      ┌──────────────────┐       │
│      │  ↕️ Pull Down     │       │
│      │  to Auto-Scan     │       │
│      │                   │       │
│      │  Swipe down on    │       │
│      │  the food list    │       │
│      │  to automatically │       │
│      │  scan your photo  │       │
│      │  gallery for food │       │
│      │  images!          │       │
│      │                   │       │
│      │  Found food       │       │
│      │  photos will be   │       │
│      │  added to your    │       │
│      │  timeline.        │       │
│      │                   │       │
│      │  [Next →]         │       │
│      └──────────────────┘       │
│                                 │
│  ↓↓↓ animated pull gesture ↓↓↓ │
│                                 │
└─────────────────────────────────┘
```

**UI:**
- Dimmed overlay ทั้งจอ
- Spotlight ตรงกลาง (บริเวณ timeline list)
- **Animated pull-down gesture** (ลูกศรเลื่อนลงแสดง visual cue)
- Tooltip card อธิบายว่า "Pull down = สแกนรูปอาหารอัตโนมัติ"

---

#### Step 3: Chat System — 2 โหมด

**ตำแหน่ง:** ชี้ไปที่ MagicButton (FAB ล่างขวา) ซึ่งเปิดไปหน้า Chat

```
┌─────────────────────────────────┐
│ [⚡ 1000]  MIRO           [👤] │
│                                 │
│                                 │
│                                 │
│                                 │
│  ┌──────────────────────┐       │
│  │ 💬 Chat with Miro!   │       │
│  │                       │       │
│  │ Two modes available:  │       │
│  │                       │       │
│  │ 🧠 Local AI (Free)   │       │
│  │  • English only       │       │
│  │  • Basic food logging │       │
│  │                       │       │
│  │ ⚡ Miro AI (1 Energy) │       │
│  │  • Any language       │       │
│  │  • Smart parsing      │       │
│  │  • Menu suggestions   │       │
│  │  • Nutrition estimates│       │
│  │                       │       │
│  │ [Got it! ✓]           │       │
│  └──────────────────────┘       │
│                         [✨]    │
│                          ↑      │
│                      spotlight  │
└─────────────────────────────────┘
```

**UI:**
- Dimmed overlay
- Spotlight ที่ MagicButton (FAB)
- Tooltip card อธิบาย 2 โหมด
- ปุ่ม "Got it!" ปิด tutorial ทั้งหมด

---

### 11.3 Technical Implementation

#### Package ที่แนะนำ

| Package | Stars | Description |
|---------|-------|-------------|
| `tutorial_coach_mark` | 600+ | Coach mark with spotlight overlay |
| `showcaseview` | 1.3K+ | Step-by-step widget showcase |
| **Custom implementation** | — | ใช้ `Overlay` + `CustomPainter` + `AnimationController` |

**แนะนำ:** ใช้ `tutorial_coach_mark` เพราะ:
- รองรับ spotlight cutout ที่ widget
- มี animation built-in
- รองรับ step-by-step flow
- ไม่ต้องเขียน overlay เอง

#### State Management

```dart
// SharedPreferences key
const String _keyTutorialCompleted = 'feature_tour_completed';

// เช็คใน HomeScreen.initState()
Future<void> _checkAndShowTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool(_keyTutorialCompleted) ?? false;
  
  if (!completed) {
    // รอให้ UI render ก่อน (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _showFeatureTour();
    }
  }
}

// บันทึกเมื่อ tutorial เสร็จ
Future<void> _completeTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyTutorialCompleted, true);
}
```

#### GlobalKeys สำหรับ Target Widgets

```dart
// ใน HomeScreen
final _energyBadgeKey = GlobalKey();    // Step 1: Energy Badge
final _timelineAreaKey = GlobalKey();    // Step 2: Pull-to-refresh area
final _magicButtonKey = GlobalKey();     // Step 3: Chat FAB

// ผูก key กับ widget
leading: Padding(
  key: _energyBadgeKey,  // ← เพิ่ม key
  child: const EnergyBadgeRiverpod(),
),

// MagicButton
floatingActionButton: MagicButton(key: _magicButtonKey),
```

### 11.4 Tour Content (Multi-language Ready)

```dart
class TourContent {
  // Step 1: Energy
  static const energyTitle = 'Energy System ⚡';
  static const energyBody = 
    'This is your Energy balance.\n\n'
    'Each AI food analysis costs 1 Energy.\n'
    'You start with 100 FREE Energy!\n\n'
    'Tap here to visit the Energy Store.';
  
  // Step 2: Pull to Refresh
  static const pullRefreshTitle = 'Auto Photo Scan 📸';
  static const pullRefreshBody = 
    'Pull down on the food list to automatically '
    'scan your photo gallery for food images!\n\n'
    'Found food photos will be added to your timeline.\n'
    'You can then analyze them with AI.';
  
  // Step 3: Chat
  static const chatTitle = 'Chat with Miro 💬';
  static const chatBody = 
    'Two modes available:\n\n'
    '🧠 Local AI (Free)\n'
    '  • English only\n'
    '  • Basic food logging\n\n'
    '⚡ Miro AI (1 Energy/chat)\n'
    '  • Any language\n'
    '  • Smart multi-food parsing\n'
    '  • Menu suggestions\n'
    '  • Nutrition estimates';
}
```

### 11.5 Timing & Flow

```
Onboarding (4 pages) → HomeScreen
                           ↓
                   isFirstLaunch?
                    ↓          ↓
                   Yes         No
                    ↓          ↓
            Permission       (skip)
            Dialog
                    ↓
             Feature Tour    ← NEW (after permissions dialog closes)
            (3 steps)
                    ↓
           Save tutorial_completed = true
                    ↓
              Normal app usage
```

**สำคัญ:** Feature Tour ต้องแสดง **หลัง Permission Dialog ปิดแล้ว** ไม่ใช่ซ้อนกัน

```dart
// ใน HomeScreen.initState
WidgetsBinding.instance.addPostFrameCallback((_) async {
  await _checkAndRequestPermissions();  // Permission dialog first
  await _checkAndShowTutorial();        // Tutorial after (if first launch)
  if (mounted) {
    GeminiService.setContext(context);
  }
});
```

### 11.6 Re-access Tutorial

ผู้ใช้สามารถดู tutorial อีกครั้งได้จาก **Profile Screen**:

```
Profile → Help & Tutorial → "Show Feature Tour Again"
```

ลบ `tutorial_completed` flag → แสดง tour อีกครั้งเมื่อกลับไป HomeScreen

### 11.7 Files ที่ต้องแก้ไข

| File | Changes |
|------|---------|
| `pubspec.yaml` | เพิ่ม `tutorial_coach_mark` dependency |
| `lib/features/home/presentation/home_screen.dart` | เพิ่ม GlobalKeys, tutorial trigger, tour steps |
| `lib/features/home/widgets/feature_tour.dart` | **NEW** — Tour configuration & steps |
| `lib/features/home/widgets/magic_button.dart` | รับ GlobalKey param |
| `lib/features/profile/presentation/profile_screen.dart` | เพิ่มปุ่ม "Show Tutorial Again" |

---

## 12. Risk & Mitigation

| Risk | Mitigation |
|------|------------|
| Gemini returns invalid JSON | Wrap in try-catch, fallback to raw text reply |
| Gemini estimates wrong calories | Disclaimer: "AI estimates — tap to edit" |
| User sends non-food message to Miro AI | Gemini should detect and reply conversationally (still costs 1 Energy) |
| Energy deducted but Gemini fails | Retry logic (3 attempts) — Energy deducted only on success |
| User spams Miro AI to drain Energy | Confirmation badge "⚡1" visible, user consent implied by pressing Send |
| User skips tutorial too fast | "Show Tutorial Again" in Profile |
| Tutorial blocks important UI | Skip button always visible, dimmed overlay is tappable to skip |

---

## 13. Updated Implementation Priority

### Phase 1 — Core Chat Upgrade (ทำก่อน)
1. ⬜ สร้าง `ChatAiMode` enum + provider
2. ⬜ เพิ่ม AI mode toggle ใน Chat Screen UI
3. ⬜ สร้าง `gemini_chat_service.dart` — ส่ง chat ไป Gemini
4. ⬜ เพิ่ม type `'chat'` ใน Backend function
5. ⬜ แก้ `ChatNotifier.sendMessage()` ให้แยก flow
6. ⬜ Energy check + deduction สำหรับ Miro AI mode
7. ⬜ Parse multi-food response จาก Gemini → save FoodEntry

### Phase 2 — Smart Conversation + FAQ
8. ⬜ Smart greeting เมื่อเปลี่ยนไป Miro AI
9. ⬜ Quick FAQ buttons แยกตาม mode
10. ⬜ สรุปสัปดาห์/เดือน (local query, ไม่ใช้ Energy)

### Phase 3 — Feature Tour (Guided Tutorial)
11. ⬜ เพิ่ม `tutorial_coach_mark` dependency
12. ⬜ สร้าง Feature Tour (3 steps: Energy, Pull-to-refresh, Chat)
13. ⬜ เพิ่ม "Show Tutorial Again" ใน Profile

### Phase 4 — Polish & Legal
14. ⬜ แนะนำเมนู (Miro AI, ใช้ 1 Energy)
15. ⬜ Language detection + greeting language matching
16. ⬜ อัปเดต Terms of Service
17. ⬜ อัปเดต CHANGELOG

---

## 14. Summary

| Feature | Local AI | Miro AI |
|---------|----------|---------|
| Price | Free | 1 Energy/chat |
| Language | English only | All languages |
| Accuracy | Low (regex) | High (Gemini AI) |
| Multi-food parsing | Basic (comma/and) | Advanced (context-aware) |
| Nutrition estimates | None (0 kcal) | AI-estimated |
| Smart greeting | No | Yes |
| Menu suggestions | No | Yes (1 Energy) |
| Weekly/Monthly summary | Basic text | Rich formatted |
| Meal type detection | Time-based only | Context-aware |
