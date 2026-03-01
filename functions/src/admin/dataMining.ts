/**
 * dataMining.ts
 *
 * Data Mining Reports — aggregated insights from synced food data.
 * Scheduled weekly computation + admin endpoint to retrieve reports.
 *
 * Reports:
 *  1. topFoods        — Most logged foods with avg nutrition (Hero Products)
 *  2. ingredientFreq  — Ingredient frequency from AI analysis
 *  3. nutritionGap    — Avg intake vs RDA, deficiency %
 *  4. mealTiming      — Meal distribution by hour of day
 *  5. demographics    — User nutrition profiles by age/gender
 *  6. macroSegments   — Diet type distribution (high-P, low-C, balanced...)
 *  7. engagement      — Sync activity & entries per user over time
 *  8. aiDataset       — AI training dataset stats (images + labels + bounding boxes)
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function verifyAdminAuth(req: any): boolean {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) return false;
  return authHeader.substring(7) === process.env.ADMIN_SECRET;
}

// ═══════════════════════════════════════════════════════════
// Scheduled: computeDataMiningReports
// Runs every Monday at 04:00 UTC+7 (21:00 UTC Sunday)
// ═══════════════════════════════════════════════════════════

export const computeDataMiningReports = onSchedule(
  {
    schedule: "0 21 * * 0", // Sunday 21:00 UTC = Monday 04:00 UTC+7
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async () => {
    console.log("📊 [DataMining] Starting weekly computation...");

    const weekEnd = new Date();
    const weekStart = new Date();
    weekStart.setDate(weekStart.getDate() - 7);
    const periodLabel = `${weekStart.toISOString().split("T")[0]}_${weekEnd.toISOString().split("T")[0]}`;

    // ─── Collect all synced entries from the past 7 days ───
    const {allEntries, profiles, totalSyncUsers} = await collectSyncData(7);

    console.log(`📊 [DataMining] Collected ${allEntries.length} entries from ${totalSyncUsers} users`);

    if (allEntries.length === 0) {
      console.log("📊 [DataMining] No entries to process, skipping.");
      return;
    }

    // ─── Compute reports ───
    const topFoods = computeTopFoods(allEntries);
    const ingredientFreq = computeIngredientFrequency(allEntries);
    const nutritionGap = computeNutritionGap(allEntries, profiles);
    const mealTiming = computeMealTiming(allEntries);
    const demographics = computeDemographics(allEntries, profiles);
    const macroSegments = computeMacroSegments(allEntries, profiles);
    const engagement = computeEngagement(allEntries, totalSyncUsers);
    const aiDataset = computeAiDatasetStats(allEntries);

    // ─── Store reports ───
    const reportRef = db.collection("data_mining_reports").doc(periodLabel);
    await reportRef.set({
      period: periodLabel,
      computedAt: admin.firestore.FieldValue.serverTimestamp(),
      totalEntries: allEntries.length,
      totalUsers: totalSyncUsers,
      topFoods,
      ingredientFreq,
      nutritionGap,
      mealTiming,
      demographics,
      macroSegments,
      engagement,
      aiDataset,
    });

    // Also write "latest" pointer
    await db.collection("data_mining_reports").doc("latest").set({
      period: periodLabel,
      computedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ [DataMining] Reports saved: ${periodLabel}`);
  }
);

// ═══════════════════════════════════════════════════════════
// Admin Endpoint: getDataMiningReport
// GET /getDataMiningReport?period=latest
// ═══════════════════════════════════════════════════════════

export const getDataMiningReport = onRequest(
  {timeoutSeconds: 30, memory: "256MiB", cors: true},
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const period = (req.query.period as string) || "latest";

      if (period === "latest") {
        const latestDoc = await db.collection("data_mining_reports").doc("latest").get();
        if (!latestDoc.exists) {
          res.status(404).json({error: "No reports computed yet"});
          return;
        }
        const latestPeriod = latestDoc.data()!.period;
        const reportDoc = await db.collection("data_mining_reports").doc(latestPeriod).get();
        res.status(200).json({success: true, report: reportDoc.data()});
        return;
      }

      const reportDoc = await db.collection("data_mining_reports").doc(period).get();
      if (!reportDoc.exists) {
        res.status(404).json({error: `Report not found: ${period}`});
        return;
      }
      res.status(200).json({success: true, report: reportDoc.data()});
    } catch (error: any) {
      console.error("❌ [getDataMiningReport]", error);
      res.status(500).json({error: error.message});
    }
  }
);

// ═══════════════════════════════════════════════════════════
// Admin Endpoint: triggerDataMining (manual trigger)
// POST /triggerDataMining { days: 7 }
// ═══════════════════════════════════════════════════════════

export const triggerDataMining = onRequest(
  {timeoutSeconds: 540, memory: "1GiB", cors: true},
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const days = parseInt(req.body?.days || "7");
      const weekEnd = new Date();
      const weekStart = new Date();
      weekStart.setDate(weekStart.getDate() - days);
      const periodLabel = `${weekStart.toISOString().split("T")[0]}_${weekEnd.toISOString().split("T")[0]}`;

      const {allEntries, profiles, totalSyncUsers} = await collectSyncData(days);

      if (allEntries.length === 0) {
        res.status(200).json({success: true, message: "No entries to process"});
        return;
      }

      const report = {
        period: periodLabel,
        computedAt: admin.firestore.FieldValue.serverTimestamp(),
        totalEntries: allEntries.length,
        totalUsers: totalSyncUsers,
        topFoods: computeTopFoods(allEntries),
        ingredientFreq: computeIngredientFrequency(allEntries),
        nutritionGap: computeNutritionGap(allEntries, profiles),
        mealTiming: computeMealTiming(allEntries),
        demographics: computeDemographics(allEntries, profiles),
        macroSegments: computeMacroSegments(allEntries, profiles),
        engagement: computeEngagement(allEntries, totalSyncUsers),
        aiDataset: computeAiDatasetStats(allEntries),
      };

      await db.collection("data_mining_reports").doc(periodLabel).set(report);
      await db.collection("data_mining_reports").doc("latest").set({
        period: periodLabel,
        computedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({success: true, period: periodLabel, totalEntries: allEntries.length});
    } catch (error: any) {
      console.error("❌ [triggerDataMining]", error);
      res.status(500).json({error: error.message});
    }
  }
);

// ═══════════════════════════════════════════════════════════
// DATA COLLECTION
// ═══════════════════════════════════════════════════════════

interface CompactEntry {
  deviceId: string;
  fn: string;       // food name
  ts: number;       // timestamp ms
  mt: number;       // meal type index
  k: number;        // calories
  p: number;        // protein
  c: number;        // carbs
  f: number;        // fat
  fi?: number;      // fiber
  so?: number;      // sodium
  su2?: number;     // sugar
  ch?: number;      // cholesterol
  sf?: number;      // saturated fat
  ij?: string;      // ingredients JSON
  src?: number;     // data source
  ac?: number;      // AI confidence
  tu?: string;      // thumbnail URL
  fe?: string;      // food name (English)
  ro?: string;      // reference object used
  cal?: boolean;    // is calibrated
  rcf?: number;     // reference confidence
  pd?: number;      // plate diameter cm
  ev?: number;      // estimated volume ml
  alj?: string;     // AR labels JSON (bounding boxes)
  aiw?: number;     // image width px
  aih?: number;     // image height px
  apc?: number;     // pixel per cm ratio
}

interface UserProfile {
  deviceId: string;
  g?: string;       // gender
  a?: number;       // age
  w?: number;       // weight
  h?: number;       // height
  kg?: number;      // calorie goal
  pg?: number;      // protein goal
  al?: string;      // activity level
  cu?: string;      // cuisine preference
}

async function collectSyncData(days: number) {
  const allEntries: CompactEntry[] = [];
  const profiles: Map<string, UserProfile> = new Map();

  const syncUsers = await db.collection("user_sync").listDocuments();
  const totalSyncUsers = syncUsers.length;

  for (const userRef of syncUsers) {
    const deviceId = userRef.id;

    // Profile
    const userDoc = await userRef.get();
    if (userDoc.exists && userDoc.data()?.profile) {
      profiles.set(deviceId, {deviceId, ...userDoc.data()!.profile});
    }

    // Daily logs from past N days
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - days);

    const logs = await userRef
      .collection("daily_logs")
      .orderBy("updatedAt", "desc")
      .limit(days)
      .get();

    for (const logDoc of logs.docs) {
      const data = logDoc.data();
      if (data.entries && Array.isArray(data.entries)) {
        for (const entry of data.entries) {
          if (entry.fn && entry.ts) {
            allEntries.push({deviceId, ...entry});
          }
        }
      }
    }
  }

  return {allEntries, profiles, totalSyncUsers};
}

// ═══════════════════════════════════════════════════════════
// REPORT COMPUTATIONS
// ═══════════════════════════════════════════════════════════

// ─── 1. Top Foods (Hero Products) ─────────────────────────

function computeTopFoods(entries: CompactEntry[]) {
  const foodMap = new Map<string, {
    count: number;
    totalKcal: number;
    totalP: number;
    totalC: number;
    totalF: number;
    mealTypes: Record<number, number>;
    uniqueUsers: Set<string>;
  }>();

  for (const e of entries) {
    const name = e.fn.toLowerCase().trim();
    if (!foodMap.has(name)) {
      foodMap.set(name, {
        count: 0, totalKcal: 0, totalP: 0, totalC: 0, totalF: 0,
        mealTypes: {}, uniqueUsers: new Set(),
      });
    }
    const f = foodMap.get(name)!;
    f.count++;
    f.totalKcal += e.k || 0;
    f.totalP += e.p || 0;
    f.totalC += e.c || 0;
    f.totalF += e.f || 0;
    f.mealTypes[e.mt] = (f.mealTypes[e.mt] || 0) + 1;
    f.uniqueUsers.add(e.deviceId);
  }

  const sorted = Array.from(foodMap.entries())
    .sort((a, b) => b[1].count - a[1].count)
    .slice(0, 50);

  return sorted.map(([name, data]) => ({
    food: name,
    count: data.count,
    uniqueUsers: data.uniqueUsers.size,
    avgKcal: Math.round(data.totalKcal / data.count),
    avgProtein: +(data.totalP / data.count).toFixed(1),
    avgCarbs: +(data.totalC / data.count).toFixed(1),
    avgFat: +(data.totalF / data.count).toFixed(1),
    mealTypes: data.mealTypes,
  }));
}

// ─── 2. Ingredient Frequency ──────────────────────────────

function computeIngredientFrequency(entries: CompactEntry[]) {
  const ingredientMap = new Map<string, {count: number; uniqueUsers: Set<string>}>();

  for (const e of entries) {
    if (!e.ij) continue;
    try {
      const ingredients = JSON.parse(e.ij);
      if (!Array.isArray(ingredients)) continue;
      for (const ing of ingredients) {
        const name = (ing.name || ing.foodName || "").toLowerCase().trim();
        if (!name || name.length < 2) continue;
        if (!ingredientMap.has(name)) {
          ingredientMap.set(name, {count: 0, uniqueUsers: new Set()});
        }
        const item = ingredientMap.get(name)!;
        item.count++;
        item.uniqueUsers.add(e.deviceId);
      }
    } catch (_) { /* skip malformed JSON */ }
  }

  return Array.from(ingredientMap.entries())
    .sort((a, b) => b[1].count - a[1].count)
    .slice(0, 100)
    .map(([name, data]) => ({
      ingredient: name,
      count: data.count,
      uniqueUsers: data.uniqueUsers.size,
    }));
}

