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

    // Get total users count
    const usersSnapshot = await db.collection('users').count().get();
    const totalUsers = usersSnapshot.data().count;

    // Get active users (logged in last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const activeUsersSnapshot = await db
      .collection('users')
      .where('lastActiveAt', '>=', sevenDaysAgo)
      .count()
      .get();
    const activeUsers7d = activeUsersSnapshot.data().count;

    // Get active users (logged in last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const activeUsers30dSnapshot = await db
      .collection('users')
      .where('lastActiveAt', '>=', thirtyDaysAgo)
      .count()
      .get();
    const activeUsers30d = activeUsers30dSnapshot.data().count;

    // Get total energy consumed (sum of all transactions)
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('amount', '<', 0) // Only spending transactions
      .get();
    
    const totalEnergyConsumed = transactionsSnapshot.docs.reduce(
      (sum: number, doc: any) => sum + Math.abs(doc.data().amount),
      0
    );

    // Get total AI analyses count
    const aiAnalysesSnapshot = await db
      .collection('transactions')
      .where('type', '==', 'ai_analysis')
      .count()
      .get();
    const totalAiAnalyses = aiAnalysesSnapshot.data().count;

    // Calculate averages
    const avgEnergyPerUser = totalUsers > 0 ? totalEnergyConsumed / totalUsers : 0;
    const avgAiPerUser = totalUsers > 0 ? totalAiAnalyses / totalUsers : 0;

    return NextResponse.json({
      users: {
        total: totalUsers,
        active7d: activeUsers7d,
        active30d: activeUsers30d,
      },
      energy: {
        totalConsumed: totalEnergyConsumed,
        avgPerUser: Math.round(avgEnergyPerUser),
      },
      ai: {
        totalAnalyses: totalAiAnalyses,
        avgPerUser: Math.round(avgAiPerUser * 10) / 10, // Round to 1 decimal
      },
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard stats' },
      { status: 500 }
    );
  }
}
