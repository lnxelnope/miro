'use client';

import Link from 'next/link';
import Image from 'next/image';
import { useState } from 'react';
import { usePathname } from 'next/navigation';
import { Menu, X, Download } from 'lucide-react';
import { publicAsset } from '@/lib/publicAsset';

const navLinks = [
  { href: '/#features', label: 'Features' },
  { href: '/#how-it-works', label: 'How It Works' },
  { href: '/#pricing', label: 'Pricing' },
  { href: '/support/', label: 'Support' },
];

export function Header() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const pathname = usePathname();
  const isThaiPage = pathname.includes('/th');

  return (
    <header className="fixed top-0 z-50 w-full border-b border-brand-100 bg-white/90 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-2.5">
          <Image
            src={publicAsset('/arcal/logo.png')}
            alt="ArCal"
            width={36}
            height={36}
            className="rounded-lg"
          />
          <span className="text-xl font-bold tracking-tight text-brand-900">
            ArCal
          </span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium text-gray-600 transition-colors hover:text-brand-700"
            >
              {link.label}
            </Link>
          ))}
          {isThaiPage ? (
            <Link
              href="/"
              className="text-sm font-semibold text-brand-700 transition-colors hover:text-brand-900"
            >
              English
            </Link>
          ) : (
            <Link
              href="/th/"
              className="text-sm font-semibold text-brand-700 transition-colors hover:text-brand-900"
            >
              ไทย
            </Link>
          )}
          <Link
            href="/#download"
            className="flex items-center gap-2 rounded-full bg-brand-600 px-5 py-2.5 text-sm font-semibold text-white transition-all hover:bg-brand-700 hover:shadow-md hover:shadow-brand-500/20"
          >
            <Download size={16} />
            Download Free
          </Link>
        </nav>

        <button
          className="md:hidden"
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label="Toggle menu"
        >
          {mobileOpen ? (
            <X size={24} className="text-gray-700" />
          ) : (
            <Menu size={24} className="text-gray-700" />
          )}
        </button>
      </div>

      {mobileOpen && (
        <div className="border-t border-brand-100 bg-white/98 backdrop-blur-xl md:hidden">
          <nav className="flex flex-col gap-1 px-4 py-4">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMobileOpen(false)}
                className="rounded-lg px-4 py-3 text-gray-700 transition-colors hover:bg-brand-50 hover:text-brand-800"
              >
                {link.label}
              </Link>
            ))}
            {isThaiPage ? (
              <Link
                href="/"
                onClick={() => setMobileOpen(false)}
                className="rounded-lg px-4 py-3 font-semibold text-brand-800 transition-colors hover:bg-brand-50"
              >
                English
              </Link>
            ) : (
              <Link
                href="/th/"
                onClick={() => setMobileOpen(false)}
                className="rounded-lg px-4 py-3 font-semibold text-brand-800 transition-colors hover:bg-brand-50"
              >
                ไทย
              </Link>
            )}
            <Link
              href="/#download"
              onClick={() => setMobileOpen(false)}
              className="mt-2 flex items-center justify-center gap-2 rounded-full bg-brand-600 px-5 py-3 font-semibold text-white"
            >
              <Download size={16} />
              Download Free
            </Link>
          </nav>
        </div>
      )}
    </header>
  );
}
