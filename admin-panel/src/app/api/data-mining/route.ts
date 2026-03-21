import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  const authError = await checkAuth(request);
  if (authError) return authError;

  try {
    const { searchParams } = new URL(request.url);
    const period = searchParams.get('period') || 'latest';

    if (period === 'latest') {
      const latestDoc = await db.collection('data_mining_reports').doc('latest').get();
      if (!latestDoc.exists) {
        return NextResponse.json({ success: false, error: 'No reports computed yet' });
      }
      const latestPeriod = latestDoc.data()!.period;
      const reportDoc = await db.collection('data_mining_reports').doc(latestPeriod).get();
      if (!reportDoc.exists) {
        return NextResponse.json({ success: false, error: 'Report not found' });
      }
      return NextResponse.json({ success: true, report: reportDoc.data() });
    }

    const reportDoc = await db.collection('data_mining_reports').doc(period).get();
    if (!reportDoc.exists) {
      return NextResponse.json({ success: false, error: `Report not found: ${period}` });
    }
    return NextResponse.json({ success: true, report: reportDoc.data() });
  } catch (error: any) {
    console.error('[DataMining API]', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  const authError = await checkAuth(request);
  if (authError) return authError;

  try {
    const body = await request.json();
    const action = body.action;

    if (action === 'trigger') {
      const days = body.days || 7;
      const result = await triggerComputation(days);
      return NextResponse.json({ success: true, ...result });
    }

    if (action === 'export') {
      const dataset = await exportDataset(body);
      return NextResponse.json({ success: true, ...dataset });
    }

    return NextResponse.json({ error: 'Unknown action' }, { status: 400 });
  } catch (error: any) {
    console.error('[DataMining API POST]', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// Direct Firestore aggregation (same logic as Cloud Function but server-side)
async function triggerComputation(days: number) {
  const weekEnd = new Date();
  const weekStart = new Date();
  weekStart.setDate(weekStart.getDate() - days);
  const periodLabel = `${fmt(weekStart)}_${fmt(weekEnd)}`;

  const { allEntries, profiles, totalSyncUsers } = await collectSyncData(days);

  if (allEntries.length === 0) {
    return { message: 'No entries to process', period: periodLabel };
  }

  const report = {
    period: periodLabel,
    computedAt: new Date().toISOString(),
    totalEntries: allEntries.length,
    totalUsers: totalSyncUsers,
    topFoods: computeTopFoods(allEntries),
    ingredientFreq: computeIngredientFrequency(allEntries),
    nutritionGap: computeNutritionGap(allEntries, profiles),
    mealTiming: computeMealTiming(allEntries),
    demographics: computeDemographics(profiles),
    macroSegments: computeMacroSegments(allEntries),
    engagement: computeEngagement(allEntries, totalSyncUsers),
    aiDataset: computeAiDatasetStats(allEntries),
  };

  await db.collection('data_mining_reports').doc(periodLabel).set(report);
  await db.collection('data_mining_reports').doc('latest').set({
    period: periodLabel,
    computedAt: new Date().toISOString(),
  });

  return { period: periodLabel, totalEntries: allEntries.length, totalUsers: totalSyncUsers };
}

async function exportDataset(opts: any) {
  const days = opts.days || 90;
  const minTier = opts.tier || 'bronze';
  const minConf = opts.minConfidence || 0;
  const limit = opts.limit || 5000;

  const { allEntries } = await collectSyncData(days);
  const tierRank: Record<string, number> = { platinum: 4, gold: 3, silver: 2, bronze: 1 };
  const minRank = tierRank[minTier] || 1;

  const dataset: any[] = [];
  for (const e of allEntries) {
    if (dataset.length >= limit) break;
    if (!e.tu) continue;
    if (minConf > 0 && (e.ac ?? 0) < minConf) continue;

    const hasBbox = !!e.alj;
    const hasCalib = !!e.cal && !!e.apc;
    const hasIng = !!e.ij;
    let tier = 'bronze', rank = 1;
    if (hasBbox && hasCalib && hasIng) { tier = 'platinum'; rank = 4; }
    else if (hasIng && (hasBbox || (e.ac ?? 0) >= 0.8)) { tier = 'gold'; rank = 3; }
    else if (hasIng || hasBbox) { tier = 'silver'; rank = 2; }

    if (rank < minRank) continue;

    const rec: any = {
      image_url: e.tu, food_name: e.fn, food_name_en: e.fe || null,
      meal_type: ['breakfast', 'lunch', 'dinner', 'snack'][e.mt] || 'other',
      tier,
      nutrition: { calories: e.k, protein: e.p, carbs: e.c, fat: e.f,
        fiber: e.fi ?? null, sodium: e.so ?? null, sugar: e.su2 ?? null },
      ai_confidence: e.ac ?? null,
    };
    if (e.ij) try { rec.ingredients = JSON.parse(e.ij); } catch {}
    if (e.alj) try {
      rec.detected_objects = JSON.parse(e.alj).map((lb: any) => ({
        label: lb.l, confidence: lb.c, center_x: lb.x, center_y: lb.y,
        bbox_width: lb.w, bbox_height: lb.h,
      }));
    } catch {}
    if (e.cal && e.apc) {
      rec.calibration = {
        reference_object: e.ro || null, pixel_per_cm: e.apc,
        plate_diameter_cm: e.pd ?? null, estimated_volume_ml: e.ev ?? null,
        image_width_px: e.aiw ?? null, image_height_px: e.aih ?? null,
      };
    }
    dataset.push(rec);
  }

  return {
    format: 'jsonl_array', version: '1.0',
    exportedAt: new Date().toISOString(),
    totalRecords: dataset.length,
    tierBreakdown: {
      platinum: dataset.filter(d => d.tier === 'platinum').length,
      gold: dataset.filter(d => d.tier === 'gold').length,
      silver: dataset.filter(d => d.tier === 'silver').length,
      bronze: dataset.filter(d => d.tier === 'bronze').length,
    },
    dataset,
  };
}

// ═══════════════════════════════════════════════════════
// Data Collection & Computation (mirrors dataMining.ts)
// ═══════════════════════════════════════════════════════

interface Entry {
  deviceId: string; fn: string; ts: number; mt: number;
  k: number; p: number; c: number; f: number;
  fi?: number; so?: number; su2?: number; ch?: number; sf?: number;
  ij?: string; src?: number; ac?: number; fe?: string;
  tu?: string; ro?: string; cal?: boolean; rcf?: number;
  pd?: number; ev?: number; alj?: string; aiw?: number; aih?: number; apc?: number;
}
interface Prof { deviceId: string; g?: string; a?: number; w?: number; h?: number; kg?: number; pg?: number; al?: string; cu?: string; }

function fmt(d: Date) { return d.toISOString().split('T')[0]; }

async function collectSyncData(days: number) {
  const allEntries: Entry[] = [];
  const profiles = new Map<string, Prof>();
  const syncUsers = await db.collection('user_sync').listDocuments();

  for (const ref of syncUsers) {
    const did = ref.id;
    const doc = await ref.get();
    if (doc.exists && doc.data()?.profile) profiles.set(did, { deviceId: did, ...doc.data()!.profile });

    const logs = await ref.collection('daily_logs').orderBy('updatedAt', 'desc').limit(days).get();
    for (const logDoc of logs.docs) {
      const data = logDoc.data();
      if (data.entries && Array.isArray(data.entries)) {
        for (const entry of data.entries) {
          if (entry.fn && entry.ts) allEntries.push({ deviceId: did, ...entry });
        }
      }
    }
  }
  return { allEntries, profiles, totalSyncUsers: syncUsers.length };
}

function computeTopFoods(entries: Entry[]) {
  const m = new Map<string, { count: number; tk: number; tp: number; tc: number; tf: number; mt: Record<number, number>; u: Set<string> }>();
  for (const e of entries) {
    const n = e.fn.toLowerCase().trim();
    if (!m.has(n)) m.set(n, { count: 0, tk: 0, tp: 0, tc: 0, tf: 0, mt: {}, u: new Set() });
    const f = m.get(n)!;
    f.count++; f.tk += e.k || 0; f.tp += e.p || 0; f.tc += e.c || 0; f.tf += e.f || 0;
    f.mt[e.mt] = (f.mt[e.mt] || 0) + 1; f.u.add(e.deviceId);
  }
  return Array.from(m.entries()).sort((a, b) => b[1].count - a[1].count).slice(0, 50).map(([name, d]) => ({
    food: name, count: d.count, uniqueUsers: d.u.size,
    avgKcal: Math.round(d.tk / d.count), avgProtein: +(d.tp / d.count).toFixed(1),
    avgCarbs: +(d.tc / d.count).toFixed(1), avgFat: +(d.tf / d.count).toFixed(1), mealTypes: d.mt,
  }));
}

function computeIngredientFrequency(entries: Entry[]) {
  const m = new Map<string, { count: number; u: Set<string> }>();
  for (const e of entries) {
    if (!e.ij) continue;
    try {
      const ings = JSON.parse(e.ij);
      if (!Array.isArray(ings)) continue;
      for (const i of ings) {
        const n = (i.name || i.foodName || '').toLowerCase().trim();
        if (!n || n.length < 2) continue;
        if (!m.has(n)) m.set(n, { count: 0, u: new Set() });
        m.get(n)!.count++; m.get(n)!.u.add(e.deviceId);
      }
    } catch {}
  }
  return Array.from(m.entries()).sort((a, b) => b[1].count - a[1].count).slice(0, 100)
    .map(([name, d]) => ({ ingredient: name, count: d.count, uniqueUsers: d.u.size }));
}

const RDA = { calories: 2000, protein: 50, carbs: 275, fat: 78, fiber: 28, sodium: 2300, sugar: 50, cholesterol: 300 };

function computeNutritionGap(entries: Entry[], profiles: Map<string, Prof>) {
  const days = new Map<string, { k: number; p: number; c: number; f: number; fi: number; so: number; su: number; ch: number }>();
  for (const e of entries) {
    const key = `${e.deviceId}_${new Date(e.ts).toISOString().split('T')[0]}`;
    if (!days.has(key)) days.set(key, { k: 0, p: 0, c: 0, f: 0, fi: 0, so: 0, su: 0, ch: 0 });
    const t = days.get(key)!;
    t.k += e.k || 0; t.p += e.p || 0; t.c += e.c || 0; t.f += e.f || 0;
    t.fi += e.fi || 0; t.so += e.so || 0; t.su += e.su2 || 0; t.ch += e.ch || 0;
  }
  const tots = Array.from(days.values()); const n = tots.length || 1;
  const avg = {
    calories: Math.round(tots.reduce((s, t) => s + t.k, 0) / n),
    protein: +(tots.reduce((s, t) => s + t.p, 0) / n).toFixed(1),
    carbs: +(tots.reduce((s, t) => s + t.c, 0) / n).toFixed(1),
    fat: +(tots.reduce((s, t) => s + t.f, 0) / n).toFixed(1),
    fiber: +(tots.reduce((s, t) => s + t.fi, 0) / n).toFixed(1),
    sodium: Math.round(tots.reduce((s, t) => s + t.so, 0) / n),
    sugar: +(tots.reduce((s, t) => s + t.su, 0) / n).toFixed(1),
    cholesterol: Math.round(tots.reduce((s, t) => s + t.ch, 0) / n),
  };
  const def = {
    protein: +(tots.filter(t => t.p < RDA.protein * 0.8).length / n * 100).toFixed(1),
    fiber: +(tots.filter(t => t.fi < RDA.fiber * 0.8).length / n * 100).toFixed(1),
    excessSodium: +(tots.filter(t => t.so > RDA.sodium).length / n * 100).toFixed(1),
    excessSugar: +(tots.filter(t => t.su > RDA.sugar).length / n * 100).toFixed(1),
    excessCholesterol: +(tots.filter(t => t.ch > RDA.cholesterol).length / n * 100).toFixed(1),
  };
  const goalUsers = Array.from(profiles.values()).filter(p => p.kg && p.kg > 0);
  const avgGoal = goalUsers.length > 0 ? Math.round(goalUsers.reduce((s, p) => s + (p.kg || 2000), 0) / goalUsers.length) : 2000;
  return {
    sampleDays: n, avgDailyIntake: avg, rda: RDA, avgCalorieGoal: avgGoal,
    deficiencyRates: def,
    goalAchievementRate: +(tots.filter(t => t.k >= avgGoal * 0.9 && t.k <= avgGoal * 1.1).length / n * 100).toFixed(1),
  };
}

function computeMealTiming(entries: Entry[]) {
  const hourDist = new Array(24).fill(0);
  const mtByHour: Record<number, number[]> = {};
  for (let i = 0; i < 4; i++) mtByHour[i] = new Array(24).fill(0);
  for (const e of entries) {
    const h = new Date(e.ts).getHours();
    hourDist[h]++;
    if (e.mt >= 0 && e.mt < 4) mtByHour[e.mt][h]++;
  }
  const names = ['breakfast', 'lunch', 'dinner', 'snack'];
  const peaks: Record<string, { peakHour: number; count: number }> = {};
  for (let i = 0; i < 4; i++) {
    const hrs = mtByHour[i]; const mx = hrs.indexOf(Math.max(...hrs));
    peaks[names[i]] = { peakHour: mx, count: hrs[mx] };
  }
  return {
    hourlyDistribution: hourDist, mealTypeByHour: mtByHour, peakHours: peaks,
    lateNightEating: +(entries.filter(e => { const h = new Date(e.ts).getHours(); return h >= 22 || h < 5; }).length / entries.length * 100).toFixed(1),
  };
}

function computeDemographics(profiles: Map<string, Prof>) {
  const all = Array.from(profiles.values());
  const gender: Record<string, number> = {};
  const age: Record<string, number> = { '<18': 0, '18-24': 0, '25-34': 0, '35-44': 0, '45-54': 0, '55+': 0 };
  const activity: Record<string, number> = {};
  const cuisine: Record<string, number> = {};
  const bmi: Record<string, number> = { underweight: 0, normal: 0, overweight: 0, obese: 0 };
  for (const p of all) {
    if (p.g) gender[p.g] = (gender[p.g] || 0) + 1;
    if (p.a) { if (p.a < 18) age['<18']++; else if (p.a <= 24) age['18-24']++; else if (p.a <= 34) age['25-34']++; else if (p.a <= 44) age['35-44']++; else if (p.a <= 54) age['45-54']++; else age['55+']++; }
    if (p.al) activity[p.al] = (activity[p.al] || 0) + 1;
    if (p.cu) cuisine[p.cu] = (cuisine[p.cu] || 0) + 1;
    if (p.w && p.h && p.h > 0) { const b = p.w / Math.pow(p.h / 100, 2); if (b < 18.5) bmi.underweight++; else if (b < 25) bmi.normal++; else if (b < 30) bmi.overweight++; else bmi.obese++; }
  }
  const ww = all.filter(p => p.w), wh = all.filter(p => p.h), wa = all.filter(p => p.a);
  return {
    totalProfiles: all.length, gender, ageGroups: age, activityLevel: activity, cuisinePreference: cuisine, bmi,
    averages: {
      weight: ww.length > 0 ? +(ww.reduce((s, p) => s + p.w!, 0) / ww.length).toFixed(1) : null,
      height: wh.length > 0 ? +(wh.reduce((s, p) => s + p.h!, 0) / wh.length).toFixed(1) : null,
      age: wa.length > 0 ? Math.round(wa.reduce((s, p) => s + p.a!, 0) / wa.length) : null,
    },
  };
}

function computeMacroSegments(entries: Entry[]) {
  const um = new Map<string, { tk: number; tp: number; tc: number; tf: number }>();
  for (const e of entries) {
    if (!um.has(e.deviceId)) um.set(e.deviceId, { tk: 0, tp: 0, tc: 0, tf: 0 });
    const u = um.get(e.deviceId)!;
    u.tk += e.k || 0; u.tp += e.p || 0; u.tc += e.c || 0; u.tf += e.f || 0;
  }
  const seg: Record<string, number> = { high_protein: 0, low_carb: 0, high_carb: 0, high_fat: 0, balanced: 0, other: 0 };
  for (const [, u] of um) {
    if (u.tk === 0) continue;
    const pp = (u.tp * 4) / u.tk * 100, cp = (u.tc * 4) / u.tk * 100, fp = (u.tf * 9) / u.tk * 100;
    if (pp > 30) seg.high_protein++;
    else if (cp < 30) seg.low_carb++;
    else if (cp > 60) seg.high_carb++;
    else if (fp > 40) seg.high_fat++;
    else if (pp >= 15 && pp <= 25 && cp >= 45 && cp <= 65 && fp >= 20 && fp <= 35) seg.balanced++;
    else seg.other++;
  }
  const tot = Array.from(um.values()).filter(u => u.tk > 0).length || 1;
  return {
    distribution: seg, totalUsersAnalyzed: tot,
    percentages: Object.fromEntries(Object.entries(seg).map(([k, v]) => [k, +(v / tot * 100).toFixed(1)])),
  };
}

function computeEngagement(entries: Entry[], totalUsers: number) {
  const daily = new Map<string, number>(), uc = new Map<string, number>();
  for (const e of entries) {
    const d = new Date(e.ts).toISOString().split('T')[0];
    daily.set(d, (daily.get(d) || 0) + 1);
    uc.set(e.deviceId, (uc.get(e.deviceId) || 0) + 1);
  }
  const counts = Array.from(uc.values()).sort((a, b) => a - b);
  const active = uc.size;
  const srcDist: Record<number, number> = {};
  for (const e of entries) { const s = e.src ?? 0; srcDist[s] = (srcDist[s] || 0) + 1; }
  return {
    totalUsers, activeUsers: active,
    activationRate: +(active / (totalUsers || 1) * 100).toFixed(1),
    avgEntriesPerUser: counts.length ? +(counts.reduce((s, c) => s + c, 0) / counts.length).toFixed(1) : 0,
    medianEntries: counts.length ? counts[Math.floor(counts.length / 2)] : 0,
    powerUsers: counts.filter(c => c > 20).length,
    powerUserRate: +(counts.filter(c => c > 20).length / (active || 1) * 100).toFixed(1),
    sourceDistribution: srcDist,
    dailyTrend: Array.from(daily.entries()).sort((a, b) => a[0].localeCompare(b[0])).map(([date, count]) => ({ date, count })),
  };
}

function computeAiDatasetStats(entries: Entry[]) {
  let wThumb = 0, wIng = 0, wBbox = 0, wCal = 0, wHigh = 0;
  let tPlat = 0, tGold = 0, tSilver = 0, tBronze = 0;
  const labels = new Map<string, number>(), refObjs = new Map<string, number>(), ress = new Map<string, number>();

  for (const e of entries) {
    const ht = !!e.tu, hi = !!e.ij, hb = !!e.alj, hc = !!e.cal && !!e.apc, hh = (e.ac ?? 0) >= 0.8;
    if (ht) wThumb++; if (hi) wIng++; if (hb) wBbox++; if (hc) wCal++; if (hh) wHigh++;
    if (ht) {
      if (hb && hc && hi) tPlat++; else if (hi && (hb || hh)) tGold++;
      else if (hi || hb) tSilver++; else tBronze++;
    }
    if (e.alj) try { for (const lb of JSON.parse(e.alj)) { const n = (lb.l || '').toLowerCase(); if (n) labels.set(n, (labels.get(n) || 0) + 1); } } catch {}
    if (e.ro) refObjs.set(e.ro, (refObjs.get(e.ro) || 0) + 1);
    if (e.aiw && e.aih) { const r = `${Math.round(e.aiw)}x${Math.round(e.aih)}`; ress.set(r, (ress.get(r) || 0) + 1); }
  }

  const tot = entries.length || 1;
  const val = tPlat * 0.5 + tGold * 0.25 + tSilver * 0.1 + tBronze * 0.03;
  return {
    totalEntries: entries.length, withThumbnail: wThumb, withIngredients: wIng, withBoundingBox: wBbox, withCalibration: wCal, withHighConfidence: wHigh,
    coverageRates: { thumbnail: +(wThumb / tot * 100).toFixed(1), ingredients: +(wIng / tot * 100).toFixed(1), boundingBox: +(wBbox / tot * 100).toFixed(1), calibration: +(wCal / tot * 100).toFixed(1), highConfidence: +(wHigh / tot * 100).toFixed(1) },
    qualityTiers: { platinum: tPlat, gold: tGold, silver: tSilver, bronze: tBronze, platinumRate: +(tPlat / (wThumb || 1) * 100).toFixed(1) },
    detectedLabels: Array.from(labels.entries()).sort((a, b) => b[1] - a[1]).slice(0, 50).map(([label, count]) => ({ label, count })),
    referenceObjects: Object.fromEntries(refObjs),
    resolutions: Array.from(ress.entries()).sort((a, b) => b[1] - a[1]).slice(0, 10).map(([resolution, count]) => ({ resolution, count })),
    estimatedDatasetValue: { totalImages: wThumb, perImagePricing: { platinum: 0.5, gold: 0.25, silver: 0.1, bronze: 0.03 }, estimatedTotalUSD: +val.toFixed(2), monthlyLicenseEstimate: +(val * 0.15).toFixed(2) },
  };
}
