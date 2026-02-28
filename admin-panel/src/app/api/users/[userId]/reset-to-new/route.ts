import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { userId } = await params;
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const previousState = {
      balance: userData.balance || 0,
      tier: userData.tier || 'none',
      totalSpent: userData.milestones?.totalSpent || 0,
    };

    // Reset to new user state
    const resetData = {
      balance: 0,
      tier: 'none',
      currentStreak: 0,
      longestStreak: 0,
      lastCheckInDate: '',
      totalEarned: 0,
      totalPurchased: 0,
      bonusRate: 0,
      
      // Reset V3 fields
      offers: {
        firstPurchaseClaimed: false,
        firstPurchaseAvailable: false,
        firstPurchaseExpiry: null,
        firstPurchaseClaimedAt: null,
        welcomeBonusClaimed: false,
        welcomeBonusAvailable: false,
        welcomeBonusExpiry: null,
        welcomeBonusClaimedAt: null,
      },
      
      milestones: {
        totalSpent: 0,
        claimedMilestones: [],
        nextMilestoneIndex: 0,
      },
      
      adViews: {
        date: '',
        count: 0,
      },
      
      dailyClaim: {
        lastClaimDate: '',
      },
      
      notifications: {
        offerExpirySent: {},
        lastStreakReminder: '',
      },
      
      // Reset old promotions structure
      promotions: {
        welcomeOfferClaimed: false,
        welcomeBackClaimed: false,
        tierPromoClaimed: {},
        tierPromoAt: {},
        tierRewardClaimed: {},
      },
      
      // Clear gamification state (old structure)
      gamificationState: FieldValue.delete(),
      
      lastUpdated: FieldValue.serverTimestamp(),
    };

    await userRef.update(resetData);

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'reset_user_to_new',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      previousState,
      newState: { balance: 0, tier: 'none', totalSpent: 0 },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: 'User reset to new state successfully',
      previousState,
    });
  } catch (error) {
    console.error('Reset to new error:', error);
    return NextResponse.json(
      { error: 'Failed to reset user' },
      { status: 500 }
    );
  }
}
