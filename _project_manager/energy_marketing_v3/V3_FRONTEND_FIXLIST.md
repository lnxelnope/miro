# V3 Frontend Fix List — งานแก้ไข Frontend ให้ตรง Blueprint

> **สถานะ:** ต้องทำทันที  
> **ผู้รับผิดชอบ:** Junior Developer  
> **อ้างอิง:** `_project_manager/ENERGY_MARKETING_BLUEPRINT.md`  
> **หมายเหตุ:** Backend (`milestoneV2.ts`, `challenge.ts`, `claimDailyEnergy.ts`) ทำถูกต้องแล้ว  
> **ปัญหา:** Frontend ยังค้างเป็นระบบเก่า (v2) หลายจุด ต้องแก้ให้ตรง v3

---

## สารบัญ

| # | งาน | Priority | ไฟล์ | ประมาณเวลา |
|---|------|----------|------|-----------|
| F1 | Energy Store ลบ Streak/Challenge/Milestone ออก | 🔴 Critical | `energy_store_screen.dart` | 30 นาที |
| F2 | Milestone เปลี่ยนจาก 2 ขั้น → 10 ขั้น | 🔴 Critical | `milestone_progress_card.dart`, `gamification_state.dart`, `gamification_provider.dart` | 3-4 ชม. |
| F3 | Weekly Challenge reward 5E → 3E | 🟡 Medium | `weekly_challenge_card.dart` | 15 นาที |
| F4 | ลบ First Empty Bonus +50E | 🟡 Medium | `no_energy_dialog.dart` | 30 นาที |
| F5 | Home Screen daily energy ค่าผิด | 🟡 Medium | `home_screen.dart` | 15 นาที |
| F6 | Subscription ราคาเก่า ฿149 | 🟢 Low | `energy_store_screen.dart`, `subscription_screen.dart` | 15 นาที |
| F7 | ลบ Random Bonus handler | 🟢 Low | `gamification_provider.dart` | 15 นาที |

---

## F1: Energy Store — ลบ Streak / Challenge / Milestone ออก

### ไฟล์: `lib/features/energy/presentation/energy_store_screen.dart`

### ทำไมต้องแก้
Blueprint Section 2 บอกว่า: **"ย้าย Streak/Challenge/Milestone ออกจากหน้า Energy Store → มาที่ Quest Bar แทน"**  
หน้า Energy Store ควรเหลือแค่: Balance Card → Subscription CTA → Promotion Banner → Energy Packages

### วิธีแก้

#### ขั้นตอน 1: ลบ import ที่ไม่ใช้แล้ว

เปิดไฟล์ `lib/features/energy/presentation/energy_store_screen.dart`

**ลบบรรทัดเหล่านี้ออก (บรรทัด 9-12):**
```dart
import 'package:miro_hybrid/features/energy/widgets/welcome_offer_progress.dart';
import 'package:miro_hybrid/features/energy/widgets/weekly_challenge_card.dart';
import 'package:miro_hybrid/features/energy/widgets/milestone_progress_card.dart';
import 'package:miro_hybrid/features/energy/widgets/streak_display.dart';
```

#### ขั้นตอน 2: ลบ widgets ออกจาก ListView

ใน method `_buildScaffold` (ประมาณบรรทัด 88-140) **ลบ block เหล่านี้ออก:**

**ลบ Streak Display (บรรทัด 102-106):**
```dart
            // ────── Streak & Tier Display (only for non-subscribers) ──────
            if (!isSubscriber) ...[
              const StreakDisplay(),
              const SizedBox(height: 20),
            ],
```

**ลบ Weekly Challenges & Milestones (บรรทัด 120-124):**
```dart
            // ────── Weekly Challenges & Milestones ──────
            const WeeklyChallengeCard(),
            const SizedBox(height: 12),
            const MilestoneProgressCard(),
            const SizedBox(height: 20),
```

**ลบ Welcome Offer Progress (บรรทัด 126-130):**
```dart
            // ────── Progress to unlock Welcome Offer ──────
            if (_offerStatus == WelcomeOfferStatus.notStarted) ...[
              const WelcomeOfferProgress(),
              const SizedBox(height: 20),
            ],
```

