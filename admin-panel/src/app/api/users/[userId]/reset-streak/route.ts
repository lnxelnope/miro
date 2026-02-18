import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

import { FieldValue } from 'firebase-admin/firestore';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const { userId } = await params;
    const { reason } = await request.json();

    if (!reason) {
      return NextResponse.json({ error: 'Missing reason' }, { status: 400 });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    await userRef.update({
      'gamificationState.currentStreak': 0,
      'gamificationState.streakTier': 'none',
      'gamificationState.lastCheckInDate': null,
      tier: 'none',
      bonusRate: 0,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error resetting streak:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