// ─── 3. Nutrition Gap Analysis ────────────────────────────

const RDA = {
  calories: 2000, protein: 50, carbs: 275, fat: 78,
  fiber: 28, sodium: 2300, sugar: 50, cholesterol: 300,
};

function computeNutritionGap(entries: CompactEntry[], profiles: Map<string, UserProfile>) {
  // Per-user daily totals
  const userDays = new Map<string, Map<string, {k: number; p: number; c: number; f: number; fi: number; so: number; su: number; ch: number}>>();

  for (const e of entries) {
    const day = new Date(e.ts).toISOString().split("T")[0];
    const key = `${e.deviceId}_${day}`;
    if (!userDays.has(key)) {
      userDays.set(key, new Map());
    }
    const dayMap = userDays.get(key)!;
    if (!dayMap.has("totals")) {
      dayMap.set("totals", {k: 0, p: 0, c: 0, f: 0, fi: 0, so: 0, su: 0, ch: 0});
    }
    const t = dayMap.get("totals")!;
    t.k += e.k || 0;
    t.p += e.p || 0;
    t.c += e.c || 0;
    t.f += e.f || 0;
    t.fi += e.fi || 0;
    t.so += e.so || 0;
    t.su += e.su2 || 0;
    t.ch += e.ch || 0;
  }

  const totals = Array.from(userDays.values()).map((m) => m.get("totals")!);
  const n = totals.length || 1;

  const avgIntake = {
    calories: Math.round(totals.reduce((s, t) => s + t.k, 0) / n),
    protein: +(totals.reduce((s, t) => s + t.p, 0) / n).toFixed(1),
    carbs: +(totals.reduce((s, t) => s + t.c, 0) / n).toFixed(1),
    fat: +(totals.reduce((s, t) => s + t.f, 0) / n).toFixed(1),
    fiber: +(totals.reduce((s, t) => s + t.fi, 0) / n).toFixed(1),
    sodium: Math.round(totals.reduce((s, t) => s + t.so, 0) / n),
    sugar: +(totals.reduce((s, t) => s + t.su, 0) / n).toFixed(1),
    cholesterol: Math.round(totals.reduce((s, t) => s + t.ch, 0) / n),
  };

  // Deficiency rates (< 80% of RDA)
  const deficiencies = {
    protein: +(totals.filter((t) => t.p < RDA.protein * 0.8).length / n * 100).toFixed(1),
    fiber: +(totals.filter((t) => t.fi < RDA.fiber * 0.8).length / n * 100).toFixed(1),
    excessSodium: +(totals.filter((t) => t.so > RDA.sodium).length / n * 100).toFixed(1),
    excessSugar: +(totals.filter((t) => t.su > RDA.sugar).length / n * 100).toFixed(1),
    excessCholesterol: +(totals.filter((t) => t.ch > RDA.cholesterol).length / n * 100).toFixed(1),
  };

  // Average calorie goal from profiles
  const goalUsers = Array.from(profiles.values()).filter((p) => p.kg && p.kg > 0);
  const avgGoal = goalUsers.length > 0
    ? Math.round(goalUsers.reduce((s, p) => s + (p.kg || 2000), 0) / goalUsers.length)
    : 2000;

  return {
    sampleDays: n,
    avgDailyIntake: avgIntake,
    rda: RDA,
    avgCalorieGoal: avgGoal,
    deficiencyRates: deficiencies,
    goalAchievementRate: +(totals.filter((t) => t.k >= avgGoal * 0.9 && t.k <= avgGoal * 1.1).length / n * 100).toFixed(1),
  };
}

