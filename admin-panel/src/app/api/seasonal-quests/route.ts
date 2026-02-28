import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

// GET: ดึง seasonal quests ทั้งหมด (เรียงจากใหม่สุด)
export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const snapshot = await db
      .collection('seasonal_quests')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const quests = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate?.()?.toISOString() || null,
    }));

    return NextResponse.json({ success: true, quests });
  } catch (error: any) {
    console.error('Error fetching seasonal quests:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// POST: สร้าง seasonal quest ใหม่
export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const {
      title,
      description,
      icon,
      scheduleType,
      startDate,
      endDate,
      durationDays,
      claimType,
      rewardPerClaim,
    } = body;

    // ─── Validation ───
    if (!title || !title.trim()) {
      return NextResponse.json(
        { success: false, error: 'Title is required' },
        { status: 400 }
      );
    }

    if (!['fixed_date', 'duration'].includes(scheduleType)) {
      return NextResponse.json(
        { success: false, error: 'scheduleType must be "fixed_date" or "duration"' },
        { status: 400 }
      );
    }

    if (!['daily', 'one_time'].includes(claimType)) {
      return NextResponse.json(
        { success: false, error: 'claimType must be "daily" or "one_time"' },
        { status: 400 }
      );
    }

    if (!rewardPerClaim || rewardPerClaim < 1 || rewardPerClaim > 100) {
      return NextResponse.json(
        { success: false, error: 'rewardPerClaim must be 1-100' },
        { status: 400 }
      );
    }

    // ─── Calculate dates ───
    let finalStartDate: string;
    let finalEndDate: string;
    let finalDurationDays: number;

    if (scheduleType === 'fixed_date') {
      if (!startDate || !endDate) {
        return NextResponse.json(
          { success: false, error: 'startDate and endDate required for fixed_date' },
          { status: 400 }
        );
      }
      if (endDate <= startDate) {
        return NextResponse.json(
          { success: false, error: 'endDate must be after startDate' },
          { status: 400 }
        );
      }
      finalStartDate = startDate;
      finalEndDate = endDate;
      // Calculate duration for display
      const diffMs = new Date(endDate).getTime() - new Date(startDate).getTime();
      finalDurationDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24)) + 1;
    } else {
      // duration type
      if (!durationDays || durationDays < 1 || durationDays > 365) {
        return NextResponse.json(
          { success: false, error: 'durationDays must be 1-365' },
          { status: 400 }
        );
      }
      // Start = today (UTC+7)
      const now = new Date(Date.now() + 7 * 60 * 60 * 1000);
      finalStartDate = now.toISOString().split('T')[0];
      // End = start + durationDays - 1
      const end = new Date(now.getTime() + (durationDays - 1) * 24 * 60 * 60 * 1000);
      finalEndDate = end.toISOString().split('T')[0];
      finalDurationDays = durationDays;
    }

    // ─── Save ───
    const questData = {
      title: title.trim(),
      description: (description || '').trim(),
      icon: icon || '🎁',
      scheduleType,
      startDate: finalStartDate,
      endDate: finalEndDate,
      durationDays: finalDurationDays,
      claimType,
      rewardPerClaim,
      status: 'active',
      createdAt: Timestamp.now(),
      createdBy: 'admin',
    };

    const docRef = await db.collection('seasonal_quests').add(questData);

    return NextResponse.json({
      success: true,
      id: docRef.id,
      quest: { id: docRef.id, ...questData, createdAt: new Date().toISOString() },
    });
  } catch (error: any) {
    console.error('Error creating seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
