import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

const TIER_THRESHOLDS = {
  starter: 0,
  bronze: 500,
  silver: 2000,
  gold: 5000,
  diamond: 10000,
};

const TIER_BONUS_RATES = {
  starter: 0,
  bronze: 0.10,
  silver: 0.15,
  gold: 0.20,
  diamond: 0.25,
};

function generateRandomString(length: number): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function getRandomTier(distribution: any): string {
  const rand = Math.random() * 100;
  let cumulative = 0;
  
  for (const [tier, percentage] of Object.entries(distribution)) {
    cumulative += percentage as number;
    if (rand <= cumulative) {
      return tier;
    }
  }
  
  return 'starter';
}

export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const { count, tierDistribution } = body;

    if (!count || count < 1 || count > 1000) {
      return NextResponse.json(
        { error: 'Count must be between 1 and 1000' },
        { status: 400 }
      );
    }

    // Default tier distribution
    const distribution = tierDistribution || {
      starter: 40,
      bronze: 30,
      silver: 20,
      gold: 8,
      diamond: 2,
    };

    const createdUsers: string[] = [];
    const batch = db.batch();
    let batchCount = 0;

    for (let i = 0; i < count; i++) {
      const deviceId = `test_${generateRandomString(16)}`;
      const tier = getRandomTier(distribution);
      const totalSpent = Math.floor(
        TIER_THRESHOLDS[tier as keyof typeof TIER_THRESHOLDS] +
        Math.random() * 100
      );
      const balance = Math.floor(Math.random() * 1000);
      const streak = Math.floor(Math.random() * 30);

      const userRef = db.collection('users').doc(deviceId);
      
      const userData = {
        miroId: `MIRO-TEST${1000 + i}`,
        balance,
        tier,
        bonusRate: TIER_BONUS_RATES[tier as keyof typeof TIER_BONUS_RATES],
        currentStreak: streak,
        longestStreak: streak,
        lastCheckInDate: new Date().toISOString().split('T')[0],
        totalEarned: balance + totalSpent,
        totalPurchased: Math.floor(totalSpent * 0.3),
        
        milestones: {
          totalSpent,
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
          date: new Date().toISOString().split('T')[0],
          count: Math.floor(Math.random() * 3),
        },
        
        dailyClaim: {
          lastClaimDate: new Date().toISOString().split('T')[0],
        },
        
        promotions: {
          welcomeOfferClaimed: false,
          welcomeBackClaimed: false,
          tierPromoClaimed: {},
          tierRewardClaimed: {},
        },
        
        isBanned: false,
        createdAt: FieldValue.serverTimestamp(),
        lastUpdated: FieldValue.serverTimestamp(),
      };

      batch.set(userRef, userData);
      createdUsers.push(deviceId);
      batchCount++;

      // Commit batch every 500 writes (Firestore limit)
      if (batchCount === 500) {
        await batch.commit();
        batchCount = 0;
      }
    }

    // Commit remaining writes
    if (batchCount > 0) {
      await batch.commit();
    }

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'bulk_create_test_users',
      details: {
        count,
        tierDistribution: distribution,
        createdUserIds: createdUsers.slice(0, 10), // Log first 10 only
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `${count} test users created successfully`,
      createdCount: count,
      sampleUserIds: createdUsers.slice(0, 5),
    });
  } catch (error) {
    console.error('Bulk create users error:', error);
    return NextResponse.json(
      { error: 'Failed to create test users' },
      { status: 500 }
    );
  }
}
