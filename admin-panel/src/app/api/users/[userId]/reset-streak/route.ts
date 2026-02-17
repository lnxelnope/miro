import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

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

    // Reset streak to zero
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      'gamificationState.currentStreak': 0,
      'gamificationState.streakTier': 'none',
      'gamificationState.lastCheckInDate': null,
    });

    return NextResponse.json({
      success: true,
      message: 'Streak reset successfully',
    });
  } catch (error) {
    console.error('Reset streak error:', error);
    return NextResponse.json(
      { error: 'Failed to reset streak' },
      { status: 500 }
    );
  }
}