// ─── 4. Meal Timing Patterns ──────────────────────────────

function computeMealTiming(entries: CompactEntry[]) {
  const hourDist = new Array(24).fill(0);
  const mealTypeByHour: Record<number, number[]> = {};

  for (let mt = 0; mt < 4; mt++) {
    mealTypeByHour[mt] = new Array(24).fill(0);
  }

  for (const e of entries) {
    const hour = new Date(e.ts).getHours();
    hourDist[hour]++;
    if (e.mt >= 0 && e.mt < 4) {
      mealTypeByHour[e.mt][hour]++;
    }
  }

  // Peak hours per meal type
  const mealNames = ["breakfast", "lunch", "dinner", "snack"];
  const peaks: Record<string, {peakHour: number; count: number}> = {};
  for (let mt = 0; mt < 4; mt++) {
    const hours = mealTypeByHour[mt];
    const maxIdx = hours.indexOf(Math.max(...hours));
    peaks[mealNames[mt]] = {peakHour: maxIdx, count: hours[maxIdx]};
  }

  return {
    hourlyDistribution: hourDist,
    mealTypeByHour,
    peakHours: peaks,
    lateNightEating: +(entries.filter((e) => {
      const h = new Date(e.ts).getHours();
      return h >= 22 || h < 5;
    }).length / entries.length * 100).toFixed(1),
  };
}

