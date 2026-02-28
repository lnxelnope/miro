import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Count active subscribers (subscription.status === 'active')
    const activeSnapshot = await db
      .collection('users')
      .where('subscription.status', '==', 'active')
      .get();

    const activeSubscribers = activeSnapshot.size;

    // Calculate MRR (assuming ฿79/month per subscriber)
    const MONTHLY_PRICE = 79;
    const mrr = activeSubscribers * MONTHLY_PRICE;

    // Count expiring soon (7 days)
    const sevenDaysFromNow = new Date();
    sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);

    const expiringSoon = activeSnapshot.docs.filter((doc: any) => {
      const data = doc.data();
      const expiryDate = data.subscription?.expiryDate?.toDate?.();
      return expiryDate && expiryDate <= sevenDaysFromNow && expiryDate > new Date();
    });

    // Count churned (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const churnedSnapshot = await db
      .collection('users')
      .where('subscription.status', 'in', ['expired', 'cancelled'])
      .get();

    const churnedLast30Days = churnedSnapshot.docs.filter((doc: any) => {
      const data = doc.data();
      const expiryDate = data.subscription?.expiryDate?.toDate?.();
      return expiryDate && expiryDate >= thirtyDaysAgo;
    });

    const churnedCount = churnedLast30Days.length;
    const churnRate = activeSubscribers > 0
      ? ((churnedCount / (activeSubscribers + churnedCount)) * 100).toFixed(1)
      : '0';

    return NextResponse.json({
      success: true,
      metrics: {
        mrr,
        activeSubscribers,
        expiringSoon: expiringSoon.length,
        churnRate: parseFloat(churnRate),
      },
    });
  } catch (error: any) {
    console.error('Error fetching subscription metrics:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
