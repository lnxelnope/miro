import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

const SCENARIOS = {
  new_user: {
    name: 'New User Journey',
    balance: 0,
    tier: 'starter',
    currentStreak: 0,
    bonusRate: 0,
    'milestones.totalSpent': 0,
    'milestones.claimedMilestones': [],
    'milestones.nextMilestoneIndex': 0,
    offers: {
      firstPurchaseClaimed: false,
      firstPurchaseAvailable: false,
      welcomeBonusClaimed: false,
      welcomeBonusAvailable: false,
    },
  },
  streak_risk: {
    name: 'About to Break Streak',
    balance: 5,
    tier: 'bronze',
    currentStreak: 14,
    bonusRate: 0.10,
    lastCheckInDate: new Date(Date.now() - 23 * 60 * 60 * 1000).toISOString().split('T')[0], // 23 hours ago
    'milestones.totalSpent': 450,
  },
  tier_up: {
    name: 'Ready for Tier Up',
    balance: 100,
    tier: 'bronze',
    currentStreak: 7,
    bonusRate: 0.10,
    'milestones.totalSpent': 495, // 5E away from Silver (500E)
    'milestones.claimedMilestones': ['milestone_10', 'milestone_50', 'milestone_100', 'milestone_250'],
  },
  churn_risk: {
    name: 'Subscription Churn Risk',
    balance: 0,
    tier: 'silver',
    currentStreak: 0,
    bonusRate: 0.15,
    'milestones.totalSpent': 1500,
    'subscription.status': 'cancelled',
  },
  whale: {
    name: 'High-Value Whale',
    balance: 500,
    tier: 'diamond',
    currentStreak: 30,
    bonusRate: 0.25,
    'milestones.totalSpent': 15000,
    'milestones.claimedMilestones': [
      'milestone_10', 'milestone_50', 'milestone_100', 'milestone_250',
      'milestone_500', 'milestone_1000', 'milestone_2000', 'milestone_2500',
      'milestone_5000', 'milestone_10000'
    ],
    'subscription.status': 'active',
  },
};

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { userId } = await params;
    const body = await request.json();
    const { scenario } = body;

    if (!scenario || !Object.keys(SCENARIOS).includes(scenario)) {
      return NextResponse.json(
        { error: `Invalid scenario. Must be: ${Object.keys(SCENARIOS).join(', ')}` },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const scenarioData = SCENARIOS[scenario as keyof typeof SCENARIOS];
    
    // Apply scenario data
    const updateData: any = {
      ...scenarioData,
      lastUpdated: FieldValue.serverTimestamp(),
    };
    
    // Remove the 'name' field from update
    delete updateData.name;

    await userRef.update(updateData);

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'apply_scenario',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      details: {
        scenario,
        scenarioName: scenarioData.name,
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: `Scenario "${scenarioData.name}" applied successfully`,
      scenario,
    });
  } catch (error) {
    console.error('Apply scenario error:', error);
    return NextResponse.json(
      { error: 'Failed to apply scenario' },
      { status: 500 }
    );
  }
}