// ─── 5. Demographic Nutrition Profiles ────────────────────

function computeDemographics(_entries: CompactEntry[], profiles: Map<string, UserProfile>) {
  const allProfiles = Array.from(profiles.values());

  const genderDist: Record<string, number> = {};
  const ageGroups: Record<string, number> = {"<18": 0, "18-24": 0, "25-34": 0, "35-44": 0, "45-54": 0, "55+": 0};
  const activityDist: Record<string, number> = {};
  const cuisineDist: Record<string, number> = {};
  const bmiCategories: Record<string, number> = {underweight: 0, normal: 0, overweight: 0, obese: 0};

  for (const p of allProfiles) {
    // Gender
    if (p.g) genderDist[p.g] = (genderDist[p.g] || 0) + 1;

    // Age groups
    if (p.a) {
      if (p.a < 18) ageGroups["<18"]++;
      else if (p.a <= 24) ageGroups["18-24"]++;
      else if (p.a <= 34) ageGroups["25-34"]++;
      else if (p.a <= 44) ageGroups["35-44"]++;
      else if (p.a <= 54) ageGroups["45-54"]++;
      else ageGroups["55+"]++;
    }

    // Activity level
    if (p.al) activityDist[p.al] = (activityDist[p.al] || 0) + 1;

    // Cuisine
    if (p.cu) cuisineDist[p.cu] = (cuisineDist[p.cu] || 0) + 1;

    // BMI
    if (p.w && p.h && p.h > 0) {
      const bmi = p.w / Math.pow(p.h / 100, 2);
      if (bmi < 18.5) bmiCategories.underweight++;
      else if (bmi < 25) bmiCategories.normal++;
      else if (bmi < 30) bmiCategories.overweight++;
      else bmiCategories.obese++;
    }
  }

  // Average stats
  const withWeight = allProfiles.filter((p) => p.w);
  const withHeight = allProfiles.filter((p) => p.h);
  const withAge = allProfiles.filter((p) => p.a);

  return {
    totalProfiles: allProfiles.length,
    gender: genderDist,
    ageGroups,
    activityLevel: activityDist,
    cuisinePreference: cuisineDist,
    bmi: bmiCategories,
    averages: {
      weight: withWeight.length > 0 ? +(withWeight.reduce((s, p) => s + p.w!, 0) / withWeight.length).toFixed(1) : null,
      height: withHeight.length > 0 ? +(withHeight.reduce((s, p) => s + p.h!, 0) / withHeight.length).toFixed(1) : null,
      age: withAge.length > 0 ? Math.round(withAge.reduce((s, p) => s + p.a!, 0) / withAge.length) : null,
    },
  };
}

