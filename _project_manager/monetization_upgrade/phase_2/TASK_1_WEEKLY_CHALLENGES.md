# Task 1: Weekly Challenges (Backend)

**ระยะเวลา:** 2 วัน | **Complexity:** 🟡 Medium

---

## 🎯 เป้าหมาย

สร้างระบบ Weekly Challenges (Log meals + Use AI)

---

## 📝 สิ่งที่ต้องทำ

### 1. เพิ่ม incrementChallengeProgress ใน analyzeFood.ts

```typescript
async function incrementChallengeProgress(
  deviceId: string,
  challengeType: 'logMeals' | 'useAi'
): Promise<void> {
  const userRef = db.collection('users').doc(deviceId);
  const today = getTodayString();
  const weekStart = getWeekStartDate(today);

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const challenges = userDoc.data()?.challenges?.weekly || {};
    
    // ถ้าสัปดาห์ใหม่ → reset
    if (challenges.weekStartDate !== weekStart) {
      transaction.update(userRef, {
        'challenges.weekly': {
          logMeals: challengeType === 'logMeals' ? 1 : 0,
          useAi: challengeType === 'useAi' ? 1 : 0,
          claimedRewards: [],
          weekStartDate: weekStart,
        },
      });
      return;
    }

    // Increment
    const current = challenges[challengeType] || 0;
    const target = challengeType === 'logMeals' ? 7 : 3;
    
    if (current < target) {
      transaction.update(userRef, {
        [`challenges.weekly.${challengeType}`]: current + 1,
      });
    }
  });
}

function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay();
  const diff = day === 0 ? 6 : day - 1;
  date.setDate(date.getDate() - diff);
  return date.toISOString().split('T')[0];
}
```

### 2. เรียก increment ใน analyzeFood

```typescript
// หลัง Gemini response สำเร็จ:
await incrementChallengeProgress(deviceId, 'logMeals');
await incrementChallengeProgress(deviceId, 'useAi');
```

### 3. สร้าง completeChallenge.ts

```typescript
// functions/src/energy/challenge.ts
export const completeChallenge = onRequest({...}, async (req, res) => {
  const { deviceId, challengeType } = req.body;
  
  const config = {
    logMeals: { target: 7, reward: 5 },
    useAi: { target: 3, reward: 5 },
  };

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const challenges = userDoc.data()?.challenges?.weekly || {};
    
    // Verify progress
    if (challenges[challengeType] < config[challengeType].target) {
      throw new Error('Challenge not completed');
    }
    
    // Verify not claimed
    if (challenges.claimedRewards.includes(challengeType)) {
      throw new Error('Already claimed');
    }
    
    // Award reward
    transaction.update(userRef, {
      balance: balance + config[challengeType].reward,
      'challenges.weekly.claimedRewards': [...claimed, challengeType],
    });
  });
});
```

---

## ✅ Checklist

```
□ เพิ่ม incrementChallengeProgress
□ เรียก ใน analyzeFood
□ สร้าง completeChallenge.ts
□ Export ใน index.ts
□ Deploy
□ Test: log 7 meals → claim 5 Energy
□ Test: use AI 3 times → claim 5 Energy
```

ดูรายละเอียดเพิ่มใน Phase 2 document เดิม
