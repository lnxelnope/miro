import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const query = request.nextUrl.searchParams.get('q') || '';
    
    if (!query) {
      return NextResponse.json({ error: 'Missing query' }, { status: 400 });
    }

    // Try search by MiRO ID first
    let userDoc: any = null;
    const miroIdQuery = await db
      .collection('users')
      .where('miroId', '==', query)
      .limit(1)
      .get();

    if (!miroIdQuery.empty) {
      userDoc = miroIdQuery.docs[0];
    } else {
      // Try search by deviceId
      const deviceDoc = await db.collection('users').doc(query).get();
      if (deviceDoc.exists) {
        userDoc = deviceDoc;
      }
    }

    if (!userDoc || !userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data();
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
        isBanned: userData.isBanned || false,
        createdAt: userData.createdAt?.toDate?.()?.toISOString() || null,
        lastUpdated: userData.lastUpdated?.toDate?.()?.toISOString() || null,
      },
    });
  } catch (error: any) {
    console.error('Error searching user:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
