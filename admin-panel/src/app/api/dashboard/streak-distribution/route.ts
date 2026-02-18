import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Count users by tier
    const tiers = ['none', 'bronze', 'silver', 'gold', 'diamond'];
    const distribution: Record<string, number> = {};

    for (const tier of tiers) {
      const snapshot = await db
        .collection('users')
        .where('tier', '==', tier)
        .count()
        .get();
      distribution[tier] = snapshot.data().count;
    }

    return NextResponse.json({
      success: true,
      distribution: [
        { tier: 'Starter', count: distribution.none || 0 },
        { tier: 'Bronze', count: distribution.bronze || 0 },
        { tier: 'Silver', count: distribution.silver || 0 },
        { tier: 'Gold', count: distribution.gold || 0 },
        { tier: 'Diamond', count: distribution.diamond || 0 },
      ],
    });
  } catch (error: any) {
    console.error('Error fetching streak distribution:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
