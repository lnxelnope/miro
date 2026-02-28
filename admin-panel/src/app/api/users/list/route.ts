import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    // Get query parameters
    const searchParams = request.nextUrl.searchParams;
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '25');
    const search = searchParams.get('search') || '';
    const tierFilter = searchParams.get('tier') || '';
    const sortBy = searchParams.get('sortBy') || 'createdAt';
    const sortOrder = searchParams.get('sortOrder') || 'desc';

    // Build query
    let query: any = db.collection('users');

    // Apply tier filter
    if (tierFilter && tierFilter !== 'all') {
      query = query.where('gamificationState.streakTier', '==', tierFilter);
    }

    // Apply sorting
    query = query.orderBy(sortBy, sortOrder as 'asc' | 'desc');

    // Get total count (for pagination)
    const countSnapshot = await query.count().get();
    const totalUsers = countSnapshot.data().count;
    const totalPages = Math.ceil(totalUsers / limit);

    // Apply pagination
    const offset = (page - 1) * limit;
    query = query.limit(limit);
    
    if (offset > 0) {
      // For pagination, we need to use cursor-based approach
      // This is a simplified version - for production, use startAfter()
      query = query.offset(offset);
    }

    // Execute query
    const snapshot = await query.get();

    // Format users data
    let users = snapshot.docs.map((doc: any) => {
      const data = doc.data();
      return {
        id: doc.id,
        miroId: data.miroId || '',
        email: data.email || '',
        displayName: data.displayName || '',
        balance: data.balance || 0,
        createdAt: data.createdAt?.toDate().toISOString() || null,
        lastActiveAt: data.lastActiveAt?.toDate().toISOString() || null,
        streakTier: data.gamificationState?.streakTier || 'none',
        currentStreak: data.gamificationState?.currentStreak || 0,
        isBanned: data.isBanned || false,
      };
    });

    // Apply client-side search filter (case-insensitive)
    if (search) {
      const searchLower = search.toLowerCase();
      users = users.filter(
        (user: any) =>
          user.miroId.toLowerCase().includes(searchLower) ||
          user.email.toLowerCase().includes(searchLower) ||
          user.displayName.toLowerCase().includes(searchLower)
      );
    }

    return NextResponse.json({
      users,
      pagination: {
        page,
        limit,
        totalUsers,
        totalPages,
      },
    });
  } catch (error) {
    console.error('Users list error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users list' },
      { status: 500 }
    );
  }
}