#### ผลลัพธ์ที่ต้องการ
หน้า Energy Store ลำดับ widgets ใน ListView ควรเป็น:
1. Balance Card
2. Subscriber Active Badge (ถ้า subscriber)
3. Subscription CTA (ถ้า non-subscriber)
4. Active Promotion Banner (ถ้ามี)
5. Welcome Offer Banner + Welcome Packages (ถ้า active)
6. Regular Energy Packages
7. Info Card

---

## F2: Milestone — เปลี่ยนจาก 2 ขั้น (500/1000) → 10 ขั้น ตาม Blueprint

### ทำไมต้องแก้
Backend (`milestoneV2.ts`) อัปเดตเป็น 10 ขั้นแล้ว แต่ Frontend ยังใช้ระบบเก่า 2 ขั้น (500E กับ 1000E)

Blueprint Section 6 กำหนด 10 ขั้น:
| # | Milestone (E spent) | Reward | แสดงเมื่อ |
|---|---------------------|--------|----------|
| 1 | 10 | 3E | เริ่มต้น |
| 2 | 25 | 5E | ผ่าน #1 |
| 3 | 50 | 7E | ผ่าน #2 |
| 4 | 100 | 10E | ผ่าน #3 |
| 5 | 250 | 15E | ผ่าน #4 |
| 6 | 500 | 20E | ผ่าน #5 |
| 7 | 1,000 | 30E | ผ่าน #6 |
| 8 | 2,500 | 50E | ผ่าน #7 |
| 9 | 5,000 | 65E | ผ่าน #8 |
| 10 | 10,000 | 100E | ผ่าน #9 |

**การแสดงผล:** แสดงทีละ 1 milestone ถัดไปเท่านั้น (Progressive Reveal)  
milestone ที่ยังไม่ unlock แสดงเป็น 🔒

### ไฟล์ที่ต้องแก้: 3 ไฟล์

---

### ขั้นตอน 1: แก้ GamificationState

**ไฟล์:** `lib/core/models/gamification_state.dart`

**ลบ field เก่า (บรรทัด 18-19):**
```dart
  final bool spent500Claimed;
  final bool spent1000Claimed;
```

**เพิ่ม field ใหม่แทน:**
```dart
  final List<String> claimedMilestones;
  final int nextMilestoneIndex;
```

**แก้ constructor — ลบ parameter เก่า เพิ่มใหม่:**

ลบ:
```dart
    this.spent500Claimed = false,
    this.spent1000Claimed = false,
```

เพิ่มแทน:
```dart
    this.claimedMilestones = const [],
    this.nextMilestoneIndex = 0,
```

**แก้ `factory GamificationState.empty()` — ลบ parameter เก่า เพิ่มใหม่:**

ลบ:
```dart
      spent500Claimed: false,
      spent1000Claimed: false,
```

เพิ่มแทน:
```dart
      claimedMilestones: const [],
      nextMilestoneIndex: 0,
```

**แก้ `copyWith` method — ลบ parameter เก่า เพิ่มใหม่:**

ลบ:
```dart
    bool? spent500Claimed,
    bool? spent1000Claimed,
```

เพิ่มแทน:
```dart
    List<String>? claimedMilestones,
    int? nextMilestoneIndex,
```

ใน body ของ copyWith ลบ:
```dart
      spent500Claimed: spent500Claimed ?? this.spent500Claimed,
      spent1000Claimed: spent1000Claimed ?? this.spent1000Claimed,
```

เพิ่มแทน:
```dart
      claimedMilestones: claimedMilestones ?? this.claimedMilestones,
      nextMilestoneIndex: nextMilestoneIndex ?? this.nextMilestoneIndex,
```

---

### ขั้นตอน 2: แก้ GamificationProvider

**ไฟล์:** `lib/features/energy/providers/gamification_provider.dart`

**ใน `_loadState()` — แก้ parsing milestone data (ประมาณบรรทัด 58-75):**

ลบ:
```dart
        spent500Claimed: milestones['spent500Claimed'] ?? false,
        spent1000Claimed: milestones['spent1000Claimed'] ?? false,
```

เพิ่มแทน:
```dart
        claimedMilestones: List<String>.from(milestones['claimedMilestones'] ?? []),
        nextMilestoneIndex: (milestones['nextMilestoneIndex'] as num?)?.toInt() ?? 0,
```

