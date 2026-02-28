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
    const body = await request.json().catch(() => ({}));
    const deleteTransactions = body.deleteTransactions !== false;

    let deletedTransactions = 0;

    if (deleteTransactions) {
      const txSnapshot = await db
        .collection('transactions')
        .where('deviceId', '==', userId)
        .get();

      const batch = db.batch();
      txSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        deletedTransactions++;
      });

      if (deletedTransactions > 0) {
        await batch.commit();
      }
    }

    await userRef.delete();

    await db.collection('adminLogs').add({
      action: 'factory_reset',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      details: {
        deletedTransactions,
        previousBalance: userData.balance || 0,
        previousTier: userData.tier || 'none',
        previousStreak: userData.currentStreak || 0,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `User document deleted. ${deletedTransactions} transactions removed. Next app launch will create a fresh account.`,
      deletedTransactions,
    });
  } catch (error) {
    console.error('Factory reset error:', error);
    return NextResponse.json(
      { error: 'Failed to factory reset user' },
      { status: 500 }
    );
  }
}
