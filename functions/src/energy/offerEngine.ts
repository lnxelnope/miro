/**
 * offerEngine.ts
 *
 * Dynamic Offer Evaluation Engine
 *
 * Central function ที่ทุก trigger event เรียก — ตรวจสอบว่า user ตรงเงื่อนไขของ offer template ไหนบ้าง
 * แล้ว activate offer ให้ user
 *
 * เรียกจาก: analyzeFood, dailyCheckIn, registerUser, verifyPurchase
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Evaluate ว่า user ควรได้ offer ไหนบ้างเมื่อเกิด event
 *
 * @param deviceId - user device ID
 * @param event - trigger event name (เช่น 'first_energy_use')
 * @param eventData - ข้อมูลเพิ่มเติมจาก event
 *
 * เรียกจาก: analyzeFood, dailyCheckIn, registerUser, verifyPurchase
 */
export async function evaluateOffers(
  deviceId: string,
  event: string,
  eventData: Record<string, any> = {}
): Promise<void> {
  try {
    // 1. Query offer_templates: WHERE triggerEvent == event AND isActive == true
    const templatesSnapshot = await db
      .collection("offer_templates")
      .where("triggerEvent", "==", event)
      .where("isActive", "==", true)
      .get();

    if (templatesSnapshot.empty) {
      // ไม่มี template ตรง → return (ไม่ต้องทำอะไร)
      return;
    }

    // 2. Load user document
    const userDoc = await db.collection("users").doc(deviceId).get();
    if (!userDoc.exists) {
      console.warn(`[OfferEngine] User ${deviceId} not found`);
      return;
    }

    const user = userDoc.data()!;
    const activeOffers = user.offers?.active || {};
    const dismissedOffers = user.offers?.dismissed || [];

    const now = admin.firestore.Timestamp.now();
    const updates: Record<string, any> = {};

    // 3. สำหรับแต่ละ template
    for (const templateDoc of templatesSnapshot.docs) {
      const templateId = templateDoc.id;
      const template = templateDoc.data();

      // a. Check: template.id อยู่ใน dismissedOffers?
      if (dismissedOffers.includes(templateId)) {
        continue; // user ปัดซ่อนแล้ว → ข้าม
      }

      // b. Check: maxClaimsPerUser — ถ้า offer มีอยู่แล้วและ claim ครบ → ข้าม
      const existingOffer = activeOffers[templateId];
      const maxClaims = template.maxClaimsPerUser || 1;
      if (existingOffer) {
        const claimCount = existingOffer.claimCount || 0;
        if (claimCount >= maxClaims) {
          continue; // claim ครบแล้ว → ข้าม
        }
        // ถ้ายัง claim ไม่ครบแต่ offer ยังไม่ claimed → ไม่ต้อง activate ซ้ำ
        if (!existingOffer.claimed) {
          continue; // offer ยัง active อยู่ → ข้าม
        }
      }

      // c. Check: triggerCondition ตรงกับ eventData?
      const triggerCondition = template.triggerCondition || {};
      let conditionMet = true;

      if (triggerCondition.minTotalSpent !== undefined) {
        const totalSpent = eventData.totalSpent || 0;
        if (totalSpent < triggerCondition.minTotalSpent) {
          conditionMet = false;
        }
      }

      if (triggerCondition.tier !== undefined && triggerCondition.tier !== "") {
        const newTier = eventData.newTier || "";
        if (newTier !== triggerCondition.tier) {
          conditionMet = false;
        }
      }

      if (triggerCondition.minMealsLogged !== undefined) {
        const totalMealsLogged = eventData.totalMealsLogged || 0;
        if (totalMealsLogged < triggerCondition.minMealsLogged) {
          conditionMet = false;
        }
      }

      if (triggerCondition.afterProductId !== undefined) {
        const productId = eventData.productId || "";
        if (productId !== triggerCondition.afterProductId) {
          conditionMet = false;
        }
      }

      if (!conditionMet) {
        continue; // เงื่อนไขไม่ตรง → ข้าม
      }

      // e. ผ่านทุกเงื่อนไข → Activate offer
      // คำนวณ expiresAt
      let expiresAt: admin.firestore.Timestamp | null = null;
      if (template.expiresAfterHours !== null && template.expiresAfterHours !== undefined) {
        const expiresAfterMs = template.expiresAfterHours * 60 * 60 * 1000;
        const expiresAtDate = new Date(now.toMillis() + expiresAfterMs);
        expiresAt = admin.firestore.Timestamp.fromDate(expiresAtDate);
      }

      // เตรียม update data
      updates[`offers.active.${templateId}`] = {
        templateId: templateId,
        slug: template.slug,
        activatedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: expiresAt,
        claimed: false,
        claimedAt: null,
        claimCount: 0,
      };

      console.log(`🎁 [OfferEngine] Activated "${template.slug}" for ${deviceId}`);
    }

    // 4. เขียน Firestore (ถ้ามี offer ที่ต้อง activate)
    if (Object.keys(updates).length > 0) {
      updates.lastUpdated = admin.firestore.FieldValue.serverTimestamp();
      await userDoc.ref.update(updates);
    }
  } catch (error) {
    // Silent fail — ห้าม crash caller
    console.error(`[OfferEngine] Error evaluating offers for ${deviceId}:`, error);
  }
}
