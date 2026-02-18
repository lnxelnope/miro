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
    const { amount, reason } = await request.json();

    if (!amount || !reason) {
      return NextResponse.json(
        { error: 'Missing amount or reason' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const newBalance = (userData.balance || 0) + amount;

    // Update balance
    await userRef.update({
      balance: newBalance,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    // Log transaction
    await db.collection('transactions').add({
      deviceId: userId,
      miroId: userData.miroId || 'unknown',
      type: 'admin_topup',
      amount,
      balanceAfter: newBalance,
      description: `Admin top-up: ${reason}`,
      metadata: {
        adminAction: true,
        reason,
      },
      createdAt: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      newBalance,
    });
  } catch (error: any) {
    console.error('Error topping up:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
