# Task 1: Admin Panel Setup — Next.js + Firebase Admin

**ระยะเวลา:** 1 วัน  
**Tech Stack:** Next.js 14+ (App Router), TypeScript, Tailwind CSS, Firebase Admin SDK

---

## ✅ Checklist

```bash
□ Download Service Account Key จาก Firebase
□ ติดตั้ง dependencies ทั้งหมด
□ Setup Firebase Admin SDK
□ สร้าง Authentication system
□ สร้าง Layout (Sidebar + Header)
□ Test connection (/api/test)
□ Test login
```

---

## 📋 Step 1: Download Service Account Key

### 1.1 ไปที่ Firebase Console

เปิดลิงก์นี้:
```
https://console.firebase.google.com/project/miro-d6856/settings/serviceaccounts/adminsdk
```

### 1.2 Generate Private Key

1. คลิกปุ่ม **"Generate new private key"**
2. คลิก **"Generate key"** (popup จะขึ้น)
3. ไฟล์ JSON จะถูก download (ชื่อประมาณ `miro-d6856-firebase-adminsdk-xxxxx.json`)

### 1.3 เปลี่ยนชื่อและวางไฟล์

```bash
# เปลี่ยนชื่อเป็น:
serviceAccountKey.json

# วางที่:
C:\aiprogram\miro\admin-panel\serviceAccountKey.json
```

**⚠️ สำคัญ:** อย่า commit ไฟล์นี้ขึ้น Git! (ถูก ignore แล้วใน .gitignore)

---

## 📋 Step 2: ติดตั้ง Dependencies

เปิด Terminal ใน `admin-panel/`:

```bash
cd C:\aiprogram\miro\admin-panel

# Firebase Admin SDK
npm install firebase-admin

# UI Components (shadcn/ui)
npx shadcn-ui@latest init

# เลือก options:
# - Style: Default
# - Base color: Slate
# - CSS variables: Yes

# ติดตั้ง components
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add input
npx shadcn-ui@latest add label
npx shadcn-ui@latest add table
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add tabs

# Charts
npm install recharts

# Date utilities
npm install date-fns

# Icons
npm install lucide-react

# JWT for auth
npm install jsonwebtoken
npm install --save-dev @types/jsonwebtoken

# Bcrypt for password hashing
npm install bcryptjs
npm install --save-dev @types/bcryptjs
```

**ตรวจสอบ `package.json`:**
```json
{
  "dependencies": {
    "firebase-admin": "^12.x.x",
    "recharts": "^2.x.x",
    "date-fns": "^3.x.x",
    "lucide-react": "^0.x.x",
    "jsonwebtoken": "^9.x.x",
    "bcryptjs": "^2.x.x"
  }
}
```

---

## 📋 Step 3: Setup Firebase Admin SDK

### 3.1 ตรวจสอบไฟล์ที่มีอยู่แล้ว

```bash
admin-panel/
├── lib/
│   └── firebase-admin.ts    ✅ มีอยู่แล้ว (ฉันสร้างให้)
├── app/
│   └── api/
│       └── test/
│           └── route.ts     ✅ มีอยู่แล้ว (ฉันสร้างให้)
└── .env.local              ✅ มีอยู่แล้ว (คุณแก้ไขแล้ว)
```

### 3.2 ตรวจสอบว่า serviceAccountKey.json อยู่ที่ถูกที่

```bash
# ควรมีไฟล์นี้:
admin-panel/serviceAccountKey.json
```

### 3.3 Test Connection

```bash
# Run dev server
npm run dev
```

เปิดเบราว์เซอร์: http://localhost:3000/api/test

**ถ้าสำเร็จจะเห็น:**
```json
{
  "success": true,
  "message": "✅ Firebase Admin connected successfully!",
  "userCount": 0,
  "timestamp": "2026-02-17T..."
}
```

**ถ้า error:**
- ✅ เช็คว่า `serviceAccountKey.json` อยู่ถูกที่
- ✅ เช็คว่าไฟล์ไม่เสีย (เป็น JSON ที่ถูกต้อง)
- ✅ ดู error logs ใน terminal

---

## 📋 Step 4: สร้าง Authentication System

### 4.1 สร้าง `lib/auth.ts`

```typescript
// lib/auth.ts

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
```

**บันทึกไฟล์:** `admin-panel/lib/auth.ts`

### 4.2 สร้าง Login API Route

```typescript
// app/api/auth/login/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { verifyCredentials, generateToken } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { username, password } = body;

    if (!username || !password) {
      return NextResponse.json(
        { error: 'Username and password are required' },
        { status: 400 }
      );
    }

    // Verify credentials
    const isValid = await verifyCredentials(username, password);

    if (!isValid) {
      return NextResponse.json(
        { error: 'Invalid username or password' },
        { status: 401 }
      );
    }

    // Generate JWT token
    const token = generateToken(username);

    // Set HTTP-only cookie
    const response = NextResponse.json({
      success: true,
      message: 'Login successful',
      username,
    });

    response.cookies.set('admin_token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60, // 7 days
      path: '/',
    });

    return response;
  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

**บันทึกไฟล์:** `admin-panel/app/api/auth/login/route.ts`

### 4.3 สร้าง Logout API Route

```typescript
// app/api/auth/logout/route.ts

