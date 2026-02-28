# Task 3: Free AI Logic (Backend)

**ระยะเวลา:** 2 วัน  
**Complexity:** 🟡 Medium  
**ต้องรู้:** TypeScript, Cloud Functions, Firestore Transactions

---

## 🎯 สิ่งที่ต้องทำ

แก้ไข `analyzeFood` Cloud Function เพื่อให้ใช้ AI ครั้งแรกของวันฟรี (ไม่หัก energy)

### เป้าหมาย
1. เพิ่ม Free AI check logic
2. แก้ไข analyzeFood ให้รองรับ free AI
3. Reset free AI ทุกวัน (lazy reset)

---

## 📚 ความรู้ที่ต้องมี

### Logic: Free AI

```
เมื่อ user เรียก analyzeFood:

1. ดึง user document จาก users/{deviceId}
2. เช็คว่า freeAiLastReset เป็นวันนี้หรือยัง
   - ถ้าไม่ใช่ → reset freeAiUsedToday = false
3. ถ้า freeAiUsedToday === false:
   → ไม่หัก energy!
   → set freeAiUsedToday = true
4. ถ้า freeAiUsedToday === true:
   → หัก energy ปกติ
```

### Timeline Example

```
Day 1:
  08:00 → use AI → freeAiUsedToday: false → ฟรี! → set true
  10:00 → use AI → freeAiUsedToday: true → หัก energy
  12:00 → use AI → freeAiUsedToday: true → หัก energy

Day 2:
  09:00 → use AI → freeAiLastReset != today → reset! → ฟรี!
  11:00 → use AI → freeAiUsedToday: true → หัก energy
```

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 3.1: แก้ไข analyzeFood.ts

**ที่อยู่:** `functions/src/analyzeFood.ts`

**เพิ่ม helper functions:**

```typescript
/**
 * ดึงวันที่ปัจจุบันตาม timezone ของ user
 * 
 * @param timezoneOffset - offset จาก UTC ในหน่วยนาที (e.g. 420 = UTC+7)
 * @returns วันที่ในรูปแบบ "YYYY-MM-DD"
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  
  // ถ้าไม่ส่ง offset มา → ใช้ UTC+7 (Thailand)
  const offset = timezoneOffset ?? 420; // 420 minutes = 7 hours
  
  // คำนวณเวลาท้องถิ่น
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  
  // Return format: "YYYY-MM-DD"
  return localTime.toISOString().split('T')[0];
}

/**
 * เช็คและจัดการ Free AI
 * 
 * @returns { isFree: boolean }
 *   isFree = true → ครั้งนี้ฟรี (ไม่หัก energy)
 */
async function checkFreeAi(
  deviceId: string,
  timezoneOffset?: number
): Promise<{ isFree: boolean }> {
  const today = getTodayString(timezoneOffset);
  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    // User ไม่มี → ไม่ฟรี (ต้อง register ก่อน)
    return { isFree: false };
  }

  const userData = userDoc.data()!;
  const lastReset = userData.freeAiLastReset || '';
  const alreadyUsed = userData.freeAiUsedToday || false;

  // ─── Case 1: วันใหม่ → reset ───
  if (lastReset !== today) {
    console.log(`🆓 [Free AI] New day! Resetting for ${deviceId}`);
    
    await userRef.update({
      freeAiUsedToday: true,
      freeAiLastReset: today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { isFree: true };
  }

  // ─── Case 2: วันเดิม + ยังไม่ใช้ → ฟรี! ───
  if (!alreadyUsed) {
    console.log(`🆓 [Free AI] First use today for ${deviceId}`);
    
    await userRef.update({
      freeAiUsedToday: true,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { isFree: true };
  }

  // ─── Case 3: วันเดิม + ใช้แล้ว → ไม่ฟรี ───
  console.log(`💰 [Free AI] Already used free AI today for ${deviceId}`);
  return { isFree: false };
}
```

**📌 จุดสำคัญ:**
- Lazy reset: เช็คตอนใช้ (ไม่ใช่ cron job)
- Timezone support: Client ส่ง offset มา
- Thread-safe: Update ทีละ user (ไม่มี race condition)

---

### Step 3.2: แก้ไข analyzeFood main handler

**ที่อยู่:** `functions/src/analyzeFood.ts`

**ก่อนเช็ค balance:**

