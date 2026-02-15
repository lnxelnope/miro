/**
 * analyzeFood - Firebase Cloud Function
 * 
 * Backend API สำหรับ MIRO Energy System
 * รับคำขอจากแอป → ตรวจสอบ Energy Token → เรียก Gemini API → ส่งผลลัพธ์กลับ
 */

import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import * as crypto from 'crypto';
import fetch from 'node-fetch';
import * as admin from 'firebase-admin';

// Define secrets
const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const ENERGY_ENCRYPTION_SECRET = defineSecret('ENERGY_ENCRYPTION_SECRET');

// Initialize Firebase Admin (ถ้ายังไม่ได้ init)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ───────────────────────────────────────────────────────────
// 1. CONSTANTS & CONFIG
// ───────────────────────────────────────────────────────────

const GEMINI_API_URL = 
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

// CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, x-energy-token, x-device-id',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// ───────────────────────────────────────────────────────────
// 2. ENERGY TOKEN VALIDATION
// ───────────────────────────────────────────────────────────

interface EnergyToken {
  userId: string;      // Device ID or User ID
  balance?: number;    // ⚠️ PHASE 3: Optional (backward compatible)
  timestamp: number;   // Token creation time
  signature: string;   // HMAC signature
}

/**
 * Verify Energy Token
 * 
 * ✅ PHASE 3: รองรับ 2 formats:
 * - Old format: { userId, balance, timestamp, signature }
 * - New format: { userId, timestamp, signature } ← ไม่มี balance
 * 
 * ⚠️ balance ใน token (ถ้ามี) จะถูก IGNORE
 * Backend อ่าน balance จาก Firestore เท่านั้น
 */
function verifyEnergyToken(token: string, secret: string): EnergyToken | null {
  try {
    const decoded = JSON.parse(
      Buffer.from(token, 'base64').toString('utf-8')
    ) as EnergyToken;
    
    const { userId, timestamp, signature } = decoded;
    
    // Validate required fields
    if (!userId || !timestamp || !signature) {
      console.log('❌ [verifyToken] Missing required fields');
      return null;
    }
    
    // ✅ PHASE 3: ไม่ต้องการ balance ใน token แล้ว
    // Token เก่าอาจจะมี balance, Token ใหม่ไม่มี
    const balance = decoded.balance; // อาจจะมีหรือไม่มีก็ได้
    
    // Verify signature
    let payload: string;
    if (balance !== undefined) {
      // Old token format (มี balance)
      payload = `${userId}:${balance}:${timestamp}`;
    } else {
      // New token format (ไม่มี balance)
      payload = `${userId}:${timestamp}`;
    }
    
    const expectedSignature = generateSignature(payload, secret);
    
    if (signature !== expectedSignature) {
      console.log('❌ [verifyToken] Invalid signature');
      return null;
    }
    
    // Check expiry (5 minutes)
    const now = Date.now();
    if (now - timestamp > 5 * 60 * 1000) {
      console.log('❌ [verifyToken] Token expired');
      return null;
    }
    
    console.log(`✅ [verifyToken] Valid token for user: ${userId}`);
    
    // ⚠️ Return balance as undefined — ไม่ใช้อีกต่อไป
    // Backend จะอ่านจาก Firestore แทน
    return { 
      userId, 
      balance: undefined, // IGNORED
      timestamp,
      signature,
    };
  } catch (error) {
    console.log('❌ [verifyToken] Parse error:', error);
    return null;
  }
}

/**
 * สร้าง HMAC signature
 */
function generateSignature(payload: string, secret: string): string {
  return crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
}

// ===================================================================
// FIRESTORE HELPERS - Phase 1: Server-side Balance
// ===================================================================

/**
 * อ่าน balance จาก Firestore (Server = Source of Truth)
 * ถ้ายังไม่มี document → สร้างใหม่พร้อม welcome gift
 */
