/**
 * analyzeFood - Firebase Cloud Function
 *
 * Backend API สำหรับ MIRO Energy System
 * รับคำขอจากแอป → ตรวจสอบ Energy Token → เรียก Gemini API → ส่งผลลัพธ์กลับ
 */

import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as crypto from "crypto";
import fetch from "node-fetch";
import * as admin from "firebase-admin";
import {processCheckIn} from "./energy/dailyCheckIn";
import {incrementChallengeProgress} from "./energy/challenge";
import {checkReferralProgress} from "./referral/checkReferralProgress";
import {checkWelcomeOfferPromotion} from "./energy/promotions";

// Define secrets
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const ENERGY_ENCRYPTION_SECRET = defineSecret("ENERGY_ENCRYPTION_SECRET");

// Initialize Firebase Admin (ถ้ายังไม่ได้ init)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ───────────────────────────────────────────────────────────
// 1. CONSTANTS & CONFIG
// ───────────────────────────────────────────────────────────

const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, x-energy-token, x-device-id",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ───────────────────────────────────────────────────────────
// 2. ENERGY TOKEN VALIDATION
// ───────────────────────────────────────────────────────────

interface EnergyToken {
  userId: string; // Device ID or User ID
  balance?: number; // ⚠️ PHASE 3: Optional (backward compatible)
  timestamp: number; // Token creation time
  signature: string; // HMAC signature
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
      Buffer.from(token, "base64").toString("utf-8")
    ) as EnergyToken;

    const {userId, timestamp, signature} = decoded;

    // Validate required fields
    if (!userId || !timestamp || !signature) {
      console.log("❌ [verifyToken] Missing required fields");
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
      console.log("❌ [verifyToken] Invalid signature");
      return null;
    }

    // Check expiry (5 minutes)
    const now = Date.now();
    if (now - timestamp > 5 * 60 * 1000) {
      console.log("❌ [verifyToken] Token expired");
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
    console.log("❌ [verifyToken] Parse error:", error);
    return null;
  }
}

/**
 * สร้าง HMAC signature
 */
function generateSignature(payload: string, secret: string): string {
  return crypto
    .createHmac("sha256", secret)
    .update(payload)
    .digest("hex");
}

// ===================================================================
// FIRESTORE HELPERS - Phase 1: Server-side Balance
// ===================================================================

/**
 * ดึงวันที่ปัจจุบันตาม timezone ของ user
 *
 * @param timezoneOffset - offset จาก UTC ในหน่วยนาที (e.g. 420 = UTC+7)
 * @return วันที่ในรูปแบบ "YYYY-MM-DD"
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();

  // ถ้าไม่ส่ง offset มา → ใช้ UTC+7 (Thailand)
  const offset = timezoneOffset ?? 420; // 420 minutes = 7 hours

  // คำนวณเวลาท้องถิ่น
  const localTime = new Date(now.getTime() + offset * 60 * 1000);

  // Return format: "YYYY-MM-DD"
  return localTime.toISOString().split("T")[0];
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
  const userRef = db.collection("users").doc(deviceId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    // User ไม่มี → ไม่ฟรี (ต้อง register ก่อน)
    return {isFree: false};
  }

  const userData = userDoc.data()!;
  const lastReset = userData.freeAiLastReset || "";
  const alreadyUsed = userData.freeAiUsedToday || false;

  // ─── Case 1: วันใหม่ → reset ───
  if (lastReset !== today) {
    console.log(`🆓 [Free AI] New day! Resetting for ${deviceId}`);

    await userRef.update({
      freeAiUsedToday: true,
      freeAiLastReset: today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {isFree: true};
  }

  // ─── Case 2: วันเดิม + ยังไม่ใช้ → ฟรี! ───
  if (!alreadyUsed) {
    console.log(`🆓 [Free AI] First use today for ${deviceId}`);

    await userRef.update({
      freeAiUsedToday: true,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {isFree: true};
  }

  // ─── Case 3: วันเดิม + ใช้แล้ว → ไม่ฟรี ───
  console.log(`💰 [Free AI] Already used free AI today for ${deviceId}`);
  return {isFree: false};
}

/**
 * อ่าน balance จาก Firestore (Server = Source of Truth)
 * อ่านจาก users collection แทน energy_balances
 */
async function getServerBalance(deviceId: string): Promise<number> {
  try {
    const docRef = db.collection("users").doc(deviceId);
    const doc = await docRef.get();

    if (!doc.exists) {
      // User ไม่มี → ควรเรียก registerUser ก่อน
      throw new Error("User not found. Please call registerUser first.");
    }

    const balance = doc.data()?.balance ?? 0;
    console.log(`📊 [Firestore] User ${deviceId}: Balance = ${balance}`);
    return balance;
  } catch (error) {
    console.error(`❌ [Firestore] Error reading balance for ${deviceId}:`, error);
    throw error;
  }
}

/**
 * หัก balance ใน Firestore (Atomic Transaction)
 * ป้องกัน race condition เมื่อมีหลาย request พร้อมกัน
 * อ่านจาก users collection แทน energy_balances
 *
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะหัก
 * @return balance ใหม่หลังหัก
 */