```typescript
// ──────────────────────────────────────────
// ก่อนหน้านี้ (ประมาณบรรทัด 100-150):
// const serverBalance = await getServerBalance(deviceId);
// if (serverBalance < energyCost) { ... }
// ──────────────────────────────────────────

// ──────────────────────────────────────────
// เพิ่มส่วนนี้ข้างบน (ก่อนเช็ค balance):
// ──────────────────────────────────────────

// ดึง timezone offset จาก request
const timezoneOffset = req.body.timezoneOffset; // Client ต้องส่งมา

// เช็ค Free AI
const { isFree } = await checkFreeAi(deviceId, timezoneOffset);

if (isFree) {
  console.log(`🆓 [analyzeFood] Free AI for ${deviceId}`);

  // ────── ไม่ต้องเช็ค balance! ──────
  // เรียก Gemini API ได้เลย

  try {
    // ... เรียก Gemini API (code เดิม) ...
    const geminiResponse = await callGeminiAPI(/* ... */);

    // ดึง balance ปัจจุบัน (ไม่หัก)
    const userDoc = await db.collection('users').doc(deviceId).get();
    const currentBalance = userDoc.data()?.balance || 0;

    // บันทึก transaction (type: 'free_ai', amount: 0)
    await db.collection('transactions').add({
      deviceId,
      miroId: userDoc.data()?.miroId || 'unknown',
      type: 'free_ai',
      amount: 0, // ไม่หัก
      balanceAfter: currentBalance, // balance ไม่เปลี่ยน
      description: 'Daily free AI analysis',
      metadata: {
        requestType: type, // 'image', 'text', 'barcode', etc.
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Return response
    res.status(200).json({
      success: true,
      data: geminiResponse,
      balance: currentBalance, // balance เดิม
      energyUsed: 0,
      energyCost: 0,
      wasFreeAi: true, // ← บอก client ว่าฟรี!
    });
    return; // จบ function ตรงนี้!
  } catch (error: any) {
    console.error('❌ [Free AI] Gemini error:', error);
    res.status(500).json({ error: error.message });
    return;
  }
}

// ────── ถ้าไม่ฟรี → ทำตามเดิม (เช็ค balance + หัก energy) ──────

const serverBalance = await getServerBalance(deviceId);

if (serverBalance < energyCost) {
  res.status(402).json({ error: 'Insufficient energy' });
  return;
}

// ... code เดิม (หัก energy + เรียก Gemini) ...
```

**📌 สำคัญ:**
- Free AI → ไม่เช็ค balance
- Free AI → ไม่หัก energy
- Free AI → บันทึก transaction type='free_ai'
- Response พิเศษ: `wasFreeAi: true`

---

### Step 3.3: อัพเดท request interface

**เพิ่มใน request body schema:**

```typescript
interface AnalyzeFoodRequest {
  deviceId: string;
  type: string; // 'image', 'text', 'barcode', 'chat'
  timezoneOffset?: number; // ← ใหม่! (optional, default: 420)
  // ... fields อื่นๆ
}
```

---

### Step 3.4: Deploy analyzeFood

```bash
cd functions
firebase deploy --only functions:analyzeFood
```

---

## ✅ Checklist

```
□ เพิ่ม getTodayString() helper function
□ เพิ่ม checkFreeAi() helper function
□ แก้ไข analyzeFood main handler (free AI check ก่อนเช็ค balance)
□ บันทึก transaction type='free_ai' เมื่อใช้ free AI
□ Return wasFreeAi: true ใน response
□ Deploy analyzeFood สำเร็จ
□ ไม่มี linter errors
```

---

## 🧪 Testing

### Test Case 1: ครั้งแรกของวัน → ฟรี

**Setup:**
```bash
# ใน Firestore Console:
# Set freeAiUsedToday = false
# Set freeAiLastReset = "2026-02-16" (เมื่อวาน)
```

**Request:**
```bash
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test-device-001",
    "type": "text",
    "text": "ข้าวผัด",
    "timezoneOffset": 420
  }'
```

**Expected:**
```json
{
  "success": true,
  "data": { /* Gemini response */ },
  "balance": 100,  ← ไม่เปลี่ยน
  "energyUsed": 0,
  "energyCost": 0,
  "wasFreeAi": true  ← ฟรี!
}
```

