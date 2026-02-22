/**
 * Rollback Script - Energy Marketing V3
 * 
 * Safely rollback V3 changes if needed:
 * - Restore old milestone format
 * - Remove new fields
 * - Preserve user data
 */

import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Rollback a single user
 */
async function rollbackUser(deviceId: string): Promise<void> {
  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    console.warn(`⚠️  User ${deviceId} does not exist`);
    return;
  }

  // Restore old milestone format (if needed)
  // Note: We keep totalSpent, just remove V3-specific fields
  const updates: any = {
    'milestones.claimedMilestones': admin.firestore.FieldValue.delete(),
    'milestones.nextMilestoneIndex': admin.firestore.FieldValue.delete(),
  };

  // Remove V3 offer fields
  updates['offers.firstPurchaseAvailable'] = admin.firestore.FieldValue.delete();
  updates['offers.firstPurchaseExpiry'] = admin.firestore.FieldValue.delete();
  updates['offers.welcomeBonusAvailable'] = admin.firestore.FieldValue.delete();
  updates['offers.welcomeBonusExpiry'] = admin.firestore.FieldValue.delete();
  updates['offers.tierPromoActive'] = admin.firestore.FieldValue.delete();

  // Note: Keep claimed flags (important for preventing abuse)
  // - offers.firstPurchaseClaimed
  // - offers.welcomeBonusClaimed
  // - offers.tierPromoClaimed

  // Remove V3-specific fields
  updates['adViews'] = admin.firestore.FieldValue.delete();
  updates['dailyClaim'] = admin.firestore.FieldValue.delete();
  updates['notifications'] = admin.firestore.FieldValue.delete();

  await userRef.update(updates);
  console.log(`✅ Rolled back user: ${deviceId}`);
}

/**
 * Rollback all users in batches
 */
async function rollbackAllUsers(): Promise<void> {
  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | null = null;
  let totalRolledBack = 0;
  let totalErrors = 0;

  console.log('🔄 Starting rollback to V2...\n');

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
      break;
    }

    console.log(`\n📦 Processing batch of ${snapshot.docs.length} users...`);

    for (const doc of snapshot.docs) {
      try {
        await rollbackUser(doc.id);
        totalRolledBack++;
      } catch (error: any) {
        console.error(`❌ Failed to rollback ${doc.id}:`, error.message);
        totalErrors++;
      }
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    console.log(`Progress: ${totalRolledBack} rolled back, ${totalErrors} errors`);

    // Rate limit
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  console.log('\n' + '='.repeat(50));
  console.log('✅ Rollback complete!');
  console.log(`   Total rolled back: ${totalRolledBack}`);
  console.log(`   Total errors: ${totalErrors}`);
  console.log('='.repeat(50) + '\n');
}

/**
 * Verify rollback
 */
async function verifyRollback(sampleSize = 10): Promise<void> {
  console.log(`\n🔍 Verifying rollback (sample size: ${sampleSize})...\n`);

  const snapshot = await db
    .collection('users')
    .limit(sampleSize)
    .get();

  let allValid = true;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const deviceId = doc.id;

    // Check that V3 fields are removed
    const v3FieldsRemoved = [
      !data.milestones?.claimedMilestones,
      !data.milestones?.nextMilestoneIndex,
      !data.offers?.firstPurchaseAvailable,
      !data.offers?.firstPurchaseExpiry,
      !data.adViews,
      !data.dailyClaim,
      !data.notifications,
    ];

    // Check that important data is preserved
    const dataPreserved = [
      typeof data.balance === 'number',
      typeof data.milestones?.totalSpent === 'number',
      typeof data.offers?.firstPurchaseClaimed === 'boolean',
    ];

    if (!v3FieldsRemoved.every(Boolean)) {
      console.error(`❌ User ${deviceId}: V3 fields not fully removed`);
      allValid = false;
    } else if (!dataPreserved.every(Boolean)) {
      console.error(`❌ User ${deviceId}: Important data lost`);
      allValid = false;
    } else {
      console.log(`✅ User ${deviceId} passed rollback verification`);
    }
  }

  if (allValid) {
    console.log('\n✅ All sampled users passed rollback verification!\n');
  } else {
    console.error('\n❌ Some users failed rollback verification.\n');
  }
}

/**
 * Main entry point
 */
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  console.log('⚠️  WARNING: This script will rollback V3 changes!');
  console.log('⚠️  Make sure you have a database backup before proceeding.\n');

  // Safety check
  if (command !== '--confirm') {
    console.log('To proceed, run:');
    console.log('  npm run rollback:v3 --confirm rollback');
    console.log('  npm run rollback:v3 --confirm verify');
    console.log('  npm run rollback:v3 --confirm single <deviceId>');
    process.exit(1);
  }

  const action = args[1];

  try {
    if (action === 'rollback') {
      await rollbackAllUsers();
    } else if (action === 'verify') {
      const sampleSize = parseInt(args[2] || '10', 10);
      await verifyRollback(sampleSize);
    } else if (action === 'single') {
      const deviceId = args[2];
      if (!deviceId) {
        console.error('❌ Usage: npm run rollback:v3 --confirm single <deviceId>');
        process.exit(1);
      }
      await rollbackUser(deviceId);
    } else {
      console.log('Usage:');
      console.log('  npm run rollback:v3 --confirm rollback        # Rollback all users');
      console.log('  npm run rollback:v3 --confirm verify [N]      # Verify N random users');
      console.log('  npm run rollback:v3 --confirm single <id>     # Rollback single user');
    }
  } catch (error: any) {
    console.error('❌ Rollback failed:', error.message);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

main();
