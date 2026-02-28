import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

// PATCH: อัปเดต status (active/paused)
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const body = await request.json();
    const { status } = body;

    if (!['active', 'paused'].includes(status)) {
      return NextResponse.json(
        { success: false, error: 'Status must be "active" or "paused"' },
        { status: 400 }
      );
    }

    const docRef = db.collection('seasonal_quests').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Quest not found' },
        { status: 404 }
      );
    }

    await docRef.update({ status });

    return NextResponse.json({ success: true, id, status });
  } catch (error: any) {
    console.error('Error updating seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// DELETE: ลบ quest
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const docRef = db.collection('seasonal_quests').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Quest not found' },
        { status: 404 }
      );
    }

    await docRef.delete();

    return NextResponse.json({ success: true, id });
  } catch (error: any) {
    console.error('Error deleting seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
