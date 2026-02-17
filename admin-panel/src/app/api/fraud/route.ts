import { NextRequest, NextResponse } from 'next/server';
import { checkAuth } from '@/lib/auth';
import { db } from '@/lib/firebase-admin';
import * as admin from 'firebase-admin';

/**
 * GET /api/fraud
 * Get fraud alerts with optional status filter
 */
export async function GET(request: NextRequest) {
  try {
    const authCheck = await checkAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status') || 'pending';

    let query: admin.firestore.Query = db
      .collection('fraud_alerts')
      .orderBy('createdAt', 'desc')
      .limit(100);

    if (status !== 'all') {
      query = query.where('status', '==', status);
    }

    const snapshot = await query.get();
    const alerts = snapshot.docs.map((doc: any) => {
      const data = doc.data();
      return {
        id: doc.id,
        deviceId: data.deviceId,
        action: data.action,
        reason: data.reason,
        severity: data.severity || 'medium',
        metadata: data.metadata || {},
        status: data.status || 'pending',
        createdAt: data.createdAt?.toDate().toISOString(),
        reviewedBy: data.reviewedBy,
        reviewedAt: data.reviewedAt?.toDate().toISOString(),
        reviewReason: data.reviewReason,
      };
    });

    return NextResponse.json({ success: true, alerts });
  } catch (error: any) {
    console.error('Get fraud alerts error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch fraud alerts' },
      { status: 500 }
    );
  }
}
