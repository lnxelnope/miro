import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get all users with gamification state
    const usersSnapshot = await db
      .collection('users')
      .select('gamificationState')
      .get();

    // Count by tier
    const tierCounts = {
      bronze: 0,
      silver: 0,
      gold: 0,
      diamond: 0,
      none: 0,
    };

    usersSnapshot.docs.forEach((doc: any) => {
      const gamification = doc.data().gamificationState;
      const tier = gamification?.streakTier || 'none';
      tierCounts[tier as keyof typeof tierCounts]++;
    });

    const chartData = [
      { name: 'Bronze', value: tierCounts.bronze, color: '#cd7f32' },
      { name: 'Silver', value: tierCounts.silver, color: '#c0c0c0' },
      { name: 'Gold', value: tierCounts.gold, color: '#ffd700' },
      { name: 'Diamond', value: tierCounts.diamond, color: '#b9f2ff' },
      { name: 'No Streak', value: tierCounts.none, color: '#9ca3af' },
    ];

    return NextResponse.json({ data: chartData });
  } catch (error) {
    console.error('Streak distribution error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch streak distribution' },
      { status: 500 }
    );
  }
}