// ─── 6. Macro Segments (Diet Types) ───────────────────────

function computeMacroSegments(entries: CompactEntry[], _profiles: Map<string, UserProfile>) {
  // Per-user average macro %
  const userMacros = new Map<string, {totalK: number; totalP: number; totalC: number; totalF: number; count: number}>();

  for (const e of entries) {
    if (!userMacros.has(e.deviceId)) {
      userMacros.set(e.deviceId, {totalK: 0, totalP: 0, totalC: 0, totalF: 0, count: 0});
    }
    const u = userMacros.get(e.deviceId)!;
    u.totalK += e.k || 0;
    u.totalP += e.p || 0;
    u.totalC += e.c || 0;
    u.totalF += e.f || 0;
    u.count++;
  }

  const segments: Record<string, number> = {
    "high_protein": 0,    // P > 30% of kcal
    "low_carb": 0,        // C < 30% of kcal
    "high_carb": 0,       // C > 60% of kcal
    "high_fat": 0,        // F > 40% of kcal
    "balanced": 0,        // P 15-25%, C 45-65%, F 20-35%
    "other": 0,
  };

  for (const [, u] of userMacros) {
    if (u.totalK === 0) continue;
    const pPct = (u.totalP * 4) / u.totalK * 100;
    const cPct = (u.totalC * 4) / u.totalK * 100;
    const fPct = (u.totalF * 9) / u.totalK * 100;

    if (pPct > 30) segments.high_protein++;
    else if (cPct < 30) segments.low_carb++;
    else if (cPct > 60) segments.high_carb++;
    else if (fPct > 40) segments.high_fat++;
    else if (pPct >= 15 && pPct <= 25 && cPct >= 45 && cPct <= 65 && fPct >= 20 && fPct <= 35) segments.balanced++;
    else segments.other++;
  }

  const total = Array.from(userMacros.values()).filter((u) => u.totalK > 0).length || 1;

  return {
    distribution: segments,
    percentages: Object.fromEntries(
      Object.entries(segments).map(([k, v]) => [k, +(v / total * 100).toFixed(1)])
    ),
    totalUsersAnalyzed: total,
  };
}

