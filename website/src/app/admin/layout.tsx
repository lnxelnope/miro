'use client';

import { useState } from 'react';
import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { AdminContext } from './admin-context';

const NAV_ITEMS = [
  { href: '/admin/data-mining', label: 'Data Mining', icon: '📊' },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [secret, setSecret] = useState('');
  const [authed, setAuthed] = useState(false);

  if (!authed) {
    return (
      <div className="min-h-screen bg-gray-950 text-white flex items-center justify-center">
        <div className="w-full max-w-sm p-8">
          <h1 className="text-2xl font-bold mb-6 text-center">MiRO Admin</h1>
          <input
            type="password"
            placeholder="Admin Secret"
            value={secret}
            onChange={(e) => setSecret(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && secret.length > 0 && setAuthed(true)}
            className="w-full px-4 py-3 rounded-lg bg-gray-800 border border-gray-700 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 mb-4"
          />
          <button
            onClick={() => secret.length > 0 && setAuthed(true)}
            className="w-full py-3 rounded-lg bg-emerald-600 hover:bg-emerald-500 font-semibold transition"
          >
            Login
          </button>
        </div>
      </div>
    );
  }

  return (
    <AdminContext.Provider value={{ secret }}>
      <div className="min-h-screen bg-gray-950 text-white">
        <header className="border-b border-gray-800 px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-6">
            <h1 className="text-lg font-bold text-emerald-400">MiRO Admin</h1>
            <nav className="flex gap-1">
              {NAV_ITEMS.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                    pathname === item.href
                      ? 'bg-emerald-600/20 text-emerald-400'
                      : 'text-gray-400 hover:text-white hover:bg-gray-800'
                  }`}
                >
                  {item.icon} {item.label}
                </Link>
              ))}
            </nav>
          </div>
          <span className="text-xs text-gray-600">Authenticated</span>
        </header>
        {children}
      </div>
    </AdminContext.Provider>
  );
}