**Verify Firestore:**
```
users/test-device-001:
  freeAiUsedToday: true     ← เปลี่ยนเป็น true
  freeAiLastReset: "2026-02-17"  ← วันนี้
  balance: 100              ← ไม่เปลี่ยน

transactions:
  - type: 'free_ai'
  - amount: 0
  - balanceAfter: 100
```

---

### Test Case 2: ครั้งที่ 2 ของวัน → หัก energy

**Request:**
```bash
# เรียก API เดิมอีกครั้ง (วันเดียวกัน)
```

**Expected:**
```json
{
  "success": true,
  "data": { /* Gemini response */ },
  "balance": 95,   ← หัก 5 energy
  "energyUsed": 5,
  "energyCost": 5,
  "wasFreeAi": false  ← ไม่ฟรี!
}
```

**Verify Firestore:**
```
users/test-device-001:
  freeAiUsedToday: true     ← ยังเป็น true
  balance: 95               ← ลดลง
```

---

### Test Case 3: วันใหม่ → ฟรีอีกครั้ง

**Setup:**
```bash
# รอข้ามวัน (หรือแก้ freeAiLastReset เป็นเมื่อวาน)
```

**Request:**
```bash
# เรียก API อีกครั้ง (วันใหม่)
```

**Expected:**
```json
{
  "wasFreeAi": true  ← ฟรีอีกครั้ง!
}
```

---

### Test Case 4: Balance = 0 + Free AI → ยังใช้ได้

**Setup:**
```bash
# Set balance = 0 ใน Firestore
# Set freeAiUsedToday = false
```

**Request:**
```bash
# เรียก API
```

**Expected:**
```json
{
  "success": true,
  "wasFreeAi": true  ← ใช้ได้! (ไม่เช็ค balance)
}
```

---

### Test Case 5: Balance = 0 + ไม่มี Free AI → Error

**Setup:**
```bash
# Set balance = 0
# Set freeAiUsedToday = true
```

**Request:**
```bash
# เรียก API
```

**Expected:**
```json
{
  "error": "Insufficient energy"
}
```

---

## ⚠️ Common Issues

### Issue 1: "Race condition - free AI ใช้ได้ 2 ครั้ง"
**อาการ:** 2 requests พร้อมกัน → ทั้งคู่ได้ free AI  
**แก้ไข:**
- ใช้ Firestore Transaction แทน update ธรรมดา:
```typescript
await db.runTransaction(async (transaction) => {
  const userDoc = await transaction.get(userRef);
  // เช็คและ update ใน transaction
});
```

### Issue 2: "Timezone ผิด → reset ไม่ตรงเวลา"
**อาการ:** User ใน Thailand ได้ free AI เวลา 07:00 (UTC)  
**แก้ไข:**
- Client ต้องส่ง `timezoneOffset` ที่ถูกต้อง
- Server ใช้ `getTodayString(offset)` เสมอ

### Issue 3: "Free AI count ผิด → ได้ free AI หลายครั้ง"
**อาการ:** freeAiUsedToday ไม่ถูก update  
**แก้ไข:**
- เช็คว่า update query ถูกต้อง
- ใช้ `.update()` ไม่ใช่ `.set()`

---

## 📌 Important Notes

1. **Server เป็น source of truth** — Client ห้ามตัดสินว่าฟรีหรือไม่
2. **Lazy reset** — ไม่ใช้ cron job (เช็คตอนใช้)
3. **Transaction type** — ต้องบันทึกเป็น 'free_ai' เพื่อ analytics
4. **Timezone support** — Client ส่ง offset มา (default: UTC+7)

---

## 📚 Related Files

- `functions/src/analyzeFood.ts` — Main file (แก้ไข)
- `functions/src/index.ts` — Export (ไม่ต้องแก้)

---

## 🔗 API Changes

### Request (เพิ่ม field)
```typescript
{
  "deviceId": "string",
  "type": "string",
  "timezoneOffset": 420  // ← ใหม่! (optional)
}
```

### Response (เพิ่ม field)
```typescript
{
  "success": true,
  "data": {},
  "balance": 100,
  "energyUsed": 0,
  "energyCost": 0,
  "wasFreeAi": true  // ← ใหม่! (true/false)
}
```

---

## ⏭️ Next Task

เมื่อทำ Task 3 เสร็จ → ไป **TASK_4_STREAK.md**