// ─── 7. Engagement ────────────────────────────────────────

function computeEngagement(entries: CompactEntry[], totalUsers: number) {
  const dailyEntries = new Map<string, number>();
  const userEntryCount = new Map<string, number>();

  for (const e of entries) {
    const day = new Date(e.ts).toISOString().split("T")[0];
    dailyEntries.set(day, (dailyEntries.get(day) || 0) + 1);
    userEntryCount.set(e.deviceId, (userEntryCount.get(e.deviceId) || 0) + 1);
  }

  const counts = Array.from(userEntryCount.values());
  counts.sort((a, b) => a - b);

  const activeUsers = userEntryCount.size;
  const avgEntriesPerUser = counts.length > 0
    ? +(counts.reduce((s, c) => s + c, 0) / counts.length).toFixed(1)
    : 0;
  const medianEntries = counts.length > 0 ? counts[Math.floor(counts.length / 2)] : 0;

  // Power users (> 20 entries/week)
  const powerUsers = counts.filter((c) => c > 20).length;

  // Entry source distribution
  const sourceDist: Record<number, number> = {};
  for (const e of entries) {
    const src = e.src ?? 0;
    sourceDist[src] = (sourceDist[src] || 0) + 1;
  }

  // Daily trend (sorted)
  const dailyTrend = Array.from(dailyEntries.entries())
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([date, count]) => ({date, count}));

  return {
    totalUsers,
    activeUsers,
    activationRate: +(activeUsers / (totalUsers || 1) * 100).toFixed(1),
    avgEntriesPerUser,
    medianEntries,
    powerUsers,
    powerUserRate: +(powerUsers / (activeUsers || 1) * 100).toFixed(1),
    sourceDistribution: sourceDist,
    dailyTrend,
  };
}

// ─── 8. AI Training Dataset Stats ─────────────────────────

