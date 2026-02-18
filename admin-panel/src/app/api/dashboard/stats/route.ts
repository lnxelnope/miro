import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    // Verify authentication
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Count total users
    const usersSnapshot = await db.collection('users').count().get();
    const totalUsers = usersSnapshot.data().count;

    // Count active users (checked in last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const sevenDaysAgoStr = sevenDaysAgo.toISOString().split('T')[0]; // YYYY-MM-DD format
    
    const activeUsersSnapshot = await db
      .collection('users')
      .where('lastCheckInDate', '>=', sevenDaysAgoStr)
      .count()
      .get();
    const activeUsers = activeUsersSnapshot.data().count;

    // Sum total revenue (from purchase transactions)
    const purchasesSnapshot = await db
      .collection('transactions')
      .where('type', '==', 'purchase')
      .get();
    
    let totalRevenue = 0;
    purchasesSnapshot.docs.forEach((doc: any) => {
      const data = doc.data();
      // Calculate revenue from metadata.totalEnergy or amount
      // Assuming each energy unit = 1 THB (adjust if needed)
      const energyAmount = data.metadata?.totalEnergy || data.amount || 0;
      totalRevenue += energyAmount;
    });

    // Count active subscribers
    const subscribersSnapshot = await db
      .collection('users')
      .where('subscription.status', '==', 'active')
      .count()
      .get();
    const activeSubscribers = subscribersSnapshot.data().count;

    return NextResponse.json({
      success: true,
      stats: {
        totalUsers,
        activeUsers,
        totalRevenue,
        activeSubscribers,
      },
    });
  } catch (error: any) {
    console.error('Error fetching stats:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
