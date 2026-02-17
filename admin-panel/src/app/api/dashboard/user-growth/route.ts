import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get user registrations for last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    thirtyDaysAgo.setHours(0, 0, 0, 0);

    const usersSnapshot = await db
      .collection('users')
      .where('createdAt', '>=', thirtyDaysAgo)
      .orderBy('createdAt', 'asc')
      .get();

    // Group by date
    const growthData: { [key: string]: number } = {};
    
    usersSnapshot.docs.forEach((doc: any) => {
      const createdAt = doc.data().createdAt?.toDate();
      if (createdAt) {
        const dateKey = createdAt.toISOString().split('T')[0]; // YYYY-MM-DD
        growthData[dateKey] = (growthData[dateKey] || 0) + 1;
      }
    });

    // Convert to array with cumulative count
    const sortedDates = Object.keys(growthData).sort();
    let cumulative = 0;
    const chartData = sortedDates.map((date) => {
      cumulative += growthData[date];
      return {
        date,
        count: growthData[date],
        cumulative,
      };
    });

    return NextResponse.json({ data: chartData });
  } catch (error) {
    console.error('User growth error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user growth data' },
      { status: 500 }
    );
  }
}