**ใน fallback state (ประมาณบรรทัด 95-110):**

ลบ:
```dart
        spent500Claimed: false,
        spent1000Claimed: false,
```

เพิ่มแทน:
```dart
        claimedMilestones: const [],
        nextMilestoneIndex: 0,
```

**ใน `updateFromAiResponse()` (ประมาณบรรทัด 129-148):**

ลบ:
```dart
      spent500Claimed: milestones['spent500Claimed'] ?? state.spent500Claimed,
      spent1000Claimed: milestones['spent1000Claimed'] ?? state.spent1000Claimed,
```

เพิ่มแทน:
```dart
      claimedMilestones: List<String>.from(milestones['claimedMilestones'] ?? state.claimedMilestones),
      nextMilestoneIndex: (milestones['nextMilestoneIndex'] as num?)?.toInt() ?? state.nextMilestoneIndex,
```

---

### ขั้นตอน 3: Rewrite MilestoneProgressCard

**ไฟล์:** `lib/features/energy/widgets/milestone_progress_card.dart`

**ลบทุกอย่างในไฟล์นี้** แล้วแทนด้วยโค้ดด้านล่าง:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_icons.dart';
import '../providers/gamification_provider.dart';

class MilestoneProgressCard extends ConsumerWidget {
  final bool compact;

  const MilestoneProgressCard({super.key, this.compact = false});

  static const List<Map<String, dynamic>> _milestones = [
    {'threshold': 10, 'reward': 3, 'label': 'milestone_10'},
    {'threshold': 25, 'reward': 5, 'label': 'milestone_25'},
    {'threshold': 50, 'reward': 7, 'label': 'milestone_50'},
    {'threshold': 100, 'reward': 10, 'label': 'milestone_100'},
    {'threshold': 250, 'reward': 15, 'label': 'milestone_250'},
    {'threshold': 500, 'reward': 20, 'label': 'milestone_500'},
    {'threshold': 1000, 'reward': 30, 'label': 'milestone_1000'},
    {'threshold': 2500, 'reward': 50, 'label': 'milestone_2500'},
    {'threshold': 5000, 'reward': 65, 'label': 'milestone_5000'},
    {'threshold': 10000, 'reward': 100, 'label': 'milestone_10000'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final totalSpent = gamification.totalSpent;
    final claimed = gamification.claimedMilestones;
    final nextIndex = gamification.nextMilestoneIndex;

    // Progressive Reveal: แสดง milestone ถัดไป + ล็อคตัวถัดจากนั้น
    final currentMilestone =
        nextIndex < _milestones.length ? _milestones[nextIndex] : null;
    final lockedMilestone =
        nextIndex + 1 < _milestones.length ? _milestones[nextIndex + 1] : null;

    // ถ้า claim ครบทุก milestone
    if (currentMilestone == null) {
      return compact
          ? _buildAllComplete()
          : Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAllComplete(),
              ),
            );
    }

