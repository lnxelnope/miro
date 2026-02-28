import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

// GET: ดึง offer templates ทั้งหมด (เรียงตาม priority)
export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const snapshot = await db
      .collection('offer_templates')
      .orderBy('priority', 'asc')
      .get();

    const offers = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
      };
    });

    return NextResponse.json({ success: true, offers });
  } catch (error: any) {
    console.error('Error fetching offers:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// POST: สร้าง offer template ใหม่
export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const {
      slug,
      triggerEvent,
      triggerCondition,
      title,
      description,
      ctaText,
      icon,
      rewardType,
      rewardConfig,
      expiresAfterHours,
      priority,
      maxClaimsPerUser,
      isActive,
    } = body;

    // ─── Validation ───
    if (!slug || !slug.trim()) {
      return NextResponse.json(
        { success: false, error: 'Slug is required' },
        { status: 400 }
      );
    }

    // Slug must be snake_case (a-z0-9_)
    if (!/^[a-z0-9_]+$/.test(slug)) {
      return NextResponse.json(
        { success: false, error: 'Slug must be lowercase + underscore only (snake_case)' },
        { status: 400 }
      );
    }

    // Check slug uniqueness
    const existingSlug = await db
      .collection('offer_templates')
      .where('slug', '==', slug)
      .get();
    if (!existingSlug.empty) {
      return NextResponse.json(
        { success: false, error: 'Slug already exists' },
        { status: 400 }
      );
    }

    const validTriggerEvents = [
      'first_energy_use',
      'energy_use_milestone',
      'tier_up',
      'first_app_open',
      'meals_logged_milestone',
      'first_purchase_complete',
    ];
    if (!triggerEvent || !validTriggerEvents.includes(triggerEvent)) {
      return NextResponse.json(
        { success: false, error: `triggerEvent must be one of: ${validTriggerEvents.join(', ')}` },
        { status: 400 }
      );
    }

    if (!title?.en || !title.en.trim()) {
      return NextResponse.json(
        { success: false, error: 'English title is required' },
        { status: 400 }
      );
    }

    const validRewardTypes = ['special_product', 'bonus_rate', 'free_energy', 'subscription_deal'];
    if (!rewardType || !validRewardTypes.includes(rewardType)) {
      return NextResponse.json(
        { success: false, error: `rewardType must be one of: ${validRewardTypes.join(', ')}` },
        { status: 400 }
      );
    }

    // Validate rewardConfig based on rewardType
    if (rewardType === 'special_product') {
      if (!rewardConfig?.productId || !rewardConfig?.energyAmount) {
        return NextResponse.json(
          { success: false, error: 'rewardConfig.productId and rewardConfig.energyAmount are required for special_product' },
          { status: 400 }
        );
      }
    } else if (rewardType === 'bonus_rate') {
      if (rewardConfig?.bonusRate === undefined || rewardConfig.bonusRate < 0.01 || rewardConfig.bonusRate > 1.0) {
        return NextResponse.json(
          { success: false, error: 'rewardConfig.bonusRate must be 0.01-1.0 for bonus_rate' },
          { status: 400 }
        );
      }
    } else if (rewardType === 'free_energy') {
      if (!rewardConfig?.amount || rewardConfig.amount < 1) {
        return NextResponse.json(
          { success: false, error: 'rewardConfig.amount must be >= 1 for free_energy' },
          { status: 400 }
        );
      }
    } else if (rewardType === 'subscription_deal') {
      if (!rewardConfig?.productId || !rewardConfig?.basePlanId || !rewardConfig?.offerId) {
        return NextResponse.json(
          { success: false, error: 'rewardConfig.productId, basePlanId, and offerId are required for subscription_deal' },
          { status: 400 }
        );
      }
    }

    if (!priority || priority < 1) {
      return NextResponse.json(
        { success: false, error: 'Priority must be >= 1' },
        { status: 400 }
      );
    }

    if (!maxClaimsPerUser || maxClaimsPerUser < 1) {
      return NextResponse.json(
        { success: false, error: 'maxClaimsPerUser must be >= 1' },
        { status: 400 }
      );
    }

    // ─── Save ───
    const offerData = {
      slug: slug.trim(),
      triggerEvent,
      triggerCondition: triggerCondition || {},
      title: {
        en: title.en.trim(),
        th: title.th?.trim() || title.en.trim(),
      },
      description: {
        en: description?.en?.trim() || '',
        th: description?.th?.trim() || description?.en?.trim() || '',
      },
      ctaText: {
        en: ctaText?.en?.trim() || 'Claim',
        th: ctaText?.th?.trim() || ctaText?.en?.trim() || 'Claim',
      },
      icon: icon || '🎁',
      rewardType,
      rewardConfig: rewardConfig || {},
      expiresAfterHours: expiresAfterHours !== null && expiresAfterHours !== undefined ? expiresAfterHours : null,
      priority,
      maxClaimsPerUser,
      isActive: isActive !== undefined ? isActive : true,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    };

    const docRef = await db.collection('offer_templates').add(offerData);

    return NextResponse.json({
      success: true,
      id: docRef.id,
    });
  } catch (error: any) {
    console.error('Error creating offer:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
