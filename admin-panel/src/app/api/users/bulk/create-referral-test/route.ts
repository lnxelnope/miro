import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

/**
 * Generate a random string for test user device IDs
 */
function generateRandomString(length: number): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Generate a random MiRO ID for test users
 */
function generateMiroId(): string {
  const part1 = Math.random().toString(36).substring(2, 6).toUpperCase();
  const part2 = Math.random().toString(36).substring(2, 6).toUpperCase();
  const part3 = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `MIRO-${part1}-${part2}-${part3}`;
}

export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const { referralCode, bypassFraud = false } = body;

    if (!referralCode) {
      return NextResponse.json(
        { error: 'Referral code (MiRO ID) is required' },
        { status: 400 }
      );
    }

    // 1. Look up referrer by MiRO ID
    const referrerSnapshot = await db
      .collection('users')
      .where('miroId', '==', referralCode)
      .limit(1)
      .get();

    if (referrerSnapshot.empty) {
      return NextResponse.json(
        { error: `Invalid referral code: ${referralCode} not found` },
        { status: 404 }
      );
    }

    const referrerDoc = referrerSnapshot.docs[0];
    const referrerData = referrerDoc.data();
    const referrerDeviceId = referrerDoc.id;
    const referrerBalanceBefore = referrerData.balance || 0;

    // 2. Create fake user (referee)
    const fakeDeviceId = `test_${generateRandomString(16)}`;
    const fakeMiroId = generateMiroId();
    const today = new Date().toISOString().split('T')[0];

    const fakeUserData = {
      miroId: fakeMiroId,
      balance: 0,
      tier: 'starter',
      bonusRate: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastCheckInDate: today,
      totalEarned: 0,
      totalPurchased: 0,
      
      milestones: {
        totalSpent: 0,
        claimedMilestones: [],
        nextMilestoneIndex: 0,
      },
      
      offers: {
        firstPurchaseClaimed: false,
        firstPurchaseAvailable: false,
        firstPurchaseExpiry: null,
        welcomeBonusClaimed: false,
        welcomeBonusAvailable: false,
        welcomeBonusExpiry: null,
      },
      
      adViews: {
        date: today,
        count: 0,
      },
      
      dailyClaim: {
        lastClaimDate: null,
      },
      
      promotions: {
        welcomeOfferClaimed: false,
        welcomeBackClaimed: false,
        tierPromoClaimed: {},
        tierRewardClaimed: {},
      },

      referrals: {
        referredBy: null,
        referredByDeviceId: null,
      },

      referredBy: null,
      
      isBanned: false,
      createdAt: FieldValue.serverTimestamp(),
      lastUpdated: FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(fakeDeviceId).set(fakeUserData);

    // 3. Submit referral — either via Cloud Function or Direct Write
    let refereeBonus = 0;
    const usedDirectWrite = bypassFraud;

    if (bypassFraud) {
      // Direct Write: bypass anti-fraud (admin toggle enabled)
      refereeBonus = 20;
      await db.collection('users').doc(fakeDeviceId).update({
        balance: refereeBonus,
        totalEarned: refereeBonus,
        'referrals.referredBy': referralCode,
        'referrals.referredByDeviceId': referrerDeviceId,
        'referredBy': referrerDeviceId,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      await db.collection('transactions').add({
        deviceId: fakeDeviceId,
        miroId: fakeMiroId,
        type: 'referral',
        amount: refereeBonus,
        balanceAfter: refereeBonus,
        description: `Referral bonus: +${refereeBonus} Energy (admin test, fraud bypassed)`,
        metadata: {
          referralCode,
          referrerMiroId: referralCode,
          isReferee: true,
          isAdminTest: true,
        },
        createdAt: FieldValue.serverTimestamp(),
      });

      await db.collection('referral_records').add({
        referrerId: referrerDeviceId,
        referrerMiroId: referralCode,
        refereeId: fakeDeviceId,
        refereeMiroId: fakeMiroId,
        status: 'pending',
        refereeAiUsageCount: 0,
        requiredUsage: 3,
        referrerReward: 15,
        refereeReward: refereeBonus,
        createdAt: FieldValue.serverTimestamp(),
        ip: { referrer: 'admin-test', referee: 'admin-test' },
      });
    } else {
      // Cloud Function: use real submitReferralCode (with anti-fraud)
      const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'miro-6d9ef';
      const functionRegion = 'us-central1';
      const submitReferralUrl = `https://${functionRegion}-${projectId}.cloudfunctions.net/submitReferralCode`;

      try {
        const submitResponse = await fetch(submitReferralUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            deviceId: fakeDeviceId,
            referralCode: referralCode,
          }),
        });

        const submitData = await submitResponse.json();

        if (submitResponse.ok && submitData.success) {
          refereeBonus = submitData.bonusEnergy || 20;
        } else {
          console.warn('submitReferralCode failed:', submitData);
          return NextResponse.json({
            success: false,
            error: submitData.error || 'submitReferralCode failed',
            hint: 'Anti-fraud อาจบล็อก test user — ลองเปิด "Bypass Anti-Fraud" toggle แล้วทดสอบใหม่',
            data: {
              fakeUser: { deviceId: fakeDeviceId, miroId: fakeMiroId },
            },
          }, { status: 400 });
        }
      } catch (error: any) {
        console.error('Error calling submitReferralCode:', error);
        return NextResponse.json({
          success: false,
          error: error.message || 'Cannot reach submitReferralCode cloud function',
          hint: 'Cloud function อาจไม่ได้ deploy หรือ URL ไม่ถูกต้อง — ลองเปิด "Bypass Anti-Fraud" toggle แล้วทดสอบใหม่',
          data: {
            fakeUser: { deviceId: fakeDeviceId, miroId: fakeMiroId },
          },
        }, { status: 500 });
      }
    }

    // 4. Simulate energy usage: set milestones.totalSpent = 10
    await db.collection('users').doc(fakeDeviceId).update({
      'milestones.totalSpent': 10,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    // 5. Give referrer their bonus — Direct Write or Cloud Function
    const REFERRAL_BASE_REWARD = 5;
    let referrerBonus = 0;
    let referrerBalanceAfter = referrerBalanceBefore;

    if (bypassFraud) {
      // Direct Write: replicate checkReferralProgress logic
      const referrerNewBalance = referrerBalanceBefore + REFERRAL_BASE_REWARD;

      const now = new Date();
      const localTime = new Date(now.getTime() + 420 * 60 * 1000); // UTC+7
      const todayStr = localTime.toISOString().split('T')[0];
      const day = localTime.getDay();
      const diff = day === 0 ? 6 : day - 1;
      const weekStartDate = new Date(localTime);
      weekStartDate.setDate(localTime.getDate() - diff);
      const weekStart = weekStartDate.toISOString().split('T')[0];

      const challenges = referrerData.challenges?.weekly || {};
      const currentWeekStart = challenges.weekStartDate || null;
      let referFriends = challenges.referFriends || 0;
      if (currentWeekStart !== weekStart) referFriends = 0;
      const newReferFriends = referFriends + 1;

      const updateData: Record<string, any> = {
        balance: referrerNewBalance,
        totalEarned: (referrerData.totalEarned || 0) + REFERRAL_BASE_REWARD,
        'challenges.weekly.referFriends': newReferFriends,
        'challenges.weekly.weekStartDate': weekStart,
        lastUpdated: FieldValue.serverTimestamp(),
      };

      if (currentWeekStart === weekStart) {
        updateData['challenges.weekly.logMeals'] = challenges.logMeals || 0;
        updateData['challenges.weekly.logMealsLastDate'] = challenges.logMealsLastDate || null;
        updateData['challenges.weekly.logMealsFailed'] = challenges.logMealsFailed || false;
        updateData['challenges.weekly.useAi'] = challenges.useAi || 0;
        updateData['challenges.weekly.claimedRewards'] = challenges.claimedRewards || [];
      } else {
        updateData['challenges.weekly.logMeals'] = 0;
        updateData['challenges.weekly.logMealsLastDate'] = null;
        updateData['challenges.weekly.logMealsFailed'] = false;
        updateData['challenges.weekly.useAi'] = 0;
        updateData['challenges.weekly.claimedRewards'] = [];
      }

      await db.collection('users').doc(referrerDeviceId).update(updateData);

      await db.collection('transactions').add({
        deviceId: referrerDeviceId,
        miroId: referrerData.miroId || 'unknown',
        type: 'referral_base_reward',
        amount: REFERRAL_BASE_REWARD,
        balanceAfter: referrerNewBalance,
        description: `Referral: friend spent 10E (+${REFERRAL_BASE_REWARD}E base, admin test)`,
        metadata: {
          friendDeviceId: fakeDeviceId,
          referFriendsCount: newReferFriends,
          baseReward: REFERRAL_BASE_REWARD,
          isAdminTest: true,
        },
        createdAt: FieldValue.serverTimestamp(),
      });

      // Mark referee as claimed
      await db.collection('users').doc(fakeDeviceId).update({
        referralRewardClaimed: true,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      referrerBonus = REFERRAL_BASE_REWARD;
      referrerBalanceAfter = referrerNewBalance;
    } else {
      // Cloud Function: call checkReferralProgressEndpoint
      const projectId2 = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'miro-6d9ef';
      const checkProgressUrl = `https://us-central1-${projectId2}.cloudfunctions.net/checkReferralProgressEndpoint`;

      try {
        const checkResponse = await fetch(checkProgressUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ deviceId: fakeDeviceId }),
        });

        const checkData = await checkResponse.json();
        if (!checkResponse.ok) {
          console.warn('checkReferralProgress failed:', checkData);
        }
      } catch (error) {
        console.error('Error calling checkReferralProgress:', error);
      }

      // Read back referrer's updated balance
      const referrerDocUpdated = await db.collection('users').doc(referrerDeviceId).get();
      const referrerDataUpdated = referrerDocUpdated.data();
      referrerBalanceAfter = referrerDataUpdated?.balance || referrerBalanceBefore;
      referrerBonus = referrerBalanceAfter - referrerBalanceBefore;
    }

    // 7. Log audit trail
    await db.collection('adminLogs').add({
      action: 'create_referral_test',
      details: {
        referralCode,
        fakeDeviceId,
        fakeMiroId,
        referrerDeviceId,
        refereeBonus,
        referrerBonus,
        bypassFraud,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: usedDirectWrite
        ? 'Referral test completed (Direct Write — Anti-Fraud bypassed)'
        : 'Referral test completed via Cloud Function',
      data: {
        fakeUser: {
          deviceId: fakeDeviceId,
          miroId: fakeMiroId,
        },
        referee: {
          bonusReceived: refereeBonus,
        },
        referrer: {
          deviceId: referrerDeviceId,
          miroId: referralCode,
          balanceBefore: referrerBalanceBefore,
          balanceAfter: referrerBalanceAfter,
          bonusReceived: referrerBonus,
        },
        usedDirectWrite,
      },
    });
  } catch (error) {
    console.error('Create referral test user error:', error);
    return NextResponse.json(
      { error: 'Failed to create referral test user' },
      { status: 500 }
    );
  }
}
