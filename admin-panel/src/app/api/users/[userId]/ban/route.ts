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
    const { isBanned, reason } = await request.json();

    if (isBanned === undefined || !reason) {
      return NextResponse.json(
        { error: 'Missing isBanned or reason' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    await userRef.update({
      isBanned,
      banReason: isBanned ? reason : null,
      banDate: isBanned ? FieldValue.serverTimestamp() : null,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating ban status:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
