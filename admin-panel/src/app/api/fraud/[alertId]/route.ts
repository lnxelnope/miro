import { NextRequest, NextResponse } from 'next/server';
import { checkAuth } from '@/lib/auth';
import { db } from '@/lib/firebase-admin';
import * as admin from 'firebase-admin';

/**
 * POST /api/fraud/[alertId]
 * Review fraud alert (dismiss, confirm, or ban)
 */
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ alertId: string }> }
) {
  try {
    const authCheck = await checkAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { alertId } = await params;
    const body = await request.json();
    const { action, reason } = body; // action: 'dismiss' | 'confirm' | 'ban'

    if (!alertId || !action) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    const alertRef = db.collection('fraud_alerts').doc(alertId);
    const alertDoc = await alertRef.get();

    if (!alertDoc.exists) {
      return NextResponse.json(
        { error: 'Alert not found' },
        { status: 404 }
      );
    }

    const alertData = alertDoc.data()!;
    const deviceId = alertData.deviceId;

    // Update alert status
    const newStatus =
      action === 'ban'
        ? 'confirmed'
        : action === 'dismiss'
          ? 'dismissed'
          : 'reviewed';

    await alertRef.update({
      status: newStatus,
      reviewedBy: 'admin', // TODO: Get from auth token
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      reviewReason: reason || '',
    });

    // If ban action → ban user
    if (action === 'ban') {
      await db.collection('users').doc(deviceId).update({
        isBanned: true,
        banReason: reason || 'Fraud confirmed',
        banDate: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return NextResponse.json({
      success: true,
      message: `Alert ${action}ed successfully`,
    });
  } catch (error: any) {
    console.error('Review fraud alert error:', error);
    return NextResponse.json(
      { error: 'Failed to review fraud alert' },
      { status: 500 }
    );
  }
}
