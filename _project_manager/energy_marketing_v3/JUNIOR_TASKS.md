# Junior Tasks — งานง่ายๆ ทำตามได้เลย

> **สำหรับ:** Junior Developer  
> **ประเภท:** Implementation ตาม spec ที่ Senior ออกแบบแล้ว  
> **ความยาก:** ง่าย-กลาง, มี step-by-step ละเอียด  
> **อัปเดตล่าสุด:** 20 ก.พ. 2026

---

## 📊 สถานะภาพรวม (ตรวจจาก Codebase จริง)

```
Phase 1 Config:           ████████████████████ 100% (J1-J5 ✅)
Phase 2 Backend:          ████████████████████ 100% (J6-J8 ✅)
Phase 3 Quest Bar:        ░░░░░░░░░░░░░░░░░░░░   0% (J9-J12 ❌ ยังไม่ทำ)
Phase 3 Frontend Energy:  ████████████████████ 100% (J13-J16 ✅)
Phase 4 Admin Panel:      ██████████████░░░░░░  70% (J17-J18 🔧)

รวม: ~80% เสร็จ
```

### สรุปด่วน — เหลือแค่นี้!
| Task | สถานะ | คนทำ |
|------|-------|------|
| ❌ J9: Quest Bar Countdown Timer | ยังไม่ทำ | Junior |
| ❌ J10: Quest Bar Swipe to Dismiss | ยังไม่ทำ | Junior |
| ❌ J11: Quest Bar เชื่อม API | ยังไม่ทำ | Junior |
| ❌ J12: Quest Bar Referral Share | ยังไม่ทำ | Junior |
| 🔧 J17: Admin Analytics | ยังไม่ครบ (ยังไม่มี date filter) | Junior |
| 🔧 J18: Admin Push Campaign | ยังไม่ครบ (ยังไม่มี history log) | Junior |
| 🔧 Localization | ยังไม่มี Quest Bar keys ใน app_en.arb | Junior |

---

## ภาพรวม

งาน Junior แบ่งเป็น 3 กลุ่ม:
1. **Config Changes** — เปลี่ยนค่าคงที่ (ง่ายมาก)
2. **Backend Implementation** — เขียน API ตาม spec ที่ Senior ออกแบบแล้ว
3. **Frontend Implementation** — สร้าง UI/UX ตามที่ Senior ระบุ

**หลักการ:** ทุก task มี step ละเอียด, ไม่ต้องคิดเอง, copy-paste ได้เลย

---

## Phase 1: Config Changes ✅ เสร็จทั้งหมด

### J1. ปรับค่า Challenge Rewards ✅ เสร็จ

**ไฟล์:** `functions/src/energy/challenge.ts`

**สิ่งที่ต้องทำ:**
1. เปิดไฟล์ `functions/src/energy/challenge.ts`
2. หาบรรทัดที่มี `CHALLENGE_REWARD`
3. เปลี่ยนค่า:
   ```typescript
   // เดิม
   const CHALLENGE_REWARD = 5;
   
   // ใหม่
   const CHALLENGE_REWARD = 3;
   ```
4. Save file
5. Deploy:
   ```bash
   firebase deploy --only functions:processChallenge
   ```

**Test:**
- ทำ challenge 1 อัน → ได้ 3E (เดิมได้ 5E)

**Effort:** 10 นาที

---

### J2. ปรับค่า Tier Upgrade Rewards ✅ เสร็จ

**ไฟล์:** `functions/src/energy/dailyCheckIn.ts` (หรือไฟล์ที่มี tier reward logic)

**สิ่งที่ต้องทำ:**
1. หาบรรทัดที่มี `TIER_REWARDS` หรือคล้ายๆ
2. เปลี่ยนค่า:
   ```typescript
   // เดิม
   const TIER_REWARDS = {
     bronze: 3,
     silver: 5,
     gold: 10,
     diamond: 15,
   };
   
   // ใหม่
   const TIER_REWARDS = {
     bronze: 5,
     silver: 10,
     gold: 15,
     diamond: 25,
   };
   ```
3. Save + Deploy:
   ```bash
   firebase deploy --only functions:processDailyCheckIn
   ```

**Test:**
- Upgrade ไป Bronze → ได้ 5E
- Upgrade ไป Diamond → ได้ 25E

**Effort:** 10 นาที

---

### J3. ลบ Subscriber Double Quest Multiplier ✅ เสร็จ

**ไฟล์:** `functions/src/energy/challenge.ts`

**สิ่งที่ต้องทำ:**
1. หา logic ที่เช็ค `if (user.isSubscriber)`
2. หา code ที่คูณ reward × 2
3. ลบ logic ทั้งหมด:
   ```typescript
   // เดิม
   let reward = CHALLENGE_REWARD;
   if (user.subscription?.isActive) {
     reward *= 2; // ← ลบบรรทัดนี้
   }
   
   // ใหม่
   const reward = CHALLENGE_REWARD; // ทุกคนได้เท่ากัน
   ```
4. Save + Deploy

**Test:**
- Subscriber ทำ challenge → ได้ 3E (เหมือนคนธรรมดา)

**Effort:** 15 นาที

---

### J4. ลบ Random Daily Bonus ✅ เสร็จ

**ไฟล์:** `functions/src/energy/dailyCheckIn.ts`

