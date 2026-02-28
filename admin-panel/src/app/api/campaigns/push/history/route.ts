import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';

export async function GET(req: NextRequest) {
  try {
    // Get campaigns ordered by createdAt (newest first)
    const snapshot = await db
      .collection('push_campaigns')
      .orderBy('createdAt', 'desc')
      .limit(50) // Limit to last 50 campaigns
      .get();

    const history = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title,
        body: data.body,
        targetSegment: data.targetSegment,
        sentCount: data.sentCount || 0,
        failedCount: data.failedCount || 0,
        totalTokens: data.totalTokens || 0,
        createdAt: data.createdAt,
        status: data.status || 'success',
      };
    });

    return NextResponse.json({
      success: true,
      history,
    });
  } catch (error: any) {
    console.error('Error fetching campaign history:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to fetch campaign history',
      },
      { status: 500 }
    );
  }
}