async function getServerBalance(deviceId: string): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      // New user — สร้าง document พร้อม welcome gift
      const welcomeBalance = 100;
      
      await docRef.set({
        balance: welcomeBalance,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        welcomeGiftClaimed: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`🎁 [Firestore] New user ${deviceId}: Welcome gift ${welcomeBalance}`);
      return welcomeBalance;
    }
    
    const balance = doc.data()?.balance ?? 0;
    console.log(`📊 [Firestore] User ${deviceId}: Balance = ${balance}`);
    return balance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error reading balance for ${deviceId}:`, error);
    throw new Error('Failed to read server balance');
  }
}

/**
 * หัก balance ใน Firestore (Atomic Transaction)
 * ป้องกัน race condition เมื่อมีหลาย request พร้อมกัน
 * 
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะหัก
 * @returns balance ใหม่หลังหัก
 */
async function deductServerBalance(
  deviceId: string,
  amount: number
): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    
    // ใช้ Transaction เพื่อป้องกัน race condition
    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      
      if (!doc.exists) {
        throw new Error('User not found in Firestore');
      }
      
      const currentBalance = doc.data()?.balance ?? 0;
      
      // ห้าม balance ติดลบ
      if (currentBalance < amount) {
        throw new Error(`Insufficient balance: have ${currentBalance}, need ${amount}`);
      }
      
      const updated = currentBalance - amount;
      
      transaction.update(docRef, {
        balance: updated,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`💰 [Firestore] ${deviceId}: ${currentBalance} - ${amount} = ${updated}`);
      return updated;
    });
    
    return newBalance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error deducting balance for ${deviceId}:`, error);
    throw error;
  }
}

/**
 * เพิ่ม balance ใน Firestore (สำหรับ purchase, gift, etc.)
 * 
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะเพิ่ม
 * @param reason - เหตุผล (purchase, gift, welcome, etc.)
 * @returns balance ใหม่หลังเพิ่ม
 * 
 * ⚠️ ฟังก์ชันนี้ไม่ได้ใช้ใน analyzeFood แต่จะใช้ใน verifyPurchase (Phase 2)
 * Exported เพื่อให้ function อื่นใช้ได้
 */
