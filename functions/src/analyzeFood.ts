/**
 * analyzeFood - Firebase Cloud Function
 *
 * Backend API สำหรับ ArCal Energy System
 * รับคำขอจากแอป → ตรวจสอบ Energy Token → เรียก Gemini API → ส่งผลลัพธ์กลับ
 */

import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as crypto from "crypto";
import fetch from "node-fetch";
import * as admin from "firebase-admin";
import {checkReferralProgress} from "./referral/checkReferralProgress";
import {checkWelcomeOfferPromotion} from "./energy/promotions";
import {checkAndProcessMilestone} from "./energy/milestoneV2";
import {evaluateOffers} from "./energy/offerEngine";
import {processCheckIn, CheckInResult} from "./energy/dailyCheckIn";

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
function getTodayString(_timezoneOffset?: number): string {
  const now = new Date();
  const localTime = new Date(now.getTime() + 420 * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

function getLocalDateString(timezoneOffset?: number): string {
  const now = new Date();
  const offsetMinutes = timezoneOffset ?? 420;
  const localTime = new Date(now.getTime() + offsetMinutes * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay();
  const diff = day === 0 ? 6 : day - 1;
  date.setDate(date.getDate() - diff);
  return date.toISOString().split("T")[0];
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
  amount: number,
  timezoneOffset?: number
): Promise<number> {
  try {
    const today = getTodayString(timezoneOffset);
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

      const prevTotalSpent = doc.data()?.totalSpent || 0;
      const prevMilestoneTotalSpent = doc.data()?.milestones?.totalSpent ?? prevTotalSpent;
      const prevTotalMealsLogged = doc.data()?.totalMealsLogged || 0;

      // ─── Inline quest counters (atomic with balance deduction) ───
      const userData = doc.data()!;
      const weekStart = getWeekStartDate(today);

      const daily = userData.challenges?.daily || {};
      let dailyCount = daily.aiCount || 0;
      let dailyClaimed = daily.claimedRewards || [];
      if (daily.date !== today) {
        dailyCount = 0;
        dailyClaimed = [];
      }
      dailyCount += amount;

      const weekly = userData.challenges?.weekly || {};
      let weeklyCount = weekly.aiCount || 0;
      let weeklyClaimed = weekly.claimedRewards || [];
      let weeklyReferFriends = weekly.referFriends || 0;
      if (weekly.weekStartDate !== weekStart) {
        weeklyCount = 0;
        weeklyClaimed = [];
        weeklyReferFriends = 0;
      }
      weeklyCount += amount;

      // ─── Tier Celebration: Initialize starter celebration on first paid AI usage ───
      const updateData: any = {
        balance: updated,
        totalSpent: prevTotalSpent + amount,
        "milestones.totalSpent": prevMilestoneTotalSpent + amount,
        totalMealsLogged: prevTotalMealsLogged + 1,
        lastAiUsageDate: today,
        "challenges.daily.aiCount": dailyCount,
        "challenges.daily.date": today,
        "challenges.daily.claimedRewards": dailyClaimed,
        "challenges.weekly.aiCount": weeklyCount,
        "challenges.weekly.weekStartDate": weekStart,
        "challenges.weekly.claimedRewards": weeklyClaimed,
        "challenges.weekly.referFriends": weeklyReferFriends,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Initialize starter tier celebration if not exists
      if (!userData.tierCelebration?.starter) {
        console.log(`🎉 [TierCelebration] Initializing starter celebration for ${deviceId}`);
        updateData["tierCelebration.starter"] = {
          startDate: today,
          claimedDays: [],
        };
      }

      transaction.update(docRef, updateData);

      console.log(`💰 [Firestore] ${deviceId}: ${currentBalance} - ${amount} = ${updated}, daily=${dailyCount}, weekly=${weeklyCount}`);
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
  type: "image" | "text" | "barcode" | "chat" | "menu_suggestion" | "batch_text";
  prompt?: string;
  text?: string;
  imageBase64?: string;
  additionalImagesBase64?: string[];
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

  return `You are ArCal, a friendly nutrition assistant for users worldwide.

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
function buildChatPrompt(text: string, userContext?: any, foodContext?: any): string {
  let contextInfo = "";

  if (userContext) {
    contextInfo = "\n\nUser Profile:";
    if (userContext.gender) contextInfo += `\n- Gender: ${userContext.gender}`;
    if (userContext.age) contextInfo += `\n- Age: ${userContext.age} years`;
    if (userContext.weight) contextInfo += `\n- Weight: ${userContext.weight} kg`;
    if (userContext.activityLevel) contextInfo += `\n- Activity Level: ${userContext.activityLevel}`;
    if (userContext.weightGoal) contextInfo += `\n- Weight Goal: ${userContext.weightGoal}`;
    
    // Nutrition Goals (comprehensive)
    contextInfo += "\n\nNUTRITION GOALS:";
    if (userContext.calorieGoal || userContext.proteinGoal || userContext.carbGoal || userContext.fatGoal) {
      contextInfo += `\n- Daily: ${userContext.calorieGoal || 2000} kcal | P: ${userContext.proteinGoal || 120}g | C: ${userContext.carbGoal || 250}g | F: ${userContext.fatGoal || 65}g`;
    }
    if (userContext.breakfastBudget || userContext.lunchBudget || userContext.dinnerBudget || userContext.snackBudget) {
      contextInfo += `\n- Meal Budgets: Breakfast ${userContext.breakfastBudget || 560} kcal | Lunch ${userContext.lunchBudget || 700} kcal | Dinner ${userContext.dinnerBudget || 600} kcal | Snack ${userContext.snackBudget || 140} kcal`;
    }
    contextInfo += `\n- Micronutrients (standard): Fiber 25g | Sugar <25g | Sodium <2300mg`;
    
    if (userContext.cuisinePreference) contextInfo += `\n- Cuisine Preference: ${userContext.cuisinePreference}`;
  }

  // Food Context from local database
  let foodContextInfo = "";
  if (foodContext) {
    if (foodContext.savedMeals && foodContext.savedMeals.length > 0) {
      foodContextInfo += "\n\nUSER'S SAVED MEALS (MyMeal database):";
      foodContextInfo += `\n[${foodContext.savedMeals.slice(0, 50).join(", ")}]`;
    }
    
    if (foodContext.savedIngredients && foodContext.savedIngredients.length > 0) {
      foodContextInfo += "\n\nUSER'S SAVED INGREDIENTS (single items they've logged before):";
      foodContextInfo += `\n[${foodContext.savedIngredients.slice(0, 50).join(", ")}]`;
    }
    
    if (foodContext.recentHistory && foodContext.recentHistory.length > 0) {
      foodContextInfo += "\n\nRECENT FOOD HISTORY (last 7 days):";
      foodContextInfo += `\n[${foodContext.recentHistory.join(" | ")}]`;
    }
    
    if (foodContext.todaySummary) {
      const ts = foodContext.todaySummary;
      foodContextInfo += "\n\nTODAY'S PROGRESS:";
      foodContextInfo += `\n- Consumed: ${ts.consumed} kcal (P: ${ts.protein}g, C: ${ts.carbs}g, F: ${ts.fat}g)`;
      foodContextInfo += `\n- Target: ${ts.target} kcal | Remaining: ${ts.remaining} kcal`;
    }
  }

  const cuisinePref = userContext?.cuisinePreference || "international";

  return `You are ArCal, a friendly nutrition assistant AND food scientist for users worldwide.${contextInfo}${foodContextInfo}

Parse the user's message and extract ALL food items mentioned.
The user may type in ANY language — detect the language automatically.

═══════════════════════════════════════════════════════════════════
CRITICAL: CUSTOM MEAL MODE — When User Specifies Ingredients
═══════════════════════════════════════════════════════════════════

If user specifies ingredients when logging food (ANY of these patterns):
  • "สร้างเมนู X มีส่วนผสม A, B, C"
  • "กินข้าวผัด จากข้าว 200g ไข่ 2 ลูก"
  • "ข้าวผัดทำเอง มี ข้าว, ไข่, น้ำมัน, ซอส"
  • "ate fried rice from rice, eggs, oil"
  • Lists items with quantities: "ข้าว 200g อกไก่ 100g"

Detection keywords: "จาก", "มี", "ส่วนผสม", "ingredients", "made of", "from", "มีส่วนผสม", "ประกอบด้วย"

→ USE CUSTOM MEAL MODE:
1. Set ALL nutrition to 0 (zero):
   - calories: 0
   - protein: 0
   - carbs: 0
   - fat: 0
   - fiber: 0
   - sugar: 0
   - sodium: 0

2. Do NOT include "ingredients_detail" field

3. Include "ingredients_hint" field with ingredient objects:
   - Extract ingredient names AND amounts/units from the user's message
   - Keep original language for names (Thai/English/etc)
   - If user specified an amount (e.g., "ข้าว 200g"), include it
   - If user did NOT specify an amount, set amount to 0
   - Format: array of objects with "name", "amount", "unit"
   - Example: "ingredients_hint": [
       {"name": "ข้าว", "amount": 200, "unit": "g"},
       {"name": "ไข่", "amount": 2, "unit": "egg"},
       {"name": "น้ำมัน", "amount": 0, "unit": "g"},
       {"name": "ซอสถั่วเหลือง", "amount": 0, "unit": "g"}
     ]

4. food_name_local = meal name ONLY (clean, no ingredients)
   - ✅ GOOD: "ข้าวผัดทำเอง"
   - ❌ BAD: "ข้าวผัดทำเอง (ข้าว, ไข่, น้ำมัน)"

5. Reply: "I've added [meal name] to your timeline with the ingredients you specified. Press Analyze All to get full nutrition breakdown!"

Example Response for Custom Meal:
{
  "type": "food_log",
  "reply": "บันทึก 'ข้าวผัดทำเอง' แล้ว! กด Analyze All ที่ Timeline เพื่อคำนวณโภชนาการครบถ้วน",
  "items": [{
    "food_name": "Homemade Fried Rice",
    "food_name_local": "ข้าวผัดทำเอง",
    "meal_type": "lunch",
    "serving_size": 1,
    "serving_unit": "serving",
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fat": 0,
    "fiber": 0,
    "sugar": 0,
    "sodium": 0,
    "ingredients_hint": [
      {"name": "ข้าว", "amount": 200, "unit": "g"},
      {"name": "ไข่", "amount": 2, "unit": "egg"},
      {"name": "น้ำมัน", "amount": 0, "unit": "g"},
      {"name": "ซอสถั่วเหลือง", "amount": 0, "unit": "g"}
    ]
  }]
}

═══════════════════════════════════════════════════════════════════
NORMAL MODE — When User Does NOT Specify Ingredients
═══════════════════════════════════════════════════════════════════

INGREDIENT DECONSTRUCTION RULES (CRITICAL):
For food items WITHOUT ingredient hints, you MUST deconstruct into specific ingredients following these rules:

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

SMART MATCHING RULES (if user has saved meals/ingredients in database):
- When user mentions a food, check if it matches any name in SAVED MEALS or SAVED INGREDIENTS
- If match found: use the EXACT saved name as food_name_local (this enables automatic DB lookup on client)
- If no match: use a descriptive name as usual
- Example: User says "ไข่ 2 ลูก" and "ไข่ต้ม" is in SAVED INGREDIENTS -> use food_name_local: "ไข่ต้ม"
- Example: User says "กะเพรา" and "ข้าวกะเพราหมูสับ" is in SAVED MEALS -> use food_name_local: "ข้าวกะเพราหมูสับ"

DATA QUESTIONS:
- When user asks about their eating patterns, history, or statistics, answer using the provided RECENT FOOD HISTORY context
- Example: "เดือนนี้กินอะไรเยอะสุด?" -> analyze the recent history data provided above

CRITICAL: When user asks questions about:
- "วันนี้กินไปกี่แคล?" → Use TODAY'S PROGRESS data above, respond with conversational answer
- "สัปดาห์นี้กินอะไรบ้าง?" → Use RECENT FOOD HISTORY data above
- "อยากทำอาหารประมาณ X แคล" → Suggest meals from SAVED MEALS or SAVED INGREDIENTS that match the target
- "ช่วยแนะนำเมนู" → Use their goals, today's progress, and saved meals to recommend

Example responses:
{
  "type": "conversational",
  "reply": "วันนี้คุณกินไป 850 kcal แล้ว (โปรตีน 45g, คาร์บ 90g, ไขมัน 30g) เหลืออีก 1150 kcal จากเป้าหมาย 2000 kcal 😊"
}

{
  "type": "conversational",
  "reply": "จากประวัติ 7 วันที่ผ่านมา คุณกิน 'ข้าวกะเพรา' บ่อยที่สุด (ปรากฏ 4 ครั้ง) รองลงมาคือ 'ส้มตำ' (3 ครั้ง) 🍽️"
}

WRONG example (don't do this):
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
async function callGeminiAPI(request: GeminiRequest, apiKey: string, userContext?: any, foodContext?: any): Promise<any> {
  // สร้าง prompt ตาม type
  let promptText: string;
  if (request.type === "menu_suggestion" && request.text) {
    promptText = buildMenuSuggestionPrompt(request.text, userContext);
  } else if (request.type === "chat" && request.text) {
    promptText = buildChatPrompt(request.text, userContext, foodContext);
  } else if (request.prompt) {
    promptText = request.prompt;
  } else {
    throw new Error("Missing prompt or text for request");
  }

  const parts: any[] = [{text: promptText}];

  if (request.imageBase64 && request.type === "image") {
    parts.push({
      inline_data: {
        mime_type: "image/png",
        data: request.imageBase64,
      },
    });

    if (request.additionalImagesBase64 && request.additionalImagesBase64.length > 0) {
      for (const additionalImage of request.additionalImagesBase64) {
        parts.push({
          inline_data: {
            mime_type: "image/png",
            data: additionalImage,
          },
        });
      }
      console.log(`📸 Multi-angle: sending ${1 + request.additionalImagesBase64.length} images to Gemini`);
    }
  }

  // batch_text needs higher output tokens for multiple items with ingredients_detail
  const maxTokens = request.type === "batch_text" ? 8192 : 4096;

  // Tune generation parameters per request type:
  // - Food analysis (image/text/barcode/batch_text): low temperature for accuracy & consistency
  // - Chat/menu_suggestion: slightly higher temperature for natural conversation
  const isAnalysis = ["image", "text", "barcode", "batch_text"].includes(request.type);

  const requestBody = {
    contents: [{parts}],
    generationConfig: {
      temperature: isAnalysis ? 0.15 : 0.4,
      topK: isAnalysis ? 10 : 32,
      topP: isAnalysis ? 0.8 : 0.95,
      maxOutputTokens: maxTokens,
      ...(isAnalysis ? {responseMimeType: "application/json"} : {}),
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

      // SECURITY: Token deduplication — ป้องกันใช้ token ซ้ำ (nonce)
      const tokenHash = crypto.createHash("sha256").update(energyToken).digest("hex").substring(0, 32);
      const tokenRef = db.collection("used_tokens").doc(tokenHash);
      const tokenDoc = await tokenRef.get();
      if (tokenDoc.exists) {
        console.warn(`🚫 [analyzeFood] Token replay detected: ${tokenHash}`);
        res.status(401).json({error: "Token already used"});
        return;
      }
      await tokenRef.set({
        deviceId: token.userId,
        usedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 10 * 60 * 1000)),
      });

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
      const {type, text, prompt, imageBase64, additionalImagesBase64, deviceId: requestDeviceId, userContext, foodContext, timezoneOffset, freeChat} = req.body;

      // ────── 4.2.0. เช็ค Subscription (Phase 5) ──────
      const userDoc = await db.collection("users").doc(deviceId).get();
      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const userData = userDoc.data()!;
      const subscription = userData.subscription;
      const isSubscriber = subscription?.status === "active";

      // ────── Freepass: auto-activate if subscription expired & has days ──────
      const freepass = userData.freepass ?? {};
      let isFreepassActive = freepass.isActive === true;
      const freepassTotalDays = freepass.totalDays ?? 0;

      // Auto-activate freepass when:
      // 1. Not a subscriber (subscription expired/cancelled/none)
      // 2. Has freepass days available
      // 3. Freepass is not yet active
      if (!isSubscriber && !isFreepassActive && freepassTotalDays > 0) {
        const now = new Date();
        const periodEnd = new Date(now.getTime() + freepassTotalDays * 24 * 60 * 60 * 1000);
        await userDoc.ref.update({
          "freepass.isActive": true,
          "freepass.activatedAt": admin.firestore.FieldValue.serverTimestamp(),
          "freepass.currentPeriodEnd": admin.firestore.Timestamp.fromDate(periodEnd),
        });
        isFreepassActive = true;
        console.log(`🎫 [Freepass] Auto-activated ${freepassTotalDays} days for ${deviceId}`);
      }

      // Deduct freepass day if active and new day
      if (isFreepassActive && freepassTotalDays > 0) {
        const today = getTodayString(timezoneOffset);
        const lastDeducted = freepass.lastDeductedDate ?? "";

        if (lastDeducted !== today) {
          const newTotalDays = freepassTotalDays - 1;
          const updateData: any = {
            "freepass.totalDays": newTotalDays,
            "freepass.lastDeductedDate": today,
          };

          if (newTotalDays <= 0) {
            updateData["freepass.isActive"] = false;
            updateData["freepass.currentPeriodEnd"] = null;
            console.log(`🎫 [Freepass] Expired for ${deviceId} — no days remaining`);
          }

          await userDoc.ref.update(updateData);
          console.log(`🎫 [Freepass] Deducted 1 day for ${deviceId}, remaining: ${newTotalDays}`);
        }
      }

      // Check if freepass expired (currentPeriodEnd passed)
      if (isFreepassActive && freepass.currentPeriodEnd) {
        const periodEnd = freepass.currentPeriodEnd.toDate
          ? freepass.currentPeriodEnd.toDate()
          : new Date(freepass.currentPeriodEnd);
        if (periodEnd < new Date()) {
          await userDoc.ref.update({
            "freepass.isActive": false,
            "freepass.totalDays": 0,
            "freepass.currentPeriodEnd": null,
          });
          isFreepassActive = false;
          console.log(`🎫 [Freepass] Period expired for ${deviceId}`);
        }
      }

      if (isSubscriber || isFreepassActive) {
        // Subscriber or Freepass → ใช้ AI ฟรีไม่จำกัด!
        const accessType = isSubscriber ? "Subscriber" : "Freepass";
        console.log(`💎 [analyzeFood] ${accessType} ${deviceId} — free unlimited!`);

        try {
          // เรียก Gemini API ได้เลย
          const geminiRequest: GeminiRequest = {
            type: type as GeminiRequest["type"],
            text: text,
            prompt: prompt,
            imageBase64: imageBase64,
            additionalImagesBase64: additionalImagesBase64,
          };

          const apiKey = GEMINI_API_KEY.value();
          const geminiResponse = await callGeminiAPI(geminiRequest, apiKey, userContext, foodContext);

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
              type: isFreepassActive ? "freepass_usage" : "subscription_usage",
              amount: 0,
              balanceAfter: currentBalance,
              description: `AI analysis (${accessType}): ${type}`,
              metadata: {
                requestType: type,
                isSubscriber,
                isFreepass: isFreepassActive,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            await userDoc.ref.update({
              totalMealsLogged: admin.firestore.FieldValue.increment(1),
            });

            // Re-read freepass in case it was updated
            const latestFreepass = isFreepassActive
              ? (await db.collection("users").doc(deviceId).get()).data()?.freepass ?? {}
              : userData.freepass ?? {};

            res.status(200).json({
              success: true,
              ...parsedResult,
              balance: currentBalance,
              energyUsed: 0,
              energyCost: 0,
              wasFreeAi: false,
              isSubscriber: isSubscriber,
              isFreepass: isFreepassActive,
              streak: {
                current: userData.currentStreak || 0,
                longest: userData.longestStreak || 0,
                tier: userData.tier || "none",
                tierUpgraded: false,
                energyBonus: 0,
              },
              challenges: {
                daily: userData.challenges?.daily || {},
                weekly: userData.challenges?.weekly || {},
              },
              milestones: userData.milestones || {},
              totalSpent: userData.totalSpent || 0,
              tierCelebration: userData.tierCelebration || {},
              freepass: latestFreepass,
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
              type: isFreepassActive ? "freepass_usage" : "subscription_usage",
              amount: 0,
              balanceAfter: currentBalance,
              description: `AI analysis (${accessType}): ${type}`,
              metadata: {
                requestType: type,
                isSubscriber,
                isFreepass: isFreepassActive,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            await userDoc.ref.update({
              totalMealsLogged: admin.firestore.FieldValue.increment(1),
            });

            const latestFreepass2 = isFreepassActive
              ? (await db.collection("users").doc(deviceId).get()).data()?.freepass ?? {}
              : userData.freepass ?? {};

            res.status(200).json({
              success: true,
              data: geminiResponse,
              balance: currentBalance,
              energyUsed: 0,
              energyCost: 0,
              wasFreeAi: false,
              isSubscriber: isSubscriber,
              isFreepass: isFreepassActive,
              streak: {
                current: userData.currentStreak || 0,
                longest: userData.longestStreak || 0,
                tier: userData.tier || "none",
                tierUpgraded: false,
                energyBonus: 0,
              },
              challenges: {
                daily: userData.challenges?.daily || {},
                weekly: userData.challenges?.weekly || {},
              },
              milestones: userData.milestones || {},
              totalSpent: userData.totalSpent || 0,
              tierCelebration: userData.tierCelebration || {},
              freepass: latestFreepass2,
            });
            return;
          }
        } catch (error: any) {
          console.error("❌ [Subscriber] Gemini error:", error);
          res.status(500).json({error: error.message});
          return;
        }
      }

      // ────── 4.2.1. เช็ค balance + หัก energy ──────

      // Validate required fields (before deducting)
      if (!type || !requestDeviceId) {
        res.status(400).json({error: "Missing required fields: type and deviceId"});
        return;
      }

      if ((type === "chat" || type === "menu_suggestion") && !text) {
        res.status(400).json({error: `Missing text for ${type} type`});
        return;
      }

      if (type === "image" && !imageBase64) {
        res.status(400).json({error: "Missing imageBase64 for image type"});
        return;
      }

      if ((type === "image" || type === "text" || type === "barcode" || type === "batch_text") && !prompt) {
        res.status(400).json({error: "Missing prompt for this type"});
        return;
      }

      const itemCount = req.body.itemCount;

      if (type === "batch_text" && (!itemCount || itemCount < 1)) {
        res.status(400).json({error: "Missing or invalid itemCount for batch_text type"});
        return;
      }

      // ────── 4.2.2. Free Chat: chat/menu_suggestion are free with daily limit ──────
      const isFreeChatRequest = freeChat === true && (type === "chat" || type === "menu_suggestion");
      const FREE_CHAT_DAILY_LIMIT = 10;

      let newBalance: number = serverBalance;
      let baseCost: number;

      if (isFreeChatRequest) {
        baseCost = 0;
        // Server-side daily chat limit check
        const today = getLocalDateString(timezoneOffset);
        const chatLimitKey = `chatLimit_${today}`;
        const dailyChatCount = userData[chatLimitKey] || 0;

        if (dailyChatCount >= FREE_CHAT_DAILY_LIMIT) {
          res.status(429).json({
            error: `Daily chat limit reached (${FREE_CHAT_DAILY_LIMIT}/day)`,
            dailyChatLimit: FREE_CHAT_DAILY_LIMIT,
            dailyChatUsed: dailyChatCount,
          });
          return;
        }

        // Increment daily chat count
        await db.collection("users").doc(deviceId).update({
          [chatLimitKey]: admin.firestore.FieldValue.increment(1),
        });

        console.log(`💬 [analyzeFood] Free chat ${dailyChatCount + 1}/${FREE_CHAT_DAILY_LIMIT} for ${deviceId}`);
      } else {
        // Determine BASE energy cost:
        // - batch_text = itemCount (client sends exact count)
        // - others = 1
        baseCost = (type === "batch_text" && itemCount > 0) ? itemCount : 1;

        // ────── 4.3. SECURITY: Deduct balance BEFORE calling Gemini API ──────
        try {
          newBalance = await deductServerBalance(deviceId, baseCost, timezoneOffset);
          console.log(`✅ [analyzeFood] Pre-deducted ${baseCost}E → balance: ${newBalance}`);
        } catch (error: any) {
          console.log(`❌ [analyzeFood] Insufficient balance: ${error.message}`);
          res.status(402).json({
            error: "Insufficient energy",
            balance: serverBalance,
            required: baseCost,
          });
          return;
        }
      }

      // ────── 4.3.1. Auto check-in: first energy use of the day = streak ──────
      let checkInResult: CheckInResult | null = null;
      try {
        checkInResult = await processCheckIn(deviceId, timezoneOffset);
        if (!checkInResult.alreadyCheckedIn) {
          console.log(`🔥 [analyzeFood] Auto check-in: streak=${checkInResult.currentStreak}, tier=${checkInResult.tier}, +${checkInResult.dailyEnergy}E`);
          newBalance = checkInResult.newBalance ?? newBalance;
        }
      } catch (e) {
        console.error("[analyzeFood] Auto check-in error:", e);
      }

      // ────── 4.4. Call Gemini API ──────
      const geminiRequest: GeminiRequest = {
        type: type as GeminiRequest["type"],
        text: text,
        prompt: prompt,
        imageBase64: imageBase64,
        additionalImagesBase64: additionalImagesBase64,
      };

      const apiKey = GEMINI_API_KEY.value();
      let geminiResponse: any;

      try {
        geminiResponse = await callGeminiAPI(geminiRequest, apiKey, userContext, foodContext);
        console.log("✅ Gemini API success");
      } catch (geminiError: any) {
        console.error("❌ [analyzeFood] Gemini API failed:", geminiError.message);
        if (!isFreeChatRequest && baseCost > 0) {
          try {
            await addServerBalance(deviceId, baseCost, "refund_gemini_fail");
            console.log(`💰 [analyzeFood] Refunded ${baseCost}E to ${deviceId}`);
          } catch (refundError) {
            console.error("❌ [analyzeFood] CRITICAL: Refund failed!", refundError);
          }
        }
        res.status(500).json({error: isFreeChatRequest ? "AI analysis failed. Please try again." : "AI analysis failed. Energy has been refunded.", noCharge: true});
        return;
      }

      // ────── 4.5. Validate & parse response ──────
      const rawText = geminiResponse?.candidates?.[0]?.content?.parts?.[0]?.text || "";
      const finishReason = geminiResponse?.candidates?.[0]?.finishReason || "UNKNOWN";

      if (finishReason === "MAX_TOKENS") {
        console.log(`⚠️ [analyzeFood] Response TRUNCATED (MAX_TOKENS) for type=${type}`);
      }

      // Chat/menu_suggestion path
      if (type === "chat" || type === "menu_suggestion") {
        const jsonText = extractJsonFromText(rawText);
        if (!jsonText) {
          if (!isFreeChatRequest && baseCost > 0) {
            try { await addServerBalance(deviceId, baseCost, "refund_invalid_response"); } catch (_e) { /* logged */ }
          }
          res.status(422).json({error: isFreeChatRequest ? "AI returned invalid response." : "AI returned invalid response. Energy refunded.", noCharge: true});
          return;
        }

        let parsedResult: any;
        try {
          parsedResult = JSON.parse(jsonText);
        } catch (_e) {
          if (!isFreeChatRequest && baseCost > 0) {
            try { await addServerBalance(deviceId, baseCost, "refund_parse_error"); } catch (_e2) { /* logged */ }
          }
          res.status(422).json({error: isFreeChatRequest ? "AI returned invalid data." : "AI returned invalid data. Energy refunded.", noCharge: true});
          return;
        }

        validateServingUnits(parsedResult);
        const chatItemCount = (parsedResult.items && Array.isArray(parsedResult.items)) ? parsedResult.items.length : 0;

        // Log transaction
        const miroId = userData.miroId || "unknown";
        await db.collection("transactions").add({
          deviceId, miroId,
          type: isFreeChatRequest ? "free_chat_usage" : "usage",
          amount: isFreeChatRequest ? 0 : -baseCost,
          balanceAfter: newBalance,
          description: `AI chat: ${type} (${chatItemCount} items parsed)${isFreeChatRequest ? " [FREE]" : ""}`,
          metadata: {requestType: type, itemCount: chatItemCount, baseCost, totalCost: baseCost, isFreeChat: isFreeChatRequest},
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        try { await checkReferralProgress(deviceId); } catch (_e) { /* non-blocking */ }

        // Milestone check
        let milestoneResult = null;
        let offerResult = null;
        let challengesData: any = {};
        let milestonesData: any = {};
        let updatedData: any = userData; // Initialize with userData as fallback
        try {
          milestoneResult = await checkAndProcessMilestone(deviceId, baseCost);
          if (milestoneResult.milestoneReached) newBalance += milestoneResult.reward;
          if (milestoneResult.triggerFirstPurchaseOffer) {
            offerResult = await checkWelcomeOfferPromotion(deviceId, milestoneResult.newTotalSpent);
          }
          const updatedUser = await db.collection("users").doc(deviceId).get();
          updatedData = updatedUser.data()!;
          challengesData = updatedData.challenges || {};
          milestonesData = updatedData.milestones || {};
          newBalance = updatedData.balance || newBalance;
        } catch (_e) { console.error("[analyzeFood] milestone check error:", _e); }

        // Evaluate offers based on events
        const newTotalSpent = milestoneResult?.newTotalSpent ?? updatedData.totalSpent ?? userData.totalSpent ?? 0;
        const prevTotalSpent = userData.totalSpent || 0;
        const newTotalMealsLogged = updatedData.totalMealsLogged ?? userData.totalMealsLogged ?? 0;

        try {
          // Event: first_energy_use (totalSpent เปลี่ยนจาก 0 → 1+)
          if (prevTotalSpent === 0 && newTotalSpent > 0) {
            await evaluateOffers(deviceId, "first_energy_use", { totalSpent: newTotalSpent });
          }

          // Event: energy_use_milestone (ตรวจทุกครั้ง — engine จะ filter เอง)
          await evaluateOffers(deviceId, "energy_use_milestone", { totalSpent: newTotalSpent });

          // Event: meals_logged_milestone
          await evaluateOffers(deviceId, "meals_logged_milestone", { totalMealsLogged: newTotalMealsLogged });
        } catch (e) {
          // Silent fail — ห้าม crash analyzeFood
          console.error("[analyzeFood] evaluateOffers error:", e);
        }

        res.status(200).set("X-Energy-Balance", newBalance.toString()).json({
          success: true, ...parsedResult, balance: newBalance,
          energyUsed: baseCost, energyCost: baseCost,
          energyBreakdown: {baseCost, itemCount: chatItemCount, perItemCost: 0, totalCost: baseCost},
          wasFreeAi: isFreeChatRequest,
          isFreeChat: isFreeChatRequest,
          ...(milestoneResult?.milestoneReached ? {milestone: {label: milestoneResult.milestoneLabel, reward: milestoneResult.reward, nextMilestone: milestoneResult.nextMilestone}} : {}),
          ...(offerResult ? {newOffer: {type: offerResult.type}} : {}),
          streak: {
            current: checkInResult?.currentStreak ?? updatedData.currentStreak ?? 0,
            longest: checkInResult?.longestStreak ?? updatedData.longestStreak ?? 0,
            tier: checkInResult?.tier ?? updatedData.tier ?? "none",
            tierUpgraded: checkInResult?.tierUpgraded ?? false,
            tierDemoted: checkInResult?.tierDemoted ?? false,
            previousTier: checkInResult?.previousTier,
            newTier: checkInResult?.tierUpgraded ? checkInResult?.newTier : undefined,
            energyBonus: checkInResult?.dailyEnergy ?? 0,
            showWelcomeBackOffer: checkInResult?.showWelcomeBackOffer ?? false,
            tierRewardEnergy: checkInResult?.tierRewardEnergy ?? 0,
            promotionBonusRate: checkInResult?.promotionBonusRate ?? 0,
          },
          challenges: {daily: challengesData.daily || {}, weekly: challengesData.weekly || {}},
          milestones: milestonesData,
          totalSpent: milestoneResult?.newTotalSpent ?? 0,
          tierCelebration: updatedData.tierCelebration || {},
          freepass: updatedData.freepass || {},
        });
        return;
      }

      // ────── Non-chat path (image/text/barcode/batch_text) ──────
      const extractedJson = extractJsonFromText(rawText);

      if (!extractedJson) {
        // Refund energy — AI couldn't process
        try { await addServerBalance(deviceId, baseCost, "refund_no_json"); } catch (_e) { /* logged */ }
        const lower = rawText.toLowerCase();
        if (lower.includes("sorry") || lower.includes("cannot") || lower.includes("unable") || lower.includes("not a food") || lower.includes("no food")) {
          res.status(422).json({error: "AI could not analyze this food. Energy refunded.", noCharge: true});
          return;
        }
        res.status(422).json({error: "AI returned invalid response. Energy refunded.", noCharge: true});
        return;
      }

      try {
        JSON.parse(extractedJson);
      } catch (_parseErr: any) {
        try { await addServerBalance(deviceId, baseCost, "refund_invalid_json"); } catch (_e) { /* logged */ }
        res.status(422).json({error: "AI returned invalid data. Energy refunded.", noCharge: true});
        return;
      }

      // Log transaction
      const miroId2 = userData.miroId || "unknown";
      await db.collection("transactions").add({
        deviceId, miroId: miroId2, type: "usage", amount: -baseCost, balanceAfter: newBalance,
        description: `AI analysis: ${type}`,
        metadata: {requestType: type},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      try { await checkReferralProgress(deviceId); } catch (_e) { /* non-blocking */ }

      // Milestone check
      let milestoneResult2 = null;
      let offerResult2 = null;
      let challengesData2: any = {};
      let milestonesData2: any = {};
      let updatedData2: any = userData; // Initialize with userData as fallback
      try {
        milestoneResult2 = await checkAndProcessMilestone(deviceId, baseCost);
        if (milestoneResult2.milestoneReached) newBalance += milestoneResult2.reward;
        if (milestoneResult2.triggerFirstPurchaseOffer) {
          offerResult2 = await checkWelcomeOfferPromotion(deviceId, milestoneResult2.newTotalSpent);
        }
        const updatedUser = await db.collection("users").doc(deviceId).get();
        updatedData2 = updatedUser.data()!;
        challengesData2 = updatedData2.challenges || {};
        milestonesData2 = updatedData2.milestones || {};
        newBalance = updatedData2.balance || newBalance;
      } catch (_e) { console.error("[analyzeFood] milestone check error:", _e); }

      // Evaluate offers based on events
      const newTotalSpent2 = milestoneResult2?.newTotalSpent ?? updatedData2.totalSpent ?? userData.totalSpent ?? 0;
      const prevTotalSpent2 = userData.totalSpent || 0;
      const newTotalMealsLogged2 = updatedData2.totalMealsLogged ?? userData.totalMealsLogged ?? 0;

      try {
        // Event: first_energy_use (totalSpent เปลี่ยนจาก 0 → 1+)
        if (prevTotalSpent2 === 0 && newTotalSpent2 > 0) {
          await evaluateOffers(deviceId, "first_energy_use", { totalSpent: newTotalSpent2 });
        }

        // Event: energy_use_milestone (ตรวจทุกครั้ง — engine จะ filter เอง)
        await evaluateOffers(deviceId, "energy_use_milestone", { totalSpent: newTotalSpent2 });

        // Event: meals_logged_milestone
        await evaluateOffers(deviceId, "meals_logged_milestone", { totalMealsLogged: newTotalMealsLogged2 });
      } catch (e) {
        // Silent fail — ห้าม crash analyzeFood
        console.error("[analyzeFood] evaluateOffers error:", e);
      }

      res.status(200).set("X-Energy-Balance", newBalance.toString()).json({
        success: true, data: geminiResponse, balance: newBalance,
        energyUsed: baseCost, energyCost: baseCost, wasFreeAi: false,
        ...(milestoneResult2?.milestoneReached ? {milestone: {label: milestoneResult2.milestoneLabel, reward: milestoneResult2.reward, nextMilestone: milestoneResult2.nextMilestone}} : {}),
        ...(offerResult2 ? {newOffer: {type: offerResult2.type}} : {}),
        streak: {
          current: checkInResult?.currentStreak ?? updatedData2.currentStreak ?? 0,
          longest: checkInResult?.longestStreak ?? updatedData2.longestStreak ?? 0,
          tier: checkInResult?.tier ?? updatedData2.tier ?? "none",
          tierUpgraded: checkInResult?.tierUpgraded ?? false,
          tierDemoted: checkInResult?.tierDemoted ?? false,
          previousTier: checkInResult?.previousTier,
          newTier: checkInResult?.tierUpgraded ? checkInResult?.newTier : undefined,
          energyBonus: checkInResult?.dailyEnergy ?? 0,
          showWelcomeBackOffer: checkInResult?.showWelcomeBackOffer ?? false,
          tierRewardEnergy: checkInResult?.tierRewardEnergy ?? 0,
          promotionBonusRate: checkInResult?.promotionBonusRate ?? 0,
        },
        challenges: {daily: challengesData2.daily || {}, weekly: challengesData2.weekly || {}},
        milestones: milestonesData2,
        totalSpent: milestoneResult2?.newTotalSpent ?? 0,
        tierCelebration: updatedData2.tierCelebration || {},
        freepass: updatedData2.freepass || {},
      });
    } catch (error: any) {
      console.error("❌ Error:", error);
      res.status(500).json({
        error: error.message || "Internal server error",
      });
    }
  });
