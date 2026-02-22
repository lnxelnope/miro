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
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const previousMilestones = userData.milestones || {};

    // Reset milestones but keep totalSpent
    const resetMilestones = {
      'milestones.claimedMilestones': [],
      'milestones.nextMilestoneIndex': 0,
      lastUpdated: FieldValue.serverTimestamp(),
    };

    await userRef.update(resetMilestones);

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'reset_milestones',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      previousState: {
        claimedMilestones: previousMilestones.claimedMilestones || [],
        nextMilestoneIndex: previousMilestones.nextMilestoneIndex || 0,
      },
      newState: {
        claimedMilestones: [],
        nextMilestoneIndex: 0,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: 'Milestones reset successfully (totalSpent preserved)',
    });
  } catch (error) {
    console.error('Reset milestones error:', error);
    return NextResponse.json(
      { error: 'Failed to reset milestones' },
      { status: 500 }
    );
  }
}
