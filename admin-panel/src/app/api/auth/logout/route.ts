import { NextResponse } from 'next/server';
import { signOut } from '@/auth';

export async function POST() {
  await signOut({ redirectTo: '/login' });
  return NextResponse.json({ success: true });
}
