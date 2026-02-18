import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';

export async function checkAuth(request: NextRequest) {
  const session = await auth();

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  return null; // Auth success
}
