import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const status = request.nextUrl.searchParams.get('status') || 'active';
    const limit = parseInt(request.nextUrl.searchParams.get('limit') || '50');

    let query: any = db.collection('users');

    if (status !== 'all') {
      query = query.where('subscription.status', '==', status);
    } else {
      // For 'all', get users with any subscription status
      query = query.where('subscription.status', '!=', null);
    }

    const snapshot = await query.limit(limit).get();

    const subscribers = snapshot.docs
      .map((doc: any) => {
        const data = doc.data();
        const gamification = data.gamificationState || {};
        return {
          deviceId: doc.id,
          miroId: data.miroId || '',
          subscriptionStatus: data.subscription?.status || 'none',
          subscriptionExpiryDate: data.subscription?.expiryDate?.toDate?.()?.toISOString() || null,
          balance: data.balance || 0,
          tier: gamification.streakTier || data.tier || 'none',
          currentStreak: gamification.currentStreak || data.currentStreak || 0,
        };
      })
      .filter((sub: any) => sub.subscriptionStatus !== 'none')
      .sort((a: any, b: any) => {
        // Sort by expiry date descending
        if (!a.subscriptionExpiryDate) return 1;
        if (!b.subscriptionExpiryDate) return -1;
        return new Date(b.subscriptionExpiryDate).getTime() - new Date(a.subscriptionExpiryDate).getTime();
      });

    return NextResponse.json({
      success: true,
      subscribers,
      total: subscribers.length,
    });
  } catch (error: any) {
    console.error('Error fetching subscribers:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
