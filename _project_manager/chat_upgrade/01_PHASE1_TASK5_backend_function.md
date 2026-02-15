# Phase 1 Task 5: อัปเดต Backend Function (Firebase)

## เป้าหมาย
เพิ่มการรองรับ `type: 'chat'` ใน Firebase Function

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `functions/index.js`

### 2. หา function `analyzeFood` 

มองหา:
```javascript
exports.analyzeFood = functions.https.onRequest(async (req, res) => {
```

### 3. แก้ไข prompt สำหรับ type: 'chat'

หาส่วนที่สร้าง prompt และเพิ่ม condition สำหรับ chat:

```javascript
// ประมาณบรรทัดที่มี: if (type === 'photo') { ... }

let prompt;

if (type === 'chat') {
  // NEW: Chat text analysis
  prompt = `You are Miro, a friendly nutrition assistant.

Parse the user's message and extract ALL food items mentioned.
For each food item, provide:
- food_name: English name
- food_name_local: Original language name (as typed by user, keep original script - Thai, Japanese, Chinese, etc.)
- meal_type: "breakfast" | "lunch" | "dinner" | "snack" (detect from context/time mentioned, default to current time if not specified)
- serving_size: number (default 1 if not specified)
- serving_unit: one of these units ONLY [plate, cup, bowl, piece, box, pack, bag, bottle, glass, egg, ball, item, slice, pair, stick, g, kg, ml, l, serving, tbsp, tsp, oz, lbs]. If user doesn't specify or uses unsupported unit, use "serving"
- calories, protein, carbs, fat: estimated values (best effort)

IMPORTANT: 
- Respond in ENGLISH only (but keep food_name_local in original language)
- Return JSON only, no markdown code blocks
- If the message is not about food, respond with a friendly conversational reply

Expected JSON format:
{
  "type": "food_log",
  "items": [
    {
      "food_name": "...",
      "food_name_local": "...",
      "meal_type": "...",
      "serving_size": 1.0,
      "serving_unit": "...",
      "calories": 0,
      "protein": 0,
      "carbs": 0,
      "fat": 0
    }
  ],
  "reply": "Logged X items! Today's total: XXX kcal 💪"
}

User message: "${text}"`;

} else if (type === 'photo') {
  // Existing photo analysis prompt
  prompt = `Analyze this food image...`;
  // ... existing code
} else {
  // Invalid type
  return res.status(400).json({ error: 'Invalid type. Must be "photo" or "chat"' });
}
```

### 4. ตรวจสอบ input validation

หาส่วน validation ด้านบน และเพิ่ม:

```javascript
// Extract parameters
const { type, text, imageBase64, deviceId } = req.body;

// Validate
if (!type || !deviceId) {
  return res.status(400).json({ error: 'Missing required fields' });
}

if (type === 'chat' && !text) {
  return res.status(400).json({ error: 'Missing text for chat type' });
}

if (type === 'photo' && !imageBase64) {
  return res.status(400).json({ error: 'Missing imageBase64 for photo type' });
}
```

### 5. Serving Unit Validation (สำคัญ!)

หลังจากได้ response จาก Gemini แล้ว เพิ่มการ validate serving_unit:

```javascript
// After getting Gemini response
const validUnits = [
  'plate', 'cup', 'bowl', 'piece', 'box', 'pack', 'bag', 
  'bottle', 'glass', 'egg', 'ball', 'item', 'slice', 'pair', 
  'stick', 'g', 'kg', 'ml', 'l', 'serving', 'tbsp', 'tsp', 'oz', 'lbs'
];

// Validate and fix units in response
if (analysisResult.items && Array.isArray(analysisResult.items)) {
  analysisResult.items.forEach(item => {
    if (!validUnits.includes(item.serving_unit)) {
      console.warn(`Invalid unit "${item.serving_unit}" replaced with "serving"`);
      item.serving_unit = 'serving';
    }
  });
}
```

## ตัวอย่าง Request/Response

### Request
```json
{
  "type": "chat",
  "text": "I ate fried rice for breakfast and pizza 2 slices for dinner",
  "deviceId": "device123"
}
```

### Response
```json
{
  "type": "food_log",
  "items": [
    {
      "food_name": "Fried rice",
      "food_name_local": "fried rice",
      "meal_type": "breakfast",
      "serving_size": 1,
      "serving_unit": "plate",
      "calories": 450,
      "protein": 12,
      "carbs": 70,
      "fat": 15
    },
    {
      "food_name": "Pizza",
      "food_name_local": "pizza",
      "meal_type": "dinner",
      "serving_size": 2,
      "serving_unit": "slice",
      "calories": 550,
      "protein": 24,
      "carbs": 60,
      "fat": 24
    }
  ],
  "reply": "Logged 2 items! Today's total: 1,000 kcal 💪"
}
```

## ทดสอบ Backend

### ทดสอบด้วย curl:
```bash
curl -X POST https://YOUR_FUNCTION_URL \
  -H "Content-Type: application/json" \
  -d '{
    "type": "chat",
    "text": "chicken breast 200g and rice 1 cup",
    "deviceId": "test123"
  }'
```

## เสร็จแล้ว
✅ Task 5 เสร็จ — Backend พร้อมแล้ว
➡️ ไปต่อ Task 6: `01_PHASE1_TASK6_chat_notifier_send_message.md`
