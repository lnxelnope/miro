import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get last 20 transactions
    const transactionsSnapshot = await db
      .collection('transactions')
      .orderBy('createdAt', 'desc')
      .limit(20)
      .get();

    const activities = await Promise.all(
      transactionsSnapshot.docs.map(async (doc: any) => {
        const data = doc.data();
        
        // Get user info
        let userName = 'Unknown User';
        let miroId = '';
        if (data.userId) {
          const userDoc = await db.collection('users').doc(data.userId).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            userName = userData?.displayName || userData?.email || 'User';
            miroId = userData?.miroId || '';
          }
        }

        return {
          id: doc.id,
          type: data.type,
          amount: data.amount,
          description: data.description || '',
          userName,
          miroId,
          createdAt: data.createdAt?.toDate().toISOString(),
        };
      })
    );

    return NextResponse.json({ data: activities });
  } catch (error) {
    console.error('Recent activities error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch recent activities' },
      { status: 500 }
    );
  }
}