**สิ่งที่ต้องทำ:**
1. หา logic ที่มี `Math.random()` และ `5% chance`
2. ลบทั้งหมด:
   ```typescript
   // เดิม
   let bonus = 0;
   if (Math.random() < 0.05) {
     bonus = Math.floor(Math.random() * 6) + 5; // 5-10E
   }
   // ... เพิ่ม bonus
   
   // ใหม่ — ลบทั้งหมด (ไม่มี random bonus)
   ```
3. Save + Deploy

**Test:**
- Check-in 20 ครั้ง → ไม่มีครั้งไหนได้ bonus เพิ่ม

**Effort:** 15 นาที

---

### J5. ลบ First Empty Bonus (+50E) ✅ เสร็จ

**ไฟล์:** `functions/src/energy/` (หาไฟล์ที่มี logic "energy หมดครั้งแรก")

**สิ่งที่ต้องทำ:**
1. Search ใน functions/ ด้วยคำว่า "first empty" หรือ "firstEmptyBonus"
2. หา code ที่เช็ค `if (balance === 0 && !user.firstEmptyBonusClaimed)`
3. ลบ logic ทั้งหมด:
   ```typescript
   // เดิม
   if (balance === 0 && !user.firstEmptyBonusClaimed) {
     await userRef.update({
       balance: 50,
       firstEmptyBonusClaimed: true,
     });
   }
   
   // ใหม่ — ลบทั้งหมด
   ```
4. Save + Deploy

**Test:**
- Energy หมด (balance = 0) → ไม่ได้ +50E ฟรี

**Effort:** 20 นาที

---

## Phase 2: Backend Implementation ✅ เสร็จทั้งหมด

### J6. Backend: Daily Claim (Manual) — Endpoint ใหม่ ✅ เสร็จ

**ไฟล์:** `functions/src/energy/claimDailyEnergy.ts` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้างไฟล์ใหม่**
```typescript
import {onRequest} from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const claimDailyEnergy = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  
  try {
    const { deviceId } = req.body;
    
    if (!deviceId) {
      return res.status(400).json({ error: 'Missing deviceId' });
    }
    
    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userData = userDoc.data()!;
    const today = new Date().toISOString().split('T')[0]; // 'YYYY-MM-DD'
    const lastClaimDate = userData.dailyClaim?.lastClaimDate || '';
    
    // ตรวจสอบว่าวันนี้ claim แล้วหรือยัง
    if (lastClaimDate === today) {
      return res.status(200).json({
        alreadyClaimed: true,
        message: 'Already claimed today',
      });
    }
    
    // คำนวณ energy ที่ได้ (ตาม tier)
    const tier = userData.tier || 'starter';
    const dailyEnergy = {
      starter: 2,
      bronze: 3,
      silver: 4,
      gold: 5,
      diamond: 7,
    }[tier] || 2;
    
    // เพิ่ม streak
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    let newStreak = userData.streak || 0;
    
    if (lastClaimDate === yesterday) {
      newStreak += 1; // ต่อเนื่อง
    } else if (lastClaimDate < yesterday) {
      newStreak = 1; // ขาดวัน → reset
    }
    
    // เช็ค tier upgrade (ทุก 7 วัน)
    let tierUpgraded = false;
    let newTier = tier;
    let tierReward = 0;
    
    if (newStreak % 7 === 0 && newStreak > 0) {
      const tierOrder = ['starter', 'bronze', 'silver', 'gold', 'diamond'];
      const currentIndex = tierOrder.indexOf(tier);
      if (currentIndex < tierOrder.length - 1) {
        newTier = tierOrder[currentIndex + 1];
        tierUpgraded = true;
        
        const tierRewards = { bronze: 5, silver: 10, gold: 15, diamond: 25 };
        tierReward = tierRewards[newTier as keyof typeof tierRewards] || 0;
      }
    }
    
    // คำนวณ energy รวม
    const totalEnergy = dailyEnergy + tierReward;
    const newBalance = userData.balance + totalEnergy;
    
    // อัพเดท Firestore
    await userRef.update({
      balance: newBalance,
      streak: newStreak,
      tier: newTier,
      'dailyClaim.lastClaimDate': today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Log transaction
    await db.collection('transactions').add({
      deviceId,
      type: 'daily_claim',
      amount: totalEnergy,
      balanceAfter: newBalance,
      description: `Daily claim: +${dailyEnergy}E (tier: ${tier})${tierUpgraded ? ` + Tier up reward: +${tierReward}E` : ''}`,
      metadata: {
        streak: newStreak,
        tierUpgraded,
        newTier: tierUpgraded ? newTier : null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // ถ้า tier upgrade → ส่ง push notification
    if (tierUpgraded && userData.fcmToken) {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification: {
          title: '🎉 ยินดีด้วย!',
          body: `คุณเลื่อนเป็น ${newTier}! Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!`,
        },
        data: {
          type: 'tier_up',
          newTier,
          reward: String(tierReward),
        },
      });
    }
    
    // ดึง active offers (สำหรับ frontend แสดงใน Quest Bar)
    // TODO: call getActiveOffers(deviceId) ที่ Senior เขียนไว้
    const activeOffers: any[] = []; // placeholder
    
    return res.status(200).json({
      success: true,
      energyClaimed: totalEnergy,
      newBalance,
      newStreak,
      tierUpgraded,
      newTier: tierUpgraded ? newTier : null,
      tierReward: tierUpgraded ? tierReward : 0,
      activeOffers,
    });
    
  } catch (error: any) {
    console.error('Error in claimDailyEnergy:', error);
    return res.status(500).json({ error: error.message });
  }
});
```