export async function addServerBalance(
  deviceId: string,
  amount: number,
  reason: string
): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    
    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      
      const currentBalance = doc.exists ? (doc.data()?.balance ?? 0) : 0;
      const updated = currentBalance + amount;
      
      if (doc.exists) {
        transaction.update(docRef, {
          balance: updated,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(docRef, {
          balance: updated,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      console.log(`💎 [Firestore] ${deviceId}: ${currentBalance} + ${amount} = ${updated} (${reason})`);
      return updated;
    });
    
    return newBalance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error adding balance for ${deviceId}:`, error);
    throw error;
  }
}

// ───────────────────────────────────────────────────────────
// 3. GEMINI API CALL
// ───────────────────────────────────────────────────────────

interface GeminiRequest {
  type: 'image' | 'text' | 'barcode' | 'chat' | 'menu_suggestion';
  prompt?: string;  // Optional: สำหรับ type=image/text/barcode
  text?: string;    // Optional: สำหรับ type=chat/menu_suggestion
  imageBase64?: string;  // Optional: สำหรับ type=image
}

/**
 * สร้าง prompt สำหรับ menu_suggestion type
 */
function buildMenuSuggestionPrompt(text: string, userContext?: any): string {
  let contextInfo = '';
  
  if (userContext) {
    contextInfo = '\n\nUser Profile:';
    if (userContext.gender) contextInfo += `\n- Gender: ${userContext.gender}`;
    if (userContext.age) contextInfo += `\n- Age: ${userContext.age} years`;
    if (userContext.weight) contextInfo += `\n- Weight: ${userContext.weight} kg`;
    if (userContext.height) contextInfo += `\n- Height: ${userContext.height} cm`;
    if (userContext.activityLevel) contextInfo += `\n- Activity Level: ${userContext.activityLevel}`;
    if (userContext.weightGoal) contextInfo += `\n- Weight Goal: ${userContext.weightGoal}`;
    if (userContext.calorieGoal) contextInfo += `\n- Daily Calorie Target: ${userContext.calorieGoal} kcal`;
    if (userContext.proteinGoal) contextInfo += `\n- Protein Goal: ${userContext.proteinGoal}g`;
    if (userContext.carbGoal) contextInfo += `\n- Carb Goal: ${userContext.carbGoal}g`;
    if (userContext.fatGoal) contextInfo += `\n- Fat Goal: ${userContext.fatGoal}g`;
    if (userContext.preferredLanguage) contextInfo += `\n- Preferred Language: ${userContext.preferredLanguage} (suggest local cuisine)`;
  }

  return `You are Miro, a friendly nutrition assistant.

The user wants meal suggestions.

Context:
- Recent food log: ${text} (last few days)
- Remaining calories for today: (if provided)
- User's typical cuisine: (detect from past meals)${contextInfo}

Suggest 3 meal ideas that:
1. Fit their remaining calorie budget and macro goals
2. ${userContext?.weightGoal ? `Match their weight goal (${userContext.weightGoal}) and activity level` : 'Are nutritionally balanced'}
3. ${userContext?.preferredLanguage === 'th' ? 'Match Thai cuisine preference' : 'Match international cuisine preference'}
4. Are balanced (good protein, reasonable carbs/fat according to their goals)

For each meal:
- Give a descriptive name${userContext?.preferredLanguage === 'th' ? ' in Thai language' : ' in English'}
- Estimate calories, protein, carbs, fat
- Make it appealing and practical

IMPORTANT: 
- ${userContext?.preferredLanguage === 'th' ? 'Respond in Thai language' : 'Respond in English'}
- Tailor suggestions to their specific health goals

Return JSON:
{
  "type": "menu_suggestion",
  "suggestions": [
    {
      "name": "Grilled Chicken Salad",
      "emoji": "🥗",
      "calories": 350,
      "protein": 35,
      "carbs": 20,
      "fat": 12
    }
  ],
  "reply": "Based on your profile and food log, here are 3 meal suggestions..."
}

User context: "${text}"`;
}

/**
 * สร้าง prompt สำหรับ chat type
 */
function buildChatPrompt(text: string, userContext?: any): string {
  let contextInfo = '';
  
  if (userContext) {
    contextInfo = '\n\nUser Profile:';
    if (userContext.gender) contextInfo += `\n- Gender: ${userContext.gender}`;
    if (userContext.age) contextInfo += `\n- Age: ${userContext.age} years`;
    if (userContext.weight) contextInfo += `\n- Weight: ${userContext.weight} kg`;
    if (userContext.activityLevel) contextInfo += `\n- Activity Level: ${userContext.activityLevel}`;
    if (userContext.weightGoal) contextInfo += `\n- Weight Goal: ${userContext.weightGoal}`;
    if (userContext.calorieGoal) contextInfo += `\n- Daily Calorie Target: ${userContext.calorieGoal} kcal`;
    if (userContext.proteinGoal) contextInfo += `\n- Protein Goal: ${userContext.proteinGoal}g`;
    if (userContext.preferredLanguage) contextInfo += `\n- Preferred Language: ${userContext.preferredLanguage}`;
  }

  return `You are Miro, a friendly nutrition assistant.${contextInfo}

Parse the user's message and extract ALL food items mentioned.
For each food item, provide:
- food_name: English name
- food_name_local: Original language name (as typed by user, keep original script - Thai, Japanese, Chinese, etc.)
- meal_type: "breakfast" | "lunch" | "dinner" | "snack" (detect from context/time mentioned, default to current time if not specified)
- serving_size: number (default 1 if not specified)
- serving_unit: one of these units ONLY [plate, cup, bowl, piece, box, pack, bag, bottle, glass, egg, ball, item, slice, pair, stick, g, kg, ml, l, serving, tbsp, tsp, oz, lbs]. If user doesn't specify or uses unsupported unit, use "serving"
- calories, protein, carbs, fat: estimated values (best effort)
- fiber, sugar, sodium: estimated micronutrients (fiber in g, sugar in g, sodium in mg)
- ingredients_detail: array of ingredient breakdown for this food item. Each ingredient must include name, name_en, amount (number), unit (g/ml/piece/etc), calories, protein, carbs, fat

When providing nutrition estimates, consider:
- User's health goals (${userContext?.weightGoal || 'not specified'})
- Their typical calorie/macro targets
- Portion sizes appropriate for their profile

IMPORTANT: 
- Respond in ENGLISH only (but keep food_name_local and ingredient names in original language)
- Return JSON only, no markdown code blocks
- If the message is not about food (e.g. asking for health advice), provide personalized advice based on their profile
- ALWAYS include ingredients_detail for each food item - break down the dish into its main ingredients

Expected JSON format:
{
  "type": "food_log",
  "items": [
    {
      "food_name": "Stir-fried basil pork with rice",
      "food_name_local": "ข้าวกะเพราหมูสับ",
      "meal_type": "lunch",
      "serving_size": 1.0,
      "serving_unit": "plate",
      "calories": 520,
      "protein": 22,
      "carbs": 55,
      "fat": 22,
      "fiber": 3,
      "sugar": 5,
      "sodium": 800,
      "ingredients_detail": [
        {"name": "Minced pork", "name_en": "Minced pork", "amount": 80, "unit": "g", "calories": 170, "protein": 15, "carbs": 0, "fat": 12},
        {"name": "Jasmine rice", "name_en": "Jasmine rice", "amount": 200, "unit": "g", "calories": 260, "protein": 5, "carbs": 52, "fat": 1},
        {"name": "Holy basil", "name_en": "Holy basil", "amount": 15, "unit": "g", "calories": 3, "protein": 0.5, "carbs": 0.5, "fat": 0},
        {"name": "Cooking oil", "name_en": "Cooking oil", "amount": 10, "unit": "ml", "calories": 87, "protein": 0, "carbs": 0, "fat": 10}
      ]
    }
  ],
  "reply": "Logged X items! Today's total: XXX kcal 💪"
}

User message: "${text}"`;
}

/**
 * Validate และแก้ไข serving_unit ให้ถูกต้อง
 */
function validateServingUnits(result: any): void {
  const validUnits = [
    'plate', 'cup', 'bowl', 'piece', 'box', 'pack', 'bag', 
    'bottle', 'glass', 'egg', 'ball', 'item', 'slice', 'pair', 
    'stick', 'g', 'kg', 'ml', 'l', 'serving', 'tbsp', 'tsp', 'oz', 'lbs'
  ];

  if (result.items && Array.isArray(result.items)) {
    result.items.forEach((item: any) => {
      if (!validUnits.includes(item.serving_unit)) {
        console.warn(`Invalid unit "${item.serving_unit}" replaced with "serving"`);
        item.serving_unit = 'serving';
      }
    });
  }
}

/**
 * เรียก Gemini API (with retry logic for 429 errors)
 */
async function callGeminiAPI(request: GeminiRequest, apiKey: string, userContext?: any): Promise<any> {
  // สร้าง prompt ตาม type
  let promptText: string;
  if (request.type === 'menu_suggestion' && request.text) {
    promptText = buildMenuSuggestionPrompt(request.text, userContext);
  } else if (request.type === 'chat' && request.text) {
    promptText = buildChatPrompt(request.text, userContext);
  } else if (request.prompt) {
    promptText = request.prompt;
  } else {
    throw new Error('Missing prompt or text for request');
  }

  const parts: any[] = [{ text: promptText }];
  
  if (request.imageBase64 && request.type === 'image') {
    parts.push({
      inline_data: {
        mime_type: 'image/jpeg',
        data: request.imageBase64,
      },
    });
  }
  
  // Use higher token limit for chat/menu_suggestion (ingredients_detail needs more tokens)
  const maxTokens = (request.type === 'chat' || request.type === 'menu_suggestion') ? 4096 : 1024;
  
  const requestBody = {
    contents: [{ parts }],
    generationConfig: {
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: maxTokens,
    },
  };
  
  // Retry logic for 429 (Rate Limit) errors
  const maxRetries = 3;
  let lastError: Error | null = null;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      });
      
      // Success - return result
      if (response.ok) {
        console.log(`✅ Gemini API success (attempt ${attempt + 1})`);
        return response.json();
      }
      
      const errorText = await response.text();
      
      // Handle 429 (Rate Limit) with retry
      if (response.status === 429) {
        console.warn(`⚠️ Rate limit hit (attempt ${attempt + 1}/${maxRetries + 1})`);
        
        // If not the last attempt, wait and retry
        if (attempt < maxRetries) {
          // Exponential backoff: 2s, 4s, 8s
          const waitTime = Math.pow(2, attempt + 1) * 1000;
          console.log(`⏳ Waiting ${waitTime}ms before retry...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
          continue; // Try again
        }
      }
      
      // Other errors or last retry - throw
      lastError = new Error(`Gemini API error (${response.status}): ${errorText}`);
      console.error(`❌ Gemini API error: ${response.status}`, errorText);
      break;
      
    } catch (error: any) {
      console.error(`❌ Network error (attempt ${attempt + 1}):`, error.message);
      lastError = error;
      
      // Retry on network errors too
      if (attempt < maxRetries) {
        const waitTime = Math.pow(2, attempt + 1) * 1000;
        console.log(`⏳ Retrying after ${waitTime}ms...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
        continue;
      }
      break;
    }
  }
  
  // All retries failed
  throw lastError || new Error('Gemini API call failed after retries');
}

// ───────────────────────────────────────────────────────────
// 4. MAIN HANDLER (Firebase Cloud Function)
// ───────────────────────────────────────────────────────────

export const analyzeFood = onRequest(
  {
    secrets: [GEMINI_API_KEY, ENERGY_ENCRYPTION_SECRET],
    timeoutSeconds: 60,
    memory: '512MiB',
    cors: '*',
  },
  async (req, res) => {
    // Handle CORS preflight
    res.set(corsHeaders);
    
    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }
    
    try {
      // ────── 4.1. Validate Energy Token ──────
      const energyToken = req.headers['x-energy-token'] as string;
      if (!energyToken) {
        res.status(401).json({ error: 'Missing energy token' });
        return;
      }
      
      const secret = ENERGY_ENCRYPTION_SECRET.value();
      const token = verifyEnergyToken(energyToken, secret);
      
      if (!token) {
        res.status(401).json({ error: 'Invalid or expired token' });
        return;
      }
      
      // ✅ PHASE 1: อ่าน balance จาก FIRESTORE (Server = Source of Truth)
      const deviceId = token.userId;
      let serverBalance: number;
      
      try {
        serverBalance = await getServerBalance(deviceId);
      } catch (error) {
        console.error('[analyzeFood] Failed to get server balance:', error);
        res.status(500).json({ error: 'Failed to check balance' });
        return;
      }
      
      console.log(`✅ Token valid. User: ${deviceId}, Server Balance: ${serverBalance}`);
      
      // ────── 4.2. Parse Request ──────
      const { type, text, prompt, imageBase64, deviceId: requestDeviceId, userContext } = req.body;
      
      // Determine BASE energy cost (chat/menu = 2, others = 1)
      // For chat: additional +1 per food item will be added AFTER Gemini responds
      const baseCost = (type === 'chat' || type === 'menu_suggestion') ? 2 : 1;
      
      // Check if user has enough energy for base cost
      if (serverBalance < baseCost) {
        console.log(`❌ [analyzeFood] Insufficient balance: have ${serverBalance}, need ${baseCost}`);
        res.status(402).json({ 
          error: 'Insufficient energy', 
          balance: serverBalance,
          required: baseCost
        });
        return;
      }
      
      console.log(`✅ [analyzeFood] Balance check passed: ${serverBalance} >= ${baseCost}`);
      console.log(`⚡ Base energy cost for ${type}: ${baseCost}`);
      
      // Log user context if provided
      if (userContext) {
        console.log(`📋 User context: ${JSON.stringify(userContext)}`);
      }
      
      // Validate required fields
      if (!type || !requestDeviceId) {
        res.status(400).json({ error: 'Missing required fields: type and deviceId' });
        return;
      }
      
      // Validate type-specific fields
      if ((type === 'chat' || type === 'menu_suggestion') && !text) {
        res.status(400).json({ error: `Missing text for ${type} type` });
        return;
      }
      
      if (type === 'image' && !imageBase64) {
        res.status(400).json({ error: 'Missing imageBase64 for image type' });
        return;
      }
      
      if ((type === 'image' || type === 'text' || type === 'barcode') && !prompt) {
        res.status(400).json({ error: 'Missing prompt for this type' });
        return;
      }
      
      const geminiRequest: GeminiRequest = {
        type: type as GeminiRequest['type'],
        text: text,
        prompt: prompt,
        imageBase64: imageBase64,
      };
      
      console.log(`📝 Request type: ${geminiRequest.type}`);
      
      // ────── 4.3. Call Gemini API ──────
      const apiKey = GEMINI_API_KEY.value();
      
      // Log prompt length for debugging
      if (geminiRequest.prompt) {
        console.log(`📏 Prompt length: ${geminiRequest.prompt.length} characters`);
      }
      
      const geminiResponse = await callGeminiAPI(geminiRequest, apiKey, userContext);
      
      console.log('✅ Gemini API success');
      
      // ────── 4.4. Parse response & calculate DYNAMIC energy cost ──────
      // For chat type: parse first to count items, then calculate total cost
      if (type === 'chat' || type === 'menu_suggestion') {
        try {
          // Parse Gemini response text
          const responseText = geminiResponse.candidates?.[0]?.content?.parts?.[0]?.text || '';
          
          // Extract JSON from response (อาจมี markdown code blocks)
          let jsonText = responseText.trim();
          if (jsonText.startsWith('```json')) {
            jsonText = jsonText.replace(/^```json\s*/, '').replace(/\s*```$/, '');
          } else if (jsonText.startsWith('```')) {
            jsonText = jsonText.replace(/^```\s*/, '').replace(/\s*```$/, '');
          }
          
          const parsedResult = JSON.parse(jsonText);
          
          // Validate serving units
          validateServingUnits(parsedResult);
          
          // ── Dynamic pricing: base 2 + 1 per food item ──
          const itemCount = (parsedResult.items && Array.isArray(parsedResult.items)) 
            ? parsedResult.items.length 
            : 0;
          const perItemCost = itemCount; // 1 energy per food item
          const totalCost = baseCost + perItemCost;
          
          // ✅ PHASE 1: เช็คว่า balance พอหรือไม่ (ก่อนหัก)
          if (serverBalance < totalCost) {
            console.log(`❌ [analyzeFood] Insufficient balance for dynamic cost: have ${serverBalance}, need ${totalCost}`);
            res.status(402).json({
              error: 'Insufficient energy',
              balance: serverBalance,
              required: totalCost,
            });
            return;
          }
          
          // ✅ PHASE 1: หัก balance ใน Firestore
          let newBalance: number;
          try {
            newBalance = await deductServerBalance(deviceId, totalCost);
            console.log(`✅ [analyzeFood] Balance updated: ${newBalance} (deducted ${totalCost})`);
          } catch (error) {
            console.error('[analyzeFood] Failed to deduct balance:', error);
            // เกิด error ตอนหัก balance แต่เราเรียก Gemini API ไปแล้ว
            console.error('⚠️ WARNING: Gemini API called but balance deduction failed!');
            console.error('⚠️ Manual intervention may be required for user:', deviceId);
            // เราจะ return result ไปก่อน แต่ไม่อัพเดท balance
            newBalance = serverBalance;
          }
          
          console.log(`⚡ Dynamic pricing: base=${baseCost} + items=${itemCount}×1 = total ${totalCost} energy`);
          console.log(`⚡ Deducted: ${totalCost} (balance: ${serverBalance} → ${newBalance})`);
          
          // ✅ PHASE 1: ส่ง balance กลับแทน token
          // Return parsed result with energy breakdown
          res.status(200)
            .set('X-Energy-Balance', newBalance.toString())
            .json({
              success: true,
              ...parsedResult,
              balance: newBalance,
              energyUsed: totalCost,
              // Energy cost breakdown for client display
              energyCost: totalCost,
              energyBreakdown: {
                baseCost,
                itemCount,
                perItemCost,
                totalCost,
              },
              // ✅ PHASE 3: ไม่ส่ง energyToken อีกต่อไป (ส่ง balance แทน)
            });
          return;
        } catch (parseError: any) {
          console.error('❌ Error parsing chat response:', parseError);
          // Fall through — still deduct base cost even if parsing fails
        }
      }
      
      // ────── 4.5. Deduct Energy for non-chat types (or chat parse failure) ──────
      // ✅ PHASE 1: หัก balance ใน Firestore
      let newBalance: number;
      
      try {
        newBalance = await deductServerBalance(deviceId, baseCost);
        console.log(`✅ [analyzeFood] Balance updated: ${newBalance} (deducted ${baseCost})`);
      } catch (error) {
        console.error('[analyzeFood] Failed to deduct balance:', error);
        // เกิด error ตอนหัก balance แต่เราเรียก Gemini API ไปแล้ว
        console.error('⚠️ WARNING: Gemini API called but balance deduction failed!');
        console.error('⚠️ Manual intervention may be required for user:', deviceId);
        // เราจะ return result ไปก่อน แต่ไม่อัพเดท balance
        newBalance = serverBalance;
      }
      
      console.log(`⚡ Energy deducted (base): ${baseCost}. New balance: ${newBalance}`);
      
      // ────── 4.6. Return Response (สำหรับ type อื่นๆ) ──────
      // ✅ PHASE 1: ส่ง balance กลับแทน token
      res.status(200)
        .set('X-Energy-Balance', newBalance.toString())
        .json({
          success: true,
          data: geminiResponse,
          balance: newBalance,
          energyUsed: baseCost,
          energyCost: baseCost,
          // ✅ PHASE 3: ไม่ส่ง energyToken อีกต่อไป (ส่ง balance แทน)
        });
      
    } catch (error: any) {
      console.error('❌ Error:', error);
      res.status(500).json({ 
        error: error.message || 'Internal server error' 
      });
    }
  });