    final threshold = currentMilestone['threshold'] as int;
    final reward = currentMilestone['reward'] as int;
    final progress = (totalSpent / threshold).clamp(0.0, 1.0);

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMilestoneRow(
            title: 'ใช้ Energy ครบ $threshold',
            progress: totalSpent,
            target: threshold,
            reward: reward,
            progressPercent: progress,
          ),
          if (lockedMilestone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'ถัดไป: ${lockedMilestone['threshold']}E',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcons.iconWithLabel(
              AppIcons.milestone,
              'Milestones',
              iconColor: AppIcons.milestoneColor,
              iconSize: 24,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            _buildMilestoneRow(
              title: 'ใช้ Energy ครบ $threshold',
              progress: totalSpent,
              target: threshold,
              reward: reward,
              progressPercent: progress,
            ),
            if (lockedMilestone != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lock, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'ถัดไป: ${lockedMilestone['threshold']}E',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String title,
    required int progress,
    required int target,
    required int reward,
    required double progressPercent,
  }) {
    final isComplete = progress >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+$reward ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(AppIcons.energy,
                    size: 14, color: AppIcons.energyColor),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$progress/$target',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllComplete() {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Text(
          'ทุก Milestone สำเร็จแล้ว!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
```

> **หมายเหตุ:** Milestone claim ทำ auto ที่ backend (analyzeFood) แล้ว Frontend แค่แสดง progress ไม่ต้องมีปุ่ม Claim

---

## F3: Weekly Challenge — reward 5E → 3E

### ไฟล์: `lib/features/energy/widgets/weekly_challenge_card.dart`

### วิธีแก้

หา `reward: 5` ทุกตัวในไฟล์ (มี 4 จุด) แล้วเปลี่ยนเป็น `reward: 3`

#### จุดที่ 1 — Compact mode, logMeals (บรรทัด 123):
```
เดิม:  reward: 5,
ใหม่:  reward: 3,
```

#### จุดที่ 2 — Compact mode, useAi (บรรทัด 134):
```
เดิม:  reward: 5,
ใหม่:  reward: 3,
```

#### จุดที่ 3 — Full Card mode, logMeals (บรรทัด 169):
```
เดิม:  reward: 5,
ใหม่:  reward: 3,
```

#### จุดที่ 4 — Full Card mode, useAi (บรรทัด 180):
```
เดิม:  reward: 5,
ใหม่:  reward: 3,
```

**ทำ Find & Replace ทั้งไฟล์ได้เลย:** `reward: 5` → `reward: 3` (4 จุดในไฟล์นี้)

---

## F4: ลบ First Empty Bonus +50E

### ทำไมต้องแก้
Blueprint v3: **"First Empty Bonus +50E → ❌ ลบออก"**  
ตอนนี้ `no_energy_dialog.dart` ยังเรียก `checkAndHandleFirstEnergyEmpty()` ซึ่งให้ +50E ฟรีครั้งแรก

### ไฟล์: `lib/features/energy/widgets/no_energy_dialog.dart`

### วิธีแก้

#### ขั้นตอน 1: ลบ import ที่ไม่ใช้

**ลบบรรทัดนี้:**
```dart
import 'welcome_offer_unlocked_dialog.dart';
```

#### ขั้นตอน 2: ลบ state variable

**ลบ (บรรทัด 34):**
```dart
  bool _receivedBonus = false;
```

#### ขั้นตอน 3: ลบ method `_checkFirstTimeBonus` ทั้งหมด

**ลบบรรทัด 83-108 ออกทั้งหมด:**
```dart
  Future<void> _checkFirstTimeBonus() async {
    final energyService = EnergyService(DatabaseService.isar);
    
    // Check if this is the first time Energy ran out
    final receivedBonus = await energyService.checkAndHandleFirstEnergyEmpty();
    
    setState(() {
      _isChecking = false;
      _receivedBonus = receivedBonus;
    });

    if (receivedBonus) {
      // Wait a moment then close this dialog
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Refresh energy balance
        ref.invalidate(energyBalanceProvider);
        
        // Close dialog
        Navigator.pop(context);
        
        // Show Welcome Offer Unlocked Dialog
        await WelcomeOfferUnlockedDialog.show(context);
      }
    }
  }
```

#### ขั้นตอน 4: แก้ initState

**เดิม:**
```dart
  @override
  void initState() {
    super.initState();
    _checkFirstTimeBonus();
    _initAd();
  }
```

**ใหม่:**
```dart
  @override
  void initState() {
    super.initState();
    _initAd();
  }
```

#### ขั้นตอน 5: ลบ state `_isChecking` และ UI ที่เกี่ยวข้อง

**ลบ (บรรทัด 33):**
```dart
  bool _isChecking = true;
```

#### ขั้นตอน 6: แก้ build method

ลบ block `if (_isChecking)` ทั้งหมด (บรรทัด 113-126):
```dart
    if (_isChecking) {
      // Show loading while checking
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppIcons.energyColor),
            SizedBox(height: 16),
            Text('Checking...'),
          ],
        ),
      );
    }
```

ลบ block `if (_receivedBonus)` ทั้งหมด (บรรทัด 128-173):
```dart
    if (_receivedBonus) {
      // Show bonus message
      return AlertDialog(
        ... (ทั้ง block จนถึง closing bracket)
      );
    }
