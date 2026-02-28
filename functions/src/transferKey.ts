import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// ============================================================
// Constants
// ============================================================

// ตัวอักษรที่ใช้สำหรับ Transfer Key (ไม่รวมตัวที่สับสน: 0/O, 1/I/L)
const CHARSET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

// Transfer Key หมดอายุใน 30 วัน
const KEY_EXPIRY_DAYS = 30;

// Rate limit: สร้าง key ได้สูงสุด 5 ครั้ง/ชั่วโมง/device
const RATE_LIMIT_PER_HOUR = 5;

// ============================================================
// Helper Functions
// ============================================================

/**
 * สร้าง Transfer Key รูปแบบ: MIRO-XXXX-XXXX-XXXX
 * ตัวอย่าง: MIRO-A3F9-K7X2-P8M1
 */
function generateTransferKeyString(): string {
  const segments: string[] = [];

  // สร้าง 3 segment (แต่ละ segment มี 4 ตัวอักษร)
  for (let i = 0; i < 3; i++) {
    let segment = "";
    for (let j = 0; j < 4; j++) {
      const randomIndex = Math.floor(Math.random() * CHARSET.length);
      segment += CHARSET[randomIndex];
    }
    segments.push(segment);
  }

  return `MIRO-${segments.join("-")}`;
}

/**
 * ตรวจสอบ Rate Limit: จำกัดการสร้าง key ไม่เกิน 5 ครั้ง/ชั่วโมง
 */
async function checkRateLimit(deviceId: string): Promise<void> {
  const oneHourAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 60 * 60 * 1000)
  );

  const recentKeys = await admin
    .firestore()
    .collection("transfer_keys")
    .where("sourceDeviceId", "==", deviceId)
    .where("createdAt", ">", oneHourAgo)
    .get();

  if (recentKeys.size >= RATE_LIMIT_PER_HOUR) {
    throw new HttpsError(
      "resource-exhausted",
      "Rate limit exceeded. You can generate up to 5 transfer keys per hour."
    );
  }
}

/**
 * Expire key เก่าที่ยัง active อยู่ (สร้างได้แค่ 1 active key/device)
 */
