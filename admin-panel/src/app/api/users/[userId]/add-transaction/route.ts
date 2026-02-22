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
    const { type, amount, source, note } = body;

    if (!type || !['earn', 'spend'].includes(type)) {
      return NextResponse.json(
        { error: 'Invalid type. Must be: earn or spend' },
        { status: 400 }
      );
    }

    if (typeof amount !== 'number' || amount <= 0) {
      return NextResponse.json(
        { error: 'Invalid amount' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const currentBalance = userData.balance || 0;
    
    // Calculate new balance
    const energyChange = type === 'earn' ? amount : -amount;
    const newBalance = Math.max(0, currentBalance + energyChange);

    // Update balance
    const updateData: any = {
      balance: newBalance,
      lastUpdated: FieldValue.serverTimestamp(),
    };

    // If spending, also update totalSpent for milestones
    if (type === 'spend') {
      const currentTotalSpent = userData.milestones?.totalSpent || 0;
      updateData['milestones.totalSpent'] = currentTotalSpent + amount;
    }

    await userRef.update(updateData);

    // Create transaction record
    await db.collection('transactions').add({
      deviceId: userId,
      miroId: userData.miroId || '',
      type: source || (type === 'earn' ? 'manual_earn' : 'manual_spend'),
      amount: energyChange,
      balanceAfter: newBalance,
      description: note || `Manual ${type} by admin`,
      metadata: {
        source: source || 'admin_manual',
        note: note || '',
        adminAction: true,
      },
      createdAt: FieldValue.serverTimestamp(),
    });

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'add_transaction',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      details: {
        type,
        amount: energyChange,
        source: source || 'manual',
        note: note || '',
        previousBalance: currentBalance,
        newBalance,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `Transaction added: ${energyChange > 0 ? '+' : ''}${energyChange}E`,
      transaction: {
        type,
        amount: energyChange,
        balanceAfter: newBalance,
      },
    });
  } catch (error) {
    console.error('Add transaction error:', error);
    return NextResponse.json(
      { error: 'Failed to add transaction' },
      { status: 500 }
    );
  }
}