```

**ผลลัพธ์:** `build()` ควรเริ่มต้นด้วย `return AlertDialog(...)` ของ "Out of Energy" dialog เลย (ส่วนที่มีปุ่ม Ad + Buy Energy)

---

## F5: Home Screen — Daily Energy ค่าผิด

### ไฟล์: `lib/features/home/presentation/home_screen.dart`

### ทำไมต้องแก้
ค่า `energyMap` ในบรรทัด 83-89 ใช้ค่า Tier Upgrade Reward (5/10/15/25) แทนที่จะเป็น Daily Energy (1/1/2/3/4)

### วิธีแก้

**เดิม (บรรทัด 83-89):**
```dart
        final energyMap = {
          'bronze': 5,
          'silver': 10,
          'gold': 15,
          'diamond': 25,
          'none': 1,
        };
```

**ใหม่:**
```dart
        final energyMap = {
          'none': 1,
          'bronze': 1,
          'silver': 2,
          'gold': 3,
          'diamond': 4,
        };
```

---

## F6: Subscription — ราคาเก่า ฿149/month

### ไฟล์ 1: `lib/features/energy/presentation/energy_store_screen.dart`

**เดิม (บรรทัด 473):**
```dart
                        'Unlimited AI Analysis • ฿149/month',
```

**ใหม่:**
```dart
                        'Unlimited AI Analysis • from \$3.33/month',
```

### ไฟล์ 2: `lib/features/subscription/presentation/subscription_screen.dart`

**เดิม (บรรทัด 214):**
```dart
            value: '฿149/month',
```

**ใหม่:**
```dart
            value: subscription.basePlanId == 'energy-pass-weekly'
                ? '\$1.99/week'
                : subscription.basePlanId == 'energy-pass-yearly'
                    ? '\$39.99/year'
                    : '\$4.99/month',
```

> **หมายเหตุ:** ตรงนี้อาจต้อง import subscription model ถ้ายังไม่ได้ import  
> ถ้า `subscription` object ไม่มี `basePlanId` ให้ใช้ fallback: `'\$4.99/month'`

---

## F7: ลบ Random Bonus Handler (ไม่ใช้แล้วใน v3)

### ไฟล์: `lib/features/energy/providers/gamification_provider.dart`

### วิธีแก้

**เดิม (บรรทัด 185-224):**
```dart
  /// Update state จาก check-in response (Phase 2: random bonus)
  /// Returns random bonus amount if got bonus, otherwise null
  int? updateFromCheckInResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final randomBonus = (response['randomBonus'] as num?)?.toInt() ?? 0;
    final gotRandomBonus = response['gotRandomBonus'] == true;
    final newBalance = (response['newBalance'] as num?)?.toInt();

    final currentStreak = (streak?['current'] as num?)?.toInt() ?? state.currentStreak;
    final tier = streak?['tier']?.toString() ?? state.tier;
    final energyBonus = (streak?['energyBonus'] as num?)?.toInt() ?? 0;

    state = state.copyWith(
      currentStreak: currentStreak,
      longestStreak: (streak?['longest'] as num?)?.toInt(),
      tier: tier,
      balance: newBalance,
    );

    // Analytics: daily check-in
    AnalyticsService.logDailyCheckIn(
      streakDays: currentStreak,
      tier: tier,
      energyBonus: energyBonus + randomBonus,
    );

    // Tier upgrade milestone
    if (streak?['tierUpgraded'] == true) {
      AnalyticsService.logStreakMilestone(
        streakDays: currentStreak,
        newTier: tier,
      );
    }

    // Return random bonus info สำหรับแสดง dialog
    if (gotRandomBonus && randomBonus > 0) {
      return randomBonus;
    }
    return null;
  }
```

**ใหม่:**
```dart
  /// Update state จาก check-in response (V3: no random bonus)
  void updateFromCheckInResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final newBalance = (response['newBalance'] as num?)?.toInt();

    final currentStreak = (streak?['current'] as num?)?.toInt() ?? state.currentStreak;
    final tier = streak?['tier']?.toString() ?? state.tier;
    final energyBonus = (streak?['energyBonus'] as num?)?.toInt() ?? 0;

    state = state.copyWith(
      currentStreak: currentStreak,
      longestStreak: (streak?['longest'] as num?)?.toInt(),
      tier: tier,
      balance: newBalance,
    );

    AnalyticsService.logDailyCheckIn(
      streakDays: currentStreak,
      tier: tier,
      energyBonus: energyBonus,
    );

    if (streak?['tierUpgraded'] == true) {
      AnalyticsService.logStreakMilestone(
        streakDays: currentStreak,
        newTier: tier,
      );
    }
  }
