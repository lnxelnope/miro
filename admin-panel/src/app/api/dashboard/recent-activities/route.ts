import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const limit = parseInt(request.nextUrl.searchParams.get('limit') || '20');

    const transactionsSnapshot = await db
      .collection('transactions')
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const activities = transactionsSnapshot.docs.map((doc: any) => {
      const data = doc.data();
      return {
        id: doc.id,
        type: data.type,
        amount: data.amount,
        description: data.description || '',
        miroId: data.miroId || 'unknown',
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      };
    });

    return NextResponse.json({
      success: true,
      activities,
    });
  } catch (error: any) {
    console.error('Error fetching recent activities:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