async function expirePreviousActiveKeys(deviceId: string): Promise<void> {
  const activeKeys = await admin
    .firestore()
    .collection("transfer_keys")
    .where("sourceDeviceId", "==", deviceId)
    .where("status", "==", "active")
    .get();

  if (activeKeys.size > 0) {
    const batch = admin.firestore().batch();

    activeKeys.forEach((doc) => {
      batch.update(doc.ref, {
        status: "expired",
        expiredAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
  }
}

// ============================================================
// Cloud Function: generateTransferKey
// ============================================================

export const generateTransferKey = onCall(
  {region: "asia-southeast1"},
  async (request) => {
    // 1. Validate Input
    const {deviceId} = request.data as { deviceId?: string };

    if (!deviceId || typeof deviceId !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "deviceId is required and must be a string"
      );
    }

    try {
      // 2. ตรวจสอบ Rate Limit
      await checkRateLimit(deviceId);

      // 3. ดึง Energy Balance ปัจจุบัน (จาก users collection)
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(deviceId)
        .get();

      if (!userDoc.exists) {
        throw new HttpsError(
          "not-found",
          "User not found"
        );
      }

      const energyBalance = userDoc.data()?.balance || 0;

      // 4. Expire key เก่าที่ยัง active
      await expirePreviousActiveKeys(deviceId);

      // 5. สร้าง Transfer Key ใหม่
      const transferKey = generateTransferKeyString();
      const now = admin.firestore.Timestamp.now();
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + KEY_EXPIRY_DAYS * 24 * 60 * 60 * 1000)
      );

      // 6. บันทึกลง Firestore
      await admin
        .firestore()
        .collection("transfer_keys")
        .add({
          transferKey,
          sourceDeviceId: deviceId,
          energyBalance, // Snapshot ตอนสร้าง key
          status: "active",
          createdAt: now,
          expiresAt,
          redeemedAt: null,
          redeemedByDeviceId: null,
        });

      // 7. Return ผลลัพธ์
      return {
        success: true,
        transferKey,
        energyBalance,
        expiresAt: expiresAt.toDate().toISOString(),
      };
    } catch (error: any) {
      console.error("Error in generateTransferKey:", error);

      // ถ้าเป็น HttpsError แล้ว → throw ต่อ
      if (error instanceof HttpsError) {
        throw error;
      }

      // Error อื่น ๆ → wrap เป็น internal error
      throw new HttpsError(
        "internal",
        "Failed to generate transfer key",
        error.message
      );
    }
  }
);

// ============================================================
// Cloud Function: redeemTransferKey
// ============================================================

export const redeemTransferKey = onCall(
  {region: "asia-southeast1"},
  async (request) => {
    // 1. Validate Input
    const {transferKey, newDeviceId} = request.data as {
      transferKey?: string;
      newDeviceId?: string;
    };

    if (!transferKey || typeof transferKey !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "transferKey is required and must be a string"
      );
    }

    if (!newDeviceId || typeof newDeviceId !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "newDeviceId is required and must be a string"
      );
    }

    // 2. Validate Transfer Key Format (ป้องกัน brute force)
    const keyPattern = /^MIRO-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$/;
    if (!keyPattern.test(transferKey)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid transfer key format"
      );
    }

    try {
      // 3. ค้นหา Transfer Key ใน Firestore
      const keysSnapshot = await admin
        .firestore()
        .collection("transfer_keys")
        .where("transferKey", "==", transferKey)
        .limit(1)
        .get();

      if (keysSnapshot.empty) {
        throw new HttpsError(
          "not-found",
          "Transfer key not found"
        );
      }

      const keyDoc = keysSnapshot.docs[0];
      const keyData = keyDoc.data();

      // 4. Validate Key Status
      if (keyData.status === "redeemed") {
        throw new HttpsError(
          "already-exists",
          "Transfer key has already been redeemed"
        );
      }

      if (keyData.status === "expired") {
        throw new HttpsError(
          "failed-precondition",
          "Transfer key has expired"
        );
      }

      // ตรวจสอบวันหมดอายุ
      const now = admin.firestore.Timestamp.now();
      if (keyData.expiresAt && keyData.expiresAt < now) {
        // Update status เป็น expired
        await keyDoc.ref.update({
          status: "expired",
          expiredAt: now,
        });

        throw new HttpsError(
          "failed-precondition",
          "Transfer key has expired"
        );
      }

      // 5. ป้องกันการโอนให้เครื่องเดิม
      const sourceDeviceId = keyData.sourceDeviceId;
      if (sourceDeviceId === newDeviceId) {
        throw new HttpsError(
          "invalid-argument",
          "Cannot transfer to the same device"
        );
      }

      // 6. ดึง Energy Balance และ MiRO ID จาก users collection
      const sourceUserDoc = await admin
        .firestore()
        .collection("users")
        .doc(sourceDeviceId)
        .get();

      if (!sourceUserDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Source device user not found"
        );
      }

      const sourceUserData = sourceUserDoc.data()!;
      const sourceBalance = sourceUserData.balance || 0;
      const sourceMiroId = sourceUserData.miroId;

      // 7. ดึง Energy Balance ปัจจุบันของเครื่องใหม่ (จาก users collection)
      const newUserDoc = await admin
        .firestore()
        .collection("users")
        .doc(newDeviceId)
        .get();

      const previousBalance = newUserDoc.exists ?
        newUserDoc.data()?.balance || 0 :
        0;

      // 8. Atomic Transaction: โอน Energy + MiRO ID
      await admin.firestore().runTransaction(async (transaction) => {
        // a. SET energy ของเครื่องเก่า = 0 และ unlink MiRO ID
        const sourceUserRef = admin.firestore().collection("users").doc(sourceDeviceId);
        transaction.update(sourceUserRef, {
          balance: 0,
          miroId: sourceMiroId ? `TRANSFERRED:${sourceMiroId}` : null,
          transferredTo: newDeviceId,
          transferredAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // b. สร้างหรืออัพเดท user document ของเครื่องใหม่
        const newUserRef = admin.firestore().collection("users").doc(newDeviceId);
        const newUserDoc = await transaction.get(newUserRef);

        if (newUserDoc.exists) {
          // มี user อยู่แล้ว → อัพเดท
          transaction.update(newUserRef, {
            balance: sourceBalance,
            miroId: sourceMiroId || newUserDoc.data()?.miroId,
            // Copy streak data ถ้ามี
            currentStreak: sourceUserData.currentStreak || newUserDoc.data()?.currentStreak || 0,
            longestStreak: sourceUserData.longestStreak || newUserDoc.data()?.longestStreak || 0,
            tier: sourceUserData.tier || newUserDoc.data()?.tier || "none",
            tierUnlockedAt: sourceUserData.tierUnlockedAt || newUserDoc.data()?.tierUnlockedAt || {},
            lastReceivedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          // ไม่มี user → สร้างใหม่
          transaction.set(newUserRef, {
            deviceId: newDeviceId,
            miroId: sourceMiroId,
            balance: sourceBalance,
            totalEarned: sourceUserData.totalEarned || 0,
            totalSpent: sourceUserData.totalSpent || 0,
            totalPurchased: sourceUserData.totalPurchased || 0,
            welcomeGiftClaimed: true,
            currentStreak: sourceUserData.currentStreak || 0,
            longestStreak: sourceUserData.longestStreak || 0,
            lastCheckInDate: sourceUserData.lastCheckInDate || null,
            tier: sourceUserData.tier || "none",
            tierUnlockedAt: sourceUserData.tierUnlockedAt || {
              bronze: null,
              silver: null,
              gold: null,
              diamond: null,
            },
            isBanned: false,
            banReason: null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastReceivedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        // c. Mark key เป็น "redeemed"
        transaction.update(keyDoc.ref, {
          status: "redeemed",
          redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
          redeemedByDeviceId: newDeviceId,
        });
      });

      // 9. Return ผลลัพธ์
      return {
        success: true,
        energyTransferred: sourceBalance,
        previousBalance,
        newBalance: sourceBalance,
      };
    } catch (error: any) {
      console.error("Error in redeemTransferKey:", error);

      // ถ้าเป็น HttpsError แล้ว → throw ต่อ
      if (error instanceof HttpsError) {
        throw error;
      }

      // Error อื่น ๆ → wrap เป็น internal error
      throw new HttpsError(
        "internal",
        "Failed to redeem transfer key",
        error.message
      );
    }
  }
);
