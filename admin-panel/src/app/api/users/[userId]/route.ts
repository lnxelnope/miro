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

    // Debug: Log user data structure
    console.log('📊 User data for', userId, ':', {
      balance: userData.balance,
      tier: userData.tier,
      gamificationState: userData.gamificationState,
      subscription: userData.subscription,
      hasBalance: 'balance' in userData,
    });

    // Get user transactions (last 50) - WITHOUT orderBy to avoid index requirement
    let transactions: any[] = [];
    try {
      // Try deviceId first (no index needed without orderBy)
      let transactionsSnapshot = await db
        .collection('transactions')
        .where('deviceId', '==', userId)
        .limit(100)
        .get();
      
      // Fallback to userId if deviceId query returns empty
      if (transactionsSnapshot.empty) {
        transactionsSnapshot = await db
          .collection('transactions')
          .where('userId', '==', userId)
          .limit(100)
          .get();
      }

      // Map and sort in code instead of Firestore
      transactions = transactionsSnapshot.docs
        .map((doc: any) => {
          const data = doc.data();
          return {
            id: doc.id,
            type: data.type,
            amount: data.amount,
            description: data.description || '',
            miroId: data.miroId || '',
            createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
            createdAtTimestamp: data.createdAt?.toMillis() || 0,
          };
        })
        .sort((a: any, b: any) => b.createdAtTimestamp - a.createdAtTimestamp)
        .slice(0, 50)
        .map(({ createdAtTimestamp, ...rest }: any) => rest);
    } catch (txError) {
      console.warn('Transaction fetch error:', txError);
      // Continue without transactions
    }

    const gamification = userData.gamificationState || {};

    return NextResponse.json({
      success: true,
      user: {
        deviceId: userDoc.id,
        miroId: userData.miroId || '',
        balance: userData.balance || 0,
        tier: gamification.streakTier || userData.tier || 'none',
        currentStreak: gamification.currentStreak || userData.currentStreak || 0,
        longestStreak: gamification.longestStreak || userData.longestStreak || 0,
        totalSpent: userData.lifetimeEnergySpent || userData.totalSpent || 0,
        totalPurchased: userData.totalPurchased || 0,
        totalEarned: userData.lifetimeEnergyEarned || userData.totalEarned || 0,
        isSubscriber: userData.subscription?.status === 'active' || userData.isSubscriber || false,
        subscriptionStatus: userData.subscription?.status || userData.subscriptionStatus,
        subscriptionExpiryDate: userData.subscription?.expiryDate?.toDate?.()?.toISOString() || null,
        isBanned: userData.isBanned || false,
        banReason: userData.banReason || null,
        challenges: userData.challenges || null,
        milestones: userData.milestones || {},
        promotions: userData.promotions || {},
        createdAt: userData.createdAt?.toDate?.()?.toISOString() || null,
        lastUpdated: userData.lastUpdated?.toDate?.()?.toISOString() || null,
      },
      transactions,
    });
  } catch (error) {
    console.error('User detail error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user details' },
      { status: 500 }
    );
  }
}