**Step 2: Export ใน index.ts**
```typescript
// functions/src/index.ts
export { claimDailyEnergy } from './energy/claimDailyEnergy';
```

**Step 3: Deploy**
```bash
firebase deploy --only functions:claimDailyEnergy
```

**Step 4: Test**
- เรียก API:
  ```bash
  curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/claimDailyEnergy \
    -H "Content-Type: application/json" \
    -d '{"deviceId": "test_device_123"}'
  ```
- Check response: `{ success: true, energyClaimed: 2, newBalance: xxx, ... }`
- เรียกซ้ำทันที → `{ alreadyClaimed: true }`

**Effort:** 2-3 ชม.

---

### J7. Backend: Referral Two-Way ✅ เสร็จ

**ไฟล์:** `functions/src/referral/checkReferralProgress.ts` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: แก้ logic ใน checkReferralProgress**
```typescript
// เดิม: เฉพาะผู้ชวนได้ reward
// ใหม่: ทั้งสองฝ่ายได้ reward

export const checkReferralProgress = onCall(async (data, context) => {
  const { deviceId } = data;
  
  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) {
    throw new Error('User not found');
  }
  
  const userData = userDoc.data()!;
  const referredBy = userData.referredBy; // device ID ของผู้ชวน
  
  if (!referredBy) {
    return { eligible: false, reason: 'Not referred by anyone' };
  }
  
  // เช็คว่าเพื่อนใช้ Energy ครบ 10E แล้วหรือยัง
  const totalSpent = userData.milestones?.totalSpent || 0;
  
  if (totalSpent < 10) {
    return {
      eligible: false,
      reason: 'Need to spend 10E first',
      progress: totalSpent,
      target: 10,
    };
  }
  
  // เช็คว่าได้ reward แล้วหรือยัง
  if (userData.referralRewardClaimed) {
    return { eligible: false, reason: 'Reward already claimed' };
  }
  
  // ✅ ได้ reward! — ทั้งผู้ชวนและเพื่อน
  const REWARD = 5; // Energy
  
  // 1. เพิ่ม energy ให้ผู้ชวน
  const referrerRef = db.collection('users').doc(referredBy);
  const referrerDoc = await referrerRef.get();
  
  if (referrerDoc.exists) {
    const referrerData = referrerDoc.data()!;
    const referrerNewBalance = referrerData.balance + REWARD;
    
    await referrerRef.update({
      balance: referrerNewBalance,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Log transaction (referrer)
    await db.collection('transactions').add({
      deviceId: referredBy,
      type: 'referral_reward',
      amount: REWARD,
      balanceAfter: referrerNewBalance,
      description: `Referral reward: friend spent 10E`,
      metadata: { friendDeviceId: deviceId },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  
  // 2. เพิ่ม energy ให้เพื่อน (ผู้ถูกชวน)
  const friendNewBalance = userData.balance + REWARD;
  
  await userRef.update({
    balance: friendNewBalance,
    referralRewardClaimed: true,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // Log transaction (friend)
  await db.collection('transactions').add({
    deviceId,
    type: 'referral_reward',
    amount: REWARD,
    balanceAfter: friendNewBalance,
    description: `Referral reward: you spent 10E`,
    metadata: { referrerDeviceId: referredBy },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  return {
    success: true,
    rewardGranted: REWARD,
    message: 'Both you and your friend received 5E!',
  };
});
```

**Step 2: Deploy**
```bash
firebase deploy --only functions:checkReferralProgress
```

**Step 3: Test**
- User A ชวน User B
- User B ใช้ Energy ครบ 10E
- เรียก `checkReferralProgress` → User A และ User B ได้ +5E

**Effort:** 1-2 ชม.

---

### J8. Backend: Winback Subscription Offer ✅ เสร็จ

**ไฟล์:** `functions/src/subscription/winbackScheduler.ts` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้าง scheduled function**
```typescript
import {onSchedule} from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const winbackScheduler = onSchedule('every 24 hours', async () => {
  console.log('Running winback scheduler...');
  
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  
  // Query: subscription expired > 7 วัน && ยังไม่ส่ง winback
  const expiredUsers = await db.collection('users')
    .where('subscription.status', '==', 'expired')
    .where('subscription.expiryDate', '<', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
    .where('winbackOfferAvailable', '==', false) // ยังไม่เคยส่ง
    .limit(100)
    .get();
  
  for (const doc of expiredUsers.docs) {
    const user = doc.data();
    
    // Set winback flag
    const expiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 วัน
    await doc.ref.update({
      winbackOfferAvailable: true,
      winbackOfferExpiry: admin.firestore.Timestamp.fromDate(expiry),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // ส่ง Push Notification
    if (user.fcmToken) {
      try {
        await admin.messaging().send({
          token: user.fcmToken,
          notification: {
            title: 'กลับมาใช้ MiRO!',
            body: 'Energy Pass เดือนแรกแค่ $3',
          },
          data: {
            type: 'winback_offer',
            offerId: 'winback-3usd',
          },
        });
        
        console.log(`Sent winback notification to ${doc.id}`);
      } catch (error) {
        console.error(`Failed to send notification to ${doc.id}:`, error);
      }
    }
  }
  
  console.log(`Processed ${expiredUsers.size} expired subscribers`);
});
```

