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
    const body = await request.json();
    const { banned, reason } = body;

    // Update user ban status
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      isBanned: banned,
      banReason: banned ? reason : null,
      bannedAt: banned ? new Date() : null,
    });

    return NextResponse.json({
      success: true,
      message: banned ? 'User banned successfully' : 'User unbanned successfully',
    });
  } catch (error) {
    console.error('Ban user error:', error);
    return NextResponse.json(
      { error: 'Failed to update ban status' },
      { status: 500 }
    );
  }
}
