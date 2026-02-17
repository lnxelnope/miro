/**
 * checkReferralProgress
 *
 * เรียกเมื่อ: Referee ใช้ AI สำเร็จ
 * สิ่งที่ทำ: เพิ่ม refereeAiUsageCount → ถ้าครบ 3 ครั้ง → ให้ referrer reward
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const REFERRAL_CONFIG = {
  referrerReward: 15,
  requiredAiUsage: 3,
};

export async function checkReferralProgress(deviceId: string): Promise<void> {
  const userDoc = await db.collection("users").doc(deviceId).get();

  if (!userDoc.exists) return;

  const user = userDoc.data()!;
  const referredBy = user.referrals?.referredBy;
  const referredByDeviceId = user.referrals?.referredByDeviceId;

  // ถ้าไม่ได้ถูก refer → ไม่ต้องทำอะไร
  if (!referredBy || !referredByDeviceId) return;

  // หา referral record
  const recordsSnapshot = await db
    .collection("referral_records")
    .where("refereeId", "==", deviceId)
    .where("status", "==", "pending")
    .limit(1)
    .get();

  if (recordsSnapshot.empty) return;

  const recordDoc = recordsSnapshot.docs[0];
  const record = recordDoc.data();

  // เช็คว่า expire หรือยัง
  const expiresAt = record.expiresAt?.toDate();
  if (expiresAt && expiresAt < new Date()) {
    // Expired → update status
    await recordDoc.ref.update({
      status: "expired",
    });
    return;
  }

  // Increment AI usage count
  await db.runTransaction(async (transaction) => {
    const recordRef = recordDoc.ref;
    const updatedRecord = await transaction.get(recordRef);
    const currentCount = updatedRecord.data()?.refereeAiUsageCount || 0;

    // Update count
    transaction.update(recordRef, {
      refereeAiUsageCount: currentCount + 1,
    });

    // ถ้าครบ 3 ครั้ง → ให้ referrer reward
    if (currentCount + 1 >= REFERRAL_CONFIG.requiredAiUsage) {
      const referrerRef = db.collection("users").doc(referredByDeviceId);
      const referrerDoc = await transaction.get(referrerRef);

      if (referrerDoc.exists) {
        const referrer = referrerDoc.data()!;
        const currentBalance = referrer.balance || 0;
        const newBalance = currentBalance + REFERRAL_CONFIG.referrerReward;

        // เช็ค monthly limit
        const now = new Date();
        const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;
        const resetDate = referrer.referrals?.referralResetDate || "";
        let referralCount = referrer.referrals?.referralCount || 0;

        if (resetDate !== currentMonth) {
          referralCount = 0;
        }

        if (referralCount < 2) {
          // ยังไม่เกิน limit → ให้ reward
          transaction.update(referrerRef, {
            "balance": newBalance,
            "totalEarned": (referrer.totalEarned || 0) + REFERRAL_CONFIG.referrerReward,
            "referrals.referralCount": referralCount + 1,
            "referrals.referralResetDate": currentMonth,
            "referrals.referredUsers": admin.firestore.FieldValue.arrayUnion(user.miroId),
            "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
          });

          // Log transaction
          const txRef = db.collection("transactions").doc();
          transaction.set(txRef, {
            deviceId: referredByDeviceId,
            miroId: referrer.miroId || "unknown",
            type: "referral",
            amount: REFERRAL_CONFIG.referrerReward,
            balanceAfter: newBalance,
            description: `Referral reward: ${user.miroId} completed! +${REFERRAL_CONFIG.referrerReward} Energy`,
            metadata: {
              refereeMiroId: user.miroId,
              isReferrer: true,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Update record status
          transaction.update(recordRef, {
            status: "completed",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          console.log(
            `🎉 [Referral] ${referrer.miroId} got reward from ${user.miroId} (+${REFERRAL_CONFIG.referrerReward} Energy)`
          );
        } else {
          // เกิน limit → mark as completed แต่ไม่ให้ reward
          transaction.update(recordRef, {
            status: "completed",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            note: "Referrer reached monthly limit",
          });
        }
      }
    }
  });
}
