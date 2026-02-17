import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get config document
    const configDoc = await db.collection('config').doc('gamification').get();

    if (!configDoc.exists) {
      // Return default config if doesn't exist
      return NextResponse.json({
        challenges: {
          logMeals: { goal: 7, reward: 30, enabled: true },
          useAi: { goal: 5, reward: 25, enabled: true },
        },
        milestones: [
          { threshold: 100, reward: 50 },
          { threshold: 500, reward: 100 },
          { threshold: 1000, reward: 200 },
          { threshold: 5000, reward: 500 },
        ],
        systemSettings: {
          freeAiCredits: 3,
          streakGracePeriod: 1,
          aiAnalysisCost: 5,
          welcomeGiftAmount: 50,
        },
        abTests: {},
      });
    }

    return NextResponse.json(configDoc.data());
  } catch (error) {
    console.error('Get config error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch configuration' },
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const body = await request.json();
    const { section, data } = body;

    // Validate section
    const validSections = ['challenges', 'milestones', 'systemSettings', 'abTests'];
    if (!validSections.includes(section)) {
      return NextResponse.json(
        { error: 'Invalid section' },
        { status: 400 }
      );
    }

    // Update config
    const configRef = db.collection('config').doc('gamification');
    await configRef.set(
      {
        [section]: data,
        updatedAt: new Date(),
        updatedBy: 'admin', // In production, track which admin
      },
      { merge: true }
    );

    // Log change to history
    await db.collection('config_history').add({
      section,
      changes: data,
      timestamp: new Date(),
      admin: 'admin',
    });

    return NextResponse.json({
      success: true,
      message: `${section} updated successfully`,
    });
  } catch (error) {
    console.error('Update config error:', error);
    return NextResponse.json(
      { error: 'Failed to update configuration' },
      { status: 500 }
    );
  }
}
