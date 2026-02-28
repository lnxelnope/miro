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
    const body = await request.json();
    const { amount, reason } = body;

    if (typeof amount !== 'number' || amount === 0) {
      return NextResponse.json(
        { error: 'Invalid amount' },
        { status: 400 }
      );
    }

    // Update user balance
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      balance: FieldValue.increment(amount),
    });

    // Create transaction record
    await db.collection('transactions').add({
      userId,
      type: 'admin_adjustment',
      amount,
      description: reason || 'Admin balance adjustment',
      createdAt: FieldValue.serverTimestamp(),
      adjustedBy: 'admin', // In production, track which admin did this
    });

    // Get updated user data
    const userDoc = await userRef.get();
    const userData = userDoc.data();

    return NextResponse.json({
      success: true,
      newBalance: userData?.balance || 0,
    });
  } catch (error) {
    console.error('Adjust balance error:', error);
    return NextResponse.json(
      { error: 'Failed to adjust balance' },
      { status: 500 }
    );
  }
}
