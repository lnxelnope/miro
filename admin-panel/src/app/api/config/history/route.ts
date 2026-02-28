import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get last 50 config changes
    const historySnapshot = await db
      .collection('config_history')
      .orderBy('timestamp', 'desc')
      .limit(50)
      .get();

    const history = historySnapshot.docs.map((doc: any) => {
      const data = doc.data();
      return {
        id: doc.id,
        section: data.section,
        changes: data.changes,
        timestamp: data.timestamp?.toDate().toISOString(),
        admin: data.admin,
      };
    });

    return NextResponse.json({ history });
  } catch (error) {
    console.error('Get config history error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch config history' },
      { status: 500 }
    );
  }
}
