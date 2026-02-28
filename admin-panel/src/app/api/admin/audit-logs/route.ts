import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '100');
    const offset = parseInt(searchParams.get('offset') || '0');
    const action = searchParams.get('action'); // Filter by action type
    const targetUserId = searchParams.get('targetUserId'); // Filter by target user

    let query = db.collection('adminLogs').orderBy('timestamp', 'desc');

    if (action) {
      query = query.where('action', '==', action);
    }

    if (targetUserId) {
      query = query.where('targetUserId', '==', targetUserId);
    }

    const snapshot = await query.limit(limit + offset).get();

    const allLogs = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        action: data.action,
        adminUid: data.adminUid || 'unknown',
        adminEmail: data.adminEmail || 'unknown',
        targetUserId: data.targetUserId || null,
        targetMiroId: data.targetMiroId || null,
        previousState: data.previousState || null,
        newState: data.newState || null,
        details: data.details || null,
        timestamp: data.timestamp?.toDate?.()?.toISOString() || null,
        ipAddress: data.ipAddress || null,
      };
    });

    // Apply pagination
    const logs = allLogs.slice(offset, offset + limit);
    const hasMore = allLogs.length > offset + limit;

    return NextResponse.json({
      success: true,
      logs,
      pagination: {
        total: allLogs.length,
        limit,
        offset,
        hasMore,
      },
    });
  } catch (error) {
    console.error('Get audit logs error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch audit logs' },
      { status: 500 }
    );
  }
}
