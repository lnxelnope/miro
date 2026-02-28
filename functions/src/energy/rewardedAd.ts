/**
 * rewardedAd.ts
 *
 * Rewarded Ads Server-Side Verification (SSV)
 *
 * Flow:
 * 1. User ดู Rewarded Ad ใน Flutter app จนจบ
 * 2. Google AdMob ส่ง SSV callback มาที่ endpoint นี้โดยตรง (server-to-server)
 * 3. เรา verify signature ด้วย AdMob public key
 * 4. Check quota (max 3 ads/วัน/user)
 * 5. Update adViews count ใน Firestore
 * 6. Flutter app poll หรือ listen Firestore → แสดง "use AI for free"
 *
 * ตั้งค่า AdMob SSV URL:
 *   AdMob Console → Ad Units → Rewarded → Server-side verification
 *   URL: https://us-central1-miro-d6856.cloudfunctions.net/verifyRewardedAd?deviceId={CUSTOM_DATA}
 *   (Flutter ส่ง deviceId ผ่าน customData parameter ของ RewardedAd)
 *
 * Security:
 * - Verify ECDSA signature จาก AdMob (ป้องกัน fake callback)
 * - Rate limit: max 3/day/user
 * - Log ทุก event สำหรับ fraud detection + analytics
 *
 * Reference:
 *   https://developers.google.com/admob/android/ssv
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import fetch from "node-fetch";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Constants ───
const MAX_ADS_PER_DAY = 3;

// AdMob public key endpoint (ดึง key ครั้งแรกแล้ว cache)
const ADMOB_PUBLIC_KEY_URL = "https://gstatic.com/admob/reward/verifier-keys.json";

// Cache public keys ใน memory (ไม่ต้อง fetch ทุก request)
let cachedKeys: Record<string, string> | null = null;
let cacheExpiry = 0;

// ─── AdMob Signature Verification ───

interface AdMobKeys {
  keys: Array<{keyId: number; pem: string; base64: string}>;
}

/**
 * ดึง AdMob Public Keys (cache 1 ชั่วโมง)
 */
async function getAdMobPublicKeys(): Promise<Record<string, string>> {
  const now = Date.now();

  if (cachedKeys && now < cacheExpiry) {
    return cachedKeys;
  }

  console.log("🔑 [RewardedAd] Fetching AdMob public keys...");
  const response = await fetch(ADMOB_PUBLIC_KEY_URL);

  if (!response.ok) {
    throw new Error(`Failed to fetch AdMob keys: ${response.status}`);
  }

  const data = (await response.json()) as AdMobKeys;
  const keys: Record<string, string> = {};

  for (const key of data.keys) {
    keys[String(key.keyId)] = key.pem;
  }

  cachedKeys = keys;
  cacheExpiry = now + 60 * 60 * 1000; // Cache 1 hour

  console.log(`🔑 [RewardedAd] Loaded ${Object.keys(keys).length} public keys`);
  return keys;
}

/**
 * Verify ECDSA Signature จาก AdMob
 *
 * AdMob signs: <query_string_without_signature>
 * ด้วย ECDSA private key ของ AdMob
 * เราต้อง verify ด้วย public key ที่ดึงมาจาก gstatic.com
 */
function verifyAdMobSignature(
  queryString: string,  // query string ทั้งหมด ยกเว้น signature=&key_id=
  signature: string,    // base64url encoded ECDSA signature
  publicKeyPem: string
): boolean {
  try {
    // Decode signature จาก base64url
    const sigBuffer = Buffer.from(
      signature.replace(/-/g, "+").replace(/_/g, "/"),
      "base64"
    );

    // Verify ECDSA signature
    const verify = crypto.createVerify("SHA256");
    verify.update(queryString);
    return verify.verify(publicKeyPem, sigBuffer);
  } catch (error) {
    console.error("❌ [RewardedAd] Signature verification error:", error);
    return false;
  }
}

// ─── Cloud Function ───

/**
 * verifyRewardedAd
 *
 * Endpoint สำหรับ AdMob SSV callback (GET request จาก AdMob servers)
 *
 * Query params ที่ AdMob ส่งมา:
 *   ad_network       - Network name
 *   ad_unit_id       - Ad unit ID
 *   custom_data      - Custom data ที่ Flutter ส่งไป (เราใช้เก็บ deviceId)
 *   key_id           - Key ID สำหรับ lookup public key
 *   reward_amount    - จำนวน reward (เราใช้แค่ verify, ไม่ใช้ amount)
 *   reward_item      - ชื่อ reward item
 *   timestamp        - Unix timestamp ที่ AdMob สร้าง callback
 *   transaction_id   - Unique transaction ID (ป้องกัน replay attack)
 *   user_id          - User ID (ถ้า set ใน Flutter, optional)
 *   signature        - ECDSA signature (ต้อง verify ก่อนทุกอย่าง)
 */