async function deductServerBalance(
  deviceId: string,
  amount: number
): Promise<number> {
  try {
    const docRef = db.collection("users").doc(deviceId);

    // ใช้ Transaction เพื่อป้องกัน race condition
    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw new Error("User not found in Firestore");
      }

      const currentBalance = doc.data()?.balance ?? 0;

      // ห้าม balance ติดลบ
      if (currentBalance < amount) {
        throw new Error(`Insufficient balance: have ${currentBalance}, need ${amount}`);
      }

      const updated = currentBalance - amount;

      transaction.update(docRef, {
        balance: updated,
        totalSpent: (doc.data()?.totalSpent || 0) + amount,
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
 * อ่านจาก users collection แทน energy_balances
 *
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะเพิ่ม
 * @param reason - เหตุผล (purchase, gift, welcome, etc.)
 * @return balance ใหม่หลังเพิ่ม
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
    const docRef = db.collection("users").doc(deviceId);

    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw new Error("User not found in Firestore");
      }

      const currentBalance = doc.data()?.balance ?? 0;
      const updated = currentBalance + amount;

      transaction.update(docRef, {
        balance: updated,
        totalEarned: (doc.data()?.totalEarned || 0) + amount,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

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
  type: "image" | "text" | "barcode" | "chat" | "menu_suggestion";
  prompt?: string; // Optional: สำหรับ type=image/text/barcode
  text?: string; // Optional: สำหรับ type=chat/menu_suggestion
  imageBase64?: string; // Optional: สำหรับ type=image
}

/**
 * สร้าง prompt สำหรับ menu_suggestion type
 */
function getCuisineExamples(cuisine: string): string {
  const examples: Record<string, string> = {
    "thai": "- Pad Krapow (Basil Stir-fry), Tom Yum Goong, Som Tam (Papaya Salad), Khao Pad (Fried Rice)",
    "japanese": "- Teriyaki Salmon, Sushi Rolls, Miso Soup with Tofu, Chicken Katsu Curry",
    "korean": "- Bibimbap, Bulgogi, Kimchi Jjigae (Kimchi Stew), Korean BBQ",
    "chinese": "- Kung Pao Chicken, Mapo Tofu, Fried Rice, Steamed Dumplings",
    "indian": "- Chicken Tikka Masala, Dal Tadka, Palak Paneer, Vegetable Biryani",
    "american": "- Grilled Chicken Breast, Caesar Salad, Turkey Sandwich, BBQ Ribs",
    "mexican": "- Chicken Burrito Bowl, Fish Tacos, Fajitas, Black Bean Soup",
    "italian": "- Grilled Chicken with Vegetables, Minestrone Soup, Caprese Salad, Spaghetti Marinara",
    "mediterranean": "- Greek Salad, Grilled Fish, Hummus with Vegetables, Chicken Souvlaki",
    "middle_eastern": "- Shawarma, Falafel, Tabbouleh, Grilled Kebabs",
    "vietnamese": "- Pho (Noodle Soup), Banh Mi, Spring Rolls, Com Tam (Broken Rice)",
    "indonesian": "- Nasi Goreng (Fried Rice), Gado-Gado, Satay, Rendang",
    "filipino": "- Adobo, Sinigang, Pancit, Grilled Bangus",
    "european": "- Grilled Chicken, Roasted Vegetables, Soup, Fish with Potatoes",
    "international": "- Mix of healthy dishes from various cuisines worldwide",
  };

  return examples[cuisine] || examples["international"];
}

/**
 * สร้าง prompt สำหรับ menu_suggestion type
 */
function buildMenuSuggestionPrompt(text: string, userContext?: any): string {
  let contextInfo = "";

  if (userContext) {
    contextInfo = "\n\nUser Profile:";
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
    if (userContext.cuisinePreference) contextInfo += `\n- Cuisine Preference: ${userContext.cuisinePreference}`;
  }

  const cuisinePref = userContext?.cuisinePreference || "international";

  return `You are Miro, a friendly nutrition assistant for users worldwide.

The user wants meal suggestions.

Context:
- Recent food log: ${text} (last few days)
- Remaining calories for today: (if provided)
- User's cuisine preference: ${cuisinePref}${contextInfo}

CRITICAL INSTRUCTION: The user has specifically chosen "${cuisinePref}" as their preferred cuisine. You MUST suggest ONLY dishes from ${cuisinePref} cuisine.

Suggest 3 meal ideas that:
1. Fit their remaining calorie budget and macro goals
2. ${userContext?.weightGoal ? `Match their weight goal (${userContext.weightGoal}) and activity level` : "Are nutritionally balanced"}
3. **MUST be authentic ${cuisinePref} dishes** — DO NOT suggest dishes from other cuisines
4. Are balanced (good protein, reasonable carbs/fat according to their goals)

Examples of ${cuisinePref} dishes you should suggest:
${getCuisineExamples(cuisinePref)}

For each meal:
- Give a descriptive name in the appropriate language for the cuisine
- Estimate calories, protein, carbs, fat based on typical ${cuisinePref} cuisine portion sizes
- Make it appealing and practical

IMPORTANT: 
- Respond in the user's preferred language based on their cuisine preference
- Tailor suggestions to their specific health goals
- **ONLY suggest dishes from ${cuisinePref} cuisine** — this is the most important rule

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
  let contextInfo = "";

  if (userContext) {
    contextInfo = "\n\nUser Profile:";
    if (userContext.gender) contextInfo += `\n- Gender: ${userContext.gender}`;
    if (userContext.age) contextInfo += `\n- Age: ${userContext.age} years`;
    if (userContext.weight) contextInfo += `\n- Weight: ${userContext.weight} kg`;
    if (userContext.activityLevel) contextInfo += `\n- Activity Level: ${userContext.activityLevel}`;
    if (userContext.weightGoal) contextInfo += `\n- Weight Goal: ${userContext.weightGoal}`;
    if (userContext.calorieGoal) contextInfo += `\n- Daily Calorie Target: ${userContext.calorieGoal} kcal`;
    if (userContext.proteinGoal) contextInfo += `\n- Protein Goal: ${userContext.proteinGoal}g`;
    if (userContext.cuisinePreference) contextInfo += `\n- Cuisine Preference: ${userContext.cuisinePreference}`;
  }

  const cuisinePref = userContext?.cuisinePreference || "international";

  return `You are Miro, a friendly nutrition assistant AND food scientist for users worldwide.${contextInfo}

Parse the user's message and extract ALL food items mentioned.
The user may type in ANY language — detect the language automatically.

INGREDIENT DECONSTRUCTION RULES (CRITICAL):
For EVERY food item, you MUST deconstruct it into specific ingredients following these rules:

1. IDENTIFY COOKING STATE: For each ingredient, specify how it was prepared (stir-fried, deep-fried, grilled, steamed, boiled, braised, raw, marinated). This affects calorie estimation.

2. INGREDIENT SPECIFICITY — NEVER use generic names:
   ❌ BAD: "Pork", "Rice", "Sauce", "Vegetables"
   ✅ GOOD: "Stir-fried Pork Belly (high fat, marinated in soy sauce)", "Steamed Jasmine Rice", "Oyster Sauce (sugar, soy, corn starch)", "Stir-fried Chinese Broccoli with Garlic Oil"

3. HIDDEN SEASONINGS: Always include cooking oil, sugar in sauces, fish sauce, soy sauce, MSG, curry paste, sesame oil, etc. as SEPARATE ingredient entries with estimated amounts.

4. CROSS-REFERENCE: For ${cuisinePref} cuisine, reference typical recipes and portion sizes for accuracy. For convenience store items (7-Eleven, FamilyMart, CP), reference known product databases.

INGREDIENT HIERARCHY RULES (CRITICAL — prevents double counting):

1. "ingredients_detail" contains ONLY recognizable food components at the ROOT level.
   These ROOT items are what get COUNTED for total calories.
   
2. Each ROOT ingredient MAY have "sub_ingredients" — these are the atomic breakdown
   showing what the component is made of. Sub-ingredients are INFORMATIONAL ONLY.
   
3. CALORIE RULES:
   - sum(ROOT.calories) MUST equal nutrition.calories (the total)
   - sum(sub_ingredients.calories) ≈ parent ROOT ingredient calories
   - NEVER put both a composite AND its raw materials at ROOT level
   
4. When to use sub_ingredients:
   - Deep-fried items → show meat + batter + absorbed oil as subs
   - Sauces → show base ingredients (sugar, vinegar, chili) as subs
   - Processed composite foods → show components as subs
   - Simple items (plain rice, raw vegetables) → no sub_ingredients needed

5. CHAT CONTEXT HANDLING:
   - If user references previous meal ("อีก 2 ชิ้น", "เพิ่ม"), maintain hierarchical structure consistent with previous analyses
   - If user asks "มีอะไรบ้าง", explain sub_ingredients breakdown

WRONG example (double counting):
{
  "ingredients_detail": [
    {"name": "Fried Chicken", "calories": 150},
    {"name": "Chicken", "calories": 100},  ← DUPLICATE!
    {"name": "Flour", "calories": 30}      ← DUPLICATE!
  ]
}

CORRECT example (hierarchical):
{
  "ingredients_detail": [
    {
      "name": "Deep-fried Chicken Pieces",
      "name_en": "Deep-fried Chicken Pieces",
      "detail": "Coated in seasoned batter and deep-fried",
      "amount": 100,
      "unit": "g",
      "calories": 150,
      "protein": 15,
      "carbs": 8,
      "fat": 8,
      "sub_ingredients": [
        {"name": "Chicken Meat", "name_en": "Chicken Meat", "amount": 70, "unit": "g", "calories": 100, "protein": 14, "carbs": 0, "fat": 5},
        {"name": "Flour Batter", "name_en": "Flour Batter", "amount": 20, "unit": "g", "calories": 30, "protein": 1, "carbs": 8, "fat": 0},
        {"name": "Absorbed Oil", "name_en": "Absorbed Oil", "amount": 5, "unit": "ml", "calories": 20, "protein": 0, "carbs": 0, "fat": 3}
      ]
    }
  ]
}

For each food item, provide:
- food_name: ALWAYS in English (for standardization)
- food_name_local: Original name as typed by the user (keep original script — any language)
- meal_type: "breakfast" | "lunch" | "dinner" | "snack" (detect from context/time mentioned, default to current time if not specified)
- serving_size: number (default 1 if not specified)
- serving_unit: one of these units ONLY [g, kg, mg, oz, lbs, ml, l, fl oz, cup, tbsp, tsp, serving, piece, slice, plate, bowl, cup_c, glass, egg, ball, fruit, skewer, whole, sheet, pair, bunch, leaf, stick, scoop, handful, pack, bag, wrap, box, can, bottle, bar]. If user doesn't specify or uses unsupported unit, use "serving"
- calories, protein, carbs, fat: estimated values with cooking method factored in
- fiber, sugar, sodium: estimated micronutrients (fiber in g, sugar in g, sodium in mg)
- ingredients_detail: array of SPECIFIC ingredient breakdown. Each ingredient must include name, name_en (English with cooking state), detail (preparation notes), amount (number), unit (g/ml/piece/etc), calories, protein, carbs, fat

When estimating nutrition, consider typical portion sizes for ${cuisinePref} cuisine.
Also consider:
- User's health goals (${userContext?.weightGoal || "not specified"})
- Their typical calorie/macro targets
- Portion sizes appropriate for their profile and cuisine preference
- Hidden calories from cooking oils, sauces, and marinades

IMPORTANT: 
- JSON field values for food_name and ingredient name_en must ALWAYS be in English
- food_name_local preserves the user's original input language
- Return JSON only, no markdown code blocks
- If the message is not about food (e.g. asking for health advice), provide personalized advice based on their profile
- ALWAYS include ingredients_detail — break down EVERY dish into specific ingredients including hidden seasonings

Expected JSON format:
{
  "type": "food_log",
  "items": [
    {
      "food_name": "Pad Kra Pao (Thai Basil Stir-fried Pork with Rice)",
      "food_name_local": "ข้าวกะเพราหมู",
      "meal_type": "lunch",
      "serving_size": 1.0,
      "serving_unit": "plate",
      "calories": 650,
      "protein": 28,
      "carbs": 70,
      "fat": 28,
      "fiber": 2,
      "sugar": 4,
      "sodium": 1200,
      "ingredients_detail": [
        {
          "name": "Stir-fried Minced Pork",
          "name_en": "Stir-fried Minced Pork (regular fat)",
          "detail": "High-heat wok stir-fried, absorbs cooking oil",
          "amount": 100,
          "unit": "g",
          "calories": 210,
          "protein": 22,
          "carbs": 0,
          "fat": 13
        },
        {
          "name": "Steamed Jasmine Rice",
          "name_en": "Steamed Jasmine Rice",
          "detail": "Thai long-grain white rice",
          "amount": 200,
          "unit": "g",
          "calories": 260,
          "protein": 5,
          "carbs": 56,
          "fat": 0.5
        },
        {
          "name": "Vegetable Oil (stir-frying)",
          "name_en": "Vegetable Oil for Wok Stir-frying",
          "detail": "High-heat cooking — significant oil absorption by minced pork",
          "amount": 15,
          "unit": "ml",
          "calories": 130,
          "protein": 0,
          "carbs": 0,
          "fat": 15
        },
        {
          "name": "Thai Holy Basil Leaves",
          "name_en": "Thai Holy Basil Leaves",
          "detail": "Flash-fried in oil for aroma",
          "amount": 10,
          "unit": "g",
          "calories": 2,
          "protein": 0.3,
          "carbs": 0.3,
          "fat": 0
        },
        {
          "name": "Seasoning Sauce Mix",
          "name_en": "Seasoning Sauce Mix (Fish Sauce + Oyster Sauce)",
          "detail": "Combined sauces — high sodium, contains added sugar",
          "amount": 18,
          "unit": "ml",
          "calories": 15,
          "protein": 1.2,
          "carbs": 2.5,
          "fat": 0,
          "sub_ingredients": [
            {"name": "Fish Sauce", "name_en": "Fish Sauce", "detail": "Primary seasoning — very high sodium", "amount": 10, "unit": "ml", "calories": 6, "protein": 1, "carbs": 0.5, "fat": 0},
            {"name": "Oyster Sauce", "name_en": "Oyster Sauce", "detail": "Contains sugar, soy extract, corn starch", "amount": 8, "unit": "ml", "calories": 9, "protein": 0.2, "carbs": 2, "fat": 0}
          ]
        },
        {
          "name": "Thai Chilies & Garlic",
          "name_en": "Crushed Thai Bird's Eye Chilies with Garlic",
          "detail": "Pounded and stir-fried in oil",
          "amount": 10,
          "unit": "g",
          "calories": 8,
          "protein": 0.3,
          "carbs": 1.5,
          "fat": 0.2
        }
      ]
    }
  ],
  "reply": "Logged X items! Today's total: XXX kcal 💪"
}

User message: "${text}"`;
}

/**
 * Extract JSON text from Gemini response (handles markdown code blocks, leading text, trailing newlines)
 * Returns the extracted JSON string or null if no JSON found
 */
function extractJsonFromText(rawText: string): string | null {
  const text = rawText.trim();
  if (!text) return null;

  // Case 1: Entire response is wrapped in ```json ... ```
  if (text.startsWith("```json") || text.startsWith("```")) {
    const cleaned = text
      .replace(/^```(?:json)?\s*\n?/, "")
      .replace(/\n?\s*```\s*$/, "")
      .trim();
    if (cleaned.startsWith("{") || cleaned.startsWith("[")) return cleaned;
  }

  // Case 2: Response is raw JSON (no code block)
  if (text.startsWith("{") || text.startsWith("[")) return text;

  // Case 3: JSON is embedded in text with markdown code block
  const codeBlockMatch = text.match(/```(?:json)?\s*\n([\s\S]*?)\n\s*```/);
  if (codeBlockMatch) {
    const inner = codeBlockMatch[1].trim();
    if (inner.startsWith("{") || inner.startsWith("[")) return inner;
  }

  // Case 4: JSON object/array is embedded in plain text (no code block)
  const braceIdx = text.indexOf("{");
  const bracketIdx = text.indexOf("[");
  const startIdx = braceIdx >= 0 && bracketIdx >= 0
    ? Math.min(braceIdx, bracketIdx)
    : braceIdx >= 0 ? braceIdx : bracketIdx;

  if (startIdx >= 0) {
    const candidate = text.substring(startIdx).trim();
    // Remove any trailing ``` that might follow the JSON
    const withoutTrailing = candidate.replace(/\n?\s*```\s*$/, "").trim();
    if (withoutTrailing.startsWith("{") || withoutTrailing.startsWith("[")) {
      return withoutTrailing;
    }
  }

  return null;
}

/**
 * Validate และแก้ไข serving_unit ให้ถูกต้อง
 */
function validateServingUnits(result: any): void {
  const validUnits = [
    "g", "kg", "mg", "oz", "lbs",
    "ml", "l", "fl oz", "cup", "tbsp", "tsp",
    "serving", "piece", "slice", "plate", "bowl", "cup_c", "glass",
    "egg", "ball", "fruit", "skewer", "whole", "sheet", "pair",
    "bunch", "leaf", "stick", "scoop", "handful",
    "pack", "bag", "wrap", "box", "can", "bottle", "bar",
  ];

  if (result.items && Array.isArray(result.items)) {
    result.items.forEach((item: any) => {
      if (!validUnits.includes(item.serving_unit)) {
        console.warn(`Invalid unit "${item.serving_unit}" replaced with "serving"`);
        item.serving_unit = "serving";
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
  if (request.type === "menu_suggestion" && request.text) {
    promptText = buildMenuSuggestionPrompt(request.text, userContext);
  } else if (request.type === "chat" && request.text) {
    promptText = buildChatPrompt(request.text, userContext);
  } else if (request.prompt) {
    promptText = request.prompt;
  } else {
    throw new Error("Missing prompt or text for request");
  }

  const parts: any[] = [{text: promptText}];

  if (request.imageBase64 && request.type === "image") {
    parts.push({
      inline_data: {
        mime_type: "image/jpeg",
        data: request.imageBase64,
      },
    });
  }

  // All analysis types need sufficient tokens for ingredients_detail + sub_ingredients JSON
  const maxTokens = (request.type === "chat" || request.type === "menu_suggestion") ? 4096 : 4096;

  // Tune generation parameters per request type:
  // - Food analysis (image/text/barcode): low temperature for accuracy & consistency
  // - Chat/menu_suggestion: slightly higher temperature for natural conversation
  const isAnalysis = ["image", "text", "barcode"].includes(request.type);

  const requestBody = {
    contents: [{parts}],
    generationConfig: {
      temperature: isAnalysis ? 0.15 : 0.4,
      topK: isAnalysis ? 10 : 32,
      topP: isAnalysis ? 0.8 : 0.95,
      maxOutputTokens: maxTokens,
    },
  };

  // Retry logic for 429 (Rate Limit) errors
  const maxRetries = 3;
  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
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
          await new Promise((resolve) => setTimeout(resolve, waitTime));
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
        await new Promise((resolve) => setTimeout(resolve, waitTime));
        continue;
      }
      break;
    }
  }

  // All retries failed
  throw lastError || new Error("Gemini API call failed after retries");
}

// ───────────────────────────────────────────────────────────
// 4. MAIN HANDLER (Firebase Cloud Function)
// ───────────────────────────────────────────────────────────

export const analyzeFood = onRequest(
  {
    secrets: [GEMINI_API_KEY, ENERGY_ENCRYPTION_SECRET],
    timeoutSeconds: 60,
    memory: "512MiB",
    cors: "*",
  },
  async (req, res) => {
    // Handle CORS preflight
    res.set(corsHeaders);

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    try {
      // ────── 4.1. Validate Energy Token ──────
      const energyToken = req.headers["x-energy-token"] as string;
      if (!energyToken) {
        res.status(401).json({error: "Missing energy token"});
        return;
      }

      const secret = ENERGY_ENCRYPTION_SECRET.value();
      const token = verifyEnergyToken(energyToken, secret);

      if (!token) {
        res.status(401).json({error: "Invalid or expired token"});
        return;
      }

      // ✅ PHASE 1: อ่าน balance จาก FIRESTORE (Server = Source of Truth)
      const deviceId = token.userId;
      let serverBalance: number;

      try {
        serverBalance = await getServerBalance(deviceId);
      } catch (error) {
        console.error("[analyzeFood] Failed to get server balance:", error);
        res.status(500).json({error: "Failed to check balance"});
        return;
      }

      console.log(`✅ Token valid. User: ${deviceId}, Server Balance: ${serverBalance}`);

      // ────── 4.2. Parse Request ──────
      const {type, text, prompt, imageBase64, deviceId: requestDeviceId, userContext, timezoneOffset} = req.body;

      // ────── 4.2.0. เช็ค Subscription (Phase 5) ──────
      const userDoc = await db.collection("users").doc(deviceId).get();
      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const userData = userDoc.data()!;
      const subscription = userData.subscription;
      const isSubscriber = subscription?.status === "active";

      if (isSubscriber) {
        // Subscriber → ใช้ AI ฟรีไม่จำกัด!
        console.log(`💎 [analyzeFood] Subscriber ${deviceId} — free unlimited!`);

        try {
          // เรียก Gemini API ได้เลย
          const geminiRequest: GeminiRequest = {
            type: type as GeminiRequest["type"],
            text: text,
            prompt: prompt,
            imageBase64: imageBase64,
          };

          const apiKey = GEMINI_API_KEY.value();
          const geminiResponse = await callGeminiAPI(geminiRequest, apiKey, userContext);

          console.log("✅ Gemini API success (Subscriber)");

          // Process response (same as free AI)
          if (type === "chat" || type === "menu_suggestion") {
            const responseText = geminiResponse.candidates?.[0]?.content?.parts?.[0]?.text || "";
            const jsonText = extractJsonFromText(responseText);

            if (!jsonText) {
              console.log("❌ [Subscriber Chat] Gemini returned non-JSON response");
              res.status(422).json({error: "AI could not process this request. Please try again.", noCharge: true});
              return;
            }

            const parsedResult = JSON.parse(jsonText);
            validateServingUnits(parsedResult);

            // Subscribers: NO streak/check-in (already paying monthly)
            console.log(`💎 [analyzeFood] Subscriber — skipping streak/check-in`);

            const currentBalance = userData.balance || 0;
            const miroId = userData.miroId || "unknown";

            // Log transaction (type: 'subscription_usage')
            await db.collection("transactions").add({
              deviceId,
              miroId,
              type: "subscription_usage",
              amount: 0,
              balanceAfter: currentBalance,
              description: `AI analysis (Subscriber): ${type}`,
              metadata: {
                requestType: type,
                isSubscriber: true,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            res.status(200).json({
              success: true,
              ...parsedResult,
              balance: currentBalance,
              energyUsed: 0,
              energyCost: 0,
              wasFreeAi: false,
              isSubscriber: true,
              streak: {
                current: userData.currentStreak || 0,
                longest: userData.longestStreak || 0,
                tier: userData.tier || "none",
                tierUpgraded: false,
                energyBonus: 0,
              },
              challenges: {
                weekly: userData.challenges?.weekly || {},
              },
              milestones: userData.milestones || {},
              totalSpent: userData.totalSpent || 0,
            });
            return;
          } else {
            // Other types (image, text, barcode) — Subscriber
            console.log(`💎 [analyzeFood] Subscriber — skipping streak/check-in`);

            // Validate Gemini response before returning to client
            const rawSubText = geminiResponse?.candidates?.[0]?.content?.parts?.[0]?.text || "";
            const extractedSubJson = extractJsonFromText(rawSubText);

            if (!extractedSubJson) {
              console.log("❌ [Subscriber] Gemini returned non-JSON response");
              console.log(`📝 Raw (first 300): ${rawSubText.substring(0, 300)}`);
              res.status(422).json({error: "AI could not analyze this food. Please try again.", noCharge: true});
              return;
            }

            try {
              JSON.parse(extractedSubJson);
            } catch {
              console.log("❌ [Subscriber] Gemini response is not valid JSON");
              console.log(`📝 Extracted (first 300): ${extractedSubJson.substring(0, 300)}`);
              res.status(422).json({error: "AI returned invalid data. Please try again.", noCharge: true});
              return;
            }

            const currentBalance = userData.balance || 0;
            const miroId = userData.miroId || "unknown";

            await db.collection("transactions").add({
              deviceId,
              miroId,
              type: "subscription_usage",
              amount: 0,
              balanceAfter: currentBalance,
              description: `AI analysis (Subscriber): ${type}`,
              metadata: {
                requestType: type,
                isSubscriber: true,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            res.status(200).json({
              success: true,
              data: geminiResponse,
              balance: currentBalance,
              energyUsed: 0,
              energyCost: 0,
              wasFreeAi: false,
              isSubscriber: true,
              streak: {
                current: userData.currentStreak || 0,
                longest: userData.longestStreak || 0,
                tier: userData.tier || "none",
                tierUpgraded: false,
                energyBonus: 0,
              },
              challenges: {
                weekly: userData.challenges?.weekly || {},
              },
              milestones: userData.milestones || {},
              totalSpent: userData.totalSpent || 0,
            });
            return;
          }
        } catch (error: any) {
          console.error("❌ [Subscriber] Gemini error:", error);
          res.status(500).json({error: error.message});
          return;
        }
      }

      // ────── 4.2.1. เช็ค Free AI (ก่อนเช็ค balance) ──────
      const {isFree} = await checkFreeAi(deviceId, timezoneOffset);

      if (isFree) {
        console.log(`🆓 [analyzeFood] Free AI for ${deviceId}`);

        // ────── Process check-in (streak + tier) ──────
        const checkInResult = await processCheckIn(deviceId, timezoneOffset);

        console.log(
          `📊 [Check-in] Streak: ${checkInResult.currentStreak}, ` +
          `Tier: ${checkInResult.tier}` +
          (checkInResult.tierUpgraded ? " (UPGRADED!)" : "")
        );

        // ────── ไม่ต้องเช็ค balance! เรียก Gemini API ได้เลย ──────
        try {
          const geminiRequest: GeminiRequest = {
            type: type as GeminiRequest["type"],
            text: text,
            prompt: prompt,
            imageBase64: imageBase64,
          };

          // Validate required fields
          if (!type || !requestDeviceId) {
            res.status(400).json({error: "Missing required fields: type and deviceId"});
            return;
          }

          // Validate type-specific fields
          if ((type === "chat" || type === "menu_suggestion") && !text) {
            res.status(400).json({error: `Missing text for ${type} type`});
            return;
          }

          if (type === "image" && !imageBase64) {
            res.status(400).json({error: "Missing imageBase64 for image type"});
            return;
          }

          if ((type === "image" || type === "text" || type === "barcode") && !prompt) {
            res.status(400).json({error: "Missing prompt for this type"});
            return;
          }

          const apiKey = GEMINI_API_KEY.value();
          const geminiResponse = await callGeminiAPI(geminiRequest, apiKey, userContext);

          console.log("✅ Gemini API success (Free AI)");

          // ดึง balance และ MiRO ID ปัจจุบัน (อาจเปลี่ยนจาก tier bonus)
          const userDoc = await db.collection("users").doc(deviceId).get();
          const userData = userDoc.data()!;
          const currentBalance = (checkInResult.newBalance ?? userData.balance) || 0;
          const miroId = userData.miroId || "unknown";

          // บันทึก transaction (type: 'free_ai', amount: 0)
          await db.collection("transactions").add({
            deviceId,
            miroId,
            type: "free_ai",
            amount: 0, // ไม่หัก
            balanceAfter: currentBalance, // balance อาจเพิ่มจาก tier bonus
            description: "Daily free AI analysis",
            metadata: {
              requestType: type, // 'image', 'text', 'barcode', etc.
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // ✅ PHASE 2: Increment challenge progress (logMeals + useAi)
          try {
            await incrementChallengeProgress(deviceId, "logMeals", timezoneOffset);
            await incrementChallengeProgress(deviceId, "useAi", timezoneOffset);
          } catch (error) {
            console.error("[analyzeFood] Failed to increment challenge:", error);
            // ไม่ block response
          }

          // Read updated challenges & milestones
          const updatedUser = await db.collection("users").doc(deviceId).get();
          const updatedData = updatedUser.data()!;
          const challenges = updatedData.challenges?.weekly || {};
          const milestones = updatedData.milestones || {};

          // Return response พร้อม streak info
          res.status(200).json({
            success: true,
            data: geminiResponse,
            balance: currentBalance,
            energyUsed: 0,
            energyCost: 0,
            wasFreeAi: true, // ← บอก client ว่าฟรี!

            streak: {
              current: checkInResult.currentStreak,
              longest: checkInResult.longestStreak,
              tier: checkInResult.tier,
              tierUpgraded: checkInResult.tierUpgraded,
              tierDemoted: checkInResult.tierDemoted,
              previousTier: checkInResult.previousTier,
              newTier: checkInResult.newTier,
              energyBonus: checkInResult.energyBonus,
              tierRewardEnergy: checkInResult.tierRewardEnergy,
              promotionBonusRate: checkInResult.promotionBonusRate,
              showWelcomeBackOffer: checkInResult.showWelcomeBackOffer,
            },
            challenges: {
              weekly: challenges,
            },
            milestones: milestones,
            totalSpent: updatedData.totalSpent || 0,
          });
          return; // จบ function ตรงนี้!
        } catch (error: any) {
          console.error("❌ [Free AI] Gemini error:", error);
          res.status(500).json({error: error.message});
          return;
        }
      }

      // ────── ถ้าไม่ฟรี → ทำตามเดิม (เช็ค balance + หัก energy) ──────

      // Process daily check-in for paid users too (idempotent if already checked in today)
      let paidCheckInResult;
      try {
        paidCheckInResult = await processCheckIn(deviceId, timezoneOffset);
      } catch (error) {
        console.error("[analyzeFood] Paid check-in failed:", error);
      }

      // Update serverBalance if daily check-in awarded energy
      if (paidCheckInResult?.newBalance != null) {
        serverBalance = paidCheckInResult.newBalance;
      }

      // Determine BASE energy cost (chat/menu = 2, others = 1)
      // For chat: additional +1 per food item will be added AFTER Gemini responds
      const baseCost = (type === "chat" || type === "menu_suggestion") ? 2 : 1;

      // Check if user has enough energy for base cost
      if (serverBalance < baseCost) {
        console.log(`❌ [analyzeFood] Insufficient balance: have ${serverBalance}, need ${baseCost}`);
        res.status(402).json({
          error: "Insufficient energy",
          balance: serverBalance,
          required: baseCost,
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
        res.status(400).json({error: "Missing required fields: type and deviceId"});
        return;
      }

      // Validate type-specific fields
      if ((type === "chat" || type === "menu_suggestion") && !text) {
        res.status(400).json({error: `Missing text for ${type} type`});
        return;
      }

      if (type === "image" && !imageBase64) {
        res.status(400).json({error: "Missing imageBase64 for image type"});
        return;
      }

      if ((type === "image" || type === "text" || type === "barcode") && !prompt) {
        res.status(400).json({error: "Missing prompt for this type"});
        return;
      }

      const geminiRequest: GeminiRequest = {
        type: type as GeminiRequest["type"],
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

      console.log("✅ Gemini API success");

      // ────── 4.4. Parse response & calculate DYNAMIC energy cost ──────
      // For chat type: parse first to count items, then calculate total cost
      if (type === "chat" || type === "menu_suggestion") {
        try {
          // Parse Gemini response text
          const responseText = geminiResponse.candidates?.[0]?.content?.parts?.[0]?.text || "";
          const jsonText = extractJsonFromText(responseText);

          if (!jsonText) {
            console.log("❌ [Chat/Paid] Gemini returned non-JSON response");
            console.log(`📝 Raw (first 300): ${responseText.substring(0, 300)}`);
            throw new Error("AI returned invalid response");
          }

          const parsedResult = JSON.parse(jsonText);

          // Validate serving units
          validateServingUnits(parsedResult);

          // ── Dynamic pricing: base 2 + 1 per food item ──
          const itemCount = (parsedResult.items && Array.isArray(parsedResult.items)) ?
            parsedResult.items.length :
            0;
          const perItemCost = itemCount; // 1 energy per food item
          const totalCost = baseCost + perItemCost;

          // ✅ PHASE 1: เช็คว่า balance พอหรือไม่ (ก่อนหัก)
          if (serverBalance < totalCost) {
            console.log(`❌ [analyzeFood] Insufficient balance for dynamic cost: have ${serverBalance}, need ${totalCost}`);
            res.status(402).json({
              error: "Insufficient energy",
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

            // บันทึก transaction
            const userDoc = await db.collection("users").doc(deviceId).get();
            const miroId = userDoc.data()?.miroId || "unknown";

            await db.collection("transactions").add({
              deviceId,
              miroId,
              type: "usage",
              amount: -totalCost,
              balanceAfter: newBalance,
              description: `AI analysis: ${type} (${itemCount} items)`,
              metadata: {
                requestType: type,
                itemCount,
                baseCost,
                perItemCost,
                totalCost,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // ✅ PHASE 2: Increment challenge progress (logMeals + useAi)
            try {
              await incrementChallengeProgress(deviceId, "logMeals", timezoneOffset);
              await incrementChallengeProgress(deviceId, "useAi", timezoneOffset);
            } catch (error) {
              console.error("[analyzeFood] Failed to increment challenge:", error);
              // ไม่ block response
            }

            // ✅ PHASE 4: Check referral progress
            try {
              await checkReferralProgress(deviceId);
            } catch (error) {
              console.error("[analyzeFood] Failed to check referral:", error);
              // ไม่ block response
            }
          } catch (error) {
            console.error("[analyzeFood] Failed to deduct balance:", error);
            // เกิด error ตอนหัก balance แต่เราเรียก Gemini API ไปแล้ว
            console.error("⚠️ WARNING: Gemini API called but balance deduction failed!");
            console.error("⚠️ Manual intervention may be required for user:", deviceId);
            // เราจะ return result ไปก่อน แต่ไม่อัพเดท balance
            newBalance = serverBalance;
          }

          console.log(`⚡ Dynamic pricing: base=${baseCost} + items=${itemCount}×1 = total ${totalCost} energy`);
          console.log(`⚡ Deducted: ${totalCost} (balance: ${serverBalance} → ${newBalance})`);

          // Read challenges & milestones
          let challenges = {};
          let milestones = {};
          let totalSpent = 0;
          let welcomePromoResult = null;
          try {
            const updatedUser = await db.collection("users").doc(deviceId).get();
            const updatedData = updatedUser.data()!;
            challenges = updatedData.challenges?.weekly || {};
            milestones = updatedData.milestones || {};
            totalSpent = updatedData.totalSpent || 0;
            newBalance = updatedData.balance || newBalance;

            // Check welcome offer promotion (first 10 energy spent)
            welcomePromoResult = await checkWelcomeOfferPromotion(deviceId, totalSpent);
            if (welcomePromoResult) {
              newBalance = updatedData.balance + welcomePromoResult.freeEnergy;
            }
          } catch (error) {
            console.error("[analyzeFood] Failed to read challenges/milestones:", error);
          }

          res.status(200)
            .set("X-Energy-Balance", newBalance.toString())
            .json({
              success: true,
              ...parsedResult,
              balance: newBalance,
              energyUsed: totalCost,
              energyCost: totalCost,
              energyBreakdown: {
                baseCost,
                itemCount,
                perItemCost,
                totalCost,
              },
              wasFreeAi: false,
              ...(paidCheckInResult ? {
                streak: {
                  current: paidCheckInResult.currentStreak,
                  longest: paidCheckInResult.longestStreak,
                  tier: paidCheckInResult.tier,
                  tierUpgraded: paidCheckInResult.tierUpgraded,
                  tierDemoted: paidCheckInResult.tierDemoted,
                  previousTier: paidCheckInResult.previousTier,
                  newTier: paidCheckInResult.newTier,
                  energyBonus: paidCheckInResult.energyBonus,
                  tierRewardEnergy: paidCheckInResult.tierRewardEnergy,
                  promotionBonusRate: paidCheckInResult.promotionBonusRate,
                  showWelcomeBackOffer: paidCheckInResult.showWelcomeBackOffer,
                },
              } : {}),
              ...(welcomePromoResult ? {
                promotion: {
                  type: welcomePromoResult.type,
                  bonusRate: welcomePromoResult.bonusRate,
                  freeEnergy: welcomePromoResult.freeEnergy,
                },
              } : {}),
              challenges: {
                weekly: challenges,
              },
              milestones: milestones,
              totalSpent: totalSpent,
            });
          return;
        } catch (parseError: any) {
          console.error("❌ Error parsing chat response:", parseError);
          // Fall through — still deduct base cost even if parsing fails
        }
      }

      // ────── 4.5. Validate Gemini response before deducting energy ──────
      // Validate that Gemini returned valid JSON before charging the user
      const rawText = geminiResponse?.candidates?.[0]?.content?.parts?.[0]?.text || "";
      const finishReason = geminiResponse?.candidates?.[0]?.finishReason || "UNKNOWN";
      console.log(`📊 [analyzeFood] type=${type}, finishReason=${finishReason}, rawText.length=${rawText.length}`);

      if (finishReason === "MAX_TOKENS") {
        console.log(`⚠️ [analyzeFood] Response was TRUNCATED (MAX_TOKENS) for type=${type}`);
        console.log(`📝 Raw tail (last 200): ...${rawText.substring(Math.max(0, rawText.length - 200))}`);
      }

      const extractedJson = extractJsonFromText(rawText);

      if (!extractedJson) {
        const lower = rawText.toLowerCase();
        if (lower.includes("sorry") || lower.includes("cannot") || lower.includes("unable") || lower.includes("not a food") || lower.includes("no food")) {
          console.log("❌ [analyzeFood] Gemini returned refusal — NOT deducting energy");
          res.status(422).json({error: "AI could not analyze this food. Please try a different name.", noCharge: true});
          return;
        }
        console.log("❌ [analyzeFood] Gemini returned non-JSON — NOT deducting energy");
        console.log(`📝 Raw response (first 500): ${rawText.substring(0, 500)}`);
        res.status(422).json({error: "AI returned invalid response. Please try again.", noCharge: true});
        return;
      }

      try {
        JSON.parse(extractedJson);
      } catch (parseError: any) {
        console.log(`❌ [analyzeFood] Gemini response is not valid JSON — NOT deducting energy (finishReason=${finishReason})`);
        console.log(`📝 Parse error: ${parseError.message}`);
        console.log(`📝 Extracted (first 500): ${extractedJson.substring(0, 500)}`);
        console.log(`📝 Extracted (last 200): ...${extractedJson.substring(Math.max(0, extractedJson.length - 200))}`);
        res.status(422).json({error: "AI returned invalid data. Please try again.", noCharge: true});
        return;
      }

      // ────── 4.6. Deduct Energy (only after validation passes) ──────
      let newBalance: number;

      try {
        newBalance = await deductServerBalance(deviceId, baseCost);
        console.log(`✅ [analyzeFood] Balance updated: ${newBalance} (deducted ${baseCost})`);

        // บันทึก transaction
        const userDoc = await db.collection("users").doc(deviceId).get();
        const miroId = userDoc.data()?.miroId || "unknown";

        await db.collection("transactions").add({
          deviceId,
          miroId,
          type: "usage",
          amount: -baseCost,
          balanceAfter: newBalance,
          description: `AI analysis: ${type}`,
          metadata: {
            requestType: type,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // ✅ PHASE 2: Increment challenge progress (logMeals + useAi)
        try {
          await incrementChallengeProgress(deviceId, "logMeals", timezoneOffset);
          await incrementChallengeProgress(deviceId, "useAi", timezoneOffset);
        } catch (error) {
          console.error("[analyzeFood] Failed to increment challenge:", error);
          // ไม่ block response
        }

        // ✅ PHASE 4: Check referral progress
        try {
          await checkReferralProgress(deviceId);
        } catch (error) {
          console.error("[analyzeFood] Failed to check referral:", error);
          // ไม่ block response
        }
      } catch (error) {
        console.error("[analyzeFood] Failed to deduct balance:", error);
        // เกิด error ตอนหัก balance แต่เราเรียก Gemini API ไปแล้ว
        console.error("⚠️ WARNING: Gemini API called but balance deduction failed!");
        console.error("⚠️ Manual intervention may be required for user:", deviceId);
        // เราจะ return result ไปก่อน แต่ไม่อัพเดท balance
        newBalance = serverBalance;
      }

      console.log(`⚡ Energy deducted (base): ${baseCost}. New balance: ${newBalance}`);

      // Read challenges & milestones after increment
      let challenges = {};
      let milestones = {};
      let totalSpent = 0;
      let welcomePromoResult2 = null;
      try {
        const updatedUser = await db.collection("users").doc(deviceId).get();
        const updatedData = updatedUser.data()!;
        challenges = updatedData.challenges?.weekly || {};
        milestones = updatedData.milestones || {};
        totalSpent = updatedData.totalSpent || 0;
        newBalance = updatedData.balance || newBalance;

        welcomePromoResult2 = await checkWelcomeOfferPromotion(deviceId, totalSpent);
        if (welcomePromoResult2) {
          newBalance = updatedData.balance + welcomePromoResult2.freeEnergy;
        }
      } catch (error) {
        console.error("[analyzeFood] Failed to read challenges/milestones:", error);
      }

      res.status(200)
        .set("X-Energy-Balance", newBalance.toString())
        .json({
          success: true,
          data: geminiResponse,
          balance: newBalance,
          energyUsed: baseCost,
          energyCost: baseCost,
          wasFreeAi: false,
          ...(paidCheckInResult ? {
            streak: {
              current: paidCheckInResult.currentStreak,
              longest: paidCheckInResult.longestStreak,
              tier: paidCheckInResult.tier,
              tierUpgraded: paidCheckInResult.tierUpgraded,
              tierDemoted: paidCheckInResult.tierDemoted,
              previousTier: paidCheckInResult.previousTier,
              newTier: paidCheckInResult.newTier,
              energyBonus: paidCheckInResult.energyBonus,
              tierRewardEnergy: paidCheckInResult.tierRewardEnergy,
              promotionBonusRate: paidCheckInResult.promotionBonusRate,
              showWelcomeBackOffer: paidCheckInResult.showWelcomeBackOffer,
            },
          } : {}),
          ...(welcomePromoResult2 ? {
            promotion: {
              type: welcomePromoResult2.type,
              bonusRate: welcomePromoResult2.bonusRate,
              freeEnergy: welcomePromoResult2.freeEnergy,
            },
          } : {}),
          challenges: {
            weekly: challenges,
          },
          milestones: milestones,
          totalSpent: totalSpent,
        });
    } catch (error: any) {
      console.error("❌ Error:", error);
      res.status(500).json({
        error: error.message || "Internal server error",
      });
    }
  });
