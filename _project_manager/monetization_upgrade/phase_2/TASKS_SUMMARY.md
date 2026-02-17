# Phase 2 Task Cards - Quick Reference

**สำหรับ Task Cards ละเอียด:** อ่าน `PHASE_2_CHALLENGES.md` ในโฟลเดอร์หลัก

---

## Task 2: Milestones (1 วัน)

```typescript
// functions/src/energy/milestone.ts
export const claimMilestone = onRequest({...}, async (req, res) => {
  const config = {
    spent500: { threshold: 500, reward: 15 },
    spent1000: { threshold: 1000, reward: 30 },
  };
  
  // Verify totalSpent >= threshold
  // Award reward
});

// ใน analyzeFood: อัพเดท totalSpent
await db.collection('users').doc(deviceId).update({
  totalSpent: admin.firestore.FieldValue.increment(energyCost),
});
```

---

## Task 3: Bonus Energy (1 วัน)

```typescript
// ใน verifyPurchase.ts
const baseEnergy = PRODUCT_MAP[productId];
const bonusRate = userDoc.data()?.bonusRate || 0; // 0.2 หรือ 0.3
const bonusEnergy = Math.floor(baseEnergy * bonusRate);
const totalEnergy = baseEnergy + bonusEnergy;

// เพิ่ม totalEnergy (ไม่ใช่ baseEnergy)
```

---

## Task 4: Random Bonus (1 วัน)

```typescript
// ใน dailyCheckIn.ts (processCheckIn)
if (Math.random() < 0.05) {
  const bonus = Math.floor(Math.random() * 6) + 5; // 5-10
  transaction.update(userRef, {
    balance: balance + bonus,
    lastRandomBonus: today,
  });
}
```

---

## Task 5: Cron Jobs (1 วัน)

```typescript
// functions/src/cron/resetWeeklyChallenges.ts
export const resetWeeklyChallenges = onSchedule({
  schedule: '0 17 * * 0', // ทุกวันจันทร์ 00:00 UTC+7
}, async () => {
  // Reset challenges.weekly ของทุก user
});
```

---

## Task 6: Flutter Client (3 วัน)

- Weekly Challenge Card widget
- Milestone Progress Card widget
- Random Bonus Dialog (animation)
- Bonus Energy badge ใน Store

---

## Task 7: Testing (2 วัน)

เหมือน Phase 1 แต่ test features ของ Phase 2
