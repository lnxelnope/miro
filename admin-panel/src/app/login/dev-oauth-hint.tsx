/**
 * แสดงเฉพาะตอน `next dev` — อธิบายว่าทำไม Google บน localhost มักล้มและต้องตั้งอะไรใน Console
 */
export function DevOauthHint() {
  if (process.env.NODE_ENV !== 'development') {
    return null;
  }

  const base =
    process.env.NEXTAUTH_URL?.replace(/\/$/, '') || 'http://localhost:3000';
  const callback = `${base}/api/auth/callback/google`;

  return (
    <div
      className="border-b border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950"
      role="note"
    >
      <p className="font-medium">โหมดพัฒนา (localhost): ถ้า Google login ไม่ได้</p>
      <ul className="mt-2 list-disc space-y-1 pl-5 text-amber-900/90">
        <li>
          ใน Google Cloud → OAuth client → ใส่ <strong>Authorized redirect URI</strong> ให้ตรงกับ:{' '}
          <code className="rounded bg-amber-100/80 px-1 py-0.5 text-xs">{callback}</code>
        </li>
        <li>
          <code className="rounded bg-amber-100/80 px-1 py-0.5 text-xs">NEXTAUTH_URL</code> ใน{' '}
          <code className="rounded bg-amber-100/80 px-1 py-0.5 text-xs">.env.local</code> ต้องเป็น{' '}
          <code className="rounded bg-amber-100/80 px-1 py-0.5 text-xs">{base}</code> (ตรงพอร์ตกับที่เปิดในเบราว์เซอร์)
        </li>
        <li>ถ้า OAuth consent เป็นโหมด Testing — เพิ่มอีเมลคุณใน Test users</li>
      </ul>
      <p className="mt-2 text-xs text-amber-800/80">
        คู่มือเต็ม: <code className="font-mono">admin-panel/LOCALHOST_GOOGLE_OAUTH.md</code>
      </p>
    </div>
  );
}
