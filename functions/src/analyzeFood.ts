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

// Define secrets
const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const ENERGY_ENCRYPTION_SECRET = defineSecret('ENERGY_ENCRYPTION_SECRET');

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
  balance: number;     // Current energy balance
  timestamp: number;   // Token creation time
  signature: string;   // HMAC signature
}

/**
 * ตรวจสอบความถูกต้องของ Energy Token
 */
function verifyEnergyToken(token: string, secret: string): EnergyToken | null {
  try {
    const decoded = JSON.parse(
      Buffer.from(token, 'base64').toString('utf-8')
    ) as EnergyToken;
    
    // ตรวจสอบว่า token ไม่เก่าเกิน 5 นาที (ป้องกัน replay attack)
    const now = Date.now();
    if (now - decoded.timestamp > 5 * 60 * 1000) {
      console.log('❌ Token expired');
      return null;
    }
    
    // ตรวจสอบ signature
    const payload = `${decoded.userId}:${decoded.balance}:${decoded.timestamp}`;
    const expectedSignature = generateSignature(payload, secret);
    
    if (decoded.signature !== expectedSignature) {
      console.log('❌ Invalid signature');
      return null;
    }
    
    return decoded;
  } catch (error) {
    console.error('❌ Token verification error:', error);
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

When providing nutrition estimates, consider:
- User's health goals (${userContext?.weightGoal || 'not specified'})
- Their typical calorie/macro targets
- Portion sizes appropriate for their profile

IMPORTANT: 
- Respond in ENGLISH only (but keep food_name_local in original language)
- Return JSON only, no markdown code blocks
- If the message is not about food (e.g. asking for health advice), provide personalized advice based on their profile

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
  
  const requestBody = {
    contents: [{ parts }],
    generationConfig: {
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: 1024,
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
      
      if (!token || token.balance < 1) {
        res.status(402).json({ 
          error: 'Insufficient energy', 
          balance: token?.balance || 0
        });
        return;
      }
      
      console.log(`✅ Token valid. User: ${token.userId}, Balance: ${token.balance}`);
      
      // ────── 4.2. Parse Request ──────
      const { type, text, prompt, imageBase64, deviceId, userContext } = req.body;
      
      // Determine energy cost based on type
      const energyCost = (type === 'chat' || type === 'menu_suggestion') ? 2 : 1;
      
      // Check if user has enough energy for this operation
      if (token.balance < energyCost) {
        res.status(402).json({ 
          error: 'Insufficient energy', 
          balance: token.balance,
          required: energyCost
        });
        return;
      }
      
      console.log(`⚡ Energy cost for ${type}: ${energyCost}`);
      
      // Log user context if provided
      if (userContext) {
        console.log(`📋 User context: ${JSON.stringify(userContext)}`);
      }
      
      // Validate required fields
      if (!type || !deviceId) {
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
      
      // ────── 4.4. Deduct Energy & Generate New Token ──────
      const newBalance = token.balance - energyCost;
      const newTimestamp = Date.now();
      const newPayload = `${token.userId}:${newBalance}:${newTimestamp}`;
      const newSignature = generateSignature(newPayload, secret);
      
      const newToken: EnergyToken = {
        userId: token.userId,
        balance: newBalance,
        timestamp: newTimestamp,
        signature: newSignature,
      };
      
      const newTokenString = Buffer.from(JSON.stringify(newToken)).toString('base64');
      
      console.log(`⚡ Energy deducted. New balance: ${newBalance}`);
      
      // ────── 4.5. Parse และ validate response (สำหรับ chat และ menu_suggestion type) ──────
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
          
          // Return parsed result
          res.status(200)
            .set('X-Energy-Balance', newBalance.toString())
            .json({
              success: true,
              ...parsedResult,
              newEnergyToken: newTokenString,
              newBalance,
            });
          return;
        } catch (parseError: any) {
          console.error('❌ Error parsing chat response:', parseError);
          // Fall through to return raw response
        }
      }
      
      // ────── 4.6. Return Response (สำหรับ type อื่นๆ) ──────
      res.status(200)
        .set('X-Energy-Balance', newBalance.toString())
        .json({
          success: true,
          data: geminiResponse,
          newEnergyToken: newTokenString,
          newBalance,
        });
      
    } catch (error: any) {
      console.error('❌ Error:', error);
      res.status(500).json({ 
        error: error.message || 'Internal server error' 
      });
    }
  });
