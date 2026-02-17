import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this';
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD_HASH = process.env.ADMIN_PASSWORD_HASH || '';

/**
 * Hash password (run once to generate hash)
 * 
 * Example usage:
 * const hash = await hashPassword('your-password');
 * console.log(hash); // Copy this to .env.local as ADMIN_PASSWORD_HASH
 */
export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

/**
 * Verify username and password
 */
export async function verifyCredentials(
  username: string,
  password: string
): Promise<boolean> {
  if (username !== ADMIN_USERNAME) {
    return false;
  }

  // If ADMIN_PASSWORD_HASH is set, use bcrypt
  if (ADMIN_PASSWORD_HASH) {
    return bcrypt.compare(password, ADMIN_PASSWORD_HASH);
  }

  // Fallback: plain text comparison (for development only!)
  const plainPassword = process.env.ADMIN_PASSWORD || '';
  return password === plainPassword;
}

/**
 * Generate JWT token
 */
export function generateToken(username: string): string {
  return jwt.sign(
    { username, role: 'admin' },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

/**
 * Verify JWT token
 */
export function verifyToken(token: string): { username: string; role: string } | null {
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    return { username: decoded.username, role: decoded.role };
  } catch {
    return null;
  }
}

/**
 * Get token from request cookies
 */
export function getTokenFromRequest(request: NextRequest): string | null {
  return request.cookies.get('admin_token')?.value || null;
}

/**
 * Middleware: Require admin auth
 */
export function requireAuth(handler: Function) {
  return async (request: NextRequest) => {
    const token = getTokenFromRequest(request);

    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized: No token provided' },
        { status: 401 }
      );
    }

    const user = verifyToken(token);

    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized: Invalid token' },
        { status: 401 }
      );
    }

    // Attach user to request (for handler to use)
    (request as any).user = user;

    return handler(request);
  };
}
