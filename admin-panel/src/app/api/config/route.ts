import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get config document from Firestore
    const configDoc = await db.collection('config').doc('promotions').get();

    if (configDoc.exists) {
      const data = configDoc.data();
      return NextResponse.json({
        success: true,
        config: data,
      });
    }

    // Return default config if doesn't exist
    const defaultConfig = {
      promotions: {
        welcomeOffer: {
          threshold: 10,
          freeEnergy: 50,
          bonusRate: 0.40,
          duration: 24,
        },
        tierUpgrade: {
          bonusRate: 0.20,
          duration: 24,
          rewards: {
            bronze: 3,
            silver: 5,
            gold: 10,
            diamond: 15,
          },
        },
        welcomeBack: {
          bonusRate: 0.40,
          duration: 24,
          condition: 'ex-Diamond fell to Starter/Bronze',
        },
      },
      dailyRewards: {
        none: 1,
        bronze: 1,
        silver: 2,
        gold: 3,
        diamond: 4,
      },
      challenges: {
        logMeals: {
          goal: 7,
          reward: 10,
        },
        useAi: {
          goal: 3,
          reward: 5,
        },
      },
      milestones: {
        spent500: 50,
        spent1000: 100,
      },
    };

    return NextResponse.json({
      success: true,
      config: defaultConfig,
    });
  } catch (error: any) {
    console.error('Error fetching config:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const { config } = await request.json();

    if (!config) {
      return NextResponse.json({ error: 'Missing config' }, { status: 400 });
    }

    // Save to Firestore config collection
    await db.collection('config').doc('promotions').set(
      {
        ...config,
        lastUpdated: new Date().toISOString(),
      },
      { merge: true }
    );

    // Log change to history
    await db.collection('config_history').add({
      type: 'promotions',
      config,
      changedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating config:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