**Step 2: Export + Deploy**
```typescript
// functions/src/index.ts
export { winbackScheduler } from './subscription/winbackScheduler';
```

```bash
firebase deploy --only functions:winbackScheduler
```

**Step 3: Test**
- สร้าง test user ที่ subscription expired > 7 วัน
- รอ 24 ชม. (หรือ manually trigger function)
- Check: `winbackOfferAvailable: true` + ได้รับ push notification

**Effort:** 1-2 ชม.

---

## Phase 3: Frontend Implementation (Sprint 3-5, สัปดาห์ที่ 3-5)

### J9. Frontend: Quest Bar - Countdown Timer ❌ ยังไม่ทำ

**ไฟล์:** `lib/features/energy/widgets/quest_bar.dart` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: เพิ่ม countdown timer**
```dart
import 'dart:async';

class _QuestBarState extends ConsumerState<QuestBar> {
  Timer? _countdownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // TODO: ดึง offer expiry จาก server (activeOffers)
    // ตอนนี้ใช้ placeholder
    final expiryTime = DateTime.now().add(const Duration(hours: 4));
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final now = DateTime.now();
      final remaining = expiryTime.difference(now);
      
      if (remaining.isNegative) {
        timer.cancel();
        setState(() => _remainingTime = null);
        // TODO: Refresh offers (offer หมดอายุแล้ว)
        // ref.read(gamificationProvider.notifier).refresh();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // แสดง countdown ใน offer row
    if (_remainingTime != null) {
      return Text(
        '⏰ เหลือเวลา ${_formatDuration(_remainingTime!)}',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
```

**Step 2: เชื่อมกับ activeOffers**
```dart
// เมื่อมี activeOffers จาก server
void _startCountdown() {
  if (_activeOffers.isEmpty) return;
  
  final firstOffer = _activeOffers.first;
  final expiryTimestamp = firstOffer['expiry']; // Timestamp จาก server
  
  if (expiryTimestamp == null) return;
  
  // Convert Timestamp to DateTime
  final expiryTime = (expiryTimestamp as Timestamp).toDate();
  
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    // ... (เหมือน code ด้านบน)
  });
}
```

**Step 3: Test**
- เปิด Quest Bar → เห็น countdown นับถอยหลัง
- รอ 1 นาที → เวลาเปลี่ยน (HH:MM:SS)
- Mock expiry time = 10 วินาที → เห็น offer หายเมื่อหมดเวลา

**Effort:** 2-3 ชม.

---

### J10. Frontend: Quest Bar - Swipe to Dismiss Offer ❌ ยังไม่ทำ

**ไฟล์:** `lib/features/energy/widgets/quest_bar.dart` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: ใช้ Dismissible widget**
```dart
Widget _buildOfferRow(BuildContext context, bool isDark) {
  final firstOffer = _activeOffers.first;
  final offerId = firstOffer['id'] as String;
  
  return Dismissible(
    key: Key('offer_$offerId'), // unique key per offer
    direction: DismissDirection.endToStart, // ปัดซ้าย
    onDismissed: (direction) {
      // ซ่อน offer
      setState(() => _dismissedOffers.add(offerId));
      
      // แสดง Snackbar (เหมือน undo ลบอาหาร)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Offer ถูกซ่อน'),
          action: SnackBarAction(
            label: 'ดู Offer',
            onPressed: () {
              // Undo - แสดง offer กลับมา
              setState(() => _dismissedOffers.remove(offerId));
            },
          ),
          duration: const Duration(days: 365), // ค้างไว้จนกว่าจะปัดอีกครั้ง
          behavior: SnackBarBehavior.floating,
        ),
      );
    },
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      color: Colors.red.shade400,
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
    ),
    child: InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstOffer['title'] ?? '🔥 Special Offer!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_remainingTime != null)
                    Text(
                      '⏰ เหลือเวลา ${_formatDuration(_remainingTime!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Step 2: เก็บ dismissed state**
```dart
class _QuestBarState extends ConsumerState<QuestBar> {
  final Set<String> _dismissedOffers = {}; // เก็บ offer ID ที่ถูกซ่อน

  @override
  Widget build(BuildContext context) {
    // กรอง offers ที่ไม่ถูก dismiss
    final activeOffers = _activeOffers
        .where((o) => !_dismissedOffers.contains(o['id']))
        .toList();
    
    if (activeOffers.isEmpty) {
      // แสดง Streak row แทน
      return _buildStreakRow(context, gamification, isDark);
    }
    
    // แสดง offer row
    return _buildOfferRow(context, isDark);
  }
}
```

**Step 3: Test**
- ปัดซ้ายบน offer → offer หาย + Snackbar ปรากฏ
- กด "ดู Offer" → offer กลับมา
- ปัดอีกครั้ง → Snackbar ยังคงอยู่ (ไม่หาย)

**Effort:** 3-4 ชม.

---

### J11. Frontend: Quest Bar - Connect to API (canClaim & activeOffers) ❌ ยังไม่ทำ

**ไฟล์:** `lib/features/energy/widgets/quest_bar.dart` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: ดึงข้อมูลจาก syncBalanceWithServer**
```dart
import '../../../core/services/energy_service.dart';
import '../../../core/database/database_service.dart';

