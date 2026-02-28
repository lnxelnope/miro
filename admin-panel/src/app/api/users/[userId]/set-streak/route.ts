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
    if (authError) return authError;

    const { userId } = await params;
    const body = await request.json();
    const { streak, lastCheckInDate } = body;

    if (typeof streak !== 'number' || streak < 0) {
      return NextResponse.json(
        { error: 'Invalid streak value' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const previousStreak = userData.currentStreak || 0;
    const previousLastCheckIn = userData.lastCheckInDate || '';

    // Format date to YYYY-MM-DD
    const dateToSet = lastCheckInDate || new Date().toISOString().split('T')[0];

    // Update streak
    const updateData: any = {
      currentStreak: streak,
      lastCheckInDate: dateToSet,
      lastUpdated: FieldValue.serverTimestamp(),
    };

    // Update longestStreak if current exceeds it
    if (streak > (userData.longestStreak || 0)) {
      updateData.longestStreak = streak;
    }

    // Also update dailyClaim field (V3)
    updateData['dailyClaim.lastClaimDate'] = dateToSet;

    await userRef.update(updateData);

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'set_streak',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      previousState: {
        streak: previousStreak,
        lastCheckInDate: previousLastCheckIn,
      },
      newState: {
        streak: streak,
        lastCheckInDate: dateToSet,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `Streak updated to ${streak} days`,
      streak,
      lastCheckInDate: dateToSet,
    });
  } catch (error) {
    console.error('Set streak error:', error);
    return NextResponse.json(
      { error: 'Failed to set streak' },
      { status: 500 }
    );
  }
}