function computeAiDatasetStats(entries: CompactEntry[]) {
  let withThumbnail = 0;
  let withIngredients = 0;
  let withBoundingBox = 0;
  let withCalibration = 0;
  let withHighConfidence = 0; // AI confidence >= 0.8

  // quality tiers
  let tierPlatinum = 0; // image + labels + bbox + calibration + ingredients
  let tierGold = 0;     // image + labels + ingredients
  let tierSilver = 0;   // image + labels
  let tierBronze = 0;   // image only

  const labelFrequency = new Map<string, number>();
  const referenceObjects = new Map<string, number>();
  const resolutions = new Map<string, number>();

  for (const e of entries) {
    const hasThumbnail = !!e.tu;
    const hasIngredients = !!e.ij;
    const hasBbox = !!e.alj;
    const hasCalib = !!e.cal && !!e.apc;
    const hasHighConf = (e.ac ?? 0) >= 0.8;

    if (hasThumbnail) withThumbnail++;
    if (hasIngredients) withIngredients++;
    if (hasBbox) withBoundingBox++;
    if (hasCalib) withCalibration++;
    if (hasHighConf) withHighConfidence++;

    // Quality tiers (requires thumbnail at minimum)
    if (hasThumbnail) {
      if (hasBbox && hasCalib && hasIngredients) tierPlatinum++;
      else if (hasIngredients && (hasBbox || hasHighConf)) tierGold++;
      else if (hasIngredients || hasBbox) tierSilver++;
      else tierBronze++;
    }

    // AR label frequency (from bounding box data)
    if (e.alj) {
      try {
        const labels = JSON.parse(e.alj);
        if (Array.isArray(labels)) {
          for (const lb of labels) {
            const name = (lb.l || "").toLowerCase().trim();
            if (name) labelFrequency.set(name, (labelFrequency.get(name) || 0) + 1);
          }
        }
      } catch (_) { /* skip */ }
    }

    // Reference objects used for calibration
    if (e.ro) {
      referenceObjects.set(e.ro, (referenceObjects.get(e.ro) || 0) + 1);
    }

    // Image resolutions
    if (e.aiw && e.aih) {
      const res = `${Math.round(e.aiw)}x${Math.round(e.aih)}`;
      resolutions.set(res, (resolutions.get(res) || 0) + 1);
    }
  }

  const total = entries.length || 1;

  return {
    totalEntries: entries.length,
    withThumbnail,
    withIngredients,
    withBoundingBox,
    withCalibration,
    withHighConfidence,
    coverageRates: {
      thumbnail: +(withThumbnail / total * 100).toFixed(1),
      ingredients: +(withIngredients / total * 100).toFixed(1),
      boundingBox: +(withBoundingBox / total * 100).toFixed(1),
      calibration: +(withCalibration / total * 100).toFixed(1),
      highConfidence: +(withHighConfidence / total * 100).toFixed(1),
    },
    qualityTiers: {
      platinum: tierPlatinum,
      gold: tierGold,
      silver: tierSilver,
      bronze: tierBronze,
      platinumRate: +(tierPlatinum / (withThumbnail || 1) * 100).toFixed(1),
    },
    detectedLabels: Array.from(labelFrequency.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 50)
      .map(([label, count]) => ({label, count})),
    referenceObjects: Object.fromEntries(referenceObjects),
    resolutions: Array.from(resolutions.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([res, count]) => ({resolution: res, count})),
    estimatedDatasetValue: estimateDatasetValue(
      withThumbnail, tierPlatinum, tierGold, tierSilver, tierBronze
    ),
  };
}

function estimateDatasetValue(
  totalImages: number, platinum: number, gold: number, silver: number, bronze: number
) {
  // Per-image pricing based on quality tier
  const platinumPrice = 0.50;  // image + bbox + calibration + ingredients
  const goldPrice = 0.25;       // image + labels + ingredients
  const silverPrice = 0.10;     // image + labels
  const bronzePrice = 0.03;     // image only

  const totalValue = platinum * platinumPrice + gold * goldPrice +
    silver * silverPrice + bronze * bronzePrice;

  return {
    totalImages,
    perImagePricing: {platinum: platinumPrice, gold: goldPrice, silver: silverPrice, bronze: bronzePrice},
    estimatedTotalUSD: +totalValue.toFixed(2),
    monthlyLicenseEstimate: +(totalValue * 0.15).toFixed(2),
  };
}