```

> **สำคัญ:** return type เปลี่ยนจาก `int?` → `void`  
> ต้อง search หา caller ที่เรียก `updateFromCheckInResponse` ทั้ง project  
> ถ้ามี caller ที่เช็ค return value (เช่น `final bonus = notifier.updateFromCheckInResponse(...)`) ต้องลบการใช้ return value ออก

**Search command:**
```
rg "updateFromCheckInResponse" --type dart
```

---

## Checklist หลังแก้เสร็จ

- [ ] F1: Energy Store — ไม่มี Streak, Challenge, Milestone แล้ว
- [ ] F2: Milestone — แสดง milestone ถัดไป (10→25→50→100→...) ไม่ใช่ 500/1000
- [ ] F2: GamificationState — ไม่มี `spent500Claimed` / `spent1000Claimed` แล้ว
- [ ] F3: Weekly Challenge — แสดง reward 3E (ไม่ใช่ 5E)
- [ ] F4: No Energy Dialog — ไม่ให้ +50E ฟรี ไม่แสดง "50 Energy FREE!"
- [ ] F5: Home Screen — Daily Energy ค่าถูก (1/1/2/3/4 ตาม tier)
- [ ] F6: Subscription — ไม่มี ฿149/month แล้ว
- [ ] F7: Random Bonus — ลบ handler แล้ว ไม่มี `gotRandomBonus`
- [ ] Build สำเร็จ ไม่มี error
- [ ] ทดสอบเปิดหน้า Energy Store — เห็นแค่ Subscription + Packages
- [ ] ทดสอบ Quest Bar — กดขยายเห็น Milestone ใหม่ (ไม่ใช่ 500/1000)

---

## Energy Package ราคาที่ถูกต้อง (ตาม Blueprint)

ไฟล์ `energy_store_screen.dart` ราคาปัจจุบัน **ใกล้เคียงแต่ไม่ตรง** กับ Blueprint:

| Package | ราคาใน code | ราคาใน Blueprint | ต้องแก้? |
|---------|-----------|-----------------|---------|
| Starter (100E) | $0.99 | $0.99 | ✅ ถูกแล้ว |
| Value (550E) | $4.99 | $4.99 | ✅ ถูกแล้ว |
| Power (1200E) | $7.99 | $9.99 | ⚠️ เช็คกับ Owner ว่าตั้ง IAP เท่าไหร่ |
| Ultimate (2000E) | $9.99 | $14.99 | ⚠️ เช็คกับ Owner ว่าตั้ง IAP เท่าไหร่ |

> ราคาจริงมาจาก Google Play — ถ้า Owner ตั้ง IAP ถูกแล้ว ไม่ต้องแก้ที่ code (Google Play จะ override)  
> แต่ถ้า Owner ยังไม่ได้ตั้ง ให้แจ้ง Owner ก่อน

---

## ลำดับทำงาน (แนะนำ)

```
1. F1 (ลบของออกจาก Energy Store)     — 30 นาที   ← ทำก่อน ง่ายสุด
2. F3 (Challenge 5→3)                 — 15 นาที
3. F5 (Home Screen energyMap)         — 15 นาที
4. F6 (ราคา Subscription)             — 15 นาที
5. F7 (ลบ Random Bonus)               — 15 นาที
6. F4 (ลบ First Empty Bonus)          — 30 นาที
7. F2 (Milestone 10 ขั้น)             — 3-4 ชม.   ← ทำหลังสุด ซับซ้อนสุด
─────────────────────────────────────────────────
รวม: ~5-6 ชั่วโมง
```

**หลังทำเสร็จ:**
1. `flutter analyze` — ต้องไม่มี error
2. `flutter build apk --debug` — ต้อง build ผ่าน
3. เปิดแอปทดสอบหน้า Energy Store + Quest Bar