import { NextResponse } from 'next/server';

export async function POST() {
  const response = NextResponse.json({
    success: true,
    message: 'Logged out successfully',
  });

  // Clear cookie
  response.cookies.delete('admin_token');

  return response;
}
```

**บันทึกไฟล์:** `admin-panel/app/api/auth/logout/route.ts`

### 4.4 สร้าง Check Auth API Route

```typescript
// app/api/auth/me/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { getTokenFromRequest, verifyToken } from '@/lib/auth';

export async function GET(request: NextRequest) {
  const token = getTokenFromRequest(request);

  if (!token) {
    return NextResponse.json(
      { authenticated: false },
      { status: 401 }
    );
  }

  const user = verifyToken(token);

  if (!user) {
    return NextResponse.json(
      { authenticated: false },
      { status: 401 }
    );
  }

  return NextResponse.json({
    authenticated: true,
    username: user.username,
    role: user.role,
  });
}
```

**บันทึกไฟล์:** `admin-panel/app/api/auth/me/route.ts`

### 4.5 อัพเดท `.env.local`

เพิ่ม JWT_SECRET:

```bash
# Admin Authentication
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-password-here

# JWT Secret (generate random string)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Firebase Admin SDK
FIREBASE_PROJECT_ID=miro-d6856
```

**⚠️ สำคัญ:** ใน production ต้องใช้ JWT_SECRET ที่ปลอดภัย (random 64 characters)

---

## 📋 Step 5: สร้าง Login Page

### 5.1 สร้าง Login Page UI

```typescript
// app/login/page.tsx

'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();

      if (response.ok) {
        // Login successful → redirect to dashboard
        router.push('/');
        router.refresh();
      } else {
        setError(data.error || 'Login failed');
      }
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-bold">🔐 MIRO Admin Panel</CardTitle>
          <CardDescription>Sign in to access the dashboard</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="username">Username</Label>
              <Input
                id="username"
                type="text"
                placeholder="admin"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded text-sm">
                {error}
              </div>
            )}

            <Button
              type="submit"
              className="w-full"
              disabled={loading}
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
```

**บันทึกไฟล์:** `admin-panel/app/login/page.tsx`

---

## 📋 Step 6: สร้าง Auth Guard Component

### 6.1 สร้าง AuthGuard

```typescript
// components/AuthGuard.tsx

'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

interface AuthGuardProps {
  children: React.ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const router = useRouter();
  const [authenticated, setAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  async function checkAuth() {
    try {
      const response = await fetch('/api/auth/me');
      
      if (response.ok) {
        setAuthenticated(true);
      } else {
        router.push('/login');
      }
    } catch (error) {
      console.error('Auth check failed:', error);
      router.push('/login');
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!authenticated) {
    return null; // Will redirect to login
  }

  return <>{children}</>;
}
```

**บันทึกไฟล์:** `admin-panel/components/AuthGuard.tsx`

---

## 📋 Step 7: สร้าง Layout (Sidebar + Header)

### 7.1 สร้าง Sidebar Component

```typescript
// components/Sidebar.tsx

'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Users, 
  Settings, 
  AlertTriangle,
  LogOut 
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useRouter } from 'next/navigation';

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', href: '/' },
  { icon: Users, label: 'Users', href: '/users' },
  { icon: Settings, label: 'Config', href: '/config' },
  { icon: AlertTriangle, label: 'Fraud Alerts', href: '/fraud' },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = async () => {
    await fetch('/api/auth/logout', { method: 'POST' });
    router.push('/login');
    router.refresh();
  };

  return (
    <div className="w-64 bg-gray-900 text-white h-screen fixed left-0 top-0 flex flex-col">
      {/* Logo */}
      <div className="p-6 border-b border-gray-800">
        <h1 className="text-2xl font-bold">🔐 MIRO Admin</h1>
        <p className="text-sm text-gray-400 mt-1">Management Panel</p>
      </div>

      {/* Menu */}
      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`
                flex items-center gap-3 px-4 py-3 rounded-lg transition-colors
                ${isActive 
                  ? 'bg-blue-600 text-white' 
                  : 'text-gray-300 hover:bg-gray-800'
                }
              `}
            >
              <Icon className="w-5 h-5" />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="p-4 border-t border-gray-800">
        <Button
          variant="ghost"
          className="w-full justify-start text-gray-300 hover:bg-gray-800"
          onClick={handleLogout}
        >
          <LogOut className="w-5 h-5 mr-3" />
          Logout
        </Button>
      </div>
    </div>
  );
}
```

**บันทึกไฟล์:** `admin-panel/components/Sidebar.tsx`

### 7.2 อัพเดท Root Layout

```typescript
// app/layout.tsx

