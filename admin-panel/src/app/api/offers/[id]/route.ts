import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

// GET: ดึง offer template เดียว
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const doc = await db.collection('offer_templates').doc(id).get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Offer not found' },
        { status: 404 }
      );
    }

    const data = doc.data()!;
    return NextResponse.json({
      success: true,
      offer: {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
      },
    });
  } catch (error: any) {
    console.error('Error fetching offer:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// PUT: อัปเดต offer template
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const body = await request.json();

    // Check if offer exists
    const docRef = db.collection('offer_templates').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Offer not found' },
        { status: 404 }
      );
    }

    const existingData = doc.data()!;

    // ─── Validation (same as POST) ───
    if (body.slug !== undefined) {
      if (!body.slug || !body.slug.trim()) {
        return NextResponse.json(
          { success: false, error: 'Slug is required' },
          { status: 400 }
        );
      }

      if (!/^[a-z0-9_]+$/.test(body.slug)) {
        return NextResponse.json(
          { success: false, error: 'Slug must be lowercase + underscore only (snake_case)' },
          { status: 400 }
        );
      }

      // Check slug uniqueness (excluding current doc)
      const existingSlug = await db
        .collection('offer_templates')
        .where('slug', '==', body.slug)
        .get();
      const slugConflict = existingSlug.docs.find((d) => d.id !== id);
      if (slugConflict) {
        return NextResponse.json(
          { success: false, error: 'Slug already exists' },
          { status: 400 }
        );
      }
    }

    if (body.triggerEvent !== undefined) {
      const validTriggerEvents = [
        'first_energy_use',
        'energy_use_milestone',
        'tier_up',
        'first_app_open',
        'meals_logged_milestone',
        'first_purchase_complete',
      ];
      if (!validTriggerEvents.includes(body.triggerEvent)) {
        return NextResponse.json(
          { success: false, error: `triggerEvent must be one of: ${validTriggerEvents.join(', ')}` },
          { status: 400 }
        );
      }
      // Warn if triggerEvent changed (but don't block)
      if (body.triggerEvent !== existingData.triggerEvent) {
        console.warn(`⚠️ [Offer Update] triggerEvent changed from ${existingData.triggerEvent} to ${body.triggerEvent} - existing activated offers won't be affected`);
      }
    }

    if (body.title?.en !== undefined && !body.title.en.trim()) {
      return NextResponse.json(
        { success: false, error: 'English title is required' },
        { status: 400 }
      );
    }

    if (body.rewardType !== undefined) {
      const validRewardTypes = ['special_product', 'bonus_rate', 'free_energy', 'subscription_deal'];
      if (!validRewardTypes.includes(body.rewardType)) {
        return NextResponse.json(
          { success: false, error: `rewardType must be one of: ${validRewardTypes.join(', ')}` },
          { status: 400 }
        );
      }
    }

    // Validate expiresAfterHours
    if (body.expiresAfterHours !== undefined && body.expiresAfterHours !== null) {
      if (typeof body.expiresAfterHours !== 'number' || body.expiresAfterHours < 1) {
        return NextResponse.json(
          { success: false, error: 'expiresAfterHours must be >= 1 or null' },
          { status: 400 }
        );
      }
    }

    // Validate rewardConfig — check against final rewardType (new or existing)
    const effectiveRewardType = body.rewardType ?? existingData.rewardType;
    const effectiveRewardConfig = body.rewardConfig ?? existingData.rewardConfig;
    if (body.rewardConfig !== undefined || body.rewardType !== undefined) {
      const rewardType = effectiveRewardType;
      const rewardConfig = effectiveRewardConfig;

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
    }

    if (body.priority !== undefined && body.priority < 1) {
      return NextResponse.json(
        { success: false, error: 'Priority must be >= 1' },
        { status: 400 }
      );
    }

    if (body.maxClaimsPerUser !== undefined && body.maxClaimsPerUser < 1) {
      return NextResponse.json(
        { success: false, error: 'maxClaimsPerUser must be >= 1' },
        { status: 400 }
      );
    }

    // ─── Prepare update data ───
    const updateData: any = {
      updatedAt: Timestamp.now(),
    };

    if (body.slug !== undefined) updateData.slug = body.slug.trim();
    if (body.triggerEvent !== undefined) updateData.triggerEvent = body.triggerEvent;
    if (body.triggerCondition !== undefined) updateData.triggerCondition = body.triggerCondition;
    if (body.title !== undefined) {
      updateData.title = {
        en: body.title.en?.trim() || existingData.title?.en || '',
        th: body.title.th?.trim() || body.title.en?.trim() || existingData.title?.th || existingData.title?.en || '',
      };
    }
    if (body.description !== undefined) {
      updateData.description = {
        en: body.description.en?.trim() || '',
        th: body.description.th?.trim() || body.description.en?.trim() || '',
      };
    }
    if (body.ctaText !== undefined) {
      updateData.ctaText = {
        en: body.ctaText.en?.trim() || 'Claim',
        th: body.ctaText.th?.trim() || body.ctaText.en?.trim() || 'Claim',
      };
    }
    if (body.icon !== undefined) updateData.icon = body.icon;
    if (body.rewardType !== undefined) updateData.rewardType = body.rewardType;
    if (body.rewardConfig !== undefined) updateData.rewardConfig = body.rewardConfig;
    if (body.expiresAfterHours !== undefined) {
      updateData.expiresAfterHours = body.expiresAfterHours !== null ? body.expiresAfterHours : null;
    }
    if (body.priority !== undefined) updateData.priority = body.priority;
    if (body.maxClaimsPerUser !== undefined) updateData.maxClaimsPerUser = body.maxClaimsPerUser;
    if (body.isActive !== undefined) updateData.isActive = body.isActive;

    await docRef.update(updateData);

    return NextResponse.json({
      success: true,
    });
  } catch (error: any) {
    console.error('Error updating offer:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// DELETE: ลบ offer template
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const docRef = db.collection('offer_templates').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Offer not found' },
        { status: 404 }
      );
    }

    await docRef.delete();

    return NextResponse.json({
      success: true,
    });
  } catch (error: any) {
    console.error('Error deleting offer:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
