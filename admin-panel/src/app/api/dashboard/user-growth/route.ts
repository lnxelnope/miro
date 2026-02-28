import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const days = parseInt(request.nextUrl.searchParams.get('days') || '30');

    // Get user creation dates for last N days
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const usersSnapshot = await db
      .collection('users')
      .where('createdAt', '>=', startDate)
      .orderBy('createdAt', 'asc')
      .get();

    // Group by date
    const growthByDate: Record<string, number> = {};
    
    usersSnapshot.docs.forEach((doc: any) => {
      const data = doc.data();
      const date = data.createdAt?.toDate?.();
      if (date) {
        const dateStr = date.toISOString().split('T')[0];
        growthByDate[dateStr] = (growthByDate[dateStr] || 0) + 1;
      }
    });

    // Convert to array
    const growth = Object.entries(growthByDate).map(([date, count]) => ({
      date,
      users: count,
    }));

    return NextResponse.json({
      success: true,
      growth,
    });
  } catch (error: any) {
    console.error('Error fetching user growth:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