import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "MIRO Admin Panel",
  description: "Management dashboard for MIRO app",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}
```

**บันทึกไฟล์:** `admin-panel/app/layout.tsx`

### 7.3 สร้าง Dashboard Layout

```typescript
// app/(dashboard)/layout.tsx

import { Sidebar } from '@/components/Sidebar';
import { AuthGuard } from '@/components/AuthGuard';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AuthGuard>
      <div className="min-h-screen bg-gray-50">
        <Sidebar />
        <main className="ml-64 p-8">
          {children}
        </main>
      </div>
    </AuthGuard>
  );
}
```

**บันทึกไฟล์:** `admin-panel/app/(dashboard)/layout.tsx`

**⚠️ สำคัญ:** Folder ชื่อ `(dashboard)` ต้องมีวงเล็บ! นี่คือ Route Group ของ Next.js

---

## 📋 Step 8: สร้าง Dashboard Page (Temporary)

```typescript
// app/(dashboard)/page.tsx

export default function DashboardPage() {
  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">📊 Dashboard</h1>
      
      <div className="bg-white rounded-lg shadow p-6">
        <p className="text-gray-600">
          ✅ Authentication working!
        </p>
        <p className="text-gray-600 mt-2">
          Dashboard UI will be created in Task 2
        </p>
      </div>
    </div>
  );
}
```

**บันทึกไฟล์:** `admin-panel/app/(dashboard)/page.tsx`

---

## 🧪 Step 9: Testing

### 9.1 Start Dev Server

```bash
cd admin-panel
npm run dev
```

### 9.2 Test Sequence

**Test 1: Login Page**
1. เปิด http://localhost:3000
2. ควร redirect ไป `/login` (เพราะยังไม่ได้ login)
3. เห็นหน้า login form

**Test 2: Login (Wrong Password)**
1. ใส่ username: `admin`
2. ใส่ password: `wrongpassword`
3. คลิก Sign In
4. ควรเห็น error: "Invalid username or password"

**Test 3: Login (Correct)**
1. ใส่ username: `admin`
2. ใส่ password: (ค่าที่คุณตั้งใน `.env.local`)
3. คลิก Sign In
4. ควร redirect ไป `/` (dashboard)
5. เห็นหน้า Dashboard พร้อม Sidebar

**Test 4: Sidebar Navigation**
1. คลิก "Users" → ควรไป `/users` (ยังไม่มีหน้า → 404)
2. คลิก "Config" → ควรไป `/config` (ยังไม่มีหน้า → 404)
3. คลิก "Dashboard" → กลับไป `/`

**Test 5: Logout**
1. คลิก "Logout" ใน Sidebar
2. ควร redirect ไป `/login`
3. ลอง access `/` → ควร redirect กลับ `/login` (ถูกบล็อก)

**Test 6: Direct URL Access**
1. Logout ก่อน
2. พิมพ์ URL โดยตรง: http://localhost:3000
3. ควร redirect ไป `/login` ทันที (AuthGuard ทำงาน)

---

## ✅ Checklist ท้ายสุด

```bash
□ Service Account Key download แล้ว + วางถูกที่
□ npm install สำเร็จ (ไม่มี errors)
□ /api/test return success
□ Login page แสดงถูกต้อง
□ Login ด้วย wrong password → error
□ Login ด้วย correct password → redirect to dashboard
□ Dashboard แสดง Sidebar + content
□ Sidebar navigation ทำงาน
□ Logout ทำงาน → redirect to login
□ AuthGuard ทำงาน (block ถ้าไม่ได้ login)
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Cannot find module 'firebase-admin'"
```bash
# Solution:
cd admin-panel
npm install firebase-admin
```

### Issue 2: "serviceAccountKey.json not found"
```bash
# Solution:
# 1. ตรวจสอบว่าไฟล์อยู่ที่: admin-panel/serviceAccountKey.json
# 2. ชื่อไฟล์ต้องถูกต้องทุกตัวอักษร (case-sensitive)
```

### Issue 3: "Unauthorized: No token provided"
```bash
# Solution:
# 1. Clear browser cookies
# 2. Login ใหม่
# 3. เช็ค .env.local มี JWT_SECRET หรือยัง
```

### Issue 4: Shadcn UI components ไม่แสดง
```bash
# Solution:
npx shadcn-ui@latest init
npx shadcn-ui@latest add button card input label
```

---

## 🎯 Next Steps

หลังจาก Task 1 เสร็จแล้ว → ไป **Task 2: Dashboard & Metrics**

Task 2 จะสร้าง:
- ✅ Dashboard UI (Cards + Charts)
- ✅ Metrics API
- ✅ Real-time data visualization

---

**เสร็จ Task 1 แล้วให้บอกนะครับ!** 🎉