// ═══════════════════════════════════════════════════════════
// EXPORT: exportDataset
// POST /exportDataset { minConfidence: 0.8, tier: "gold", limit: 1000 }
// Generates a JSONL manifest for AI training
// ═══════════════════════════════════════════════════════════

export const exportDataset = onRequest(
  {timeoutSeconds: 540, memory: "1GiB", cors: true},
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const minConfidence = parseFloat(req.body?.minConfidence || "0");
      const minTier = req.body?.tier || "bronze"; // platinum, gold, silver, bronze
      const limit = parseInt(req.body?.limit || "5000");
      const days = parseInt(req.body?.days || "30");

      const {allEntries} = await collectSyncData(days);

      const tierRank: Record<string, number> = {platinum: 4, gold: 3, silver: 2, bronze: 1};
      const minTierRank = tierRank[minTier] || 1;

      const dataset: any[] = [];

      for (const e of allEntries) {
        if (dataset.length >= limit) break;
        if (!e.tu) continue; // must have thumbnail
        if (minConfidence > 0 && (e.ac ?? 0) < minConfidence) continue;

        // Determine tier
        const hasBbox = !!e.alj;
        const hasCalib = !!e.cal && !!e.apc;
        const hasIngredients = !!e.ij;
        let tier = "bronze";
        let rank = 1;
        if (hasBbox && hasCalib && hasIngredients) { tier = "platinum"; rank = 4; }
        else if (hasIngredients && (hasBbox || (e.ac ?? 0) >= 0.8)) { tier = "gold"; rank = 3; }
        else if (hasIngredients || hasBbox) { tier = "silver"; rank = 2; }

        if (rank < minTierRank) continue;

        // Build anonymized record (no deviceId, no personal info)
        const record: any = {
          image_url: e.tu,
          food_name: e.fn,
          food_name_en: e.fe || null,
          meal_type: ["breakfast", "lunch", "dinner", "snack"][e.mt] || "other",
          tier,
          nutrition: {
            calories: e.k,
            protein: e.p,
            carbs: e.c,
            fat: e.f,
            fiber: e.fi ?? null,
            sodium: e.so ?? null,
            sugar: e.su2 ?? null,
            cholesterol: e.ch ?? null,
            saturated_fat: e.sf ?? null,
          },
          ai_confidence: e.ac ?? null,
        };

        // Ingredients
        if (e.ij) {
          try {
            record.ingredients = JSON.parse(e.ij);
          } catch (_) { /* skip */ }
        }

        // AR Scale / Bounding boxes
        if (e.alj) {
          try {
            const labels = JSON.parse(e.alj);
            record.detected_objects = labels.map((lb: any) => ({
              label: lb.l,
              confidence: lb.c,
              center_x: lb.x,
              center_y: lb.y,
              bbox_width: lb.w,
              bbox_height: lb.h,
            }));
          } catch (_) { /* skip */ }
        }

        // Calibration data
        if (e.cal && e.apc) {
          record.calibration = {
            reference_object: e.ro || null,
            reference_confidence: e.rcf ?? null,
            pixel_per_cm: e.apc,
            plate_diameter_cm: e.pd ?? null,
            estimated_volume_ml: e.ev ?? null,
            image_width_px: e.aiw ?? null,
            image_height_px: e.aih ?? null,
          };
        }

        dataset.push(record);
      }

      // Return as JSONL-style array
      res.status(200).json({
        success: true,
        format: "jsonl_array",
        version: "1.0",
        exportedAt: new Date().toISOString(),
        filter: {minConfidence, minTier, days, limit},
        totalRecords: dataset.length,
        tierBreakdown: {
          platinum: dataset.filter((d) => d.tier === "platinum").length,
          gold: dataset.filter((d) => d.tier === "gold").length,
          silver: dataset.filter((d) => d.tier === "silver").length,
          bronze: dataset.filter((d) => d.tier === "bronze").length,
        },
        dataset,
      });
    } catch (error: any) {
      console.error("❌ [exportDataset]", error);
      res.status(500).json({error: error.message});
    }
  }
);
