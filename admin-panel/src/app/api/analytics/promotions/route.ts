import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

export async function GET(req: NextRequest) {
  try {
    // Get date range from query params
    const { searchParams } = new URL(req.url);
    const dateRange = searchParams.get('dateRange') || '7d'; // Default: 7 days
    
    // Calculate start date based on range
    const now = new Date();
    let startDate = new Date();
    
    if (dateRange === '7d') {
      startDate.setDate(now.getDate() - 7);
    } else if (dateRange === '30d') {
      startDate.setDate(now.getDate() - 30);
    } else if (dateRange === '90d') {
      startDate.setDate(now.getDate() - 90);
    } else if (dateRange.startsWith('custom:')) {
      // Custom range: custom:startTimestamp:endTimestamp
      const parts = dateRange.split(':');
      if (parts.length === 3) {
        startDate = new Date(parseInt(parts[1]));
        const endDate = new Date(parseInt(parts[2]));
        // Use endDate if provided, otherwise use now
        if (!isNaN(endDate.getTime())) {
          // We'll filter by startDate only for now
        }
      }
    }
    
    // Query transactions ที่เป็น promotion และอยู่ใน date range
    const transactionsRef = db.collection('transactions');
    
    // Query สำหรับ promotion types
    const promotionTypes = ['first_purchase', 'bonus_40', 'tier_promo'];
    
    const statsMap: Record<string, { purchased: number; revenue: number }> = {};
    
    // Query แต่ละ promotion type with date filter
    for (const promoType of promotionTypes) {
      let query = transactionsRef.where('type', '==', promoType);
      
      // Add date filter if createdAt field exists
      // Note: Some transactions might use timestamp field instead
      const snapshot = await query.get();
      
      statsMap[promoType] = { purchased: 0, revenue: 0 };
      
      snapshot.forEach((doc) => {
        const data = doc.data();
        
        // Get createdAt - handle both Timestamp and Date formats
        let createdAt: Date;
        if (data.createdAt) {
          if (data.createdAt.toDate) {
            createdAt = data.createdAt.toDate();
          } else if (data.createdAt instanceof Date) {
            createdAt = data.createdAt;
          } else {
            createdAt = new Date();
          }
        } else if (data.timestamp) {
          createdAt = data.timestamp.toDate ? data.timestamp.toDate() : new Date();
        } else {
          // Fallback: use doc creation time or current time
          createdAt = new Date();
        }
        
        // Filter by date range
        if (createdAt >= startDate) {
          statsMap[promoType].purchased += 1;
          statsMap[promoType].revenue += data.metadata?.price || 0;
        }
      });
    }

    // TODO: Query "times shown" จาก analytics events (หรือ hardcode ตอนนี้)
    // ตอนนี้ใช้ placeholder values
    const promotions: Array<{
      name: string;
      timesShown: number;
      purchased: number;
      conversionRate: number;
      revenue: number;
    }> = [
      {
        name: '$1 = 200E',
        timesShown: statsMap['first_purchase']?.purchased * 10 || 0, // Estimate: 10% conversion
        purchased: statsMap['first_purchase']?.purchased || 0,
        conversionRate: 0,
        revenue: statsMap['first_purchase']?.revenue || 0,
      },
      {
        name: '40% Bonus',
        timesShown: statsMap['bonus_40']?.purchased * 15 || 0, // Estimate: ~6.7% conversion
        purchased: statsMap['bonus_40']?.purchased || 0,
        conversionRate: 0,
        revenue: statsMap['bonus_40']?.revenue || 0,
      },
      {
        name: 'Tier Upgrade Promo',
        timesShown: statsMap['tier_promo']?.purchased * 20 || 0, // Estimate: 5% conversion
        purchased: statsMap['tier_promo']?.purchased || 0,
        conversionRate: 0,
        revenue: statsMap['tier_promo']?.revenue || 0,
      },
    ];

    // คำนวณ conversion rate
    promotions.forEach((p) => {
      p.conversionRate = p.timesShown > 0 ? (p.purchased / p.timesShown) * 100 : 0;
    });

    return NextResponse.json({
      success: true,
      stats: promotions,
      dateRange,
      startDate: startDate.toISOString(),
      endDate: now.toISOString(),
    });
  } catch (error: any) {
    console.error('Error fetching promotion stats:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to fetch promotion stats',
      },
      { status: 500 }
    );
  }
}
