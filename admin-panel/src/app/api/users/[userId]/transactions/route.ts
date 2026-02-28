import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { userId } = await params;
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '100');
    const offset = parseInt(searchParams.get('offset') || '0');

    // Get transactions
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('deviceId', '==', userId)
      .limit(limit + offset)
      .get();

    // Map and sort transactions
    const allTransactions = transactionsSnapshot.docs
      .map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          type: data.type,
          amount: data.amount,
          balanceAfter: data.balanceAfter,
          description: data.description || '',
          source: data.metadata?.source || data.type,
          note: data.metadata?.note || '',
          createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
          createdAtTimestamp: data.createdAt?.toMillis() || 0,
        };
      })
      .sort((a, b) => b.createdAtTimestamp - a.createdAtTimestamp);

    // Apply pagination
    const transactions = allTransactions.slice(offset, offset + limit);
    const hasMore = allTransactions.length > offset + limit;

    // Calculate summary stats
    const totalEarned = allTransactions
      .filter(t => t.amount > 0)
      .reduce((sum, t) => sum + t.amount, 0);
    
    const totalSpent = allTransactions
      .filter(t => t.amount < 0)
      .reduce((sum, t) => sum + Math.abs(t.amount), 0);

    return NextResponse.json({
      success: true,
      transactions: transactions.map(({ createdAtTimestamp, ...rest }) => rest),
      pagination: {
        total: allTransactions.length,
        limit,
        offset,
        hasMore,
      },
      summary: {
        totalEarned,
        totalSpent,
        netBalance: totalEarned - totalSpent,
      },
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch transactions' },
      { status: 500 }
    );
  }
}
