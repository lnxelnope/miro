/**
 * User Migration Script - Energy Marketing V3
 * 
 * Migrates existing users to new schema:
 * - Initialize new offer fields
 * - Migrate milestone data
 * - Add daily claim state
 * - Add ad views tracking
 */

import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

interface MilestoneState {
  claimedMilestones: number[];
  nextMilestoneIndex: number;
}

/**
 * Compute milestone state from totalSpent
 */
function computeMilestoneState(totalSpent: number): MilestoneState {
  const milestones = [20, 50, 100, 200, 350, 500, 750, 1000, 1500, 2000];
  const claimedMilestones: number[] = [];
  let nextMilestoneIndex = 0;

  for (let i = 0; i < milestones.length; i++) {
    if (totalSpent >= milestones[i]) {
      claimedMilestones.push(i);
    } else {
      nextMilestoneIndex = i;
      break;
    }
  }

  // If all milestones claimed
  if (claimedMilestones.length === milestones.length) {
    nextMilestoneIndex = milestones.length;
  }

  return { claimedMilestones, nextMilestoneIndex };
}

/**
 * Migrate a single user
 */
async function migrateUser(deviceId: string): Promise<void> {
  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    console.warn(`⚠️  User ${deviceId} does not exist`);
    return;
  }

  const userData = userDoc.data()!;

  // 1. Compute milestone state from totalSpent
  const totalSpent = userData.milestones?.totalSpent || 0;
  const { claimedMilestones, nextMilestoneIndex } = computeMilestoneState(totalSpent);

  // 2. Initialize new fields (only if they don't exist)
  const updates: any = {};

  // Offers
  if (!userData.offers?.firstPurchaseClaimed) {
    updates['offers.firstPurchaseClaimed'] = false;
  }
  if (!userData.offers?.firstPurchaseAvailable) {
    updates['offers.firstPurchaseAvailable'] = false;
  }
  if (!userData.offers?.firstPurchaseExpiry) {
    updates['offers.firstPurchaseExpiry'] = null;
  }

  if (!userData.offers?.welcomeBonusClaimed) {
    updates['offers.welcomeBonusClaimed'] = false;
  }
  if (!userData.offers?.welcomeBonusAvailable) {
    updates['offers.welcomeBonusAvailable'] = false;
  }
  if (!userData.offers?.welcomeBonusExpiry) {
    updates['offers.welcomeBonusExpiry'] = null;
  }

  if (!userData.offers?.tierPromoClaimed) {
    updates['offers.tierPromoClaimed'] = {
      bronze: false,
      silver: false,
      gold: false,
      diamond: false,
    };
  }
  if (!userData.offers?.tierPromoActive) {
    updates['offers.tierPromoActive'] = { tier: null, expiry: null };
  }

  // Milestones V2
  updates['milestones.claimedMilestones'] = claimedMilestones;
  updates['milestones.nextMilestoneIndex'] = nextMilestoneIndex;

  // Ad Views
  if (!userData.adViews) {
    updates['adViews'] = { date: '', count: 0 };
  }

  // Daily Claim
  if (!userData.dailyClaim) {
    updates['dailyClaim'] = {
      lastClaimDate: '',
      canClaim: false,
    };
  }

  // Notifications
  if (!userData.notifications) {
    updates['notifications'] = {
      offerExpirySent: {},
      lastStreakReminder: '',
    };
  }

  // 3. Apply updates
  if (Object.keys(updates).length > 0) {
    await userRef.update(updates);
    console.log(`✅ Migrated user: ${deviceId}`);
  } else {
    console.log(`⏭️  User ${deviceId} already migrated`);
  }
}

/**
 * Migrate all users in batches
 */
async function migrateAllUsers(): Promise<void> {
  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | null = null;
  let totalMigrated = 0;
  let totalErrors = 0;

  console.log('🚀 Starting user migration to V3...\n');

  while (true) {
    let query = db
      .collection('users')
      .orderBy('lastUpdated')
      .limit(100);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      break; // No more users
    }

    console.log(`\n📦 Processing batch of ${snapshot.docs.length} users...`);

    for (const doc of snapshot.docs) {
      try {
        await migrateUser(doc.id);
        totalMigrated++;
      } catch (error: any) {
        console.error(`❌ Failed to migrate ${doc.id}:`, error.message);
        totalErrors++;
      }
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    console.log(`Progress: ${totalMigrated} migrated, ${totalErrors} errors`);

    // Rate limit (prevent Firestore overload)
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  console.log('\n' + '='.repeat(50));
  console.log('✅ Migration complete!');
  console.log(`   Total migrated: ${totalMigrated}`);
  console.log(`   Total errors: ${totalErrors}`);
  console.log('='.repeat(50) + '\n');
}

/**
 * Verify migration for a sample of users
 */
async function verifyMigration(sampleSize = 10): Promise<void> {
  console.log(`\n🔍 Verifying migration (sample size: ${sampleSize})...\n`);

  const snapshot = await db
    .collection('users')
    .limit(sampleSize)
    .get();

  let allValid = true;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const deviceId = doc.id;

    const checks = [
      { field: 'offers.firstPurchaseClaimed', expected: typeof data.offers?.firstPurchaseClaimed === 'boolean' },
      { field: 'offers.tierPromoClaimed', expected: typeof data.offers?.tierPromoClaimed === 'object' },
      { field: 'milestones.claimedMilestones', expected: Array.isArray(data.milestones?.claimedMilestones) },
      { field: 'milestones.nextMilestoneIndex', expected: typeof data.milestones?.nextMilestoneIndex === 'number' },
      { field: 'adViews', expected: typeof data.adViews === 'object' },
      { field: 'dailyClaim', expected: typeof data.dailyClaim === 'object' },
      { field: 'notifications', expected: typeof data.notifications === 'object' },
    ];

    const failed = checks.filter((check) => !check.expected);

    if (failed.length > 0) {
      console.error(`❌ User ${deviceId} failed checks:`);
      failed.forEach((check) => console.error(`   - ${check.field}`));
      allValid = false;
    } else {
      console.log(`✅ User ${deviceId} passed all checks`);
    }
  }

  if (allValid) {
    console.log('\n✅ All sampled users passed verification!\n');
  } else {
    console.error('\n❌ Some users failed verification. Check logs above.\n');
  }
}

/**
 * Main entry point
 */
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  try {
    if (command === 'migrate') {
      await migrateAllUsers();
    } else if (command === 'verify') {
      const sampleSize = parseInt(args[1] || '10', 10);
      await verifyMigration(sampleSize);
    } else if (command === 'single') {
      const deviceId = args[1];
      if (!deviceId) {
        console.error('❌ Usage: npm run migrate:v3 single <deviceId>');
        process.exit(1);
      }
      await migrateUser(deviceId);
    } else {
      console.log('Usage:');
      console.log('  npm run migrate:v3 migrate        # Migrate all users');
      console.log('  npm run migrate:v3 verify [N]     # Verify N random users (default: 10)');
      console.log('  npm run migrate:v3 single <id>    # Migrate single user');
    }
  } catch (error: any) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

main();
