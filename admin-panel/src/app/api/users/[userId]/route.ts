import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const { userId } = await params;

    // Get user document
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const userData = userDoc.data()!;

    // Get user transactions (last 50)
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const transactions = transactionsSnapshot.docs.map((doc: any) => {
      const data = doc.data();
      return {
        id: doc.id,
        type: data.type,
        amount: data.amount,
        description: data.description,
        createdAt: data.createdAt?.toDate().toISOString(),
      };
    });

    // Format user data
    const user = {
      id: userDoc.id,
      miroId: userData.miroId || '',
      email: userData.email || '',
      displayName: userData.displayName || '',
      phoneNumber: userData.phoneNumber || '',
      balance: userData.balance || 0,
      createdAt: userData.createdAt?.toDate().toISOString() || null,
      lastActiveAt: userData.lastActiveAt?.toDate().toISOString() || null,
      isBanned: userData.isBanned || false,
      
      // Gamification state
      gamification: {
        streakTier: userData.gamificationState?.streakTier || 'none',
        currentStreak: userData.gamificationState?.currentStreak || 0,
        lastCheckInDate: userData.gamificationState?.lastCheckInDate || null,
        longestStreak: userData.gamificationState?.longestStreak || 0,
        totalCheckIns: userData.gamificationState?.totalCheckIns || 0,
      },

      // Weekly challenge
      weeklyChallenge: userData.weeklyChallenge || null,

      // Milestones
      milestones: userData.milestones || {},

      // Referral
      referralCode: userData.referralCode || null,
      referredBy: userData.referredBy || null,
      referralCount: userData.referralStats?.totalReferred || 0,

      // Stats
      lifetimeEnergyEarned: userData.lifetimeEnergyEarned || 0,
      lifetimeEnergySpent: userData.lifetimeEnergySpent || 0,
      totalAiAnalyses: userData.totalAiAnalyses || 0,

      transactions,
    };

    return NextResponse.json(user);
  } catch (error) {
    console.error('User detail error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user details' },
      { status: 500 }
    );
  }
}
