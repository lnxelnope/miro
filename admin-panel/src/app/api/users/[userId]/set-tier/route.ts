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

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { userId } = await params;
    const body = await request.json();
    const { tier } = body;

    if (!tier || !['starter', 'bronze', 'silver', 'gold', 'diamond'].includes(tier)) {
      return NextResponse.json(
        { error: 'Invalid tier. Must be: starter, bronze, silver, gold, or diamond' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const previousTier = userData.tier || 'starter';
    const previousTotalSpent = userData.milestones?.totalSpent || 0;

    // Calculate required totalSpent for this tier
    const requiredTotalSpent = TIER_THRESHOLDS[tier as keyof typeof TIER_THRESHOLDS];
    const bonusRate = TIER_BONUS_RATES[tier as keyof typeof TIER_BONUS_RATES];

    // Update user tier and related fields
    await userRef.update({
      tier: tier,
      bonusRate: bonusRate,
      'milestones.totalSpent': requiredTotalSpent,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'set_tier',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      previousState: {
        tier: previousTier,
        totalSpent: previousTotalSpent,
      },
      newState: {
        tier: tier,
        totalSpent: requiredTotalSpent,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `User tier updated to ${tier}`,
      tier,
      bonusRate,
      totalSpent: requiredTotalSpent,
    });
  } catch (error) {
    console.error('Set tier error:', error);
    return NextResponse.json(
      { error: 'Failed to set tier' },
      { status: 500 }
    );
  }
}