export const verifyRewardedAd = onRequest(
  {
    timeoutSeconds: 15,
    memory: "256MiB",
    cors: false, // SSV ถูกเรียกจาก AdMob servers ไม่ใช่ browser
  },
  async (req, res) => {
    // AdMob ส่งมาเป็น GET
    if (req.method !== "GET") {
      res.status(405).send("Method not allowed");
      return;
    }

    try {
      const query = req.query;

      const signature = query.signature as string;
      const keyId = query.key_id as string;
      const customData = query.custom_data as string; // deviceId ของ user
      const transactionId = query.transaction_id as string;
      const timestamp = query.timestamp as string;

      // ─── AdMob Console URL Verification Test ───
      // เมื่อ AdMob console กด "Verify URL" จะส่ง test ping มา
      // โดยที่ custom_data อาจว่าง (ไม่มี deviceId จริง)
      // เราต้องตอบ 200 OK เพื่อให้ผ่านการ verify
      if (!customData) {
        console.log("🔍 [RewardedAd] AdMob URL verification ping (no custom_data) → 200 OK");
        res.status(200).send("OK");
        return;
      }

      // Validate params จริงๆ (สำหรับ real SSV callback)
      if (!signature || !keyId || !transactionId || !timestamp) {
        console.error("❌ [RewardedAd] Missing required params:", {
          hasSignature: !!signature,
          hasKeyId: !!keyId,
          hasTransactionId: !!transactionId,
          hasTimestamp: !!timestamp,
        });
        res.status(400).send("Missing required parameters");
        return;
      }

      const deviceId = customData;

      // ─── 1. Verify signature ───
      const publicKeys = await getAdMobPublicKeys();
      const publicKeyPem = publicKeys[keyId];

      if (!publicKeyPem) {
        console.error(`❌ [RewardedAd] Unknown key_id: ${keyId}`);
        res.status(403).send("Unknown key_id");
        return;
      }

      // สร้าง query string สำหรับ verify (ทุก param ยกเว้น signature)
      const queryWithoutSig = req.url
        .split("?")[1]
        .replace(/&?signature=[^&]*/, "")
        .replace(/^&/, "");

      const isValid = verifyAdMobSignature(queryWithoutSig, signature, publicKeyPem);

      if (!isValid) {
        console.error(`🚫 [RewardedAd] Invalid signature for deviceId: ${deviceId}`);
        res.status(403).send("Invalid signature");
        return;
      }

      // ─── 2. Replay attack prevention (transaction_id dedup) ───
      const txRef = db.collection("ad_transactions").doc(transactionId);
      const txDoc = await txRef.get();

      if (txDoc.exists) {
        console.warn(`⚠️ [RewardedAd] Duplicate transaction: ${transactionId}`);
        // ตอบ 200 เพื่อไม่ให้ AdMob retry
        res.status(200).send("OK");
        return;
      }

      // ─── 3. Check quota (max 3 ads/วัน) ───
      const userRef = db.collection("users").doc(deviceId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        console.error(`❌ [RewardedAd] User not found: ${deviceId}`);
        res.status(404).send("User not found");
        return;
      }

      const user = userDoc.data()!;
      const adViews = user.adViews || {date: "", count: 0};
      // SECURITY: ใช้ UTC+7 เหมือนกับ daily claim เพื่อให้ quota reset ตรงกัน
      const nowUtc7 = new Date(Date.now() + 7 * 60 * 60 * 1000);
      const today = nowUtc7.toISOString().split("T")[0]; // 'YYYY-MM-DD'

      const todayCount = adViews.date === today ? adViews.count : 0;

      if (todayCount >= MAX_ADS_PER_DAY) {
        console.warn(`⚠️ [RewardedAd] Daily limit reached for ${deviceId}: ${todayCount}/${MAX_ADS_PER_DAY}`);
        // ตอบ 200 (AdMob ไม่ต้อง retry แต่ user ไม่ได้ reward)
        res.status(200).send("OK");
        return;
      }

      // ─── 4. Atomic update: เพิ่ม count + บันทึก transaction ───
      const newCount = todayCount + 1;

      const AD_REWARD_ENERGY = 3;
      const currentBalance = user.balance || 0;
      const newBalance = currentBalance + AD_REWARD_ENERGY;

      await db.runTransaction(async (transaction) => {
        // Update adViews + balance
        transaction.update(userRef, {
          "adViews.date": today,
          "adViews.count": newCount,
          "balance": newBalance,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // บันทึก transaction_id (ป้องกัน replay)
        transaction.set(txRef, {
          deviceId,
          transactionId,
          timestamp: parseInt(timestamp),
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log ใน transactions collection (สำหรับ analytics)
        const logRef = db.collection("transactions").doc();
        transaction.set(logRef, {
          deviceId,
          miroId: user.miroId || "unknown",
          type: "ad_reward",
          amount: AD_REWARD_ENERGY,
          balanceAfter: newBalance,
          description: `Rewarded ad: +${AD_REWARD_ENERGY}E (${newCount}/${MAX_ADS_PER_DAY} today)`,
          metadata: {
            transactionId,
            adNetwork: query.ad_network,
            adUnitId: query.ad_unit_id,
            adCount: newCount,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      console.log(
        `✅ [RewardedAd] ${deviceId}: ad ${newCount}/${MAX_ADS_PER_DAY} verified, +${AD_REWARD_ENERGY}E (balance: ${newBalance}). TX: ${transactionId}`
      );

      // AdMob คาดหวัง 200 OK
      res.status(200).send("OK");
    } catch (error: any) {
      console.error("❌ [RewardedAd] Error:", error);
      // ส่ง 500 → AdMob จะ retry
      res.status(500).send("Internal error");
    }
  }
);

/**
 * claimAdReward — Flutter เรียกหลังดู ad จนจบ (client-side fallback)
 * POST { deviceId } → { success, reward, newBalance }
 */
export const claimAdReward = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId} = req.body;
      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      const userRef = db.collection("users").doc(deviceId);
      const nowUtc7 = new Date(Date.now() + 7 * 60 * 60 * 1000);
      const today = nowUtc7.toISOString().split("T")[0];

      const result = await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw new Error("User not found");

        const user = userDoc.data()!;
        const adViews = user.adViews || {date: "", count: 0};
        const todayCount = adViews.date === today ? adViews.count : 0;

        if (todayCount >= MAX_ADS_PER_DAY) {
          throw new Error(`Daily limit reached: ${todayCount}/${MAX_ADS_PER_DAY}`);
        }

        const AD_REWARD = 3;
        const currentBalance = user.balance || 0;
        const newBalance = currentBalance + AD_REWARD;
        const newCount = todayCount + 1;

        transaction.update(userRef, {
          "adViews.date": today,
          "adViews.count": newCount,
          balance: newBalance,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: user.miroId || "unknown",
          type: "ad_reward",
          amount: AD_REWARD,
          balanceAfter: newBalance,
          description: `Ad reward: +${AD_REWARD}E (${newCount}/${MAX_ADS_PER_DAY})`,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {reward: AD_REWARD, newBalance, adsToday: newCount};
      });

      console.log(`✅ [claimAdReward] ${deviceId}: +${result.reward}E, balance=${result.newBalance}`);
      res.status(200).json({success: true, ...result});
    } catch (error: any) {
      console.error("❌ [claimAdReward] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * getAdStatus — Flutter app เรียกเพื่อเช็คว่าดู ad ได้อีกกี่ครั้ง
 * POST { deviceId } → { canWatch: boolean, remaining: number, watchedToday: number }
 */
export const getAdStatus = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId} = req.body;

      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      const userDoc = await db.collection("users").doc(deviceId).get();

      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const user = userDoc.data()!;
      const adViews = user.adViews || {date: "", count: 0};
      // SECURITY: ใช้ UTC+7 เหมือนกับ verifyRewardedAd
      const nowUtc7 = new Date(Date.now() + 7 * 60 * 60 * 1000);
      const today = nowUtc7.toISOString().split("T")[0];
      const watchedToday = adViews.date === today ? adViews.count : 0;
      const remaining = Math.max(0, MAX_ADS_PER_DAY - watchedToday);

      res.status(200).json({
        canWatch: remaining > 0,
        remaining,
        watchedToday,
        maxPerDay: MAX_ADS_PER_DAY,
      });
    } catch (error: any) {
      console.error("❌ [getAdStatus] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