class _QuestBarState extends ConsumerState<QuestBar> {
  bool _canClaim = false;
  int _claimableEnergy = 0;
  List<dynamic> _activeOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await EnergyService(DatabaseService.isar).syncBalanceWithServer();
      
      if (mounted) {
        final tier = data['tier'] as String? ?? 'starter';
        final energyMap = {
          'starter': 1,
          'bronze': 1,
          'silver': 2,
          'gold': 3,
          'diamond': 4,
        };
        
        setState(() {
          _canClaim = data['canClaimToday'] as bool? ?? false;
          _claimableEnergy = energyMap[tier] ?? 1;
          _activeOffers = data['activeOffers'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
        
        // เริ่ม countdown ถ้ามี offer
        if (_activeOffers.isNotEmpty) {
          _startCountdown();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // มี Offer หรือไม่?
    final activeOffers = _activeOffers
        .where((o) => !_dismissedOffers.contains(o['id']))
        .toList();
    final hasActiveOffer = activeOffers.isNotEmpty;
    
    if (hasActiveOffer) {
      return _buildOfferRow(context, isDark);
    } else {
      return _buildStreakRow(context, gamification, isDark);
    }
  }
}
```

**Step 2: แสดง active offers**
```dart
Widget _buildOfferRow(BuildContext context, bool isDark) {
  final firstOffer = _activeOffers.first;
  final title = firstOffer['title'] ?? '🔥 Special Offer!';
  final expiry = firstOffer['expiry']; // Timestamp
  
  // คำนวณ countdown จาก expiry
  // ... (ใช้ใน _startCountdown)
}
```

**Step 3: Test**
- เปิดแอป → Quest Bar โหลดข้อมูลจาก server
- มี offer → แสดง offer row พร้อม countdown
- ไม่มี offer → แสดง streak row

**Effort:** 2-3 ชม.

---

### J12. Frontend: Quest Bar - Referral Share ❌ ยังไม่ทำ

**ไฟล์:** `lib/features/energy/widgets/quest_bar.dart` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: เพิ่ม dependency**
```yaml
# pubspec.yaml
dependencies:
  share_plus: ^7.0.0
```

```bash
flutter pub get
```

**Step 2: สร้าง referral share function**
```dart
import 'package:share_plus/share_plus.dart';
import '../../../core/services/device_id_service.dart';

Widget _buildReferralLink(BuildContext context, bool isDark) {
  return InkWell(
    onTap: () async {
      try {
        // ดึง deviceId ของ user
        final deviceId = await DeviceIdService.getDeviceId();
        
        // สร้าง referral link (dynamic link)
        // TODO: ต้องมี Firebase Dynamic Links setup ก่อน
        // ตอนนี้ใช้ placeholder
        final referralLink = 'https://miro.app/ref/$deviceId';
        
        // แชร์
        await Share.share(
          'มาลองแอป MiRO กัน! วิเคราะห์อาหารด้วย AI 🍔\n'
          'ใช้ลิงก์นี้ เราทั้งคู่ได้ +5 Energy ฟรี!\n\n'
          '$referralLink',
          subject: 'ชวนใช้ MiRO',
        );
        
        // Log analytics
        // AnalyticsService.logReferralShare();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    },
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '👥 ชวนเพื่อนได้ 5E',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}
```

**Step 3: Test**
- กดปุ่ม "ชวนเพื่อน" → เปิด share sheet
- เลือก Line/Messenger → ส่งลิงก์ได้
- เพื่อนคลิกลิงก์ → เปิดแอป (หรือ Store)

**Effort:** 1-2 ชม.

---

### J13. Frontend: Daily Claim Button + Confetti ✅ เสร็จ

**ไฟล์:** `lib/features/energy/widgets/claim_button.dart` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้าง widget**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../core/services/energy_service.dart';

class ClaimButton extends ConsumerStatefulWidget {
  final int claimableEnergy;

  const ClaimButton({
    super.key,
    required this.claimableEnergy,
  });

  @override
  ConsumerState<ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends ConsumerState<ClaimButton> {
  late ConfettiController _confettiController;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);

    try {
      // เรียก API claimDailyEnergy
      final result = await EnergyService.claimDailyEnergy();

      if (result['success'] == true) {
        // แสดง confetti
        _confettiController.play();

        // แสดง snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ได้รับ +${result['energyClaimed']}E แล้ว!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ถ้ามี tier upgrade → แสดง overlay
        if (result['tierUpgraded'] == true) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => TierUpOverlay(
                newTier: result['newTier'] as String,
                reward: result['tierReward'] as int,
                onDismiss: () => Navigator.of(context).pop(),
              ),
            );
          }
        }
      } else if (result['alreadyClaimed'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('วันนี้เคลมไปแล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: -3.14 / 2, // ขึ้นบน
          emissionFrequency: 0.05,
          numberOfParticles: 30,
          gravity: 0.3,
        ),

        // ปุ่ม Claim
        GestureDetector(
          onTap: _isClaiming ? null : _handleClaim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isClaiming ? Colors.grey : Colors.green,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${widget.claimableEnergy}E',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_isClaiming)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

**Step 2: เพิ่ม dependency**
```yaml
# pubspec.yaml
dependencies:
  confetti: ^0.7.0
```

```bash
flutter pub get
```

**Step 3: เพิ่ม import TierUpOverlay**
```dart
// lib/features/energy/widgets/claim_button.dart
import '../widgets/tier_up_overlay.dart';
```

**Step 4: ใช้งานใน Quest Bar**
```dart
// lib/features/energy/widgets/quest_bar.dart
if (_canClaim) {
  ClaimButton(
    claimableEnergy: _claimableEnergy,
    onClaimed: () => setState(() => _canClaim = false),
    onTierUp: () => _loadData(), // Refresh data after tier up
  ),
}
```

**Note:** ClaimButton ต้องมี callback `onClaimed` และ `onTierUp`:
```dart
class ClaimButton extends ConsumerStatefulWidget {
  final int claimableEnergy;
  final VoidCallback? onClaimed;
  final VoidCallback? onTierUp;

  const ClaimButton({
    super.key,
    required this.claimableEnergy,
    this.onClaimed,
    this.onTierUp,
  });
  
  // ใน _handleClaim หลัง claim สำเร็จ:
  widget.onClaimed?.call();
  if (result['tierUpgraded'] == true) {
    widget.onTierUp?.call();
  }
}
```

**Step 4: Test**
- กดปุ่ม Claim → เห็น confetti 2 วิ + snackbar
- กดซ้ำทันที → แสดง "วันนี้เคลมไปแล้ว"

**Effort:** 2-3 ชม.

---

### J14. Frontend: Tier Up Overlay ✅ เสร็จ

**ไฟล์:** `lib/features/energy/widgets/tier_up_overlay.dart` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้าง widget**
```dart
import 'package:flutter/material.dart';

class TierUpOverlay extends StatefulWidget {
  final String newTier;
  final int reward;
  final VoidCallback onDismiss;

  const TierUpOverlay({
    super.key,
    required this.newTier,
    required this.reward,
    required this.onDismiss,
  });

  @override
  State<TierUpOverlay> createState() => _TierUpOverlayState();
}

class _TierUpOverlayState extends State<TierUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss หลัง 3 วิ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTierIcon(String tier) {
    const icons = {
      'bronze': '🥉',
      'silver': '🥈',
      'gold': '🥇',
      'diamond': '💎',
    };
    return icons[tier] ?? '⭐';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tier icon
                  Text(
                    _getTierIcon(widget.newTier),
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 16),

                  // ยินดีด้วย
                  const Text(
                    '🎉 ยินดีด้วย!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tier name
                  Text(
                    'คุณเลื่อนเป็น ${widget.newTier.toUpperCase()}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Motivation text
                  const Text(
                    'Track calories เก่งมาก\nหุ่นในฝันใกล้จะเป็นจริงแล้ว!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reward
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '+${widget.reward}E Reward!',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: ใช้งานหลัง Claim**
```dart
// lib/features/energy/widgets/claim_button.dart
if (result['tierUpgraded'] == true) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TierUpOverlay(
      newTier: result['newTier'],
      reward: result['tierReward'],
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
```

**Step 3: Test**
- Claim ตอนครบ 7 วัน → เห็น overlay + animation
- Tap anywhere → dismiss

**Effort:** 2-3 ชม.

---

### J15. Frontend: Rewarded Ads (AdMob) Integration ✅ เสร็จ

**ไฟล์:** `lib/core/services/ad_service.dart` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: เพิ่ม dependency**
```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^5.0.0
```

```bash
flutter pub get
```

**Step 2: Config AndroidManifest.xml**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-6145254112451474~9703380291"/>
  </application>
</manifest>
```

**Step 3: สร้าง AdService**
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static const String _rewardedAdUnitId = 'ca-app-pub-6145254112451474/4582480782';
  
  RewardedAd? _rewardedAd;
  int _adsWatchedToday = 0;
  static const int maxAdsPerDay = 3;

  bool get canWatchAd => _adsWatchedToday < maxAdsPerDay;
  int get remainingAds => maxAdsPerDay - _adsWatchedToday;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();
  }

  Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad loaded');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not loaded yet');
      return false;
    }

    if (!canWatchAd) {
      debugPrint('⚠️ Daily ad limit reached');
      return false;
    }

    bool adWatched = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Ad dismissed');
        ad.dispose();
        _loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('✅ User earned reward: ${reward.amount}');
        _adsWatchedToday++;
        adWatched = true;
      },
    );

    _rewardedAd = null;
    return adWatched;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
```

**Step 4: ใช้งานหน้า Analyze**
```dart
// lib/features/camera/presentation/camera_screen.dart
final adService = AdService();

// เมื่อ Energy = 0
ElevatedButton(
  onPressed: () async {
    final success = await adService.showRewardedAd();
    
    if (success) {
      // ให้ใช้ AI ฟรี 1 ครั้ง
      await analyzeFood(isFreeFromAd: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('โฆษณายังไม่พร้อม กรุณาลองอีกครั้งในอีกสักครู่'),
        ),
      );
    }
  },
  child: Text('📺 ดูโฆษณา วิเคราะห์ฟรี (เหลือ ${adService.remainingAds}/3)'),
)
```

**Step 5: Test**
- Energy = 0 → กดปุ่มดู ad
- ดูจบ → ได้ใช้ AI ฟรี 1 ครั้ง
- ดู 3 ครั้ง → ปุ่มถูกซ่อน

**Effort:** 3-4 ชม.

---

### J16. Frontend: Subscription Plans UI (3 Plans) ✅ เสร็จ

**ไฟล์:** `lib/features/subscription/presentation/subscription_screen.dart` (แก้ไข)

**สิ่งที่ต้องทำ:**

**Step 1: อัปเดต UI**
```dart
// แสดง 3 plans แทน 1 plan
ListView(
  children: [
    // Weekly
    _buildPlanCard(
      title: 'Weekly',
      price: '\$1.99',
      period: 'week',
      isRecommended: false,
    ),

    // Monthly (recommended)
    _buildPlanCard(
      title: 'Monthly',
      price: '\$4.99',
      period: 'month',
      isRecommended: true,
      badge: 'BEST VALUE',
      savings: 'ประหยัด 42%',
    ),

    // Yearly
    _buildPlanCard(
      title: 'Yearly',
      price: '\$39.99',
      period: 'year',
      isRecommended: false,
      savings: 'ประหยัด 62% — เฉลี่ย \$3.33/เดือน',
    ),
  ],
)

Widget _buildPlanCard({
  required String title,
  required String price,
  required String period,
  bool isRecommended = false,
  String? badge,
  String? savings,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(
        color: isRecommended ? Colors.orange : Colors.grey,
        width: isRecommended ? 3 : 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$price/$period',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        if (savings != null)
          Text(
            savings,
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
      ],
    ),
  );
}
```

**Step 2: เชื่อม IAP**
```dart
// ใช้ SubscriptionPlan model ที่ Senior เขียนไว้
final plans = SubscriptionPlan.availablePlans();

for (final plan in plans) {
  _buildPlanCard(
    title: plan.name,
    price: plan.price,
    period: plan.period,
    isRecommended: plan.isPopular,
    savings: plan.savingsText,
  );
}
```

**Step 3: Test**
- เปิดหน้า Subscription → เห็น 3 plans
- Monthly มี badge "BEST VALUE"
- Yearly แสดง savings

**Effort:** 2-3 ชม.

---

## Phase 4: Admin Panel (Sprint 5-6, สัปดาห์ที่ 5-6)

### J17. Admin: Promotion Conversion Rate Page 🔧 ทำแล้วบางส่วน

**ไฟล์:** `admin-panel/pages/dashboard/analytics/promotions.tsx` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้าง page**
```tsx
import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase';

interface PromotionStats {
  name: string;
  timesShown: number;
  purchased: number;
  conversionRate: number;
  revenue: number;
}

export default function PromotionsPage() {
  const [stats, setStats] = useState<PromotionStats[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPromotionStats();
  }, []);

  async function fetchPromotionStats() {
    setLoading(true);

    // Query transactions ที่เป็น promotion
    const q = query(
      collection(db, 'transactions'),
      where('type', 'in', ['first_purchase', 'bonus_40', 'tier_promo'])
    );

    const snapshot = await getDocs(q);
    
    // นับจำนวน purchase ต่อ promotion
    const statsMap: Record<string, { purchased: number; revenue: number }> = {};
    
    snapshot.forEach((doc) => {
      const data = doc.data();
      const promoType = data.type;
      
      if (!statsMap[promoType]) {
        statsMap[promoType] = { purchased: 0, revenue: 0 };
      }
      
      statsMap[promoType].purchased += 1;
      statsMap[promoType].revenue += data.metadata?.price || 0;
    });

    // TODO: Query "times shown" จาก analytics events (หรือ hardcode ตอนนี้)
    const promotions: PromotionStats[] = [
      {
        name: '$1 = 200E',
        timesShown: 1234, // TODO: get from analytics
        purchased: statsMap['first_purchase']?.purchased || 0,
        conversionRate: 0,
        revenue: statsMap['first_purchase']?.revenue || 0,
      },
      {
        name: '40% Bonus',
        timesShown: 456,
        purchased: statsMap['bonus_40']?.purchased || 0,
        conversionRate: 0,
        revenue: statsMap['bonus_40']?.revenue || 0,
      },
      // ... tier promos
    ];

    // คำนวณ conversion rate
    promotions.forEach((p) => {
      p.conversionRate = p.timesShown > 0 ? (p.purchased / p.timesShown) * 100 : 0;
    });

    setStats(promotions);
    setLoading(false);
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Promotion Conversion Rate</h1>

      {loading ? (
        <p>Loading...</p>
      ) : (
        <table className="w-full border">
          <thead>
            <tr className="bg-gray-100">
              <th className="border p-2">Promotion</th>
              <th className="border p-2">Times Shown</th>
              <th className="border p-2">Purchased</th>
              <th className="border p-2">Conversion %</th>
              <th className="border p-2">Revenue</th>
            </tr>
          </thead>
          <tbody>
            {stats.map((stat) => (
              <tr key={stat.name}>
                <td className="border p-2">{stat.name}</td>
                <td className="border p-2">{stat.timesShown.toLocaleString()}</td>
                <td className="border p-2">{stat.purchased.toLocaleString()}</td>
                <td className="border p-2">{stat.conversionRate.toFixed(1)}%</td>
                <td className="border p-2">${stat.revenue.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
```

**Step 2: เพิ่มลิงค์ใน sidebar**
```tsx
// admin-panel/components/Sidebar.tsx
<Link href="/dashboard/analytics/promotions">
  Promotion Conversion
</Link>
```

**Step 3: Test**
- เปิด `/dashboard/analytics/promotions`
- เห็นตาราง + conversion rate

**Effort:** 3-4 ชม.

---

### J18. Admin: Push Notification Campaign 🔧 ทำแล้วบางส่วน

**ไฟล์:** `admin-panel/pages/dashboard/campaigns/push.tsx` (สร้างใหม่)

**สิ่งที่ต้องทำ:**

**Step 1: สร้างหน้า UI**
```tsx
import { useState } from 'react';

export default function PushCampaignPage() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);

  async function sendPushNotification() {
    setSending(true);

    try {
      // เรียก Cloud Function
      const response = await fetch(
        'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendBulkPushNotification',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title,
            body,
            targetSegment: 'all', // หรือ filter ตาม tier/subscription
          }),
        }
      );

      const result = await response.json();
      alert(`Sent to ${result.sentCount} users`);
    } catch (error) {
      alert(`Error: ${error}`);
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Push Notification Campaign</h1>

      <div className="space-y-4">
        <div>
          <label className="block mb-2">Title</label>
          <input
            type="text"
            className="border p-2 w-full"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g., 🎉 Flash Sale!"
          />
        </div>

        <div>
          <label className="block mb-2">Body</label>
          <textarea
            className="border p-2 w-full"
            rows={4}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="e.g., Get 50% off all Energy packages for the next 24 hours!"
          />
        </div>

        <button
          className="bg-blue-500 text-white px-4 py-2 rounded disabled:bg-gray-300"
          onClick={sendPushNotification}
          disabled={sending || !title || !body}
        >
          {sending ? 'Sending...' : 'Send to All Users'}
        </button>
      </div>
    </div>
  );
}
```

**Step 2: สร้าง Cloud Function (sendBulkPushNotification)**
```typescript
// functions/src/admin/sendBulkPushNotification.ts
export const sendBulkPushNotification = onRequest(async (req, res) => {
  const { title, body, targetSegment } = req.body;

  // Query users (all หรือ filtered)
  let usersQuery = db.collection('users');

  if (targetSegment === 'subscribers') {
    usersQuery = usersQuery.where('subscription.status', '==', 'active');
  }

  const snapshot = await usersQuery.limit(1000).get();
  const tokens: string[] = [];

  snapshot.forEach((doc) => {
    const fcmToken = doc.data().fcmToken;
    if (fcmToken) tokens.push(fcmToken);
  });

  // Send multicast
  const result = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
  });

  res.json({ sentCount: result.successCount, failedCount: result.failureCount });
});
```

**Step 3: Deploy + Test**
```bash
firebase deploy --only functions:sendBulkPushNotification
```

- กรอก title/body → Send
- Check: users ได้รับ notification

**Effort:** 3-4 ชม.

---

## สรุป Timeline (Junior) — อัปเดต 20 ก.พ. 2026

| Phase | งาน | สถานะ | Effort |
|-------|-----|-------|--------|
| Config | J1-J5 | ✅ เสร็จหมดแล้ว | 1-2 วัน |
| Backend | J6-J8 | ✅ เสร็จหมดแล้ว | 4-6 วัน |
| Frontend Quest Bar | J9-J12 | ❌ **ยังไม่ทำ** | 3-4 วัน |
| Frontend Energy | J13-J16 | ✅ เสร็จหมดแล้ว | 8-10 วัน |
| Admin Panel | J17-J18 | 🔧 ทำแล้วบางส่วน | 2-3 วัน |

### 🎯 งานที่ต้องทำต่อ (เหลือ ~4-6 วัน)

**ลำดับความสำคัญ:**
1. ❌ **J9-J12: Quest Bar Enhancement** (~3-4 วัน) — backend API (S3) เสร็จแล้ว ทำได้เลย!
   - J9: Countdown Timer
   - J10: Swipe to Dismiss Offer
   - J11: Connect to API (canClaim & activeOffers)
   - J12: Referral Share
2. 🔧 **J17: Admin Analytics** (~0.5 วัน) — เพิ่ม date filter
3. 🔧 **J18: Admin Push Campaign** (~0.5 วัน) — เพิ่ม history log
4. 🔧 **Localization** (~0.5 วัน) — เพิ่ม Quest Bar keys ใน `app_en.arb` / `app_th.arb`

### ✅ งานที่เสร็จแล้ว (14/18 tasks)
- ✅ J1-J5: Config Changes (ครบ)
- ✅ J6-J8: Backend (ครบ)
- ✅ J13-J16: Frontend Energy (ครบ)
- ✅ Quest Bar Widget สร้างเสร็จ (`quest_bar.dart`)
- ✅ เพิ่มเข้าไปในหน้า Timeline แล้ว
- ✅ แสดง Streak + Progress Bar + Collapsible section

---

## Tips สำหรับ Junior

1. **ทำตาม step-by-step** — ไม่ต้องคิดเอง แค่ copy code แล้วปรับ
2. **Test ทุกขั้นตอน** — อย่ารอถึง deploy ค่อย test
3. **ถ้าติดปัญหา** — ถาม Senior พร้อม error message + screenshot
4. **Commit บ่อยๆ** — ทุก task ที่เสร็จ commit ทันที
5. **อ่าน comment ในโค้ด** — Senior เขียนไว้เยอะ เพื่อให้เข้าใจ logic
